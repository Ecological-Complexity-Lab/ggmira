#' Open a network in MiRA with MiRA's defaults
#'
#' Converts an EMLN \code{multilayer} object to JSON and opens MiRA, the
#' multilayer interactive R-network app, in the default web browser, with
#' MiRA's default view, in the view (mode) given by `mode`. To describe how
#' the plot should look in code, use [mira()] instead.
#'
#' `plot_multilayer()` is the same function without `mode` (always network
#' mode), under the name emln uses.
#'
#' @param multilayer A multilayer object (created by \code{create_multilayer_network}
#'   or \code{load_emln}).
#' @param bipartite Logical. Whether the network is bipartite. Defaults to
#'   \code{FALSE}. Bipartite is not auto-detected. When \code{TRUE}, the nodes
#'   table must contain a \code{node_type} (or legacy \code{node_group})
#'   column with exactly two distinct values across the network.
#' @param setA_type Optional character. The \code{node_type} value to render
#'   as Set A (top row) in MiRA's bipartite layout. By ecological convention
#'   this is the higher trophic level (e.g. \code{"pollinator"},
#'   \code{"parasite"}, \code{"disperser"}). Only used when
#'   \code{bipartite = TRUE}.
#' @param directed Logical or NULL. Whether intralayer links are directed.
#'   If NULL (default), auto-detected by checking intralayer edge symmetry.
#' @param directed_interlayer Logical or NULL. Whether interlayer links are
#'   directed. If NULL (default), inherits from \code{directed}.
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
#'   the system default via \code{getOption("browser")}. Can be a browser
#'   name (e.g. "chrome", "firefox") or a command
#'   (e.g. "open -a 'Google Chrome'").
#'
#' @note
#' MiRA (Multilayer Interactive Rendering Application) is a browser-based
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
#'
#' `plot_multilayer()` replaces \code{emln::plot_multilayer()}, with the
#' same arguments and behavior.
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
#' # plot_mira(net, browser = "firefox", mira_path = "~/MiRA")
#'
#' # The same as plot_mira(net, bipartite = TRUE, setA_type = "bird")
#' plot_multilayer(net, bipartite = TRUE, setA_type = "bird")
#'
#' # When done, stop the servers
#' httpuv::stopAllServers()
plot_mira <- function(multilayer, bipartite = FALSE, setA_type = NULL,
                      directed = NULL, directed_interlayer = NULL,
                      mode = NETWORK_MODE, port = 8080, mira_path = NULL,
                      browser = getOption("browser")) {
  mode <- .choice(MODES)(mode, "mode", "plot_mira")
  if (mode == "map" && !.has_coordinates(multilayer)) {
    .abort_arg("plot_mira", "mode", '"map" needs the layers\' coordinates: `latitude` and `longitude` in net$layers')
  }
  if (!.should_serve(browser_given = !missing(browser))) return(invisible(NULL))
  message("Please report issues at ",
          "https://github.com/Ecological-Complexity-Lab/MiRA/issues")
  network_json <- .network_json(
    multilayer,
    bipartite           = bipartite,
    setA_type           = setA_type,
    directed            = directed,
    directed_interlayer = directed_interlayer
  )
  # Network mode sends no view spec: exactly plot_multilayer()
  view_json <- if (mode == NETWORK_MODE) NULL else .to_json(list(version = VIEW_SPEC_VERSION, mode = list(view = mode)))
  .serve_mira(network_json, view_json = view_json, port = port,
              mira_path = mira_path, browser = browser)
}

#' @rdname plot_mira
#' @export
plot_multilayer <- function(multilayer, bipartite = FALSE, setA_type = NULL,
                            directed = NULL, directed_interlayer = NULL,
                            port = 8080, mira_path = NULL,
                            browser = getOption("browser")) {
  if (!.should_serve(browser_given = !missing(browser))) return(invisible(NULL))
  message("Please report issues at ",
          "https://github.com/Ecological-Complexity-Lab/MiRA/issues")
  network_json <- .network_json(
    multilayer,
    bipartite           = bipartite,
    setA_type           = setA_type,
    directed            = directed,
    directed_interlayer = directed_interlayer
  )
  .serve_mira(network_json, view_json = NULL, port = port,
              mira_path = mira_path, browser = browser)
}
