# A mira plot: the network plus a view spec built from mira_*() components.
# Printing it serves both to MiRA, which applies the spec when it loads
# (MiRA side: js/rBridge.js and js/viewSpec.js).

VIEW_SPEC_VERSION <- 1

#' Start a plot: a multilayer network to draw in MiRA
#'
#' Creates a plot of a multilayer network that opens in MiRA, the
#' browser-based multilayer network visualizer. Describe how it should look
#' by adding components with `+`, as in ggplot2; printing the plot (typing
#' its name at the console) opens it in the browser.
#'
#' @section Components:
#' Each component sets one part of the plot. Add them in any order:
#'
#' - [mira_layout()]: where the nodes go (the layout algorithm, a seed).
#' - [mira_node()]: node color, size, shape, labels.
#' - [mira_intralayer()]: the links within layers.
#' - [mira_interlayer()]: the links between layers.
#' - [mira_layer()]: layer colors, names and arrangement.
#'
#' In each, `color_by` and `size_by` map an attribute of the data (a column
#' of the network's tables, or one MiRA computes, such as a degree); `color`,
#' `size` and `shape` set constants. The colors of a mapping are chosen with
#' `color_values` and `color_scale` in the same component: see
#' [mira_scales].
#'
#' Anything not set keeps MiRA's default, and everything can still be
#' changed in MiRA's interface. When the same setting is given twice, the
#' later component wins. A later `color` replaces an earlier `color_by` of
#' the same element, and the other way round.
#'
#' Components are checked against the network as they are added: settings
#' that cannot work (per-set values or the bipartite layout without
#' `bipartite = TRUE`, a layer name that does not exist) are errors; a column
#' that is not in the network is a warning, and MiRA keeps its default for
#' that setting. [mira_spec()] shows what a plot sends to MiRA.
#'
#' @inheritParams plot_multilayer
#' @param net A multilayer object (created by `emln::create_multilayer_network()`
#'   or `emln::load_emln()`).
#' @param directed Logical or NULL. Whether intralayer links are directed.
#'   If NULL (default): undirected when `bipartite = TRUE` (bipartite edge
#'   lists usually store each link once, which would look directed);
#'   otherwise auto-detected from edge symmetry, as in [plot_multilayer()].
#' @return A `mira_plot` object.
#' @seealso [mira_spec()] to see what a plot sends to MiRA;
#'   [print.mira_plot()] for the browser and port options;
#'   [plot_multilayer()] to open a network with MiRA's defaults and no
#'   components.
#' @export
#' @examplesIf requireNamespace("emln", quietly = TRUE)
#' library(emln)
#' net <- load_emln(17) # 4 layers; bird and plant nodes
#'
#' # MiRA's default view
#' mira(net, bipartite = TRUE, setA_type = "bird")
#'
#' # Directed links, within and between layers
#' mira(net, bipartite = TRUE, setA_type = "bird",
#'      directed = TRUE, directed_interlayer = TRUE)
#'
#' # Add components with +
#' mira(net, bipartite = TRUE, setA_type = "bird") +
#'   mira_layout("kamada_kawai", seed = 42) +
#'   mira_node(color_by = "verification_level", size_by = "intra_degree_sum") +
#'   mira_intralayer(color_by = "type") +
#'   mira_interlayer(show = TRUE) +
#'   mira_layer(labels = TRUE)
#'
#' # When done, stop the servers the plots started
#' httpuv::stopAllServers()
mira <- function(net, bipartite = FALSE, setA_type = NULL, directed = NULL,
                 directed_interlayer = NULL) {
  # Bipartite edge lists usually store each link once (e.g. pollinator ->
  # plant), which the auto-detection would read as directed
  if (isTRUE(bipartite) && is.null(directed)) {
    directed <- FALSE
    message("Bipartite network: drawn as undirected. Use directed = TRUE for a directed one.")
  }
  network_json <- .network_json(
    net,
    bipartite           = bipartite,
    setA_type           = setA_type,
    directed            = directed,
    directed_interlayer = directed_interlayer
  )
  structure(list(
    net          = net,
    network_json = network_json,
    bipartite    = bipartite,
    set_types    = if (bipartite) .node_types(net$nodes) else NULL,
    computed     = .computed_node_attrs(net, network_json, directed_interlayer),
    spec         = list(),
    scale_order  = character() # color scale settings (section, attribute, part), the latest last
  ), class = "mira_plot")
}

#' Add a component to a mira plot
#'
#' @param e1 A `mira_plot`.
#' @param e2 A component (from a `mira_*()` function), or `NULL` (no change).
#' @return The `mira_plot` with the component added.
#' @keywords internal
#' @export
`+.mira_plot` <- function(e1, e2) {
  if (!inherits(e1, "mira_plot")) {
    stop("A mira plot starts with mira(net); add components after it.", call. = FALSE)
  }
  if (is.null(e2)) return(e1)
  if (!inherits(e2, "mira_piece")) {
    stop("Only mira_*() components (e.g. mira_node()) can be added to a mira plot.", call. = FALSE)
  }
  .validate_piece(e2, e1)
  e1$spec <- .merge_piece(e1$spec, e2)
  .update_scales(e1, e2)
}

#' Open a mira plot in the browser
#'
#' Starts a local server with the network and its view spec and opens MiRA.
#' Typing a plot's name at the console does this; call `print()` to choose
#' the port or the browser. Each print starts a new server (on the next free
#' port when `port` is taken).
#'
#' @param x A `mira_plot`.
#' @inheritParams plot_multilayer
#' @param ... Not used.
#' @return Invisibly, the server handle. Stop it with
#'   `httpuv::stopServer(handle)`, or stop all servers with
#'   `httpuv::stopAllServers()`.
#' @export
#' @examplesIf requireNamespace("emln", quietly = TRUE)
#' library(emln)
#' net <- load_emln(17) # 4 layers; bird and plant nodes
#' p <- mira(net, bipartite = TRUE, setA_type = "bird")
#'
#' p        # the same as print(p)
#'
#' print(p, port = 9000)            # another port
#' # print(p, browser = "firefox")  # another browser
#' # print(p, mira_path = "~/MiRA") # a local copy of MiRA, not the bundled one
#'
#' # When done, stop the servers the plots started
#' httpuv::stopAllServers()
print.mira_plot <- function(x, port = 8080, mira_path = NULL,
                            browser = getOption("browser"), ...) {
  if (!.should_serve(browser_given = !missing(browser))) return(invisible(NULL))
  message("Please report issues at ",
          "https://github.com/Ecological-Complexity-Lab/MiRA/issues")
  .serve_mira(x$network_json, view_json = mira_spec(x, json = TRUE), port = port,
              mira_path = mira_path, browser = browser)
}

#' What a plot sends to MiRA
#'
#' Shows the settings a plot sends to MiRA: those of its components, after
#' merging. Useful to check a plot before opening it.
#'
#' @param x A `mira_plot`.
#' @param json `FALSE` (default) for an R list, `TRUE` for the JSON string
#'   MiRA receives.
#' @return A list, or a JSON string.
#' @export
#' @examplesIf requireNamespace("emln", quietly = TRUE)
#' library(emln)
#' net <- load_emln(17) # 4 layers; bird and plant nodes
#' p <- mira(net, bipartite = TRUE, setA_type = "bird")
#'
#' mira_spec(p + mira_node(color = "red"))
#' mira_spec(p + mira_node(color = "red"), json = TRUE)
mira_spec <- function(x, json = FALSE) {
  if (!inherits(x, "mira_plot")) stop("`x` must be a mira plot (from mira()).", call. = FALSE)
  spec <- c(list(version = VIEW_SPEC_VERSION), .spec_for_mira(x))
  if (isTRUE(json)) .to_json(spec) else spec
}

#' Merge a component into the spec: its fields replace the same fields
#'
#' `color` and `color_by` are one channel, so a later `color` removes an
#' earlier `color_by` in the same section, and the other way round. A
#' `color`, or a `color_by` of a different column, also removes earlier
#' `color_values` / `color_scale` (they belong to the earlier mapping),
#' unless the piece gives them too. `pairs` turns interlayer links on unless
#' the piece gives `show`.
#' @keywords internal
#' @noRd
.merge_piece <- function(spec, piece) {
  fields <- piece$fields
  if (length(fields) == 0) return(spec)
  section <- spec[[piece$section]]
  if (is.null(section)) section <- list()
  new_mapping <- "color_by" %in% names(fields) && !identical(fields$color_by, section$color_by)
  if ("color" %in% names(fields)) section[["color_by"]] <- NULL
  if ("color_by" %in% names(fields)) section[["color"]] <- NULL
  if ("color" %in% names(fields) || new_mapping) {
    for (field in setdiff(COLOR_SCALE_FIELDS, names(fields))) section[[field]] <- NULL
  }
  if ("pairs" %in% names(fields) && !"show" %in% names(fields)) section$show <- TRUE
  for (field in names(fields)) section[field] <- list(fields[[field]]) # keeps NULL values
  spec[[piece$section]] <- section
  spec
}
