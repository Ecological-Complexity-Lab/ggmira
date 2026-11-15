# Color scales: color_values and color_scale in mira_node(),
# mira_intralayer(), mira_interlayer() and mira_layer().
#
# In R each component describes the colors of its own color_by. MiRA keeps
# one scale per attribute name, used wherever that attribute colors nodes,
# links or layers, so the spec sends them as one `scales` section:
# { <attr>: { type, values } }. Settings for the same attribute from
# different components are merged; when they disagree, the later one wins,
# with a warning. One color per layer (color_by = "layer_name") is not a
# scale: its colors go to the layer section as `colors`.

#' Scales: how data values become colors and sizes
#'
#' A scale turns the values of a mapped attribute into colors or sizes. In
#' ggmira the scale lives in the component that maps the attribute: in
#' [mira_node()], [mira_intralayer()], [mira_interlayer()] and [mira_layer()],
#' `color_by` chooses what is colored, and five arguments in the same call
#' choose the colors: `color_scale` (one color per value, or a gradient),
#' `color_palette` and `color_reverse` (which colors), `color_limits` (the
#' ends of a gradient) and `color_values` (colors given by hand).
#'
#' @section Color:
#' - `color_scale = "categorical"` gives each value its own color (MiRA's
#'   Dark2 palette); `"continuous"` a gradient (Viridis, from the column's
#'   minimum to its maximum; numeric columns only). Without it, MiRA decides
#'   from the data: text gets one color per value; numbers get a gradient
#'   when they have more than two values or a name that sounds like a
#'   measure (containing `weight`, `abundance`, `degree`, `strength`,
#'   `mass`, `size` or `value`), unless the name marks groups (`module`,
#'   `group`, `cluster`, `community`, `partition`). [mira_options()] shows
#'   the type MiRA picks for each attribute.
#' - `color_palette` chooses the palette by name (matched without case):
#'   - categorical: `"Dark2"` (MiRA's default), `"Set1"`, `"Set2"`,
#'     `"Set3"`, `"Paired"`, `"Accent"`, `"Okabe-Ito"` (colorblind-safe).
#'     Columns with more values than colors reuse them, so two values can
#'     share a color (the palettes have 8 to 12 colors).
#'   - continuous, sequential: `"viridis"` (MiRA's default), `"magma"`,
#'     `"cividis"` (colorblind-optimized), `"Blues"`, `"Greens"`, `"Reds"`,
#'     `"Purples"`, `"Oranges"`, `"Greys"`, `"YlOrRd"`, `"YlGnBu"`.
#'   - continuous, diverging (two sides of a middle): `"RdBu"`, `"RdYlBu"`,
#'     `"Spectral"`, `"PiYG"`, `"BrBG"`, `"PuOr"`.
#'
#'   A categorical palette gives a categorical scale and a continuous one a
#'   gradient, so `color_scale` is not needed with it. `color_reverse = TRUE`
#'   reverses the palette (light to dark, or the two sides of a diverging
#'   one). In MiRA, the legend has the same choices.
#' - `color_limits = c(min, max)` sets the ends of a gradient instead of the
#'   data's range, so several plots can share one scale (e.g. 0 to 1 for
#'   proportions); values outside take the end colors. With a diverging
#'   palette, limits centered on 0 put the middle color at 0. It gives a
#'   continuous scale.
#' - Palettes and limits need no values, so they also work for the
#'   attributes MiRA computes (`intra_degree_sum`, ...).
#' - `color_values` sets the colors of some values, named by value:
#'   `c("1" = "red", "3" = "#1f77b4")` (numbers need quotes as names). Values
#'   not listed keep the palette's color. It gives a categorical scale, so it
#'   cannot be combined with `color_scale = "continuous"`.
#' - On a bipartite network, `mira_node()` takes all five per node set:
#'   `color_scale = c(bird = "continuous")`,
#'   `color_palette = c(bird = "magma")`, `color_reverse = c(bird = TRUE)`,
#'   `color_limits = list(bird = c(0, 10))`,
#'   `color_values = list(plant = c(species = "blue"))`. They differ between
#'   the sets only when the sets are colored by different attributes (one
#'   scale per attribute name, below).
#' - Two special mappings take colors named by element rather than by
#'   value: `mira_layer(color_by = "layer_name", color_values = c(L1 = "red"))`
#'   colors layers one by one, and
#'   `mira_node(color_by = ".set", color_values = c(bird = "red"))` colors
#'   the two node sets. These two are not scales: they take `color_values`
#'   only, and `color_scale`, `color_palette`, `color_reverse` and
#'   `color_limits` with them are errors.
#'
#' **One scale per attribute name.** MiRA keeps one color scale (type,
#' palette, reversal, limits and colors) per attribute name, used wherever
#' that attribute colors nodes, links or
#' layers (as in MiRA's legends, where changing a color changes it for every
#' element). So when two components color by the same attribute name, their
#' settings are merged: a value that appears in both tables (node `module`
#' 1 and link `module` 1) has one color. If the components disagree (a value
#' given two colors, or two scale types), the later one wins, with a
#' warning; a continuous scale cannot be combined with `color_values` for the
#' same attribute (an error). A `color`, or a `color_by` of a different
#' column, drops that component's earlier `color_values` and `color_scale`.
#'
#' @section Size:
#' `mira_node(size_by = )` sizes nodes by a numeric attribute, scaled by
#' MiRA from the smallest to the largest value; `size` sets the base size
#' (and the only size, without `size_by`). Link width always follows the
#' `weight` column, which is why `weight` cannot color links. A size range
#' from R is planned.
#'
#' @name mira_scales
#' @seealso [mira()] for how components combine.
#' @examplesIf requireNamespace("emln", quietly = TRUE)
#' library(emln)
#' net <- load_emln(17) # 4 layers; bird and plant nodes
#' p <- mira(net, bipartite = TRUE, setA_type = "bird")
#'
#' # Colors of some values; the others keep MiRA's palette
#' p + mira_node(color_by = "verification_level",
#'               color_values = c(species = "#1f77b4", genus = "orange"))
#'
#' # The same numeric attribute as a gradient, or one color per value
#' p + mira_node(color_by = "intra_degree_sum", color_scale = "continuous")
#' p + mira_node(color_by = "intra_degree_sum", color_scale = "categorical")
#'
#' # A palette, reversed; a gradient with fixed ends
#' p + mira_node(color_by = "verification_level", color_palette = "Okabe-Ito")
#' p + mira_node(color_by = "intra_degree_sum", color_palette = "magma", color_reverse = TRUE)
#' p + mira_node(color_by = "intra_degree_sum", color_palette = "cividis", color_limits = c(0, 30))
#' p + mira_intralayer(color_by = "type", color_palette = "Set1")
#'
#' # Per node set
#' p + mira_node(color_by = c(bird = "intra_degree_sum", plant = "verification_level"),
#'               color_scale = c(bird = "continuous"),
#'               color_values = list(plant = c(species = "blue")))
#'
#' # One color per layer; the colors of the two node sets
#' p + mira_layer(color_by = "layer_name", color_values = c(layer_1 = "orange"))
#' p + mira_node(color_by = ".set", color_values = c(bird = "red", plant = "green"))
#'
#' # Size by an attribute, from a base size
#' p + mira_node(size_by = "intra_degree_sum", size = 6)
NULL

COLOR_SCALE_FIELDS <- c("color_values", "color_scale", "color_palette", "color_reverse", "color_limits")
# MiRA's named palettes (js/palettes.js), by scale type
CATEGORICAL_PALETTES <- c("Dark2", "Set1", "Set2", "Set3", "Paired", "Accent", "Okabe-Ito")
CONTINUOUS_PALETTES <- c("viridis", "magma", "cividis", "Blues", "Greens", "Reds", "Purples",
                         "Oranges", "Greys", "YlOrRd", "YlGnBu", # sequential
                         "RdBu", "RdYlBu", "Spectral", "PiYG", "BrBG", "PuOr") # diverging
COLOR_FIELDS <- c("color_by", "color", COLOR_SCALE_FIELDS)
LINK_SECTIONS <- c("intralayer", "interlayer")
WEIGHT_COLUMN <- "weight" # MiRA does not color links by it (yet)

SCALE_PARTS <- c("type", "values", "palette", "reverse", "limits")
SCALE_KEY_SEP <- "\u001f" # joins section, attribute and part in plot$scale_order

#' Update the plot's scales after a piece was merged into its section
#'
#' Checks the merged section (errors), then the scale settings the piece
#' itself gives against the network and against the scales of the other
#' sections (warnings), and records those settings as the latest in
#' `plot$scale_order` (the latest wins in mira_spec()). A piece that gives
#' no scale setting changes nothing here, so earlier warnings are not
#' repeated and the order stays.
#' @keywords internal
#' @noRd
.update_scales <- function(plot, piece) {
  if (!any(COLOR_FIELDS %in% names(piece$fields))) return(plot)
  name <- piece$section
  section <- .drop_weight_color(plot$spec[[name]], name)
  .section_scales(section, piece$fn, plot)
  if (!any(COLOR_SCALE_FIELDS %in% names(piece$fields))) return(plot)
  own <- section
  for (field in setdiff(COLOR_SCALE_FIELDS, names(piece$fields))) own[[field]] <- NULL
  scales <- .section_scales(own, piece$fn, plot, warn = TRUE)
  if (length(scales) == 0) return(plot)
  .warn_scale_values(scales, name, piece$fn, plot$net)
  for (other in setdiff(.scale_sections(plot), name)) {
    other_scales <- .section_scales(.drop_weight_color(plot$spec[[other]], other), NULL, plot)
    for (attr in intersect(names(scales), names(other_scales))) {
      .check_scale_conflict(scales[[attr]], other_scales[[attr]], attr, piece$fn,
                            sprintf("in mira_%s()", other))
    }
  }
  keys <- .scale_keys(name, scales)
  plot$scale_order <- c(setdiff(plot$scale_order, keys), keys)
  plot
}

# One key per setting a section's scales give: section, attribute, part
.scale_keys <- function(name, scales) {
  keys <- character()
  for (attr in names(scales)) {
    for (part in SCALE_PARTS) {
      if (!is.null(scales[[attr]][[part]])) keys <- c(keys, paste(name, attr, part, sep = SCALE_KEY_SEP))
    }
  }
  keys
}

.scale_sections <- function(plot) {
  unique(vapply(strsplit(plot$scale_order, SCALE_KEY_SEP, fixed = TRUE), `[[`, character(1), 1))
}

#' The scales a section sets: list(<attr> = list(type, values))
#'
#' @param fn The piece's function name, for errors; NULL when the section was
#'   already checked (when its piece was added), so it cannot fail.
#' @param warn Warn when two sets of a bipartite network give the same
#'   attribute different colors or scale types (the later set wins).
#' @keywords internal
#' @noRd
.section_scales <- function(section, fn, plot, warn = FALSE) {
  if (!any(COLOR_SCALE_FIELDS %in% names(section))) return(list())
  if (identical(section$color_by, INDIVIDUAL_KEYWORD)) {
    .check_layer_colors(section, fn, plot)
    return(list()) # sent as layer colors, not as a scale
  }
  if (identical(section$color_by, SET_KEYWORD)) return(.set_colors(section, fn, plot))
  scales <- list()
  set_of <- list() # attr -> the set that last set it
  for (set in .scale_sets(section, fn)) {
    attr <- .per_set(section$color_by, set)
    if (is.null(attr) || attr %in% KEYWORDS) {
      .abort_piece(fn, sprintf("`color_values` and `color_scale` need a column in `color_by`%s",
                               .set_suffix(set)))
    }
    scale <- list(type = .per_set(section$color_scale, set),
                  values = .per_set(section$color_values, set),
                  palette = .per_set(section$color_palette, set),
                  reverse = .per_set(section$color_reverse, set),
                  limits = .per_set(section$color_limits, set))
    scale$type <- .scale_type(scale, fn, set)
    if (warn && !is.null(scales[[attr]])) {
      .check_scale_conflict(scale, scales[[attr]], attr, fn, sprintf('for set "%s"', set_of[[attr]]))
    }
    scales <- .combine_scales(scales, stats::setNames(list(scale), attr))
    set_of[[attr]] <- set
  }
  scales
}

#' The scale type a scale's settings give: color_scale, or the one its
#' palette, limits or values need. Settings that need different types are an
#' error (fn is NULL when the section was already checked).
#' @keywords internal
#' @noRd
.scale_type <- function(scale, fn, set) {
  needs <- c(
    color_scale   = scale$type,
    color_palette = if (!is.null(scale$palette)) .palette_type(scale$palette),
    color_limits  = if (!is.null(scale$limits)) "continuous",
    color_values  = if (!is.null(scale$values)) "categorical"
  )
  if (length(unique(needs)) > 1 && !is.null(fn)) {
    if (identical(scale$type, "continuous") && !is.null(scale$values)) {
      .abort_piece(fn, '`color_values` need a categorical scale, not color_scale = "continuous"')
    }
    shown <- sprintf("`%s` (%s)", names(needs), needs)
    .abort_piece(fn, sprintf("these need different scale types%s: %s", .set_suffix(set),
                             paste(shown, collapse = ", ")))
  }
  if (length(needs) == 0) NULL else unname(needs[length(needs)])
}

.palette_type <- function(palette) {
  if (palette %in% CONTINUOUS_PALETTES) "continuous" else "categorical"
}

#' The sets a section's color settings apply to: NA for a shared color_by;
#' else the node_type names used by per-set settings, or, when the settings
#' are shared, every set with a color_by
#' @keywords internal
#' @noRd
.scale_sets <- function(section, fn) {
  per_set <- Filter(is.list, section[COLOR_SCALE_FIELDS])
  if (!is.list(section$color_by)) {
    if (length(per_set) > 0) {
      .abort_piece(fn, "per-set `color_values` and `color_scale` need a per-set `color_by`")
    }
    return(NA)
  }
  if (length(per_set) == 0) return(names(Filter(Negate(is.null), section$color_by)))
  unique(unlist(lapply(per_set, names)))
}

# A setting for one set: the per-set value, or the shared one (set = NA)
.per_set <- function(value, set) {
  if (is.list(value) && !is.na(set)) value[[set]] else if (is.list(value)) NULL else value
}

.set_suffix <- function(set) if (is.na(set)) "" else sprintf(' for "%s"', set)

#' Node color by set membership: `color_values` named by the two node_type
#' values color the sets; sent as the scale of ".set". No scale type.
#' @keywords internal
#' @noRd
.set_colors <- function(section, fn, plot) {
  if (!is.null(fn)) {
    if (!is.null(section$color_scale)) {
      .abort_piece(fn, '`color_scale` does not apply to color_by = ".set"')
    }
    .abort_palette_fields(section, fn, 'color_by = ".set"')
    if (is.list(section$color_values)) {
      .abort_piece(fn, 'with color_by = ".set", `color_values` are named by node set: c(pollinator = "red")')
    }
    unknown <- setdiff(names(section$color_values), plot$set_types)
    if (length(unknown) > 0) {
      .abort_arg(fn, "color_values", sprintf("with color_by = \".set\" must use node_type values (%s); not: %s",
                                             paste(plot$set_types, collapse = ", "),
                                             paste(unknown, collapse = ", ")))
    }
  }
  if (is.null(section$color_values)) return(list())
  stats::setNames(list(list(values = section$color_values)), SET_KEYWORD)
}

# Links colored by weight: R has warned that MiRA keeps its default, so
# neither the mapping nor its scale is sent
.drop_weight_color <- function(section, name) {
  if (name %in% LINK_SECTIONS && identical(section$color_by, WEIGHT_COLUMN)) {
    section[c("color_by", COLOR_SCALE_FIELDS)] <- NULL
  }
  section
}

.check_layer_colors <- function(section, fn, plot) {
  if (is.null(fn)) return()
  if (!is.null(section$color_scale)) {
    .abort_piece(fn, '`color_scale` does not apply to one color per layer (color_by = "layer_name")')
  }
  .abort_palette_fields(section, fn, 'one color per layer (color_by = "layer_name")')
  .check_layer_names(names(section$color_values), "color_values", fn, plot)
}

# Palettes, reversal and limits belong to a scale of a column
.abort_palette_fields <- function(section, fn, what) {
  given <- intersect(c("color_palette", "color_reverse", "color_limits"), names(section))
  if (length(given) > 0) {
    .abort_piece(fn, sprintf("`%s` does not apply to %s; give colors with `color_values`", given[1], what))
  }
}

.check_layer_names <- function(names, arg, fn, plot) {
  layers <- as.character(plot$net$layers$layer_name)
  unknown <- setdiff(names, layers)
  if (length(unknown) == 0) return()
  .abort_arg(fn, arg, sprintf("must use layer_name values (%s); not: %s",
                              paste(layers, collapse = ", "), paste(unknown, collapse = ", ")))
}

#' Merge scales: for each attribute, a later type replaces an earlier one and
#' later colors replace earlier colors for the same value
#' @keywords internal
#' @noRd
.combine_scales <- function(scales, later) {
  for (attr in names(later)) {
    old <- scales[[attr]]
    new <- later[[attr]]
    values <- c(old$values[setdiff(names(old$values), names(new$values))], new$values)
    later_or <- function(part) if (is.null(new[[part]])) old[[part]] else new[[part]]
    scales[[attr]] <- list(type = later_or("type"),
                           values = if (length(values) > 0) values else NULL,
                           palette = later_or("palette"), reverse = later_or("reverse"),
                           limits = later_or("limits"))
  }
  scales
}

#' A new scale against an earlier one for the same attribute
#'
#' A continuous scale and manual colors cannot be combined (as within one
#' piece): error. A different scale type or a different color for the same
#' value is a warning; the new setting wins.
#' @param other Where the earlier setting comes from, e.g. `in mira_node()`
#'   or `for set "plant"`.
#' @keywords internal
#' @noRd
.check_scale_conflict <- function(new, old, attr, fn, other) {
  if (identical(new$type, "continuous") && !is.null(old$values)) {
    .abort_piece(fn, sprintf('color_scale = "continuous" for "%s" cannot be combined with the color_values %s',
                             attr, other))
  }
  if (!is.null(new$values) && identical(old$type, "continuous")) {
    .abort_piece(fn, sprintf('color_values for "%s" cannot be combined with color_scale = "continuous" %s',
                             attr, other))
  }
  if (!is.null(new$type) && !is.null(old$type) && new$type != old$type) {
    .warn_replaces(fn, sprintf('color_scale "%s" for "%s"', new$type, attr), other)
  }
  for (part in c("palette", "reverse", "limits")) {
    if (!is.null(new[[part]]) && !is.null(old[[part]]) && !identical(new[[part]], old[[part]])) {
      .warn_replaces(fn, sprintf('color_%s for "%s"', part, attr), other)
    }
  }
  shared <- intersect(names(new$values), names(old$values))
  changed <- shared[new$values[shared] != old$values[shared]]
  if (length(changed) > 0) {
    .warn_replaces(fn, sprintf('color_values "%s" for "%s"', paste(changed, collapse = '", "'), attr),
                   other)
  }
}

.warn_replaces <- function(fn, what, other) {
  warning(sprintf("%s(): %s replaces the setting %s; MiRA keeps one color scale per attribute",
                  fn, what, other), call. = FALSE)
}

#' Values that are not in the column, and continuous scales on text columns
#'
#' Computed attributes (degree, strength) are not checked: their values exist
#' only in MiRA.
#' @keywords internal
#' @noRd
.warn_scale_values <- function(scales, section_name, fn, net) {
  for (attr in names(scales)) {
    column <- .scale_column(attr, section_name, net)
    if (is.null(column)) next
    unknown <- setdiff(names(scales[[attr]]$values), as.character(unique(column)))
    if (length(unknown) > 0) {
      warning(sprintf('%s(): `color_values`: "%s" is not a value of "%s"', fn,
                      paste(unknown, collapse = '", "'), attr), call. = FALSE)
    }
    if (identical(scales[[attr]]$type, "continuous") && !.looks_numeric(column)) {
      warning(sprintf('%s(): `color_scale`: "%s" is not numeric; MiRA uses a categorical scale',
                      fn, attr), call. = FALSE)
    }
  }
}

# The data column an attribute comes from; NULL when there is none.
# "node_type" is the converter's name for the type column (type, node_group).
.scale_column <- function(attr, section_name, net) {
  if (attr %in% KEYWORDS) return(NULL)
  switch(section_name,
    node = {
      column <- if (attr == "node_type") .type_column(net$nodes) else attr
      if (is.na(column)) NULL else c(net$nodes[[column]], net$state_nodes[[attr]])
    },
    layer = net$layers[[attr]],
    net$extended[[attr]]
  )
}

#' The spec as MiRA receives it: color settings become `scales` (and layer
#' `colors`)
#'
#' Each setting in `plot$scale_order` is taken from its section's current
#' scales (a setting dropped by a later mapping is skipped), the latest
#' last, so for each attribute the latest type and the latest color of a
#' value win.
#' @keywords internal
#' @noRd
.spec_for_mira <- function(plot) {
  spec <- plot$spec
  for (name in intersect(LINK_SECTIONS, names(spec))) {
    spec[[name]] <- .drop_weight_color(spec[[name]], name)
  }
  sections <- lapply(spec[.scale_sections(plot)], .section_scales, fn = NULL, plot = plot)
  scales <- list()
  for (key in plot$scale_order) {
    parts <- strsplit(key, SCALE_KEY_SEP, fixed = TRUE)[[1]]
    setting <- sections[[parts[1]]][[parts[2]]][[parts[3]]]
    if (is.null(setting)) next
    scales <- .combine_scales(scales, stats::setNames(list(stats::setNames(list(setting), parts[3])), parts[2]))
  }
  for (attr in names(scales)) { # R has warned; MiRA would use a categorical scale anyway
    if (identical(scales[[attr]]$type, "continuous") && !.numeric_attr(attr, plot$net)) {
      scales[[attr]] <- NULL
    }
  }
  layer <- spec$layer
  if (identical(layer$color_by, INDIVIDUAL_KEYWORD) && !is.null(layer$color_values)) {
    spec$layer$colors <- as.list(layer$color_values)
  }
  spec <- lapply(spec, function(section) section[setdiff(names(section), COLOR_SCALE_FIELDS)])
  spec <- Filter(length, spec)
  if (length(scales) > 0) spec$scales <- lapply(scales, .scale_json)
  spec
}

# Whether an attribute is numeric in the table that has it; TRUE when no
# table has it (MiRA's computed attributes are numeric)
.numeric_attr <- function(attr, net) {
  for (table in list(net$nodes, net$state_nodes, net$extended, net$layers)) {
    if (!is.null(table[[attr]])) return(.looks_numeric(table[[attr]]))
  }
  TRUE
}

.scale_json <- function(scale) {
  json <- list()
  if (!is.null(scale$type)) json$type <- scale$type
  if (!is.null(scale$values)) json$values <- as.list(scale$values)
  if (!is.null(scale$palette)) json$palette <- scale$palette
  if (!is.null(scale$reverse)) json$reverse <- scale$reverse
  if (!is.null(scale$limits)) json$limits <- as.list(scale$limits)
  json
}
