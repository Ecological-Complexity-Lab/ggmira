# Views ("modes"): the view MiRA opens in. A plot opens in one view; the
# components of the plot (colors, sizes, filter, highlight...) apply in
# every view where MiRA uses them. Without a mode, MiRA opens in network
# mode. MiRA's own word is "mode", hence mira_mode_*().

MODES <- c("network", "grid", "map", "layer", "meta", "dashboard", "data")
NETWORK_MODE <- "network"
GRID_COLUMNS_MAX <- 8
META_AGGREGATIONS <- c("occurrence", "weights", "union")
META_LAYOUTS <- c("circular", "force", "bipartite")
META_MEASURES <- c("participation", "degree", "uniform")
META_SIZE_MIN <- 0.2  # multiplier of MiRA's node sizes
META_SIZE_MAX <- 3
META_LABEL_SIZE_MIN <- 8
META_LABEL_SIZE_MAX <- 24
LATITUDE_COLUMNS <- c("latitude", "Latitude") # as MiRA reads them

#' Views: open the plot in another MiRA mode
#'
#' MiRA shows a network in several views, its *modes*, each opened by a
#' button in MiRA's toolbar. A `mira_mode_*()` component opens the plot in
#' that view; without one, MiRA opens in network mode, the stack of layers.
#' Everything can still be changed in MiRA, including the view.
#' - [mira_mode_grid()]: the layers side by side.
#' - [mira_mode_map()]: the layers on a geographic map.
#' - [mira_mode_layer()]: one bubble per layer, linked by shared nodes and
#'   interlayer links.
#' - [mira_mode_meta()]: the network aggregated over layers.
#' - [mira_mode_dashboard()]: summary charts.
#' - [mira_mode_data()]: the data tables.
#'
#' **One view per plot.** A plot opens in one view. A later
#' `mira_mode_*()` of another view replaces the earlier one, with a warning;
#' a later one of the same view changes only the arguments it gives. To
#' show a network in two views, make two plots. To open a network in any
#' view with MiRA's defaults, use [plot_mira()] with `mode`.
#'
#' **What applies where.** The other components of the plot apply in the
#' views where MiRA uses them:
#'
#' | Component | network | grid | map | layer | meta | dashboard, data |
#' |---|---|---|---|---|---|---|
#' | [mira_layout()] | yes | yes | yes | inside the bubbles | | |
#' | [mira_node()] | yes | yes | yes | | shapes | |
#' | [mira_intralayer()] | yes | yes | yes | | | |
#' | [mira_interlayer()] | yes | | yes | | | |
#' | [mira_layer()] colors | yes | yes | yes | yes | | |
#' | `mira_node(highlight = )` | yes | yes | yes | | yes | |
#' | [mira_filter()] | yes | yes | yes | | | |
#' | [mira_camera()] | yes | | | | | |
#'
#' R warns when [mira_filter()] or [mira_camera()] is combined with a view
#' that does not use it. The meta-network has its own layer filter, which
#' dims the other layers instead: `mira_mode_meta(layers = )`.
#'
#' @seealso [plot_mira()] to open a network in a view with MiRA's defaults.
#' @family components
#' @name mira_mode
NULL

#' Grid: open the plot with the layers side by side
#'
#' Opens the plot in MiRA's grid mode: one panel per layer, each with its
#' own nodes and links, as drawn in network mode (positions, colors, sizes,
#' shapes, layer colors, node names, the highlighted node). Interlayer
#' links are not drawn. [mira_filter()] applies: layers and nodes it drops
#' are not drawn, and the remaining layers fill the grid. In MiRA, the grid
#' button (four squares) opens this view.
#'
#' A plot opens in one view: see [mira_mode] for the rules and for what
#' applies in each view.
#'
#' \if{html}{\figure{mira_mode_grid.jpg}{options: width="100\%" alt="Network 17 in grid mode: four layer panels, birds as squares and plants as circles"}}
#'
#' @param columns Number of columns of layers, a whole number between 1 and
#'   8. MiRA's default is the square root of the number of layers, rounded
#'   up.
#' @return A component, to add to a plot with `+`.
#' @seealso [mira_mode] for the other views.
#' @family components
#' @export
#' @examplesIf requireNamespace("emln", quietly = TRUE)
#' library(emln)
#' net <- load_emln(17) # 4 layers; bird and plant nodes
#' p <- mira(net, bipartite = TRUE, setA_type = "bird") +
#'   mira_node(color_by = "verification_level")
#'
#' # MiRA's default columns (here 2), then all layers in one row
#' p + mira_mode_grid()
#' p + mira_mode_grid(columns = 4)
#'
#' # The filter applies in the grid
#' p + mira_filter(nodes = type == "plant" | node_name == "Geospiza_fortis") +
#'   mira_mode_grid()
mira_mode_grid <- function(columns) {
  .mode_piece("grid", "mira_mode_grid", environment(), list(columns = .whole_number_in(1, GRID_COLUMNS_MAX)))
}

#' Map: open the plot with the layers on a geographic map
#'
#' Opens the plot in MiRA's map mode: each layer at its coordinates on a
#' satellite map, fitted to the layers. Clicking a location (or its name in
#' the *Select Layers* panel) draws that layer's network over the map, as
#' drawn in network mode. [mira_filter()] applies. In MiRA, the map button
#' opens this view.
#'
#' The map needs the layers' coordinates: `latitude` and `longitude`
#' columns in `net$layers`. Without them R stops with an error. The map's
#' settings (opacity, street map, which layers are drawn) are not
#' available from R yet; the map opens with MiRA's defaults.
#'
#' A plot opens in one view: see [mira_mode] for the rules and for what
#' applies in each view.
#'
#' \if{html}{\figure{mira_mode_map.jpg}{options: width="100\%" alt="Network 17 in map mode: the Galapagos, with the layers' two islands marked"}}
#'
#' @return A component, to add to a plot with `+`.
#' @seealso [mira_mode] for the other views; [mira_mode_layer()], which
#'   also places the layers on the map.
#' @family components
#' @export
#' @examplesIf requireNamespace("emln", quietly = TRUE)
#' library(emln)
#' net <- load_emln(17) # 4 layers on two islands of the Galapagos
#' net$layers[, c("layer_name", "latitude", "longitude")]
#' p <- mira(net, bipartite = TRUE, setA_type = "bird")
#' p + mira_mode_map()
mira_mode_map <- function() .mode_piece("map", "mira_mode_map", environment(), list())

#' Layer view: open the plot with one bubble per layer
#'
#' Opens the plot in MiRA's layer view: each layer is a bubble, with its
#' network drawn inside (positions from [mira_layout()]) and the layer's
#' color from [mira_layer()]; bubbles are linked by the nodes the layers
#' share and by interlayer links. When the layers have coordinates (`latitude` and `longitude` in
#' `net$layers`) the bubbles are placed on a map, fitted so that none is
#' under MiRA's panels; otherwise they are placed by a force layout. In
#' MiRA, the layer view button opens this view.
#'
#' The layer view's settings (bubble size and color, links between
#' bubbles, labels) are not available from R yet; it opens with MiRA's
#' defaults.
#'
#' A plot opens in one view: see [mira_mode] for the rules and for what
#' applies in each view.
#'
#' \if{html}{\figure{mira_mode_layer.jpg}{options: width="100\%" alt="Network 17 in the layer view: four bubbles on the map of the Galapagos, linked"}}
#'
#' @return A component, to add to a plot with `+`.
#' @seealso [mira_mode] for the other views.
#' @family components
#' @export
#' @examplesIf requireNamespace("emln", quietly = TRUE)
#' library(emln)
#' net <- load_emln(17) # 4 layers on two islands: bubbles on the map
#' p <- mira(net, bipartite = TRUE, setA_type = "bird")
#' p + mira_mode_layer()
#'
#' # Bubbles in the layers' colors
#' p + mira_layer(color_by = "layer_name",
#'                color_values = c(layer_1 = "orange", layer_3 = "purple")) +
#'   mira_mode_layer()
mira_mode_layer <- function() .mode_piece("layer", "mira_mode_layer", environment(), list())

#' Dashboard: open the plot as summary charts
#'
#' Opens the plot in MiRA's dashboard: a summary of the network (nodes,
#' layers, links, density), charts per layer (nodes, links, density) and
#' the distributions of link weights. It shows the whole network; the
#' other components of the plot do not apply (see [mira_mode]). In MiRA,
#' the dashboard button (a bar chart) opens this view.
#'
#' \if{html}{\figure{mira_mode_dashboard.jpg}{options: width="100\%" alt="Network 17 in the dashboard: summary numbers, per-layer charts and link weight distributions"}}
#'
#' @return A component, to add to a plot with `+`.
#' @seealso [mira_mode] for the other views.
#' @family components
#' @export
#' @examplesIf requireNamespace("emln", quietly = TRUE)
#' library(emln)
#' net <- load_emln(17)
#' mira(net, bipartite = TRUE, setA_type = "bird") + mira_mode_dashboard()
mira_mode_dashboard <- function() .mode_piece("dashboard", "mira_mode_dashboard", environment(), list())

#' Data: open the plot as the data tables
#'
#' Opens the plot in MiRA's data mode: the network's tables (nodes, state
#' nodes, links, layers), with every attribute, sortable and filterable,
#' and *Export CSV*. A filter set there applies to network, grid and map
#' modes, like [mira_filter()] from R. It opens on the nodes table with
#' every row; the other components of the plot do not apply (see
#' [mira_mode]). In MiRA, the data button (a table) opens this view.
#'
#' \if{html}{\figure{mira_mode_data.jpg}{options: width="100\%" alt="Network 17 in data mode: the nodes table with its attributes"}}
#'
#' @return A component, to add to a plot with `+`.
#' @seealso [mira_filter()] to filter from R; [mira_mode] for the other
#'   views.
#' @family components
#' @export
#' @examplesIf requireNamespace("emln", quietly = TRUE)
#' library(emln)
#' net <- load_emln(17)
#' mira(net, bipartite = TRUE, setA_type = "bird") + mira_mode_data()
mira_mode_data <- function() .mode_piece("data", "mira_mode_data", environment(), list())

#' Meta-network: open the plot as the network aggregated over layers
#'
#' Opens the plot in MiRA's meta-network mode: each node once, linked to the
#' nodes it interacts with in any layer. Arguments not given keep the
#' values MiRA uses when its meta-network button is clicked.
#'
#' A plot opens in one view: see [mira_mode] for the rules (a later
#' `mira_mode_*()` of another view replaces this one, with a warning).
#' `color_by` and `size_by` here are meta-network measures, not columns of
#' the data. Node shapes follow `mira_node(shape = )`, with a shape legend
#' when the node sets have different shapes. The `"force"` layout is random: it differs each time the plot
#' opens.
#'
#' \if{html}{\figure{mira_mode_meta.jpg}{options: width="100\%" alt="Network 17 as a meta-network: birds in one row, plants in the other, sized by degree"}}
#'
#' @param aggregation How links of different layers combine into one:
#'   `"occurrence"` (MiRA's default: the number of layers with the link),
#'   `"weights"` (the sum of their weights) or `"union"` (present in any
#'   layer).
#' @param layout `"circular"`, `"force"` or `"bipartite"` (two rows, one
#'   per node set; needs `mira(..., bipartite = TRUE)`). MiRA's default is
#'   `"bipartite"` for bipartite networks and `"circular"` otherwise.
#' @param color_by Node color: `"uniform"` (MiRA's default: one color, see
#'   `color`), `"participation"` (the number of layers a node is in) or
#'   `"degree"` (the number of nodes it links to in the meta-network).
#' @param size_by Node size: `"degree"` (MiRA's default), `"participation"`
#'   or `"uniform"`.
#' @param size Node size multiplier, between 0.2 and 3 (default 1).
#' @param min_weight Hide links with an aggregated weight below this (a
#'   number of 0 or more; default 0).
#' @param nested `TRUE` (default) or `FALSE`: sort each row of the
#'   bipartite layout by degree. Only for bipartite networks, and only
#'   used by the `"bipartite"` layout.
#' @param labels `TRUE` to show node names (default `FALSE`).
#' @param label_size Size of node names in pixels, a whole number between
#'   8 and 24 (default 12).
#' @param color One color for every node (`color_by = "uniform"`), or one
#'   per node set, named by `node_type` (e.g.
#'   `c(bird = "orange", plant = "darkgreen")`). Give `color_by` or `color`,
#'   not both: a later `color` replaces an earlier `color_by`, and the
#'   other way round.
#' @param layers Layers to select in the meta-network's *Filter Layers*
#'   panel: nodes and links not in them are dimmed (not removed, and the
#'   meta-network is not recomputed). Layer names, or a condition on the
#'   columns of `net$layers` evaluated like [subset()] (e.g.
#'   `layer_name != "layer_1"`, `!layer_name %in% c("layer_1", "layer_2")`,
#'   `latitude > 0`). `NULL` or `NA` (MiRA's default) = none selected,
#'   nothing dimmed. Unlike [mira_filter()], which the meta-network does not
#'   use, nothing is hidden.
#' @return A component, to add to a plot with `+`.
#' @seealso [mira_mode] for the other views.
#' @family components
#' @export
#' @examplesIf requireNamespace("emln", quietly = TRUE)
#' library(emln)
#' net <- load_emln(17) # 4 layers; bird and plant nodes
#' p <- mira(net, bipartite = TRUE, setA_type = "bird")
#'
#' # MiRA's meta-network
#' p + mira_mode_meta()
#'
#' # Links weighted by the sum of weights; nodes colored by the number of
#' # layers they are in, with their names
#' p + mira_mode_meta(aggregation = "weights", color_by = "participation",
#'                    size_by = "degree", size = 1.5, labels = TRUE, label_size = 14)
#'
#' # Only links in at least two layers, in a circle
#' p + mira_mode_meta(layout = "circular", min_weight = 2)
#'
#' # Two rows not sorted by degree, with a color per node set
#' p + mira_mode_meta(nested = FALSE, color = c(bird = "orange", plant = "darkgreen"))
#'
#' # Shapes from mira_node(): birds as squares, in a circle
#' p + mira_node(shape = c(bird = "square", plant = "circle")) +
#'   mira_mode_meta(layout = "circular")
#'
#' # Dim the nodes and links of layer_1: select the other layers
#' p + mira_mode_meta(layers = layer_name != "layer_1")
#' p + mira_mode_meta(layers = c("layer_2", "layer_3"))
mira_mode_meta <- function(aggregation, layout, color_by, size_by, size, min_weight, nested,
                           labels, label_size, color, layers) {
  piece <- .mode_piece("meta", "mira_mode_meta", environment(), list(
    aggregation = .choice(META_AGGREGATIONS),
    layout      = .choice(META_LAYOUTS),
    color_by    = .choice(META_MEASURES),
    size_by     = .choice(META_MEASURES),
    size        = .number_in(META_SIZE_MIN, META_SIZE_MAX),
    min_weight  = .number_at_least(0),
    nested      = .check_flag,
    labels      = .check_flag,
    label_size  = .whole_number_in(META_LABEL_SIZE_MIN, META_LABEL_SIZE_MAX),
    color       = .shared_or_per_set(.check_color)
  ))
  # A condition, captured here and evaluated against the network when added (as mira_filter())
  if (!missing(layers)) piece$fields["layers"] <- list(.capture_condition(substitute(layers), parent.frame()))
  piece
}

#' mira_mode_meta(layers = ): the condition or names -> the layer names MiRA
#' selects (an empty list selects none)
#' @keywords internal
#' @noRd
.resolve_meta_layers <- function(piece, plot) {
  if (piece$section != "mode" || !"layers" %in% names(piece$fields)) return(piece)
  condition <- piece$fields$layers
  piece$fields["layers"] <- list(if (is.null(condition)) list() else .meta_layers(condition, plot$net, piece$fn))
  piece
}

.meta_layers <- function(condition, net, fn) {
  layers <- as.data.frame(net$layers)
  value <- .eval_condition(condition, layers, "layers", "net$layers", fn)
  if (is.null(value) || identical(value, NA)) return(list()) # e.g. a variable set to NULL: none selected
  names <- .format_names(layers$layer_name)
  numeric_names <- is.numeric(value) && is.numeric(layers$layer_name) # names given as numbers
  if (is.character(value) || is.factor(value) || numeric_names) {
    if (anyNA(value)) .abort_arg(fn, "layers", "names must not be NA")
    value <- if (is.factor(value)) as.character(value) else .format_names(value)
    unknown <- setdiff(value, names)
    if (length(unknown) > 0) {
      .abort_arg(fn, "layers", sprintf('"%s" %s not a layer name (layer_name values: %s)',
                                       paste(unknown, collapse = '", "'), if (length(unknown) == 1) "is" else "are",
                                       paste(utils::head(names, NAMES_SHOWN), collapse = ", ")))
    }
    kept <- unique(value)
  } else if (is.logical(value) && length(value) == nrow(layers)) {
    kept <- unique(names[value %in% TRUE])
  } else {
    .abort_arg(fn, "layers",
               "must be layer names or a condition on the columns of net$layers (TRUE or FALSE for each layer)")
  }
  if (length(kept) == 0) warning(sprintf("%s(): `layers` keeps no layers; nothing is dimmed", fn), call. = FALSE)
  as.list(kept)
}

# A mode component: its view goes first in the section, then the arguments
.mode_piece <- function(view, fn, env, checks) {
  piece <- .build_piece("mode", fn, env, checks)
  piece$fields <- c(list(view = view), piece$fields)
  piece
}

#' Checks of a mode component against the plot
#' @keywords internal
#' @noRd
.validate_mode <- function(piece, plot) {
  fields <- piece$fields
  if (identical(fields$view, "map") && !.has_coordinates(plot$net)) {
    .abort_piece(piece$fn, "the map needs the layers' coordinates: `latitude` and `longitude` in net$layers")
  }
  if (!identical(fields$view, "meta")) return(invisible(NULL))
  if (identical(fields$layout, "bipartite") && !plot$bipartite) {
    .abort_piece(piece$fn, 'layout = "bipartite" needs mira(..., bipartite = TRUE)')
  }
  if (!is.null(fields$nested) && !plot$bipartite) {
    .abort_piece(piece$fn, "`nested` needs mira(..., bipartite = TRUE)")
  }
  .check_sets(fields$color, "color", piece$fn, plot)
  # The layout this plot will have: this component's, an earlier meta one's, or MiRA's default
  earlier <- if (identical(plot$spec$mode$view, "meta")) plot$spec$mode$layout
  layout <- fields$layout
  if (is.null(layout)) layout <- earlier
  if (is.null(layout)) layout <- if (plot$bipartite) "bipartite" else "circular"
  if (!is.null(fields$nested) && layout != "bipartite") {
    warning(sprintf('%s(): `nested` is used only by layout = "bipartite"', piece$fn), call. = FALSE)
  }
  invisible(NULL)
}

.has_coordinates <- function(net) {
  layers <- as.data.frame(net$layers)
  latitude <- intersect(LATITUDE_COLUMNS, names(layers))
  length(latitude) > 0 && any(!is.na(layers[[latitude[1]]]))
}

#' A mode component of another view replaces the earlier one (one view per
#' plot), with a warning; of the same view, it is merged like any component.
#' @keywords internal
#' @noRd
.replace_mode <- function(spec, piece) {
  earlier <- spec$mode$view
  if (piece$section != "mode" || is.null(earlier) || identical(earlier, piece$fields$view)) return(spec)
  warning(sprintf("%s() replaces mira_mode_%s(): a plot opens in one view", piece$fn, earlier), call. = FALSE)
  spec$mode <- NULL
  spec
}

# Components that work in some views only: the camera (network mode) and
# the filter (MiRA's data filter: network, grid and map modes). Warned once,
# when the component or the view is added.
CAMERA_MODES <- NETWORK_MODE
FILTER_MODES <- c(NETWORK_MODE, "grid", "map")
VIEW_NAMES <- c(meta = "the meta-network", layer = "layer mode", dashboard = "dashboard mode",
                data = "data mode") # views without the data filter, as warnings name them

.warn_view_only <- function(spec, piece) {
  view <- spec$mode$view
  if (is.null(view)) return(invisible(NULL))
  if (piece$section %in% c("camera", "mode") && !is.null(spec$camera) && !view %in% CAMERA_MODES) {
    warning(sprintf("%s(): mira_camera() has no effect in mira_mode_%s(); it sets the view in network mode only",
                    piece$fn, view), call. = FALSE)
  }
  if (piece$section %in% c("filter", "mode") && length(spec$filter) > 0 && !view %in% FILTER_MODES) {
    hint <- if (view == "meta") "; to dim layers in the meta-network, use mira_mode_meta(layers = )" else ""
    warning(sprintf(paste0("%s(): mira_filter() is not applied in %s, which shows the whole network; ",
                           "MiRA's data filter works in network, grid and map modes%s"),
                    piece$fn, VIEW_NAMES[[view]], hint), call. = FALSE)
  }
  invisible(NULL)
}
