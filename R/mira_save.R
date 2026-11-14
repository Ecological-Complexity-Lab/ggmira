# mira_save(): an image file of a plot, drawn by MiRA in a headless browser.
#
# R serves MiRA as print() does, with ?save=true. chromote opens it in a
# headless Chrome; MiRA sets window.miraStatus once the plot is drawn and
# still, then window.miraSaveToR() exports it (MiRA's own export) and posts
# the file to /api/save (MiRA side: js/rBridge.js, js/exportManager.js).
#
# chromote's synchronous calls wait on a private event loop, where the
# httpuv server cannot answer the browser. So every call is asynchronous
# and .wait_for() runs R's main event loop, which serves both.

SAVE_ENDPOINT <- "/api/save"
SAVE_FORMATS <- c(png = "png", jpg = "jpg", jpeg = "jpg", pdf = "pdf")
SAVE_BACKGROUNDS <- c("grid", "white", "transparent")
SAVE_PORT <- 8790
SAVE_POLL_SECONDS <- 0.1

#' Save a mira plot as an image file
#'
#' Draws the plot in MiRA, in a browser that does not open a window, and
#' saves it with MiRA's own export: the same picture as MiRA's camera
#' button, with the legends and the "Visualized with MiRA" mark. Works in
#' scripts and R Markdown, where printing a plot does nothing.
#'
#' Needs the chromote package and Google Chrome (or Chromium, or Microsoft
#' Edge; chromote finds it, or set the `CHROMOTE_CHROME` environment
#' variable to its path). MiRA loads its libraries and map tiles from the
#' internet, as when a plot opens in the browser.
#'
#' @param plot A `mira_plot`.
#' @param file The file name, such as `"fig1.png"`. Without an extension,
#'   `format` is added.
#' @param format `"png"`, `"jpg"` or `"pdf"`. Without it, the extension of
#'   `file` decides.
#' @param resolution 1 (screen), 2 (high) or 4 (print): the image is
#'   `resolution` times `width` by `height` pixels. A PDF page is `width` by
#'   `height`, with the picture at this resolution.
#' @param width,height The size of MiRA's window, in pixels. The plot is
#'   fitted to it as in the browser.
#' @param background `"grid"` (MiRA's grid; the map in map view),
#'   `"white"`, or `"transparent"` (PNG only). The map view is saved only
#'   with `"grid"`; the meta-network and the dashboard not with
#'   `"transparent"`.
#' @param legends `TRUE` to include the legends (as [mira_legends()] sets
#'   them) and any open panels of the layer view.
#' @param timeout Seconds to wait for MiRA to draw and save the plot. Large
#'   pictures at `resolution = 4` can need more than the default.
#' @inheritParams plot_mira
#' @return The path of the file, invisibly.
#' @seealso [print.mira_plot()] to open the plot in the browser.
#' @export
#' @examples
#' \dontrun{
#' # Needs the chromote package and Chrome; writes files in the working directory
#' library(emln)
#' net <- load_emln(17)
#' p <- mira(net, bipartite = TRUE, setA_type = "bird") +
#'   mira_node(color_by = "intra_degree_sum")
#'
#' mira_save(p, "birds.png")
#' mira_save(p, "birds", format = "pdf", resolution = 4)
#' mira_save(p, "birds-clear.png", background = "transparent", legends = FALSE)
#' }
mira_save <- function(plot, file, format = NULL, resolution = 2, width = 1500, height = 900,
                      background = "grid", legends = TRUE, timeout = 60, mira_path = NULL) {
  fn <- "mira_save"
  if (!inherits(plot, "mira_plot")) .abort_arg(fn, "plot", "must be a mira plot, from mira()")
  target <- .save_target(file, format, fn)
  resolution <- .check_save_number(resolution, "resolution", fn, c(1, 4), whole = TRUE)
  width <- .check_save_number(width, "width", fn, c(100, 8000), whole = TRUE)
  height <- .check_save_number(height, "height", fn, c(100, 8000), whole = TRUE)
  timeout <- .check_save_number(timeout, "timeout", fn, c(1, Inf))
  if (!is.character(background) || !.is_scalar(background) || !background %in% SAVE_BACKGROUNDS) {
    .abort_arg(fn, "background", sprintf("must be one of %s", paste0('"', SAVE_BACKGROUNDS, '"', collapse = ", ")))
  }
  legends <- .check_flag(legends, "legends", fn)
  .check_save_view(mira_spec(plot)$mode$view, target$format, background, fn)
  if (!requireNamespace("chromote", quietly = TRUE)) {
    .abort_piece(fn, 'needs the chromote package: install.packages("chromote")')
  }

  received <- new.env()
  app <- .mira_app(plot$network_json, .view_json(plot), .resolve_mira_path(mira_path),
                   on_save = function(body) received$image <- body)
  server <- .start_server(app, SAVE_PORT)
  on.exit(httpuv::stopServer(server$handle), add = TRUE)

  browser <- tryCatch(
    chromote::ChromoteSession$new(width = width, height = height),
    error = function(e) .abort_piece(fn, paste("could not start Chrome:", conditionMessage(e)))
  )
  on.exit(browser$close(), add = TRUE)

  deadline <- Sys.time() + timeout
  url <- sprintf("http://localhost:%d/?autoload=true&save=true", server$port)
  .wait_for(browser$Page$navigate(url, wait_ = FALSE), deadline, fn)
  status <- .wait_for_status(browser, deadline, fn)
  if (!isTRUE(status$rendered)) .abort_piece(fn, paste("MiRA could not open the plot:", status$error))
  for (warning in unlist(status$warnings)) warning("MiRA: ", warning, call. = FALSE)

  options <- sprintf('{"format": "%s", "resolution": %d, "background": "%s", "legends": %s}',
                     target$format, as.integer(resolution), background, tolower(legends))
  # timeout_: chromote gives a command 10 seconds; a large export takes longer
  result <- .wait_for(browser$Runtime$evaluate(sprintf("window.miraSaveToR(%s)", options),
                                               awaitPromise = TRUE, wait_ = FALSE,
                                               timeout_ = .seconds_left(deadline)), deadline, fn)
  if (!is.null(result$exceptionDetails)) {
    .abort_piece(fn, paste("MiRA could not save the plot:", result$exceptionDetails$exception$description))
  }
  if (is.null(received$image)) .abort_piece(fn, "MiRA sent no image")
  writeBin(received$image, target$file)
  invisible(target$file)
}

#' The file and format to save: `format`, or the extension of `file`
#' @keywords internal
#' @noRd
.save_target <- function(file, format, fn) {
  if (!is.character(file) || !.is_scalar(file) || is.na(file) || !nzchar(file)) {
    .abort_arg(fn, "file", "must be a file name")
  }
  extension <- tolower(tools::file_ext(file))
  if (!is.null(format)) {
    if (!is.character(format) || !.is_scalar(format) || !tolower(format) %in% names(SAVE_FORMATS)) {
      .abort_arg(fn, "format", 'must be "png", "jpg" or "pdf"')
    }
    format <- SAVE_FORMATS[[tolower(format)]]
    if (!nzchar(extension)) return(list(file = paste0(file, ".", format), format = format))
    if (!extension %in% names(SAVE_FORMATS) || SAVE_FORMATS[[extension]] != format) {
      .abort_arg(fn, "format", sprintf('is "%s" but `file` ends in ".%s"', format, extension))
    }
    return(list(file = file, format = format))
  }
  if (!extension %in% names(SAVE_FORMATS)) {
    .abort_arg(fn, "file", 'must end in ".png", ".jpg" or ".pdf", or give `format`')
  }
  list(file = file, format = SAVE_FORMATS[[extension]])
}

.check_save_number <- function(value, arg, fn, range, whole = FALSE) {
  ok <- is.numeric(value) && .is_scalar(value) && !is.na(value) &&
    value >= range[1] && value <= range[2] && (!whole || value == round(value))
  if (!ok) {
    kind <- if (whole) "a whole number" else "a number"
    .abort_arg(fn, arg, sprintf("must be %s from %s to %s", kind, range[1], range[2]))
  }
  value
}

#' Views and backgrounds MiRA cannot save
#' @keywords internal
#' @noRd
.check_save_view <- function(view, format, background, fn) {
  if (identical(view, "data")) {
    .abort_piece(fn, "the data view is a table, not a picture; it cannot be saved as an image")
  }
  if (identical(view, "map") && background != "grid") {
    # without its map the picture is the legends alone
    .abort_arg(fn, "background", sprintf('"%s" is not available in the map view, which is drawn on its map', background))
  }
  if (background == "transparent") {
    if (format != "png") .abort_arg(fn, "background", '"transparent" needs a PNG file')
    if (!is.null(view) && view %in% c("meta", "dashboard")) {
      .abort_arg(fn, "background", sprintf('"transparent" is not available in the %s view',
                                           if (view == "meta") "meta-network" else "dashboard"))
    }
  }
}

#' The seconds until `deadline`, at least one
#' @keywords internal
#' @noRd
.seconds_left <- function(deadline) {
  max(1, as.numeric(difftime(deadline, Sys.time(), units = "secs")))
}

#' Run R's event loop until a chromote promise settles
#' @return The promise's value.
#' @keywords internal
#' @noRd
.wait_for <- function(promise, deadline, fn) {
  state <- new.env()
  promises::then(promise,
                 onFulfilled = function(value) state$value <- value,
                 onRejected = function(error) state$error <- error)
  while (is.null(state$value) && is.null(state$error)) {
    if (Sys.time() > deadline) .abort_piece(fn, "timed out waiting for MiRA; try a longer `timeout`")
    later::run_now(SAVE_POLL_SECONDS)
  }
  if (!is.null(state$error)) .abort_piece(fn, paste("the browser failed:", conditionMessage(state$error)))
  state$value
}

#' Wait until MiRA reports the plot drawn (or failed)
#' @return MiRA's window.miraStatus as a list.
#' @keywords internal
#' @noRd
.wait_for_status <- function(browser, deadline, fn) {
  repeat {
    result <- .wait_for(browser$Runtime$evaluate("window.miraStatus", returnByValue = TRUE, wait_ = FALSE),
                        deadline, fn)
    status <- result$result$value
    if (!is.null(status)) return(status)
    if (Sys.time() > deadline) .abort_piece(fn, "timed out waiting for MiRA; try a longer `timeout`")
    later::run_now(SAVE_POLL_SECONDS)
  }
}
