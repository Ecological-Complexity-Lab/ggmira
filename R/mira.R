# A mira plot: the network plus a view spec built from mira_*() pieces.
# Printing it serves both to MiRA, which applies the spec when it loads
# (MiRA side: js/rBridge.js and js/viewSpec.js).

VIEW_SPEC_VERSION <- 1

#' Start a mira plot
#'
#' Creates a plot of a multilayer network that opens in MiRA, the browser-based
#' multilayer network visualizer. Describe how it should look by adding
#' pieces with `+`, as in ggplot2: [mira_layout()], [mira_node()],
#' [mira_intralayer()], [mira_interlayer()], [mira_layer()]. Printing the plot
#' (typing its name at the console) opens it in the browser.
#'
#' Anything not set keeps MiRA's default, and everything can still be changed
#' in MiRA's interface. When the same setting is given twice, the later piece
#' wins. A later `color` replaces an earlier `color_by` in the same section,
#' and the other way round.
#'
#' Pieces are checked against the network as they are added: per-set values
#' and the bipartite layout need `bipartite = TRUE`, and a column that is not
#' in the network gives a warning (MiRA then keeps its default for that
#' setting).
#'
#' @section Color scales:
#' Each piece's `color_by` chooses what is colored; `color_values` and
#' `color_scale` in the same piece choose the colors:
#'
#' - `color_scale = "categorical"` gives each value its own color (MiRA's
#'   Dark2 palette); `"continuous"` a gradient (Viridis, from the column's
#'   minimum to its maximum; numeric columns only). Without it, MiRA decides
#'   from the data.
#' - `color_values` sets the colors of some values, named by value:
#'   `c("1" = "red", "3" = "#1f77b4")` (numbers need quotes as names). Values
#'   not listed keep the palette's color. It gives a categorical scale, so
#'   it cannot be combined with `color_scale = "continuous"`.
#' - `mira_layer(color_by = "layer_name")` gives each layer its own color;
#'   `color_values` named by layer set some of them. Likewise
#'   `mira_node(color_by = ".set")` colors nodes by set membership and
#'   `color_values` named by node set set the two colors.
#'
#' MiRA keeps one color scale per attribute name, used wherever that
#' attribute colors nodes, links or layers (as in MiRA's legends, where
#' changing a color changes it for every element). So when two pieces color
#' by the same attribute name, their settings are merged: a value that
#' appears in both tables (node `module` 1 and link `module` 1) has one
#' color. If the pieces disagree (a value given two colors, or two scale
#' types), the later piece wins, with a warning; a continuous scale cannot
#' be combined with `color_values` for the same attribute (an error). A
#' `color`, or a `color_by` of a different column, drops that section's
#' earlier `color_values` and `color_scale`.
#'
#' @inheritParams plot_multilayer
#' @param net A multilayer object (created by `emln::create_multilayer_network()`
#'   or `emln::load_emln()`).
#' @param directed Logical or NULL. Whether intralayer links are directed.
#'   If NULL (default): undirected when `bipartite = TRUE` (bipartite edge
#'   lists usually store each link once, which would look directed);
#'   otherwise auto-detected from edge symmetry, as in [plot_multilayer()].
#' @return A `mira_plot` object.
#' @seealso [mira_spec()] to see the view spec;
#'   [print.mira_plot()] for the browser and port options.
#' @export
#' @examples
#' if (interactive() && requireNamespace("emln", quietly = TRUE)) {
#' library(emln)
#' net <- load_emln(60)
#' mira(net, bipartite = TRUE, setA_type = "pollinator") +
#'   mira_layout("kamada_kawai", seed = 42) +
#'   mira_node(color_by = c(pollinator = "module", plant = NA)) +
#'   mira_interlayer(color = "red")
#'
#' # When done:
#' httpuv::stopAllServers()
#' }
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

#' Add a piece to a mira plot
#'
#' @param e1 A `mira_plot`.
#' @param e2 A `mira_piece` (from a `mira_*()` function), or `NULL` (no change).
#' @return The `mira_plot` with the piece added.
#' @keywords internal
#' @export
`+.mira_plot` <- function(e1, e2) {
  if (!inherits(e1, "mira_plot")) {
    stop("A mira plot starts with mira(net); add pieces after it.", call. = FALSE)
  }
  if (is.null(e2)) return(e1)
  if (!inherits(e2, "mira_piece")) {
    stop("Only mira_*() pieces (e.g. mira_node()) can be added to a mira plot.", call. = FALSE)
  }
  .validate_piece(e2, e1)
  e1$spec <- .merge_piece(e1$spec, e2)
  .update_scales(e1, e2)
}

#' Open a mira plot in the browser
#'
#' Starts a local server with the network and its view spec and opens MiRA.
#' Each print starts a new server (on the next free port when `port` is
#' taken).
#'
#' @param x A `mira_plot`.
#' @inheritParams plot_multilayer
#' @param ... Not used.
#' @return Invisibly, the server handle. Stop it with
#'   `httpuv::stopServer(handle)`, or stop all servers with
#'   `httpuv::stopAllServers()`.
#' @export
print.mira_plot <- function(x, port = 8080, mira_path = NULL,
                            browser = getOption("browser"), ...) {
  message("Please report issues at ",
          "https://github.com/Ecological-Complexity-Lab/MiRA/issues")
  .serve_mira(x$network_json, view_json = mira_spec(x, json = TRUE), port = port,
              mira_path = mira_path, browser = browser)
}

#' The view spec of a mira plot
#'
#' Shows what a plot sends to MiRA: the settings from its pieces, after
#' merging. Useful to check a plot before opening it.
#'
#' @param x A `mira_plot`.
#' @param json `FALSE` (default) for an R list, `TRUE` for the JSON string
#'   MiRA receives.
#' @return A list, or a JSON string.
#' @export
#' @examples
#' if (requireNamespace("emln", quietly = TRUE)) {
#' library(emln)
#' p <- mira(load_emln(60), bipartite = TRUE) + mira_node(size = 10)
#' mira_spec(p)
#' }
mira_spec <- function(x, json = FALSE) {
  if (!inherits(x, "mira_plot")) stop("`x` must be a mira plot (from mira()).", call. = FALSE)
  spec <- c(list(version = VIEW_SPEC_VERSION), .spec_for_mira(x))
  if (isTRUE(json)) .to_json(spec) else spec
}

#' Merge a piece into the spec: its fields replace the same fields
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
