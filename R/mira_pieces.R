# The components of a plot. Each mira_*() function records only the arguments
# it was given, as one section of the view spec (contract: dev/ggmira/view-spec.md
# on MiRA's development branch). Checks that need no network run here;
# checks against the network run when the piece is added to a plot
# (mira_validate.R).

LAYOUT_TYPES <- c("fruchterman", "kamada_kawai", "bipartite", "circle", "grid", "random")
SHAPES <- c("circle", "square", "triangle", "diamond")
NODE_SIZE_MIN <- 3   # MiRA's node size slider range
NODE_SIZE_MAX <- 25
WEIGHT_MIN <- 0      # link weight filter; no upper bound (MiRA's sliders
                     # run to the largest weight in the data)
OPAQUE_ALPHA <- 255  # col2rgb() alpha of a fully opaque color
# MiRA's slider ranges
LABEL_SIZE_MIN <- 8        # node labels
LABEL_SIZE_MAX <- 24
LAYER_LABEL_SIZE_MIN <- 8  # layer names
LAYER_LABEL_SIZE_MAX <- 32
LAYER_SPACING_MIN <- 100
LAYER_SPACING_MAX <- 600
ARROW_SIZE_MIN <- 0
ARROW_SIZE_MAX <- 3
CURVATURE_MIN <- 0
CURVATURE_MAX <- 1
STACK_MODES <- c("horizontal", "vertical")
SCALE_TYPES <- c("categorical", "continuous")

# Keywords that are not column names
SET_KEYWORD <- ".set"               # node color by set membership
INDIVIDUAL_KEYWORD <- ".individual" # one color per layer
KEYWORDS <- c(SET_KEYWORD, INDIVIDUAL_KEYWORD)
LAYER_NAME_COLUMN <- "layer_name"   # mira_layer(color_by = "layer_name") = ".individual"

#' Layout: where the nodes go
#'
#' Chooses MiRA's network layout, the one setting that places the nodes.
#' Add it to a plot made with [mira()]; without it, MiRA uses its default
#' (the bipartite layout for a bipartite network, Fruchterman-Reingold
#' otherwise).
#'
#' @param type One of `"fruchterman"`, `"kamada_kawai"`, `"bipartite"`,
#'   `"circle"`, `"grid"`, `"random"`. `"bipartite"` needs
#'   `mira(..., bipartite = TRUE)`.
#' @param seed A whole number. The same seed and the same data give the same
#'   node positions, so a figure can be reproduced. Without a seed, a layout
#'   that starts from random positions (`"fruchterman"`, MiRA's default for
#'   a network that is not bipartite, among them) differs each time the
#'   plot opens.
#' @param nested `TRUE` or `FALSE`. Bipartite layout only: sort nodes by
#'   degree (nested order).
#' @return A component, to add to a plot with `+`.
#' @seealso [mira()] to start a plot; [mira_node()], [mira_intralayer()],
#'   [mira_interlayer()] and [mira_layer()] for the elements it draws.
#' @family components
#' @export
#' @examplesIf requireNamespace("emln", quietly = TRUE)
#' library(emln)
#' net <- load_emln(17) # 4 layers; bird and plant nodes
#' p <- mira(net, bipartite = TRUE, setA_type = "bird")
#'
#' p + mira_layout("kamada_kawai")
#'
#' # The same node positions every time
#' p + mira_layout("fruchterman", seed = 42)
#'
#' # Bipartite layout, nodes sorted by degree
#' p + mira_layout("bipartite", nested = TRUE)
mira_layout <- function(type, seed, nested) {
  .build_piece("layout", "mira_layout", environment(), list(
    type   = .choice(LAYOUT_TYPES),
    seed   = .check_seed,
    nested = .check_flag
  ))
}

#' Nodes: color, size, shape and labels
#'
#' Maps node color and size to node attributes (`color_by`, `size_by`), or
#' sets them to constants (`color`, `size`, `shape`), and shows node names.
#' Add it to a plot made with [mira()]. Anything not given keeps MiRA's
#' default.
#'
#' **Per set.** On a bipartite network (`mira(..., bipartite = TRUE)`),
#' `color_by`, `size_by`, `shape`, `color_scale`, `color_palette` and
#' `color_reverse` also take a vector named by the `node_type` values,
#' giving each set its own setting, e.g.
#' `color_by = c(pollinator = "module", plant = NA)`; `color_values` and
#' `color_limits` take a list named the same way,
#' `list(pollinator = c("1" = "red"))`. A set that is not named keeps
#' MiRA's default, and a later per-set value replaces an earlier one whole:
#' name both sets in one call. The scale settings of the two sets differ
#' only when the sets are colored by different attributes, because MiRA
#' keeps one scale per attribute name ([mira_scales]). When color or size
#' is per set and `shape` is not given, MiRA draws one set as circles and
#' the other as squares.
#'
#' **Computed attributes.** MiRA computes each node's degree (its number of
#' links) and strength (the sum of their weights), within layers (`intra_`)
#' and between layers (`inter_`, when the network has interlayer links). For
#' each node in each layer (a state node): `intra_degree`, `intra_strength`,
#' `inter_degree`, `inter_strength`. For each node over all its layers,
#' their sum and their mean: `intra_degree_sum`, `intra_degree_mean`, and
#' so on. On a directed network the names carry the direction instead:
#' `intra_in_degree`, `intra_out_degree`, `intra_in_strength_sum`, ... R
#' warns when a name is not computed for the network, and suggests the ones
#' that are; [mira_options()] lists them.
#'
#' **Columns that cannot be mapped.** MiRA does not offer the columns that
#' identify the rows: `node_id`, `node_name`, `layer_id`, `layer_name` and
#' `layers_present` for nodes; `layer_from`, `node_from`, `layer_to`,
#' `node_to`, `weight` and `directed` for links; `layer_id`, `bipartite`,
#' `latitude` and `longitude` for layers. To map one, copy it to a column
#' of another name (`net$layers$lat <- net$layers$latitude`).
#'
#' @param color_by Column to color nodes by: a node or state-node column
#'   (e.g. `"module"`) or a MiRA-computed attribute (e.g.
#'   `"intra_degree_sum"`). `".set"` colors by set membership (bipartite
#'   networks). `NULL` or `NA` = MiRA's default.
#' @param color A constant node color: a color name (`"red"`) or `"#rrggbb"`.
#'   Give `color_by` or `color`, not both. Colors are opaque: the
#'   transparency of a color such as `"#ff000080"` is ignored, with a
#'   warning (here and in every other color argument).
#' @param size_by Numeric column to size nodes by. `NULL` or `NA` = default.
#' @param size Base node size, a whole number between 3 and 25 (10 = MiRA's
#'   default).
#' @param shape `"circle"`, `"square"`, `"triangle"` or `"diamond"`. Every
#'   shape has the circle's area, so node sizes stay comparable.
#' @param labels `TRUE` or `FALSE`: show node names.
#' @param label_size Node name size, a whole number between 8 and 24 (12 =
#'   MiRA's default). Used when node names are shown.
#' @param perspective `TRUE` or `FALSE`: draw nodes in the layers' 3D
#'   perspective (MiRA's default) or flat.
#' @param color_values Colors for values of the `color_by` column, named by
#'   value: `c("1" = "red", "3" = "#1f77b4")`. Values not listed keep MiRA's
#'   palette. Gives a categorical scale. Per set:
#'   `list(pollinator = c(...))`. With `color_by = ".set"`, the colors of
#'   the sets: `c(pollinator = "red", plant = "green")`. See
#'   [mira_scales].
#' @param color_scale `"categorical"` (one color per value) or
#'   `"continuous"` (a gradient; numeric columns only). Without it, MiRA
#'   decides from the data. Per set: `c(pollinator = "continuous")`. See
#'   [mira_scales].
#' @param color_palette A named palette for the `color_by` scale: a
#'   categorical one (`"Okabe-Ito"`, `"Set1"`, ...) gives one color per
#'   value, a continuous one (`"magma"`, `"RdBu"`, ...) a gradient. Names
#'   are matched without case; the list is in [mira_scales]. Per set:
#'   `c(pollinator = "magma")`.
#' @param color_reverse `TRUE` reverses the palette. Per set:
#'   `c(pollinator = TRUE)`.
#' @param color_limits `c(min, max)`: the gradient runs from `min` to `max`
#'   instead of the data's range, so several plots can share one scale;
#'   values outside take the end colors. Gives a continuous scale. Per set:
#'   `list(pollinator = c(0, 10))`.
#' @param highlight A node name: the node and its neighbors stand out in
#'   every layer and the rest is dimmed, as when the node is picked in
#'   MiRA's Search Node. The banner "Selected node" clears it.
#' @return A component, to add to a plot with `+`.
#' @seealso [mira_scales] for `color_values`, `color_scale` and sizes;
#'   [mira()] for how components combine.
#' @family components
#' @export
#' @examplesIf requireNamespace("emln", quietly = TRUE)
#' library(emln)
#' net <- load_emln(17) # 4 layers; bird and plant nodes
#' p <- mira(net, bipartite = TRUE, setA_type = "bird")
#'
#' # Map color and size to attributes
#' p + mira_node(color_by = "verification_level", size_by = "intra_degree_sum")
#'
#' # Constants
#' p + mira_node(color = "steelblue", size = 8, shape = "triangle")
#'
#' # One setting per node set
#' p + mira_node(color_by = c(bird = "intra_degree_sum", plant = NA),
#'               shape = c(bird = "diamond", plant = "circle"))
#'
#' # Node names; flat nodes
#' p + mira_node(labels = TRUE, label_size = 10, perspective = FALSE)
#'
#' # Highlight a node and its neighbors
#' p + mira_node(highlight = "Geospiza_fortis")
#'
#' # Choose the colors (see ?mira_scales)
#' p + mira_node(color_by = "verification_level",
#'               color_values = c(species = "#1f77b4", genus = "orange"))
#' p + mira_node(color_by = "intra_degree_sum", color_scale = "categorical")
mira_node <- function(color_by, color, size_by, size, shape, labels, label_size, perspective,
                      color_values, color_scale, highlight, color_palette, color_reverse,
                      color_limits) {
  .build_piece("node", "mira_node", environment(), list(
    color_by     = .shared_or_per_set(.mapping(SET_KEYWORD), .mapping()),
    color        = .check_color,
    size_by      = .shared_or_per_set(.mapping()),
    size         = .whole_number_in(NODE_SIZE_MIN, NODE_SIZE_MAX),
    shape        = .shared_or_per_set(.choice(SHAPES)),
    labels       = .check_flag,
    label_size   = .whole_number_in(LABEL_SIZE_MIN, LABEL_SIZE_MAX),
    perspective  = .check_flag,
    color_values = .check_color_values(per_set = TRUE),
    color_scale  = .shared_or_per_set(.choice(SCALE_TYPES)),
    highlight    = .check_name,
    color_palette = .shared_or_per_set(.check_palette),
    color_reverse = .shared_or_per_set(.check_flag),
    color_limits  = .shared_or_per_set(.check_limits)
  ))
}

#' Intralayer links: color, weight filter and arrowheads
#'
#' Styles the links within layers: color by a link column (`color_by`) or
#' one constant (`color`), hide weak links (`min_weight`), size arrowheads
#' (`arrow_size`). Add it to a plot made with [mira()].
#'
#' @param color_by Link column to color intralayer links by (a column of
#'   `net$extended`, e.g. `"type"`; not `weight`, which sets the links'
#'   width). `NULL` or `NA` = default.
#' @param color A constant link color: a color name or `"#rrggbb"`. Give
#'   `color_by` or `color`, not both.
#' @param min_weight Hide links with weight below this value (0 or more,
#'   in the units of the data's `weight` column).
#' @param arrow_size Arrowhead size, between 0 and 3 (1 = MiRA's default).
#'   Directed networks only. MiRA has one arrowhead size, so this also sizes
#'   the arrowheads of directed interlayer links.
#' @param color_values Colors for values of the `color_by` column, named by
#'   value. See [mira_scales].
#' @param color_scale `"categorical"` or `"continuous"`. See [mira_scales].
#' @param color_palette A named palette for the `color_by` scale:
#'   categorical (`"Okabe-Ito"`, ...) or continuous (`"magma"`, ...); see
#'   [mira_scales] for the list.
#' @param color_reverse `TRUE` reverses the palette.
#' @param color_limits `c(min, max)`: the gradient runs from `min` to `max`
#'   instead of the data's range; values outside take the end colors. Gives a
#'   continuous scale.
#' @return A component, to add to a plot with `+`.
#' @seealso [mira_interlayer()] for the links between layers;
#'   [mira_scales] for `color_values` and `color_scale`.
#' @family components
#' @export
#' @examplesIf requireNamespace("emln", quietly = TRUE)
#' library(emln)
#' net <- load_emln(17) # 4 layers; bird and plant nodes
#' p <- mira(net, bipartite = TRUE, setA_type = "bird")
#'
#' # Color by a link column
#' p + mira_intralayer(color_by = "type")
#'
#' # One color; hide links with weight below 0.05
#' p + mira_intralayer(color = "grey60", min_weight = 0.05)
#'
#' # Choose the colors (see ?mira_scales)
#' p + mira_intralayer(color_by = "type", color_values = c(pollination = "#d62728"))
#' p + mira_intralayer(color_by = "type", color_scale = "categorical")
#'
#' # Arrowheads, on a directed network
#' mira(net, bipartite = TRUE, setA_type = "bird", directed = TRUE) +
#'   mira_intralayer(arrow_size = 0.5)
mira_intralayer <- function(color_by, color, min_weight, arrow_size, color_values, color_scale,
                            color_palette, color_reverse, color_limits) {
  .build_piece("intralayer", "mira_intralayer", environment(), list(
    color_by     = .mapping(),
    color        = .check_color,
    min_weight   = .number_at_least(WEIGHT_MIN),
    arrow_size   = .number_in(ARROW_SIZE_MIN, ARROW_SIZE_MAX),
    color_values = .check_color_values(per_set = FALSE),
    color_scale  = .choice(SCALE_TYPES),
    color_palette = .check_palette,
    color_reverse = .check_flag,
    color_limits  = .check_limits
  ))
}

#' Interlayer links: show, color, curvature and layer pairs
#'
#' Styles the links between layers: whether they are drawn (`show`; MiRA
#' hides them by default), their color, a weight filter, how much they
#' curve, and between which layers they are shown (`pairs`). Add it to a
#' plot made with [mira()].
#'
#' Interlayer links are drawn only with `show = TRUE` or `pairs`: the other
#' arguments alone style links that stay hidden (a `color_by` still shows
#' its legend).
#'
#' @param show `TRUE` or `FALSE`: draw interlayer links.
#' @inheritParams mira_intralayer
#' @param color_by Link column to color interlayer links by. `NULL` or `NA`
#'   = default.
#' @param curvature Curvature of interlayer links, between 0 (straight) and
#'   1 (0.35 = MiRA's default).
#' @param pairs Show only the interlayer links between these pairs of
#'   layers: `list(c("L1", "L2"), c("L2", "L3"))`, by `layer_name`; one pair
#'   may be given as a vector, `c("L1", "L2")`. The order within a pair does
#'   not matter. Also turns interlayer links on, unless the same call gives
#'   `show = FALSE`. A pair of layers with no links between them draws
#'   nothing. A later `pairs` replaces an earlier one; there is no value
#'   that shows all pairs again.
#' @return A component, to add to a plot with `+`.
#' @seealso [mira_intralayer()] for the links within layers;
#'   [mira_scales] for `color_values` and `color_scale`.
#' @family components
#' @export
#' @examplesIf requireNamespace("emln", quietly = TRUE)
#' library(emln)
#' net <- load_emln(17) # 4 layers; bird and plant nodes
#' p <- mira(net, bipartite = TRUE, setA_type = "bird")
#'
#' # Show interlayer links (hidden by default)
#' p + mira_interlayer(show = TRUE)
#'
#' # One color, more curved; hide links with weight below 0.5
#' p + mira_interlayer(show = TRUE, color = "red", curvature = 0.8, min_weight = 0.5)
#'
#' # Only between some layers (this also shows them)
#' p + mira_interlayer(pairs = list(c("layer_1", "layer_2")))
#'
#' # Color by a link column, and choose the colors (see ?mira_scales)
#' p + mira_interlayer(show = TRUE, color_by = "type",
#'                     color_values = c(interlayer = "black"))
#' p + mira_interlayer(show = TRUE, color_by = "type", color_scale = "categorical")
mira_interlayer <- function(show, color_by, color, min_weight, curvature, pairs, color_values,
                            color_scale, color_palette, color_reverse, color_limits) {
  .build_piece("interlayer", "mira_interlayer", environment(), list(
    show         = .check_flag,
    color_by     = .mapping(),
    color        = .check_color,
    min_weight   = .number_at_least(WEIGHT_MIN),
    curvature    = .number_in(CURVATURE_MIN, CURVATURE_MAX),
    pairs        = .check_pairs,
    color_values = .check_color_values(per_set = FALSE),
    color_scale  = .choice(SCALE_TYPES),
    color_palette = .check_palette,
    color_reverse = .check_flag,
    color_limits  = .check_limits
  ))
}

#' Layers: color, names and arrangement
#'
#' Styles the layers: their color (by a layer column, one per layer, or one
#' constant), their names and the node set names, and how they are stacked
#' and spaced. Add it to a plot made with [mira()].
#'
#' Layer colors are used in the network, grid and map views. In the layer
#' view ([mira_mode_layer()]) the bubbles follow `color_by`, not a constant
#' `color`. One color per layer (`color_by = "layer_name"`) is not a scale:
#' its colors are given with `color_values`, and `color_scale`,
#' `color_palette`, `color_reverse` and `color_limits` with it are errors.
#'
#' @param color_by Layer column to color layers by (a column of
#'   `net$layers`), or `"layer_name"` for one color per layer
#'   (`".individual"` works too). `NULL` or `NA` = default.
#' @param color A constant layer color: a color name or `"#rrggbb"`. Give
#'   `color_by` or `color`, not both.
#' @param color_values Colors for values of the `color_by` column, named by
#'   value. With `color_by = "layer_name"`, named by layer:
#'   `c(L1 = "red", L3 = "#1f77b4")`; layers not listed keep MiRA's color.
#'   See [mira_scales].
#' @param color_scale `"categorical"` or `"continuous"`. Not with
#'   `color_by = "layer_name"`. See [mira_scales].
#' @inheritParams mira_intralayer
#' @param labels `TRUE` or `FALSE`: show layer names.
#' @param label_size Layer name size, a whole number between 8 and 32 (14 =
#'   MiRA's default). Used when layer names are shown.
#' @param set_labels `TRUE` or `FALSE`: show node set names (bipartite
#'   layout only; needs `mira(..., bipartite = TRUE)`).
#' @param stack `"horizontal"` or `"vertical"`: how layers are stacked.
#' @param spacing Space between layers, a whole number between 100 and 600
#'   (300 = MiRA's default).
#' @return A component, to add to a plot with `+`.
#' @seealso [mira_scales] for `color_values` and `color_scale`.
#' @family components
#' @export
#' @examplesIf requireNamespace("emln", quietly = TRUE)
#' library(emln)
#' net <- load_emln(17) # 4 layers; bird and plant nodes
#' p <- mira(net, bipartite = TRUE, setA_type = "bird")
#'
#' # Color by a layer column, or one color for all
#' p + mira_layer(color_by = "interaction_type")
#' p + mira_layer(color = "#e5e7eb")
#'
#' # One color per layer, two of them set by hand
#' p + mira_layer(color_by = "layer_name",
#'                color_values = c(layer_1 = "orange", layer_3 = "#9467bd"))
#'
#' # Choose the colors of a column (see ?mira_scales)
#' p + mira_layer(color_by = "interaction_type", color_scale = "categorical",
#'                color_values = c("seed-dispersal" = "#17becf"))
#'
#' # Layer names and node set names
#' p + mira_layer(labels = TRUE, label_size = 18, set_labels = TRUE)
#'
#' # Stack the layers top to bottom, closer together
#' p + mira_layer(stack = "vertical", spacing = 250)
mira_layer <- function(color_by, color, color_values, color_scale, labels, label_size, set_labels,
                       stack, spacing, color_palette, color_reverse, color_limits) {
  .build_piece("layer", "mira_layer", environment(), list(
    color_by     = .layer_mapping,
    color        = .check_color,
    color_values = .check_color_values(per_set = FALSE),
    color_scale  = .choice(SCALE_TYPES),
    labels       = .check_flag,
    label_size   = .whole_number_in(LAYER_LABEL_SIZE_MIN, LAYER_LABEL_SIZE_MAX),
    set_labels   = .check_flag,
    stack        = .choice(STACK_MODES),
    spacing      = .whole_number_in(LAYER_SPACING_MIN, LAYER_SPACING_MAX),
    color_palette = .check_palette,
    color_reverse = .check_flag,
    color_limits  = .check_limits
  ))
}

# ---- Building a piece ---------------------------------------------------------

#' Record the supplied arguments of a mira_*() call, each run through its check
#'
#' @param env The mira_*() function's environment (to see which arguments
#'   were supplied).
#' @param checks Named list: argument -> function(value, arg, fn) returning
#'   the value to put in the spec (stops on invalid input).
#' @keywords internal
#' @noRd
.build_piece <- function(section, fn, env, checks) {
  supplied <- Filter(function(arg) !eval(call("missing", as.name(arg)), env), names(checks))
  fields <- lapply(supplied, function(arg) checks[[arg]](get(arg, envir = env), arg, fn))
  names(fields) <- supplied
  if (all(c("color_by", "color") %in% supplied)) {
    .abort_piece(fn, "give `color_by` or `color`, not both")
  }
  structure(list(section = section, fn = fn, fields = fields), class = "mira_piece")
}

.abort_piece <- function(fn, message) {
  stop(sprintf("%s(): %s", fn, message), call. = FALSE)
}

.abort_arg <- function(fn, arg, message) {
  .abort_piece(fn, sprintf("`%s` %s", arg, message))
}

.is_scalar <- function(value) length(value) == 1 && !is.list(value)

# ---- Argument checks ----------------------------------------------------------
# Each check is function(value, arg, fn) and returns the spec value.

.check_color <- function(value, arg, fn) {
  if (!is.character(value) || !.is_scalar(value) || is.na(value)) {
    .abort_arg(fn, arg, 'must be one color: a name such as "red" or a "#rrggbb" string')
  }
  rgb <- tryCatch(grDevices::col2rgb(value, alpha = TRUE), error = function(e) NULL)
  if (is.null(rgb)) .abort_arg(fn, arg, sprintf('"%s" is not a color', value))
  if (rgb[4] < OPAQUE_ALPHA) {
    warning(sprintf("%s(): `%s` transparency is ignored", fn, arg), call. = FALSE)
  }
  sprintf("#%02x%02x%02x", rgb[1], rgb[2], rgb[3])
}

# One non-empty string (a node name; checked against the network when added)
.check_name <- function(value, arg, fn) {
  if (!is.character(value) || !.is_scalar(value) || is.na(value) || !nzchar(value)) {
    .abort_arg(fn, arg, "must be one name")
  }
  unname(value)
}

.check_flag <- function(value, arg, fn) {
  if (!is.logical(value) || !.is_scalar(value) || is.na(value)) {
    .abort_arg(fn, arg, "must be TRUE or FALSE")
  }
  unname(value)
}

.check_seed <- function(value, arg, fn) {
  if (!is.numeric(value) || !.is_scalar(value) || !is.finite(value) || value != round(value)) {
    .abort_arg(fn, arg, "must be a whole number")
  }
  unname(value)
}

.number_in <- function(min, max) {
  function(value, arg, fn) {
    ok <- is.numeric(value) && .is_scalar(value) && is.finite(value)
    if (!ok || value < min || value > max) {
      .abort_arg(fn, arg, sprintf("must be a number between %s and %s", min, max))
    }
    unname(value)
  }
}

# For settings MiRA keeps on a slider with whole-number steps (sizes, spacing)
.whole_number_in <- function(min, max) {
  function(value, arg, fn) {
    ok <- is.numeric(value) && .is_scalar(value) && is.finite(value) && value == round(value)
    if (!ok || value < min || value > max) {
      .abort_arg(fn, arg, sprintf("must be a whole number between %s and %s", min, max))
    }
    unname(value)
  }
}

.number_at_least <- function(min) {
  function(value, arg, fn) {
    ok <- is.numeric(value) && .is_scalar(value) && is.finite(value)
    if (!ok || value < min) .abort_arg(fn, arg, sprintf("must be a number of %s or more", min))
    unname(value)
  }
}

# A palette name, matched without case; returned as MiRA spells it
.check_palette <- function(value, arg, fn) {
  palettes <- c(CATEGORICAL_PALETTES, CONTINUOUS_PALETTES)
  match <- if (is.character(value) && .is_scalar(value)) palettes[tolower(palettes) == tolower(value)] else character()
  if (length(match) == 0) {
    .abort_arg(fn, arg, sprintf("must be a palette name: categorical %s; continuous %s",
                                paste(CATEGORICAL_PALETTES, collapse = ", "),
                                paste(CONTINUOUS_PALETTES, collapse = ", ")))
  }
  match
}

.check_limits <- function(value, arg, fn) {
  ok <- is.numeric(value) && length(value) == 2 && all(is.finite(value)) && value[1] < value[2]
  if (!ok) .abort_arg(fn, arg, "must be c(min, max), two numbers with min < max")
  unname(as.numeric(value))
}

.choice <- function(choices) {
  function(value, arg, fn) {
    if (!is.character(value) || !.is_scalar(value) || !(value %in% choices)) {
      .abort_arg(fn, arg, sprintf("must be one of %s", paste0('"', choices, '"', collapse = ", ")))
    }
    unname(value)
  }
}

#' Check for a mapping (color_by, size_by): a column name, or NULL / NA for
#' MiRA's default (stored as NULL, sent as JSON null)
#' @param keywords Keywords allowed here (e.g. ".set").
#' @keywords internal
#' @noRd
.mapping <- function(keywords = character()) {
  function(value, arg, fn) {
    if (is.null(value) || (.is_scalar(value) && is.na(value))) return(NULL)
    if (!is.character(value) || !.is_scalar(value) || !is.null(names(value)) || !nzchar(value)) {
      .abort_arg(fn, arg, "must be one column name, NULL or NA")
    }
    if (value %in% setdiff(KEYWORDS, keywords)) {
      .abort_arg(fn, arg, sprintf('"%s" is not available here', value))
    }
    value
  }
}

#' A check that also accepts a vector named by node_type (per set)
#'
#' A named value becomes a named list (a JSON object) with each element run
#' through `per_set_check` (for a mapping, an NA element becomes NULL, JSON
#' null: MiRA's default for that set).
#' @keywords internal
#' @noRd
.shared_or_per_set <- function(shared_check, per_set_check = shared_check) {
  function(value, arg, fn) {
    if (is.null(names(value))) return(shared_check(value, arg, fn))
    .check_set_names(names(value), arg, fn)
    labels <- names(value)
    per_set <- lapply(labels, function(label) {
      per_set_check(value[[label]], sprintf('%s["%s"]', arg, label), fn)
    })
    names(per_set) <- labels
    per_set
  }
}

# "layer_name" means one color per layer, MiRA's ".individual"
.layer_mapping <- function(value, arg, fn) {
  value <- .mapping(INDIVIDUAL_KEYWORD)(value, arg, fn)
  if (identical(value, LAYER_NAME_COLUMN)) INDIVIDUAL_KEYWORD else value
}

#' Check for color_values: colors named by value (a named character vector)
#' @param per_set Also accept a list of them named by node_type.
#' @keywords internal
#' @noRd
.check_color_values <- function(per_set) {
  function(value, arg, fn) {
    if (!(per_set && is.list(value) && !is.null(names(value)))) return(.check_value_colors(value, arg, fn))
    .check_set_names(names(value), arg, fn)
    is_named_vector <- function(v) is.character(v) && !is.null(names(v))
    if (!all(vapply(value, is_named_vector, logical(1)))) {
      .abort_arg(fn, arg, paste0('as a list gives one vector per node set, e.g. ',
                                 'list(pollinator = c("1" = "red")); for colors shared by both sets ',
                                 'give the vector itself: c("1" = "red", "2" = "blue")'))
    }
    per_set_values <- lapply(names(value), function(label) {
      .check_value_colors(value[[label]], sprintf('%s[["%s"]]', arg, label), fn)
    })
    names(per_set_values) <- names(value)
    per_set_values
  }
}

.check_value_colors <- function(value, arg, fn) {
  labels <- names(value)
  ok <- is.character(value) && length(value) > 0 && !is.null(labels) && !anyNA(labels) &&
    all(nzchar(labels)) && anyDuplicated(labels) == 0
  if (!ok) {
    .abort_arg(fn, arg, 'must be a character vector of colors named by value, e.g. c("1" = "red", "2" = "blue")')
  }
  colors <- vapply(labels, function(label) {
    .check_color(value[[label]], sprintf('%s["%s"]', arg, label), fn)
  }, character(1))
  names(colors) <- labels
  colors
}

# One pair c("L1", "L2") or a list of them; each pair becomes a JSON array.
# A pair given twice (in either order) is kept once.
.check_pairs <- function(value, arg, fn) {
  if (is.character(value)) value <- list(value)
  is_pair <- function(pair) is.character(pair) && length(pair) == 2 && !anyNA(pair)
  if (!is.list(value) || length(value) == 0 || !all(vapply(value, is_pair, logical(1)))) {
    .abort_arg(fn, arg, 'must be a list of layer-name pairs, e.g. list(c("L1", "L2"))')
  }
  pairs <- lapply(unname(value), function(pair) as.list(unname(pair)))
  if (any(vapply(pairs, function(pair) pair[[1]] == pair[[2]], logical(1)))) {
    .abort_arg(fn, arg, "a pair must be two different layers")
  }
  keys <- vapply(pairs, function(pair) paste(sort(unlist(pair)), collapse = "\u001f"), character(1))
  pairs[!duplicated(keys)]
}

.check_set_names <- function(labels, arg, fn) {
  if (anyNA(labels) || !all(nzchar(labels)) || anyDuplicated(labels) > 0) {
    .abort_arg(fn, arg, "names must be unique node_type values")
  }
}

# ---- Printing a piece -----------------------------------------------------------

#' Show a component as the call that would make it
#'
#' Colors are shown as the `"#rrggbb"` sent to MiRA, `NULL` mappings
#' (MiRA's default) as `NA`, and one color per layer as
#' `color_by = "layer_name"`.
#' @param x A component (class `mira_piece`).
#' @param ... Not used.
#' @return `format()`: one string. `print()`: `x`, invisibly.
#' @keywords internal
#' @export
#' @examples
#' mira_node(color_by = c(pollinator = "module", plant = NA), size = 8)
format.mira_piece <- function(x, ...) {
  fields <- x$fields
  if (identical(fields$color_by, INDIVIDUAL_KEYWORD)) fields$color_by <- LAYER_NAME_COLUMN
  if (x$section == "mode") fields$view <- NULL # the function's name says the view
  args <- vapply(names(fields), function(arg) {
    paste(arg, "=", .format_field(fields[[arg]]))
  }, character(1))
  sprintf("%s(%s)", x$fn, paste(args, collapse = ", "))
}

#' @rdname format.mira_piece
#' @export
print.mira_piece <- function(x, ...) {
  cat(format(x), "\n", sep = "")
  invisible(x)
}

.format_field <- function(value) {
  if (is.null(value)) return("NA")
  if (inherits(value, "mira_condition")) return(paste(trimws(deparse(value$expr)), collapse = " "))
  if (!is.list(value) && length(value) == 1 && is.null(names(value))) return(.format_scalar(value))
  items <- vapply(seq_along(value), function(i) .format_field(value[[i]]), character(1))
  if (!is.null(names(value))) items <- paste(vapply(names(value), .format_name, character(1)), "=", items)
  # Scalars (per-set values, named colors) make a vector; anything else a list
  is_scalar <- function(v) is.null(v) || (!is.list(v) && length(v) == 1 && is.null(names(v)))
  wrapper <- if (all(vapply(value, is_scalar, logical(1)))) "c" else "list"
  sprintf("%s(%s)", wrapper, paste(items, collapse = ", "))
}

.format_scalar <- function(value) {
  if (is.character(value)) encodeString(value, quote = '"') else as.character(value)
}

# A set name that is not a valid R name (e.g. "filter feeder") needs quotes
.format_name <- function(label) {
  if (identical(make.names(label), label)) label else encodeString(label, quote = '"')
}
