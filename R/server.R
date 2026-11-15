# Local HTTP server that serves the MiRA web app plus the network (and,
# for mira() plots, the view spec) to the browser.
#
# Adapted from emln::plot_multilayer() (emln 1.2.0). Additions: the
# /api/view.json endpoint, the request handler as its own function (so it
# can be tested without starting a server), and a stricter path check.

NETWORK_ENDPOINT <- "/api/network.json"
VIEW_ENDPOINT <- "/api/view.json"
MAX_PORT_ATTEMPTS <- 50
MAX_OPEN_PLOTS <- 10 # printed plots whose servers are kept; older ones are stopped
RSTUDIO_PANE_QUERY <- "&pane=rstudio" # MiRA's small-window warning then talks about the pane

CONTENT_TYPES <- c(
  html = "text/html; charset=utf-8",
  htm = "text/html; charset=utf-8",
  js = "application/javascript; charset=utf-8",
  mjs = "application/javascript; charset=utf-8",
  css = "text/css; charset=utf-8",
  json = "application/json; charset=utf-8",
  png = "image/png",
  jpg = "image/jpeg",
  jpeg = "image/jpeg",
  svg = "image/svg+xml",
  gif = "image/gif",
  ico = "image/x-icon",
  woff = "font/woff",
  woff2 = "font/woff2"
)
BINARY_EXTENSIONS <- c("png", "jpg", "jpeg", "gif", "ico", "woff", "woff2")

#' Whether to start a server and open the browser
#'
#' Not when R is not interactive (a script, R CMD check, building the docs)
#' and no browser was given: no one would see the plot, and the server would
#' stop when the script ends. Giving `browser` serves anyway.
#' @keywords internal
#' @noRd
.should_serve <- function(browser_given) {
  if (.is_interactive() || browser_given) return(TRUE)
  message("Not opened: R is not interactive. Print the plot in an R session, ",
          "or give `browser` to open it from a script.")
  FALSE
}

.is_interactive <- function() interactive() # a function, so tests can mock it

#' Serve MiRA with a network (and optional view spec) and open the browser
#'
#' @param network_json Network JSON string (from `.network_json()`).
#' @param view_json View spec JSON string, or NULL (then `/api/view.json`
#'   returns 404 and MiRA shows its default view).
#' @param viewer TRUE: RStudio's Viewer pane, when R runs in RStudio.
#' @return The httpuv server handle, invisibly.
#' @keywords internal
#' @noRd
.serve_mira <- function(network_json, view_json = NULL, port = 8080,
                        mira_path = NULL, browser = getOption("browser"),
                        viewer = FALSE) {
  mira_path <- .resolve_mira_path(mira_path)
  message(sprintf("Serving MiRA from: %s", mira_path))

  server <- .start_server(.mira_app(network_json, view_json, mira_path), port)
  .remember_server(server$handle)
  url <- sprintf("http://localhost:%d?autoload=true", server$port)
  message(sprintf("Server running at: %s", url))
  message("Call httpuv::stopServer(handle) to stop the server when done.")

  .open_mira(url, browser, viewer)
  invisible(server$handle)
}

#' Open MiRA in RStudio's Viewer pane (`viewer = TRUE`, in RStudio) or the browser
#' @keywords internal
#' @noRd
.open_mira <- function(url, browser, viewer) {
  rstudio_viewer <- getOption("viewer") # set by RStudio, as for htmlwidgets
  if (viewer && is.function(rstudio_viewer)) {
    rstudio_viewer(paste0(url, RSTUDIO_PANE_QUERY))
    return(invisible())
  }
  if (viewer) message("Not in RStudio: opening MiRA in the browser.")
  utils::browseURL(url, browser = .resolve_browser(browser))
}

#' `viewer`, checked; an explicit `browser` wins
#' @keywords internal
#' @noRd
.use_viewer <- function(viewer, browser_given, fn) {
  .check_flag(viewer, "viewer", fn) && !browser_given
}

#' httpuv app: API endpoints first, then static MiRA files
#' @param on_save For mira_save(): a function given the body (raw) MiRA
#'   posts to /api/save; NULL = no such endpoint.
#' @keywords internal
#' @noRd
.mira_app <- function(network_json, view_json, mira_path, on_save = NULL) {
  # Evaluate now: the handler runs later, when the plot the arguments were
  # computed from may have been changed or reassigned
  force(network_json)
  force(view_json)
  list(
    call = function(req) {
      path <- req$PATH_INFO
      if (!is.null(on_save) && path == SAVE_ENDPOINT && identical(req$REQUEST_METHOD, "POST")) {
        on_save(req$rook.input$read())
        return(list(status = 200L, headers = list(), body = "saved"))
      }
      if (path == NETWORK_ENDPOINT) return(.json_response(network_json))
      if (path == VIEW_ENDPOINT && !is.null(view_json)) return(.json_response(view_json))
      .static_response(path, mira_path)
    },
    onWSOpen = function(ws) {
      ws$close() # No WebSocket support needed
    }
  )
}

.json_response <- function(body) {
  list(
    status = 200L,
    headers = list(
      "Content-Type" = "application/json",
      "Access-Control-Allow-Origin" = "*",
      "Cache-Control" = "no-cache"
    ),
    body = body
  )
}

#' Whether `file_path` is inside the directory `dir`
#'
#' Both are compared with "/": on Windows normalizePath() returns "\", so a
#' prefix built with "/" would match no file there.
#' @keywords internal
#' @noRd
.inside_dir <- function(file_path, dir) {
  slashes <- function(path) gsub("\\", "/", path, fixed = TRUE)
  startsWith(slashes(file_path), paste0(sub("/+$", "", slashes(dir)), "/"))
}

.static_response <- function(url_path, mira_path) {
  if (url_path == "/" || url_path == "") url_path <- "/index.html"
  file_path <- normalizePath(file.path(mira_path, gsub("^/", "", url_path)), mustWork = FALSE)

  # Only files inside mira_path. Compare against "<mira_path>/" so a sibling
  # directory that shares the prefix (e.g. ".../MiRA-dev") is rejected.
  if (!.inside_dir(file_path, mira_path)) {
    return(list(status = 403L, headers = list(), body = "Forbidden"))
  }
  if (!file.exists(file_path) || dir.exists(file_path)) {
    return(list(status = 404L, headers = list(), body = "Not Found"))
  }

  ext <- tolower(tools::file_ext(file_path))
  ctype <- if (ext %in% names(CONTENT_TYPES)) CONTENT_TYPES[[ext]] else "application/octet-stream"
  body <- if (ext %in% BINARY_EXTENSIONS) {
    readBin(file_path, "raw", file.info(file_path)$size)
  } else {
    paste(readLines(file_path, warn = FALSE), collapse = "\n")
  }
  list(
    status = 200L,
    headers = list("Content-Type" = ctype, "Cache-Control" = "no-cache"),
    body = body
  )
}

#' Start the server on `port`, or the next free port
#' @return list(handle, port)
#' @keywords internal
#' @noRd
.start_server <- function(app, port) {
  held <- .session_ports()
  for (attempt in seq_len(MAX_PORT_ATTEMPTS)) {
    while (port %in% held) port <- port + 1 # this session's own servers: no need to try
    handle <- tryCatch(
      httpuv::startServer("127.0.0.1", port, app),
      error = function(e) NULL # port in use: try the next one
    )
    if (!is.null(handle)) return(list(handle = handle, port = port))
    port <- port + 1
  }
  stop("Could not find an available port to start the server after ",
       MAX_PORT_ATTEMPTS, " attempts.")
}

#' The ports of the servers running in this R session
#' @keywords internal
#' @noRd
.session_ports <- function() {
  vapply(httpuv::listServers(), function(server) as.numeric(server$getPort()), numeric(1))
}

# The servers of the plots printed in this session, oldest first
.printed <- new.env(parent = emptyenv())

#' Keep the servers of the last `MAX_OPEN_PLOTS` printed plots
#'
#' Every printed plot has its own server, which MiRA needs only while its
#' page loads (and again if the page is reloaded). Without a limit a long
#' session runs out of ports. Servers the user stopped are dropped.
#' @keywords internal
#' @noRd
.remember_server <- function(handle) {
  open <- Filter(function(server) server$isRunning(), c(.printed$servers, list(handle)))
  while (length(open) > MAX_OPEN_PLOTS) {
    httpuv::stopServer(open[[1]])
    open <- open[-1]
  }
  .printed$servers <- open
  invisible(handle)
}

# Chrome on macOS needs the `open -a` form
.resolve_browser <- function(browser) {
  is_chrome <- !is.null(browser) && is.character(browser) &&
    tolower(browser) %in% c("chrome", "google chrome")
  if (is_chrome && Sys.info()[["sysname"]] == "Darwin") return("open -a 'Google Chrome'")
  browser
}

#' Resolve path to the MiRA web app
#'
#' Looks first for an installed copy at
#' \code{system.file("MiRA", package = "ggmira")}, then falls back to
#' sibling/dev locations for in-source development.
#' @keywords internal
#' @noRd
.resolve_mira_path <- function(mira_path = NULL) {
  if (!is.null(mira_path)) {
    if (!file.exists(file.path(mira_path, "index.html"))) {
      stop(sprintf("`mira_path` does not contain index.html: %s", mira_path))
    }
    return(normalizePath(mira_path, mustWork = TRUE))
  }

  # 1. Installed package: inst/MiRA
  installed <- system.file("MiRA", package = "ggmira")
  if (nzchar(installed) && file.exists(file.path(installed, "index.html"))) {
    return(normalizePath(installed, mustWork = TRUE))
  }

  # 2. Dev fallbacks (running from the ggmira source tree or a sibling checkout)
  cwd <- getwd()
  candidates <- c(
    file.path(cwd, "inst", "MiRA"),
    file.path(cwd, "..", "ggmira", "inst", "MiRA"),
    file.path(cwd, "..", "MiRA"),
    file.path(dirname(cwd), "MiRA")
  )
  for (cand in candidates) {
    if (file.exists(file.path(cand, "index.html"))) {
      return(normalizePath(cand, mustWork = TRUE))
    }
  }

  stop(
    "Could not find the MiRA web app.\n",
    "Looked in: system.file('MiRA', package = 'ggmira') and: ",
    paste(candidates, collapse = ", "), "\n",
    "If you are developing from source, pass `mira_path = ",
    "'path/to/MiRA'` explicitly."
  )
}
