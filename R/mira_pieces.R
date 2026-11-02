# The grammar pieces. Each mira_*() function records only the arguments it
# was given, as one section of the view spec (contract: dev/ggmira/view-spec.md
# on MiRA's development branch). Checks that need no network run here;
# checks against the network run when the piece is added to a plot
# (mira_validate.R).

LAYOUT_TYPES <- c("fruchterman", "kamada_kawai", "bipartite", "circle", "grid", "random")
SHAPES <- c("circle", "square")
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

#' Layout of a mira plot
#'
#' Chooses MiRA's network layout. Add it to a plot made with [mira()].
#'
#' @param type One of `"fruchterman"`, `"kamada_kawai"`, `"bipartite"`,
#'   `"circle"`, `"grid"`, `"random"`. `"bipartite"` needs
#'   `mira(..., bipartite = TRUE)`.
#' @param seed A whole number. The same seed and the same data give the same
#'   node positions, so a figure can be reproduced.
#' @param nested `TRUE` or `FALSE`. Bipartite layout only: sort nodes by
#'   degree (nested order).
#' @return A `mira_piece`, to add to a plot with `+`.
#' @seealso [mira()]
#' @export
#' @examples
#' mira_layout("kamada_kawai", seed = 42)
mira_layout <- function(type, seed, nested) {
  .build_piece("layout", "mira_layout", environment(), list(
    type   = .choice(LAYOUT_TYPES),
    seed   = .check_seed,
    nested = .check_flag
  ))
}

#' Node style of a mira plot
#'
#' Maps node color and size to node attributes, or sets them to constants.
#' Add it to a plot made with [mira()].
#'
#' **Per set.** On a bipartite network (`mira(..., bipartite = TRUE)`),
#' `color_by`, `size_by`, `shape` and `color_scale` also take a vector named
#' by the `node_type` values, giving each set its own setting, e.g.
#' `color_by = c(pollinator = "module", plant = NA)`; `color_values` takes a
#' list named the same way, `list(pollinator = c("1" = "red"))`. When color
#' or size is per set and `shape` is not given, MiRA draws one set as
#' circles and the other as squares.
#'
#' @param color_by Column to color nodes by: a node or state-node column
#'   (e.g. `"module"`) or a MiRA-computed attribute (e.g.
#'   `"intra_degree_sum"`). `".set"` colors by set membership (bipartite
#'   networks). `NULL` or `NA` = MiRA's default.
#' @param color A constant node color: a color name (`"red"`) or `"#rrggbb"`.
#'   Give `color_by` or `color`, not both.
#' @param size_by Numeric column to size nodes by. `NULL` or `NA` = default.
#' @param size Base node size, a whole number between 3 and 25.
#' @param shape `"circle"` or `"square"`.
#' @param labels `TRUE` or `FALSE`: show node names.
#' @param label_size Node name size, a whole number between 8 and 24.
#' @param perspective `TRUE` or `FALSE`: draw nodes in the layers' 3D
#'   perspective (MiRA's default) or flat.
#' @param color_values Colors for values of the `color_by` column, named by
#'   value: `c("1" = "red", "3" = "#1f77b4")`. Values not listed keep MiRA's
#'   palette. Gives a categorical scale. Per set:
#'   `list(pollinator = c(...))`. See **Color scales** in [mira()].
#' @param color_scale `"categorical"` (one color per value) or
#'   `"continuous"` (a gradient; numeric columns only). Without it, MiRA
#'   decides from the data. Per set: `c(pollinator = "continuous")`.
#' @return A `mira_piece`, to add to a plot with `+`.
#' @seealso [mira()]
#' @export
#' @examples
#' mira_node(color_by = "module", size = 10)
#' mira_node(color = "steelblue", shape = "square")
#' mira_node(color_by = c(pollinator = "module", plant = NA))
#' mira_node(color_by = "module", color_values = c("1" = "red", "3" = "#1f77b4"))
#' mira_node(labels = TRUE, label_size = 14)
mira_node <- function(color_by, color, size_by, size, shape, labels, label_size, perspective,
                      color_values, color_scale) {
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
    color_scale  = .shared_or_per_set(.choice(SCALE_TYPES))
  ))
}

#' Intralayer link style of a mira plot
#'
#' @param color_by Link column to color intralayer links by. `NULL` or `NA`
#'   = default.
#' @param color A constant link color: a color name or `"#rrggbb"`. Give
#'   `color_by` or `color`, not both.
#' @param min_weight Hide links with weight below this value (0 or more,
#'   in the units of the data's `weight` column).
#' @param arrow_size Arrowhead size, between 0 and 3 (1 = MiRA's default).
#'   Directed networks only. MiRA has one arrowhead size, so this also sizes
#'   the arrowheads of directed interlayer links.
#' @param color_values Colors for values of the `color_by` column, named by
#'   value. See [mira_node()] and **Color scales** in [mira()].
#' @param color_scale `"categorical"` or `"continuous"`. See [mira_node()].
#' @return A `mira_piece`, to add to a plot with `+`.
#' @seealso [mira()]
#' @export
#' @examples
#' mira_intralayer(color = "grey60", min_weight = 0.1)
mira_intralayer <- function(color_by, color, min_weight, arrow_size, color_values, color_scale) {
  .build_piece("intralayer", "mira_intralayer", environment(), list(
    color_by     = .mapping(),
    color        = .check_color,
    min_weight   = .number_at_least(WEIGHT_MIN),
    arrow_size   = .number_in(ARROW_SIZE_MIN, ARROW_SIZE_MAX),
    color_values = .check_color_values(per_set = FALSE),
    color_scale  = .choice(SCALE_TYPES)
  ))
}

#' Interlayer link style of a mira plot
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
#'   not matter. Also turns interlayer links on, unless the same piece gives
#'   `show = FALSE`.
#' @return A `mira_piece`, to add to a plot with `+`.
#' @seealso [mira()]
#' @export
#' @examples
#' mira_interlayer(show = TRUE, color = "red")
#' mira_interlayer(pairs = list(c("L1", "L2")), curvature = 0.6)
mira_interlayer <- function(show, color_by, color, min_weight, curvature, pairs, color_values,
                            color_scale) {
  .build_piece("interlayer", "mira_interlayer", environment(), list(
    show         = .check_flag,
    color_by     = .mapping(),
    color        = .check_color,
    min_weight   = .number_at_least(WEIGHT_MIN),
    curvature    = .number_in(CURVATURE_MIN, CURVATURE_MAX),
    pairs        = .check_pairs,
    color_values = .check_color_values(per_set = FALSE),
    color_scale  = .choice(SCALE_TYPES)
  ))
}

#' Layer style of a mira plot
#'
#' @param color_by Layer column to color layers by, or `"layer_name"` for
#'   one color per layer (`".individual"` works too). `NULL` or `NA` =
#'   default.
#' @param color A constant layer color: a color name or `"#rrggbb"`. Give
#'   `color_by` or `color`, not both.
#' @param color_values Colors for values of the `color_by` column, named by
#'   value. With `color_by = "layer_name"`, named by layer:
#'   `c(L1 = "red", L3 = "#1f77b4")`; layers not listed keep MiRA's color.
#'   See **Color scales** in [mira()].
#' @param color_scale `"categorical"` or `"continuous"`. Not with
#'   `color_by = "layer_name"`.
#' @param labels `TRUE` or `FALSE`: show layer names.
#' @param label_size Layer name size, a whole number between 8 and 32.
#' @param set_labels `TRUE` or `FALSE`: show node set names (bipartite
#'   layout only; needs `mira(..., bipartite = TRUE)`).
#' @param stack `"horizontal"` or `"vertical"`: how layers are stacked.
#' @param spacing Space between layers, a whole number between 100 and 600
#'   (300 = MiRA's default).
#' @return A `mira_piece`, to add to a plot with `+`.
#' @seealso [mira()]
#' @export
#' @examples
#' mira_layer(color_by = "layer_name", color_values = c(L1 = "red"))
#' mira_layer(labels = TRUE, stack = "vertical", spacing = 200)
mira_layer <- function(color_by, color, color_values, color_scale, labels, label_size, set_labels,
                       stack, spacing) {
  .build_piece("layer", "mira_layer", environment(), list(
    color_by     = .layer_mapping,
    color        = .check_color,
    color_values = .check_color_values(per_set = FALSE),
    color_scale  = .choice(SCALE_TYPES),
    labels       = .check_flag,
    label_size   = .whole_number_in(LAYER_LABEL_SIZE_MIN, LAYER_LABEL_SIZE_MAX),
    set_labels   = .check_flag,
    stack        = .choice(STACK_MODES),
    spacing      = .whole_number_in(LAYER_SPACING_MIN, LAYER_SPACING_MAX)
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

#' Show a piece as the call that would make it
#'
#' Colors are shown as the `"#rrggbb"` sent to MiRA, `NULL` mappings
#' (MiRA's default) as `NA`, and one color per layer as
#' `color_by = "layer_name"`.
#' @param x A `mira_piece`.
#' @param ... Not used.
#' @return `format()`: one string. `print()`: `x`, invisibly.
#' @keywords internal
#' @export
#' @examples
#' mira_node(color_by = c(pollinator = "module", plant = NA), size = 8)
format.mira_piece <- function(x, ...) {
  fields <- x$fields
  if (identical(fields$color_by, INDIVIDUAL_KEYWORD)) fields$color_by <- LAYER_NAME_COLUMN
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
