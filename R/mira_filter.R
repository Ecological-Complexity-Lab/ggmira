# Filters: draw only some nodes or links (MiRA's Data mode filter).
# A condition is captured when mira_filter() is called and evaluated against
# the network when the component is added to a plot (components do not know
# the network), so MiRA receives plain lists: node names, and links as
# [layer_from, node_from, layer_to, node_to].

LINK_ID_COLUMNS <- c("layer_from", "node_from", "layer_to", "node_to")
NAMES_SHOWN <- 5 # node names listed in an error message

#' Filter: draw only some nodes or links
#'
#' Keeps part of the network: some nodes, some links, or both. Each argument
#' takes a condition on the columns of the network's tables, evaluated like
#' [subset()]: `nodes` on `net$nodes`, `links` on `net$extended`. Variables
#' of your session can be used too. `nodes` also takes node names.
#'
#' A hidden node hides its links. Filters on nodes and links combine: a link
#' is drawn when it passes `links` and both its nodes pass `nodes`. A later
#' `mira_filter()` replaces the same argument of an earlier one, so combine
#' two conditions on nodes in one: `nodes = A & B`.
#'
#' Rows where a condition is `NA` are dropped. MiRA shows "Data filter
#' active" with a button that removes the filter.
#'
#' A condition is evaluated where `mira_filter()` is called, like
#' [subset()]: inside a function, it sees that function's variables. A
#' function that passes its arguments on through `...` does not see its
#' caller's variables; pass values, not names, through such a wrapper.
#' A node that `mira_node(highlight = )` highlights must pass the filter,
#' or MiRA highlights nothing (a warning).
#'
#' @param nodes A condition on the columns of `net$nodes` (e.g.
#'   `type == "bird"`), or node names. `NULL` or `NA` = no node filter.
#' @param links A condition on the columns of `net$extended` (e.g.
#'   `weight > 0.05`, `layer_from == "layer_1"`). `NULL` or `NA` = no link
#'   filter.
#' @return A component, to add to a plot with `+`.
#' @seealso [mira_intralayer()] and [mira_interlayer()] for `min_weight`,
#'   which hides weak links without a filter.
#' @family components
#' @export
#' @examplesIf requireNamespace("emln", quietly = TRUE)
#' library(emln)
#' net <- load_emln(17) # 4 layers; bird and plant nodes
#' p <- mira(net, bipartite = TRUE, setA_type = "bird")
#'
#' # Nodes by a condition on their columns
#' p + mira_filter(nodes = verification_level == "species")
#'
#' # Nodes by name
#' p + mira_filter(nodes = c("Geospiza_fortis", "Opuntia_echios"))
#'
#' # Links by a condition: strong links, or the links of one layer
#' p + mira_filter(links = weight > 0.1)
#' p + mira_filter(links = layer_from == "layer_1" & layer_to == "layer_1")
#'
#' # Both, in one call; a variable of your session
#' keep <- c("species", "genus")
#' p + mira_filter(nodes = verification_level %in% keep, links = weight > 0.05)
mira_filter <- function(nodes, links) {
  fields <- list()
  if (!missing(nodes)) fields["nodes"] <- list(.capture_condition(substitute(nodes), parent.frame()))
  if (!missing(links)) fields["links"] <- list(.capture_condition(substitute(links), parent.frame()))
  structure(list(section = "filter", fn = "mira_filter", fields = fields), class = "mira_piece")
}

# NULL / NA = no filter (sent as JSON null, which clears it)
.capture_condition <- function(expr, env) {
  if (is.null(expr) || identical(expr, NA)) return(NULL)
  structure(list(expr = expr, env = env), class = "mira_condition")
}

#' Evaluate a filter component's conditions against the plot's network
#'
#' @return The component with each condition replaced by what MiRA receives:
#'   a list of node names, or a list of [layer_from, node_from, layer_to,
#'   node_to] links.
#' @keywords internal
#' @noRd
.resolve_filter <- function(piece, plot) {
  if (piece$section != "filter") return(piece)
  for (arg in names(piece$fields)) {
    condition <- piece$fields[[arg]]
    if (is.null(condition)) next
    kept <- switch(arg,
      nodes = .filter_nodes(condition, plot$net),
      links = .filter_links(condition, plot$net)
    )
    piece$fields[arg] <- list(kept)
  }
  piece
}

.filter_nodes <- function(condition, net) {
  nodes <- as.data.frame(net$nodes)
  value <- .eval_condition(condition, nodes, "nodes", "net$nodes")
  names <- .node_names(net)
  numeric_names <- is.numeric(value) && is.numeric(nodes$node_name) # names given as numbers
  if (is.character(value) || is.factor(value) || numeric_names) {
    if (anyNA(value)) .abort_arg("mira_filter", "nodes", "names must not be NA")
    value <- if (is.factor(value)) as.character(value) else .format_names(value)
    unknown <- setdiff(value, names)
    if (length(unknown) > 0) .abort_arg("mira_filter", "nodes", .not_node_names(unknown, names))
    kept <- unique(value)
  } else if (is.logical(value) && length(value) == nrow(nodes)) {
    kept <- unique(names[value %in% TRUE])
  } else {
    .abort_arg("mira_filter", "nodes",
               "must be node names or a condition on the columns of net$nodes (TRUE or FALSE for each node)")
  }
  if (length(kept) == 0) warning("mira_filter(): `nodes` keeps no nodes; MiRA will draw none", call. = FALSE)
  as.list(kept)
}

.filter_links <- function(condition, net) {
  links <- as.data.frame(net$extended)
  value <- .eval_condition(condition, links, "links", "net$extended")
  if (!is.logical(value) || length(value) != nrow(links)) {
    .abort_arg("mira_filter", "links",
               "must be a condition on the columns of net$extended (TRUE or FALSE for each link), e.g. weight > 0.1")
  }
  kept <- unique(links[value %in% TRUE, LINK_ID_COLUMNS, drop = FALSE])
  if (nrow(kept) == 0) warning("mira_filter(): `links` keeps no links; MiRA will draw none", call. = FALSE)
  lapply(seq_len(nrow(kept)), function(i) as.list(vapply(kept[i, ], .format_names, character(1), USE.NAMES = FALSE)))
}

# The condition's columns come from the table; other names from where
# mira_filter() was called
.eval_condition <- function(condition, table, arg, what) {
  tryCatch(eval(condition$expr, table, condition$env), error = function(e) {
    .abort_arg("mira_filter", arg, sprintf("could not be evaluated on the columns of %s: %s",
                                           what, conditionMessage(e)))
  })
}
