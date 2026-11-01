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

#' Update the plot's scales after a piece was merged into its section
#'
#' Checks the section's color settings against the network and against the
#' scales of the other sections, and records the section as the latest to
#' set scales (later sections win in mira_spec()).
#' @keywords internal
#' @noRd
.update_scales <- function(plot, piece) {
  if (!any(COLOR_FIELDS %in% names(piece$fields))) return(plot)
  name <- piece$section
  section <- plot$spec[[name]]
  scales <- .section_scales(section, piece$fn, plot)
  .warn_scale_values(scales, name, piece$fn, plot$net)
  for (other in setdiff(plot$scale_order, name)) {
    .warn_scale_conflicts(scales, .section_scales(plot$spec[[other]], NULL, plot), piece$fn, other)
  }
  plot$scale_order <- c(setdiff(plot$scale_order, name), name)
  plot
}

#' The scales a section sets: list(<attr> = list(type, values))
#'
#' @param fn The piece's function name, for errors; NULL when the section was
#'   already checked (when its piece was added), so it cannot fail.
#' @keywords internal
#' @noRd
.section_scales <- function(section, fn, plot) {
  if (!any(COLOR_SCALE_FIELDS %in% names(section))) return(list())
  if (identical(section$color_by, INDIVIDUAL_KEYWORD)) {
    .check_layer_colors(section, fn, plot)
    return(list()) # sent as layer colors, not as a scale
  }
  scales <- list()
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
    scales <- .combine_scales(scales, stats::setNames(list(scale), attr))
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

.warn_scale_conflicts <- function(scales, other_scales, fn, other) {
  for (attr in intersect(names(scales), names(other_scales))) {
    new <- scales[[attr]]
    old <- other_scales[[attr]]
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
}

.warn_replaces <- function(fn, what, other) {
  warning(sprintf("%s(): %s replaces the setting in mira_%s(); MiRA keeps one color scale per attribute",
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

# The data column an attribute comes from; NULL when there is none
.scale_column <- function(attr, section_name, net) {
  switch(section_name,
    node = c(net$nodes[[attr]], net$state_nodes[[attr]]),
    layer = net$layers[[attr]],
    net$extended[[attr]]
  )
}

#' The spec as MiRA receives it: color settings become `scales` (and layer
#' `colors`)
#' @keywords internal
#' @noRd
.spec_for_mira <- function(plot) {
  spec <- plot$spec
  scales <- list()
  for (name in plot$scale_order) scales <- .combine_scales(scales, .section_scales(spec[[name]], NULL, plot))
  layer <- spec$layer
  if (identical(layer$color_by, INDIVIDUAL_KEYWORD) && !is.null(layer$color_values)) {
    spec$layer$colors <- as.list(layer$color_values)
  }
  spec <- lapply(spec, function(section) section[setdiff(names(section), COLOR_SCALE_FIELDS)])
  if (length(scales) > 0) spec$scales <- lapply(scales, .scale_json)
  spec
}

.scale_json <- function(scale) {
  json <- list()
  if (!is.null(scale$type)) json$type <- scale$type
  if (!is.null(scale$values)) json$values <- as.list(scale$values)
  json
}
