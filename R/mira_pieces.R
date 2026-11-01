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

# Keywords that are not column names
SET_KEYWORD <- ".set"               # node color by set membership
INDIVIDUAL_KEYWORD <- ".individual" # one color per layer
KEYWORDS <- c(SET_KEYWORD, INDIVIDUAL_KEYWORD)

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
#' `color_by`, `size_by` and `shape` also take a vector named by the
#' `node_type` values, giving each set its own setting, e.g.
#' `color_by = c(pollinator = "module", plant = NA)`. When color or size is
#' per set and `shape` is not given, MiRA draws one set as circles and the
#' other as squares.
#'
#' @param color_by Column to color nodes by: a node or state-node column
#'   (e.g. `"module"`) or a MiRA-computed attribute (e.g.
#'   `"intra_degree_sum"`). `".set"` colors by set membership (bipartite
#'   networks). `NULL` or `NA` = MiRA's default.
#' @param color A constant node color: a color name (`"red"`) or `"#rrggbb"`.
#'   Give `color_by` or `color`, not both.
#' @param size_by Numeric column to size nodes by. `NULL` or `NA` = default.
#' @param size Base node size, between 3 and 25.
#' @param shape `"circle"` or `"square"`.
#' @return A `mira_piece`, to add to a plot with `+`.
#' @seealso [mira()]
#' @export
#' @examples
#' mira_node(color_by = "module", size = 10)
#' mira_node(color = "steelblue", shape = "square")
#' mira_node(color_by = c(pollinator = "module", plant = NA))
mira_node <- function(color_by, color, size_by, size, shape) {
  .build_piece("node", "mira_node", environment(), list(
    color_by = .shared_or_per_set(.mapping(SET_KEYWORD), .mapping()),
    color    = .check_color,
    size_by  = .shared_or_per_set(.mapping()),
    size     = .number_in(NODE_SIZE_MIN, NODE_SIZE_MAX),
    shape    = .shared_or_per_set(.choice(SHAPES))
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
#' @return A `mira_piece`, to add to a plot with `+`.
#' @seealso [mira()]
#' @export
#' @examples
#' mira_intralayer(color = "grey60", min_weight = 0.1)
mira_intralayer <- function(color_by, color, min_weight) {
  .build_piece("intralayer", "mira_intralayer", environment(), list(
    color_by   = .mapping(),
    color      = .check_color,
    min_weight = .number_at_least(WEIGHT_MIN)
  ))
}

#' Interlayer link style of a mira plot
#'
#' @param show `TRUE` or `FALSE`: draw interlayer links.
#' @inheritParams mira_intralayer
#' @param color_by Link column to color interlayer links by. `NULL` or `NA`
#'   = default.
#' @return A `mira_piece`, to add to a plot with `+`.
#' @seealso [mira()]
#' @export
#' @examples
#' mira_interlayer(show = TRUE, color = "red")
mira_interlayer <- function(show, color_by, color, min_weight) {
  .build_piece("interlayer", "mira_interlayer", environment(), list(
    show       = .check_flag,
    color_by   = .mapping(),
    color      = .check_color,
    min_weight = .number_at_least(WEIGHT_MIN)
  ))
}

#' Layer style of a mira plot
#'
#' @param color_by Layer column to color layers by, or `".individual"` for
#'   one color per layer. `NULL` or `NA` = default.
#' @param color A constant layer color: a color name or `"#rrggbb"`. Give
#'   `color_by` or `color`, not both.
#' @return A `mira_piece`, to add to a plot with `+`.
#' @seealso [mira()]
#' @export
#' @examples
#' mira_layer(color_by = ".individual")
mira_layer <- function(color_by, color) {
  .build_piece("layer", "mira_layer", environment(), list(
    color_by = .mapping(INDIVIDUAL_KEYWORD),
    color    = .check_color
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
#' through `per_set_check`; NA elements become NULL (JSON null).
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

.check_set_names <- function(labels, arg, fn) {
  if (anyNA(labels) || !all(nzchar(labels)) || anyDuplicated(labels) > 0) {
    .abort_arg(fn, arg, "names must be unique node_type values")
  }
}

# ---- Printing a piece -----------------------------------------------------------

#' Show a piece as the call that would make it
#'
#' Colors are shown as the `"#rrggbb"` sent to MiRA, and `NULL` mappings
#' (MiRA's default) as `NA`.
#' @param x A `mira_piece`.
#' @param ... Not used.
#' @return `format()`: one string. `print()`: `x`, invisibly.
#' @keywords internal
#' @export
#' @examples
#' mira_node(color_by = c(pollinator = "module", plant = NA), size = 8)
format.mira_piece <- function(x, ...) {
  args <- vapply(names(x$fields), function(arg) {
    paste(arg, "=", .format_field(x$fields[[arg]]))
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
  if (!is.list(value)) return(.format_scalar(value))
  per_set <- vapply(names(value), function(label) {
    paste(.format_name(label), "=", .format_field(value[[label]]))
  }, character(1))
  sprintf("c(%s)", paste(per_set, collapse = ", "))
}

.format_scalar <- function(value) {
  if (is.character(value)) encodeString(value, quote = '"') else as.character(value)
}

# A set name that is not a valid R name (e.g. "filter feeder") needs quotes
.format_name <- function(label) {
  if (identical(make.names(label), label)) label else encodeString(label, quote = '"')
}
