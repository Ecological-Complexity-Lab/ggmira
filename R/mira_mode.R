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
#' MiRA shows a network in several views, its *modes*: the stack of layers
#' (network mode, the default), the layers side by side (grid), the layers
#' on a geographic map (map), one bubble per layer (layer), the network
#' aggregated over layers (meta-network), summary charts (dashboard) and
#' the data tables (data). A `mira_mode_*()` component opens the plot in
#' that view. Everything can still be changed in MiRA, including the view.
#'
#' **One view per plot.** A plot opens in one view. A later
#' `mira_mode_*()` of another view replaces the earlier one, with a warning;
#' a later one of the same view changes only the arguments it gives. To
#' show a network in two views, make two plots.
#'
#' **What applies where.** The other components still apply where MiRA
#' uses them: colors, sizes and shapes of nodes, links and layers show in
#' network, grid and map modes; `highlight` also carries over to the
#' meta-network. Two components work in fewer views, and R warns when they
#' are combined with another one:
#' - [mira_filter()]: network, grid and map modes only (MiRA's data
#'   filter); the other views show the whole network. The meta-network has
#'   its own layer filter, which dims the other layers:
#'   `mira_mode_meta(layers = )`.
#' - [mira_camera()]: network mode only.
#'
#' The map needs the layers' coordinates (`latitude` and `longitude` in
#' `net$layers`). The layer, map, dashboard and data views open with
#' MiRA's defaults; their settings are not available from R yet.
#'
#' @param columns Number of columns of layers, a whole number between 1 and
#'   8. MiRA's default is the square root of the number of layers, rounded
#'   up.
#' @return A component, to add to a plot with `+`.
#' @seealso [mira_mode_meta()] for the meta-network; [plot_mira()] to open
#'   a network in a view with MiRA's defaults.
#' @family components
#' @name mira_mode
#' @examplesIf requireNamespace("emln", quietly = TRUE)
#' library(emln)
#' net <- load_emln(17) # 4 layers; bird and plant nodes
#' p <- mira(net, bipartite = TRUE, setA_type = "bird") +
#'   mira_node(color_by = "verification_level")
#'
#' # The layers side by side, in two columns
#' p + mira_mode_grid(columns = 2)
#'
#' # The other views, with MiRA's defaults
#' p + mira_mode_map()       # needs latitude and longitude in net$layers
#' p + mira_mode_layer()
#' p + mira_mode_dashboard()
#' p + mira_mode_data()
NULL

#' @rdname mira_mode
#' @export
mira_mode_grid <- function(columns) {
  .mode_piece("grid", "mira_mode_grid", environment(), list(columns = .whole_number_in(1, GRID_COLUMNS_MAX)))
}

#' @rdname mira_mode
#' @export
mira_mode_map <- function() .mode_piece("map", "mira_mode_map", environment(), list())

#' @rdname mira_mode
#' @export
mira_mode_layer <- function() .mode_piece("layer", "mira_mode_layer", environment(), list())

#' @rdname mira_mode
#' @export
mira_mode_dashboard <- function() .mode_piece("dashboard", "mira_mode_dashboard", environment(), list())

#' @rdname mira_mode
#' @export
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
#' the data. The `"force"` layout is random: it differs each time the plot
#' opens.
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
mira_mode_meta <- function(aggregation, layout, color_by, size_by, size, min_weight, nested,
                           labels, label_size, color) {
  .mode_piece("meta", "mira_mode_meta", environment(), list(
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
