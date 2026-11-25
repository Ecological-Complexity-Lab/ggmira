#' Open a network in MiRA with MiRA's defaults
#'
#' Converts an EMLN \code{multilayer} object to JSON and opens MiRA, the
#' Multilayer Interactive Rendering Application, in the default web browser,
#' with MiRA's default view, in the view given by `mode`. To describe how
#' the plot should look in code, use [mira()] instead.
#'
#' The plot is the one MiRA shows for the same network loaded on its
#' website, with two differences: the legends start minimized (as for every
#' plot from R; [mira_legends()] opens them), and the map and the layer view
#' are fitted to the layers.
#'
#' `plot_multilayer()` is the same function without `mode` (always network
#' mode), under the name emln uses. While emln has a function of that name
#' too, the package attached last provides it: after `library(emln)`, write
#' `ggmira::plot_multilayer()`, or use `plot_mira()`.
#'
#' **From MiRA back to R.** Change the plot in MiRA, then click MiRA's **R**
#' button (Copy as R code, next to Save Session): it shows the [mira()] code
#' that draws the current view, starting from this network and these
#' arguments, to paste into a script. Not for `plot_multilayer()`.
#'
#' @param multilayer A multilayer object (created by \code{create_multilayer_network}
#'   or \code{load_emln}).
#' @param bipartite Logical. Whether the network is bipartite. Defaults to
#'   \code{FALSE}. Bipartite is not auto-detected. When \code{TRUE}, the nodes
#'   table must contain a \code{node_type} column (or \code{node_group}, or
#'   \code{type}, as in the networks of \code{load_emln}) with exactly two
#'   distinct values across the network. MiRA knows the column as
#'   \code{node_type}, whatever its name in the data.
#' @param setA_type Optional character. The \code{node_type} value to render
#'   as Set A (top row) in MiRA's bipartite layout. By ecological convention
#'   this is the higher trophic level (e.g. \code{"pollinator"},
#'   \code{"parasite"}, \code{"disperser"}). Only used when
#'   \code{bipartite = TRUE}.
#' @param directed Logical or NULL. Whether intralayer links are directed.
#'   If NULL (default), auto-detected by checking intralayer edge symmetry.
#' @param directed_interlayer Logical or NULL. Whether interlayer links are
#'   directed. If NULL (default), inherits from \code{directed}. Interlayer
#'   links are directed whenever intralayer links are, so \code{FALSE} has
#'   no effect on a directed network.
#' @param port Integer. Port for the local HTTP server. Default is 8080.
#' @param mira_path Character. Path to the MiRA web-app directory. If NULL
#'   (default), uses the copy bundled with the package
#'   (\code{system.file("MiRA", package = "ggmira")}).
#' @param mode The view MiRA opens in: `"network"` (default), `"grid"`,
#'   `"map"` (needs `latitude` and `longitude` in `net$layers`), `"layer"`,
#'   `"meta"` (the meta-network), `"dashboard"` or `"data"`; each with
#'   MiRA's default settings. One view per call: to see a network in two
#'   views, call `plot_mira()` twice. To set a view's options (grid columns,
#'   meta-network settings), use [mira()] with [mira_mode_grid()] or
#'   [mira_mode_meta()].
#' @param browser Choose the specific browser to open MiRA in. Defaults to
#'   the system default via \code{getOption("browser")}. A command that
#'   opens a page, as for \code{\link[utils]{browseURL}}: a browser's name
#'   where that is a command (e.g. "firefox" on Linux), or on macOS
#'   "open -a Firefox". "chrome" works on macOS too. When R is not
#'   interactive (a script), a plot opens only when \code{browser} is given.
#' @param viewer `TRUE` to open MiRA in RStudio's Viewer pane instead of the
#'   browser (outside RStudio, the browser opens). Defaults to `FALSE`, or to
#'   `getOption("ggmira.viewer")`: put `options(ggmira.viewer = TRUE)` in
#'   your `.Rprofile` to always use the pane (the option must be `TRUE` or
#'   `FALSE`; anything else is an error). A `browser` given in the call
#'   wins. MiRA needs room (at least 1024 x 600 pixels): maximize the pane,
#'   or click its *Show in new window* button to move the plot to the
#'   browser.
#'
#' @note
#' MiRA is a browser-based
#' interactive visualization tool for multilayer networks, available at
#' \url{https://mira.ecomplab.com/}.
#'
#' If you use MiRA in published research, please cite:
#'
#' Nehoray SM, Bloch Y, Pilosof S (2026). Interactively visualizing biological
#' multilayer networks using MiRA. \emph{arXiv}:2605.09597 \[cs.SI\].
#' \doi{doi:10.48550/arXiv.2605.09597}
#'
#' Feedback and bug reports:
#' \url{https://github.com/Ecological-Complexity-Lab/MiRA/issues}.
#'
#' @return Invisibly returns the server handle. Use
#'   \code{httpuv::stopServer(handle)} to stop the server when done.
#'   \code{NULL} when nothing was opened: R is not interactive (a script, R
#'   Markdown) and \code{browser} was not given.
#'
#' @details
#' The function:
#' \enumerate{
#'   \item Converts the multilayer object to MiRA's JSON format (the same
#'     output as \code{emln::multilayer_to_json})
#'   \item Starts a local HTTP server (using \code{httpuv}) that serves the
#'     MiRA app and the network JSON
#'   \item Opens the browser with auto-load enabled
#' }
#'
#' The server runs in the background. Call \code{httpuv::stopServer(handle)} or
#' close R to stop it. The JSON data is kept in memory and never written to disk.
#' MiRA loads its drawing libraries and map tiles from the web, so the plot
#' needs an internet connection.
#'
#' `plot_multilayer()` replaces \code{emln::plot_multilayer()}: the same
#' arguments and behavior, plus `viewer`.
#'
#' @seealso [mira()] to describe the plot in code; [mira_mode] for the
#'   views; \code{emln::load_emln}, \code{emln::multilayer_to_json}
#'
#' @export
#'
#' @examplesIf requireNamespace("emln", quietly = TRUE)
#' library(emln)
#' net <- load_emln(17)
#'
#' # Open with MiRA's defaults
#' plot_mira(net, bipartite = TRUE, setA_type = "bird")
#'
#' # In another view: the meta-network, or the layers side by side
#' plot_mira(net, bipartite = TRUE, setA_type = "bird", mode = "meta")
#' plot_mira(net, bipartite = TRUE, setA_type = "bird", mode = "grid")
#'
#' # Directed links, on another port
#' plot_mira(net, bipartite = TRUE, setA_type = "bird",
#'           directed = TRUE, directed_interlayer = TRUE, port = 9000)
#'
#' # Another browser; a local copy of MiRA, not the bundled one
#' # plot_mira(net, browser = "chrome", mira_path = "~/MiRA")
#'
#' # In RStudio's Viewer pane
#' # plot_mira(net, bipartite = TRUE, setA_type = "bird", viewer = TRUE)
#'
#' # The same as plot_mira(net, bipartite = TRUE, setA_type = "bird").
#' # ggmira:: because emln, attached above, has a plot_multilayer() too
#' ggmira::plot_multilayer(net, bipartite = TRUE, setA_type = "bird")
#'
#' # When done, stop the servers
#' httpuv::stopAllServers()
plot_mira <- function(multilayer, bipartite = FALSE, setA_type = NULL,
                      directed = NULL, directed_interlayer = NULL,
                      mode = "network", port = 8080, mira_path = NULL,
                      browser = getOption("browser"),
                      viewer = getOption("ggmira.viewer", FALSE)) {
  mode <- .choice(MODES)(mode, "mode", "plot_mira")
  viewer <- .use_viewer(viewer, !missing(browser), "plot_mira")
  if (mode == "map" && !.has_coordinates(multilayer)) {
    .abort_arg("plot_mira", "mode", '"map" needs the layers\' coordinates: `latitude` and `longitude` in net$layers')
  }
  if (!.should_serve(browser_given = !missing(browser))) return(invisible(NULL))
  message("Please report issues at ",
          "https://github.com/Ecological-Complexity-Lab/MiRA/issues")
  .warn_zero_weight(multilayer, "plot_mira")
  .warn_self_loops(multilayer, "plot_mira")
  network_json <- .network_json(
    multilayer,
    bipartite           = bipartite,
    setA_type           = setA_type,
    directed            = directed,
    directed_interlayer = directed_interlayer
  )
  # A view spec with no settings, only R's text for MiRA's R button (the
  # same plot as mira() code), and the view
  spec <- list(version = VIEW_SPEC_VERSION)
  r_call <- .as_mira_call(match.call(), bipartite, directed, network_json)
  if (!is.null(r_call)) spec$r <- list(mira = r_call)
  if (mode != NETWORK_MODE) spec$mode <- list(view = mode)
  view_json <- .to_json(spec)
  .serve_mira(network_json, view_json = view_json, port = port,
              mira_path = mira_path, browser = browser, viewer = viewer)
}

#' @rdname plot_mira
#' @export
plot_multilayer <- function(multilayer, bipartite = FALSE, setA_type = NULL,
                            directed = NULL, directed_interlayer = NULL,
                            port = 8080, mira_path = NULL,
                            browser = getOption("browser"),
                            viewer = getOption("ggmira.viewer", FALSE)) {
  viewer <- .use_viewer(viewer, !missing(browser), "plot_multilayer")
  if (!.should_serve(browser_given = !missing(browser))) return(invisible(NULL))
  message("Please report issues at ",
          "https://github.com/Ecological-Complexity-Lab/MiRA/issues")
  .warn_zero_weight(multilayer, "plot_multilayer")
  .warn_self_loops(multilayer, "plot_multilayer")
  network_json <- .network_json(
    multilayer,
    bipartite           = bipartite,
    setA_type           = setA_type,
    directed            = directed,
    directed_interlayer = directed_interlayer
  )
  .serve_mira(network_json, view_json = NULL, port = port,
              mira_path = mira_path, browser = browser, viewer = viewer)
}

# plot_mira()'s arguments that mira() takes
MIRA_CALL_ARGS <- c("bipartite", "setA_type", "directed", "directed_interlayer")

#' The mira() call that makes the same plot as a plot_mira() call
#'
#' The network and the arguments mira() takes, as written. mira() draws a
#' bipartite network as undirected unless told; plot_mira() auto-detects,
#' so `directed = TRUE` is added when it found a directed network.
#' @return The call's text, or NULL when it is too long to have been typed.
#' @keywords internal
#' @noRd
.as_mira_call <- function(call, bipartite, directed, network_json) {
  args <- as.list(call)[-1]
  args <- c(args["multilayer"], args[intersect(MIRA_CALL_ARGS, names(args))])
  names(args)[1] <- ""
  if (isTRUE(bipartite) && is.null(directed) && .json_directed(network_json)) args$directed <- TRUE
  .mira_call_text(as.call(c(as.name("mira"), args)))
}

# The network's "directed" flag, MiRA's JSON's first field
.json_directed <- function(network_json) {
  identical(regmatches(network_json, regexpr('"directed": (true|false)', network_json)), '"directed": true')
}
