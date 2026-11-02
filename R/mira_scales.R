# Color scales: color_values and color_scale in mira_node(),
# mira_intralayer(), mira_interlayer() and mira_layer().
#
# In R each piece describes the colors of its own color_by. MiRA keeps one
# scale per attribute name, used wherever that attribute colors nodes, links
# or layers, so the spec sends them as one `scales` section:
# { <attr>: { type, values } }. Settings for the same attribute from
# different pieces are merged; when they disagree, the later piece wins, with
# a warning. One color per layer (color_by = "layer_name") is not a scale: its
# colors go to the layer section as `colors`.

COLOR_SCALE_FIELDS <- c("color_values", "color_scale")
COLOR_FIELDS <- c("color_by", "color", COLOR_SCALE_FIELDS)
LINK_SECTIONS <- c("intralayer", "interlayer")
WEIGHT_COLUMN <- "weight" # MiRA does not color links by it (yet)

SCALE_PARTS <- c("type", "values")
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
  scales <- list()
  set_of <- list() # attr -> the set that last set it
  for (set in .scale_sets(section, fn)) {
    attr <- .per_set(section$color_by, set)
    if (is.null(attr) || attr %in% KEYWORDS) {
      .abort_piece(fn, sprintf("`color_values` and `color_scale` need a column in `color_by`%s",
                               .set_suffix(set)))
    }
    scale <- list(type = .per_set(section$color_scale, set),
                  values = .per_set(section$color_values, set))
    if (!is.null(scale$values)) {
      if (identical(scale$type, "continuous")) {
        .abort_piece(fn, '`color_values` need a categorical scale, not color_scale = "continuous"')
      }
      scale$type <- "categorical"
    }
    if (warn && !is.null(scales[[attr]])) {
      .check_scale_conflict(scale, scales[[attr]], attr, fn, sprintf('for set "%s"', set_of[[attr]]))
    }
    scales <- .combine_scales(scales, stats::setNames(list(scale), attr))
    set_of[[attr]] <- set
  }
  scales
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
  .check_layer_names(names(section$color_values), "color_values", fn, plot)
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
    scales[[attr]] <- list(type = if (is.null(new$type)) old$type else new$type,
                           values = if (length(values) > 0) values else NULL)
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
  layer <- spec$layer
  if (identical(layer$color_by, INDIVIDUAL_KEYWORD) && !is.null(layer$color_values)) {
    spec$layer$colors <- as.list(layer$color_values)
  }
  spec <- lapply(spec, function(section) section[setdiff(names(section), COLOR_SCALE_FIELDS)])
  spec <- Filter(length, spec)
  if (length(scales) > 0) spec$scales <- lapply(scales, .scale_json)
  spec
}

.scale_json <- function(scale) {
  json <- list()
  if (!is.null(scale$type)) json$type <- scale$type
  if (!is.null(scale$values)) json$values <- as.list(scale$values)
  json
}
