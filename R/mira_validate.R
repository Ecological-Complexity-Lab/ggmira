# Checks of a piece against the network, run when it is added to a plot.
# Settings that cannot work (per-set values without bipartite = TRUE, set
# names that are not node types) are errors. A column that is not in the
# network is only a warning: MiRA has the final say, and keeps its default.

# Columns MiRA does not offer as attributes (js/dataParser.js)
NODE_HIDDEN_COLUMNS <- c("node_id", "node_name", "layer_name", "layers_present")
STATE_NODE_HIDDEN_COLUMNS <- c("layer_id", "node_id", "layer_name", "node_name")
LINK_HIDDEN_COLUMNS <- c("layer_from", "node_from", "layer_to", "node_to", "weight", "directed")
LAYER_HIDDEN_COLUMNS <- c("layer_id", "layer_name", "bipartite", "latitude", "longitude",
                          "name") # `name` is dropped by the converter
# Node attributes MiRA computes (degree and strength)
COMPUTED_NODE_ATTR <- "^(intra|inter)_((in|out)_)?(degree|strength)(_sum|_mean)?$"
# Node type column names, in the converter's order of precedence
TYPE_COLUMNS <- c("node_type", "node_group", "type")
PER_SET_FIELDS <- c("color_by", "size_by", "shape", "color_values", "color_scale")

.validate_piece <- function(piece, plot) {
  switch(piece$section,
    layout     = .validate_layout(piece, plot),
    node       = .validate_node(piece, plot),
    intralayer = .validate_links(piece, plot),
    interlayer = .validate_links(piece, plot),
    layer      = .validate_layer(piece, plot),
    mode       = .validate_mode(piece, plot)
  )
  invisible(NULL)
}

.validate_layout <- function(piece, plot) {
  if (identical(piece$fields$type, "bipartite") && !plot$bipartite) {
    .abort_piece(piece$fn, 'type = "bipartite" needs mira(..., bipartite = TRUE)')
  }
}

.validate_node <- function(piece, plot) {
  fields <- piece$fields
  for (arg in intersect(names(fields), PER_SET_FIELDS)) {
    .check_sets(fields[[arg]], arg, piece$fn, plot)
  }
  if (identical(fields$color_by, SET_KEYWORD) && !plot$bipartite) {
    .abort_piece(piece$fn, 'color_by = ".set" needs mira(..., bipartite = TRUE)')
  }
  known <- .node_attr_names(plot$net)
  # ".set" works only as a shared value on a bipartite plot
  color_keywords <- if (plot$bipartite && !is.list(fields$color_by)) SET_KEYWORD else character()
  .warn_unknown(.data_names(fields$color_by), known, "color_by", piece$fn, "node or state-node",
                color_keywords)
  .warn_unknown(.data_names(fields$size_by), known, "size_by", piece$fn, "node or state-node")
  .warn_not_computed(fields$color_by, plot, "color_by", piece$fn)
  .warn_not_computed(fields$size_by, plot, "size_by", piece$fn)
  .warn_non_numeric(.mapping_names(fields$size_by), plot$net, piece$fn)
  if (!is.null(fields$highlight)) {
    names <- .node_names(plot$net)
    if (!fields$highlight %in% names) .abort_arg(piece$fn, "highlight", .not_node_names(fields$highlight, names))
  }
}

# Node names as MiRA has them: a numeric name is written out ("100000",
# not "1e+05"), as in the network JSON
.node_names <- function(net) .format_names(net$nodes$node_name)

.format_names <- function(x) {
  if (is.numeric(x)) vapply(x, format, character(1), scientific = FALSE, digits = 15) else as.character(x)
}

# The message for names that are not in the network, for `nodes` and `highlight`
.not_node_names <- function(unknown, names) {
  sprintf('"%s" %s not a node name (node_name values include %s)',
          paste(unknown, collapse = '", "'), if (length(unknown) == 1) "is" else "are",
          paste(utils::head(names, NAMES_SHOWN), collapse = ", "))
}

# A highlighted node that the node filter hides: MiRA dims everything and
# highlights nothing. Checked after a node or filter component is merged.
.warn_hidden_highlight <- function(spec, piece) {
  if (!piece$section %in% c("node", "filter")) return(invisible(NULL)) # warn once, when it happens
  fn <- piece$fn
  highlight <- spec$node$highlight
  kept <- spec$filter$nodes
  if (is.null(highlight) || is.null(kept) || highlight %in% unlist(kept)) return(invisible(NULL))
  warning(sprintf('%s(): the highlighted node "%s" is hidden by `mira_filter(nodes)`, so MiRA highlights nothing',
                  fn, highlight), call. = FALSE)
}

.validate_links <- function(piece, plot) {
  if (!is.null(piece$fields$arrow_size) && !.is_directed(plot)) {
    warning(sprintf("%s(): `arrow_size`: the network is undirected, so MiRA draws no arrowheads",
                    piece$fn), call. = FALSE)
  }
  if (!is.null(piece$fields$pairs)) .validate_pairs(piece$fields$pairs, piece$fn, plot)
  used <- .mapping_names(piece$fields$color_by)
  if (identical(used, "weight")) {
    warning(sprintf("%s(): coloring links by `weight` is not available in MiRA yet; MiRA keeps its default",
                    piece$fn), call. = FALSE)
    return()
  }
  known <- setdiff(names(plot$net$extended), LINK_HIDDEN_COLUMNS)
  .warn_unknown(used, known, "color_by", piece$fn, "link")
}

.validate_layer <- function(piece, plot) {
  if (isTRUE(piece$fields$set_labels) && !plot$bipartite) {
    .abort_piece(piece$fn, "set_labels = TRUE needs mira(..., bipartite = TRUE)")
  }
  known <- setdiff(names(plot$net$layers), LAYER_HIDDEN_COLUMNS)
  .warn_unknown(.mapping_names(piece$fields$color_by), known, "color_by", piece$fn, "layer",
                INDIVIDUAL_KEYWORD)
}

# ---- Helpers --------------------------------------------------------------------

# MiRA computes in_ / out_ attributes only for a directed side
.is_directed <- function(plot) any(grepl("^(intra|inter)_(in|out)_", plot$computed))

#' Pairs must be layer names; a pair without interlayer links is a warning
#' @keywords internal
#' @noRd
.validate_pairs <- function(pairs, fn, plot) {
  .check_layer_names(unlist(pairs), "pairs", fn, plot)
  links <- as.data.frame(plot$net$extended)
  links <- links[links$layer_from != links$layer_to, ]
  linked <- paste(links$layer_from, links$layer_to, sep = "::")
  for (pair in pairs) {
    keys <- c(paste(pair[[1]], pair[[2]], sep = "::"), paste(pair[[2]], pair[[1]], sep = "::"))
    if (!any(keys %in% linked)) {
      warning(sprintf('%s(): `pairs`: no interlayer links between "%s" and "%s"',
                      fn, pair[[1]], pair[[2]]), call. = FALSE)
    }
  }
}

#' Per-set values need two node sets, named by the node_type values
#' @keywords internal
#' @noRd
.check_sets <- function(value, arg, fn, plot) {
  if (!is.list(value)) return()
  if (!plot$bipartite) {
    .abort_arg(fn, arg, "per-set values need mira(..., bipartite = TRUE)")
  }
  unknown <- setdiff(names(value), plot$set_types)
  if (length(unknown) > 0) {
    .abort_arg(fn, arg, sprintf("names must be node_type values (%s); not: %s",
                                paste(plot$set_types, collapse = ", "),
                                paste(unknown, collapse = ", ")))
  }
}

#' Column names used by a mapping (shared or per set), without keywords
#' @keywords internal
#' @noRd
.mapping_names <- function(value) {
  setdiff(as.character(unlist(value, use.names = FALSE)), KEYWORDS)
}

# Node attribute names that should be data columns (MiRA computes the others)
.data_names <- function(value) {
  used <- .mapping_names(value)
  used[!grepl(COMPUTED_NODE_ATTR, used)]
}

#' @param keywords Keywords valid here; a name that is a keyword without its
#'   dot (e.g. "individual") gets a "did you mean" hint.
#' @keywords internal
#' @noRd
.warn_unknown <- function(used, known, arg, fn, what, keywords = character()) {
  unknown <- setdiff(used, known)
  if (length(unknown) == 0) return()
  warning(sprintf('%s(): `%s`: "%s" is not a %s column; MiRA keeps its default%s',
                  fn, arg, paste(unknown, collapse = '", "'), what,
                  .keyword_hint(unknown, keywords)), call. = FALSE)
}

.keyword_hint <- function(names, keywords) {
  matched <- keywords[keywords %in% paste0(".", tolower(names))]
  if (length(matched) == 0) return("")
  sprintf(' (did you mean "%s"?)', matched[1])
}

.warn_non_numeric <- function(used, net, fn) {
  non_numeric <- Filter(function(col) .is_non_numeric_column(col, net), used)
  if (length(non_numeric) == 0) return()
  warning(sprintf('%s(): `size_by`: "%s" is not numeric; MiRA sizes nodes by numeric columns only',
                  fn, paste(non_numeric, collapse = '", "')), call. = FALSE)
}

# MiRA looks for a node column first, then a state-node column
.is_non_numeric_column <- function(col, net) {
  column <- if (col %in% names(net$nodes)) net$nodes[[col]] else net$state_nodes[[col]]
  !is.null(column) && !.looks_numeric(column)
}

# MiRA's rule (isNumericAttr in js/app.js): the first non-empty value is a
# number or a numeric string, so "6" counts as numeric
.looks_numeric <- function(column) {
  if (is.numeric(column)) return(TRUE)
  values <- as.character(column[!is.na(column)])
  values <- values[nzchar(values)]
  length(values) > 0 && !is.na(suppressWarnings(as.numeric(values[1])))
}

#' Node and state-node columns MiRA offers as node attributes
#' @keywords internal
#' @noRd
.node_attr_names <- function(net) {
  node_columns <- names(net$nodes)
  type_column <- .type_column(net$nodes)
  node_columns[node_columns %in% type_column] <- "node_type" # the converter renames it
  union(setdiff(node_columns, NODE_HIDDEN_COLUMNS),
        setdiff(names(net$state_nodes), STATE_NODE_HIDDEN_COLUMNS))
}

.type_column <- function(nodes) {
  intersect(TYPE_COLUMNS, names(nodes))[1] # NA when there is none
}

#' The two node_type values of a bipartite network (mira() has checked there are two)
#' @keywords internal
#' @noRd
.node_types <- function(nodes) {
  types <- unique(nodes[[.type_column(nodes)]])
  as.character(types[!is.na(types)])
}
