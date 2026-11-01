# Node attributes MiRA computes for a network (js/calc/nodeMetrics.js), so
# R can warn about a computed name MiRA will not have. MiRA computes degree
# and strength per side (intra / inter); a directed side has in / out
# variants instead; interlayer fields exist only when there are interlayer
# links. Each state-node field also has a _sum and a _mean on physical nodes.

COMPUTED_MEASURES <- c("degree", "strength")
COMPUTED_AGGREGATES <- c("", "_sum", "_mean")
DIRECTED_PREFIXES <- c("in_", "out_")

#' Computed node attribute names MiRA will have for this network
#'
#' Follows MiRA's parser (js/dataParser.js): a side is directed when R says
#' so, or when a layer or link has `directed = TRUE`; interlayer links with
#' weight 0 are dropped.
#' @param network_json The JSON from `.network_json()` (its first key is the
#'   intralayer `directed` flag).
#' @keywords internal
#' @noRd
.computed_node_attrs <- function(net, network_json, directed_interlayer) {
  links <- as.data.frame(net$extended)
  is_inter <- links$layer_from != links$layer_to
  # [[ ]] rather than $: a missing column is NULL, with no tibble warning
  directed <- grepl('^\\{\\s*"directed": true', network_json) ||
    .any_true(net$layers[["directed"]]) || .any_true(links[["directed"]][!is_inter])
  attrs <- .side_attrs("intra", directed)
  if (!any(is_inter & !.zero_weight(links[["weight"]]))) return(attrs)
  directed_inter <- isTRUE(directed_interlayer) || directed ||
    .any_true(links[["directed"]][is_inter])
  c(attrs, .side_attrs("inter", directed_inter))
}

.side_attrs <- function(side, directed) {
  directions <- if (directed) DIRECTED_PREFIXES else ""
  fields <- as.vector(outer(paste0(side, "_", directions), COMPUTED_MEASURES, paste0))
  as.vector(outer(fields, COMPUTED_AGGREGATES, paste0))
}

# Only a logical TRUE counts (a "TRUE" string is not true in MiRA)
.any_true <- function(values) is.logical(values) && any(values %in% TRUE)

.zero_weight <- function(weight) {
  if (is.null(weight)) return(FALSE)
  number <- suppressWarnings(as.numeric(weight))
  !is.na(number) & number == 0
}

#' Warn about computed names MiRA will not have for this network
#'
#' The hint names the variants it does have (e.g. "intra_in_degree_sum" for
#' "intra_degree_sum" on a directed network).
#' @keywords internal
#' @noRd
.warn_not_computed <- function(value, plot, arg, fn) {
  used <- .mapping_names(value)
  missing <- used[grepl(COMPUTED_NODE_ATTR, used) & !(used %in% plot$computed)]
  for (name in missing) {
    warning(sprintf('%s(): `%s`: "%s" is not computed by MiRA for this network; MiRA keeps its default%s',
                    fn, arg, name, .computed_hint(name, plot$computed)), call. = FALSE)
  }
}

.computed_hint <- function(name, computed) {
  variants <- computed[.without_direction(computed) == .without_direction(name)]
  if (length(variants) > 0) {
    return(sprintf(" (did you mean %s?)", paste0('"', variants, '"', collapse = " or ")))
  }
  if (startsWith(name, "inter_")) return(" (the network has no interlayer links)")
  ""
}

.without_direction <- function(names) {
  sub(sprintf("_(%s)", paste(DIRECTED_PREFIXES, collapse = "|")), "_", names)
}
