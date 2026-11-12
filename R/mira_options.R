# mira_options(): what each component can be set to for a network — the
# attributes its arguments take, with the type MiRA gives them and their
# values. Built from the same rules the checks use (mira_validate.R,
# mira_computed.R), so the table and the warnings agree.

# MiRA's rule for the default scale of numeric data (js/colorMapper.js): a
# continuous-sounding name wins over a categorical one ("module_size")
CONTINUOUS_NAME_PATTERN <- "weight|abundance|degree|strength|mass|size|value"
CATEGORICAL_NAME_PATTERN <- "module|group|cluster|community|partition"
VALUES_SHOWN <- 5 # values listed for a categorical attribute
META_MEASURE_TYPES <- c(participation = "continuous", degree = "continuous", uniform = "constant")

#' What each component can be set to, for a network
#'
#' Lists the attributes a network offers to each component's arguments: the
#' columns and computed attributes `color_by` and `size_by` take, the
#' columns conditions in [mira_filter()] and `mira_mode_meta(layers = )`
#' can use, and the measures of the meta-network. For each, the type MiRA
#' gives it and a summary of its values, to choose a mapping and write
#' `color_values` before making the plot.
#'
#' Give the same arguments as to [mira()]: they decide what MiRA computes
#' (in- and out-degree only on a directed network) and whether nodes can be
#' set per set (`bipartite = TRUE`).
#'
#' **Types.** `"categorical"` (one color per value) or `"continuous"` (a
#' gradient) is the scale MiRA picks by default: numbers with more than two
#' values, or with a name such as `abundance` or `degree`, are continuous,
#' unless the name marks groups (`module`, `cluster`); text is categorical.
#' Where `switchable` is `TRUE`, `color_scale` can choose the other one (see
#' [mira_scales]). The type also decides the palettes `color_palette` can
#' name: categorical ones (`"Okabe-Ito"`, `"Set1"`, ...) or continuous ones
#' (`"magma"`, `"RdBu"`, ...). `"set"` and `"individual"` are keywords: one color per
#' node set, one color per layer. Columns for conditions have the type of
#' their values: `"number"`, `"text"` or `"logical"`.
#'
#' @param net A multilayer network from emln (as for [mira()]).
#' @param ... Arguments of [mira()]: `bipartite`, `setA_type`, `directed`,
#'   `directed_interlayer`.
#' @return A data frame of class `mira_options`, one row per argument and
#'   attribute, with columns `component`, `argument`, `attribute`, `type`,
#'   `switchable`, `source` (`"node"`, `"state node"`, `"link"`, `"layer"`,
#'   `"computed"` by MiRA, or `"keyword"`), `sets` (on a bipartite network,
#'   the node sets that have the attribute) and `values`. It prints grouped
#'   by component, with MiRA's computed node attributes on one line (the
#'   data frame has a row for each), and with the sets only when they differ
#'   between attributes. Filter it as a data frame.
#' @seealso [mira()] to start a plot; [mira_node()] and the other
#'   components for the arguments; [mira_scales] for `color_values`,
#'   `color_scale`, `color_palette`, `color_reverse` and `color_limits`.
#' @export
#' @examplesIf requireNamespace("emln", quietly = TRUE)
#' library(emln)
#' net <- load_emln(17) # 4 layers; bird and plant nodes
#'
#' mira_options(net, bipartite = TRUE, setA_type = "bird")
#'
#' # Only what can size nodes
#' opts <- mira_options(net, bipartite = TRUE)
#' opts[opts$argument == "size_by", ]
mira_options <- function(net, ...) {
  plot <- suppressMessages(suppressWarnings(mira(net, ...)))
  rows <- rbind(
    .node_options(plot),
    .link_options(plot, "intralayer"),
    .link_options(plot, "interlayer"),
    .layer_options(plot),
    .filter_options(plot),
    .meta_options(plot)
  )
  rownames(rows) <- NULL
  structure(rows, class = c("mira_options", "data.frame"))
}

#' @export
print.mira_options <- function(x, ...) {
  rows <- .collapse_computed(as.data.frame(x))
  if (nrow(rows) == 0) {
    cat("<no options>\n")
    return(invisible(x))
  }
  # The sets column only when attributes differ in which sets have them
  show_sets <- length(unique(rows$sets[rows$component == "mira_node" & rows$source != "keyword"])) > 1
  type <- ifelse(rows$switchable, paste0(rows$type, "*"), rows$type)
  argument <- rows$argument
  argument[duplicated(paste(rows$component, rows$argument))] <- ""
  columns <- list(argument, rows$attribute, type, rows$source)
  if (show_sets) columns <- c(columns, list(rows$sets))
  columns <- lapply(columns, function(col) formatC(col, width = -max(nchar(col)), flag = "-"))
  lines <- paste(" ", do.call(paste, c(columns, list(rows$values, sep = "  "))))
  width <- getOption("width", 80)
  long <- nchar(lines) > width
  lines[long] <- paste0(substr(lines[long], 1, width - 3), "...")
  # Color the attribute by its element and grey the values (where the console has colors)
  element <- .row_element(rows$component, rows$argument)
  attr_start <- 2 + nchar(columns[[1]][1]) + 2 + 1
  values_start <- sum(nchar(vapply(columns, `[`, character(1), 1))) + 2 * length(columns) + 2 + 1
  lines <- .color_lines(lines, element, attr_start, attr_start + nchar(columns[[2]][1]) - 1, values_start)
  for (component in unique(rows$component)) {
    elements <- unique(element[rows$component == component])
    header <- paste0(component, "()")
    cat(if (length(elements) == 1) .element_style(elements)(header) else cli::style_bold(header), "\n", sep = "")
    cat(lines[rows$component == component], sep = "\n")
  }
  if (any(rows$switchable)) {
    cat('* MiRA\'s default scale; color_scale can choose the other (see ?mira_scales)\n')
  }
  if (cli::num_ansi_colors() > 1) {
    shown <- intersect(ELEMENTS, element)
    cat(paste(vapply(shown, function(e) .element_style(e)(paste0(e, "s")), character(1)), collapse = "  "), "\n")
  }
  invisible(x)
}

# Each row is about nodes, intralayer links, interlayer links or layers.
# mira_filter(links = ) takes both kinds of link: the intralayer color.
ELEMENTS <- c("node", "intralayer link", "interlayer link", "layer")
ELEMENT_COLORS <- c(node = "#d97706", "intralayer link" = "#0ea5e9", "interlayer link" = "#1e40af",
                    layer = "#8b5cf6") # amber, light blue, blue, MiRA's layer purple

.row_element <- function(component, argument) {
  element <- rep("node", length(component))
  element[component == "mira_intralayer" | (component == "mira_filter" & argument == "links")] <- "intralayer link"
  element[component == "mira_interlayer"] <- "interlayer link"
  element[component == "mira_layer" | (component %in% c("mira_mode_meta", "mira_filter") & argument == "layers")] <- "layer"
  element
}

.element_style <- function(element) cli::make_ansi_style(ELEMENT_COLORS[[element]])

# Positions are those of the plain line, so colors never change the alignment
.color_lines <- function(lines, element, attr_start, attr_end, values_start) {
  if (cli::num_ansi_colors() <= 1) return(lines)
  vapply(seq_along(lines), function(i) {
    line <- lines[i]
    paste0(substr(line, 1, attr_start - 1),
           .element_style(element[i])(substr(line, attr_start, attr_end)),
           substr(line, attr_end + 1, values_start - 1),
           cli::col_grey(substr(line, values_start, nchar(line))))
  }, character(1))
}

# One printed row per component and argument for MiRA's computed node
# attributes (the data frame keeps one row each)
.collapse_computed <- function(rows) {
  computed <- rows$component == "mira_node" & rows$source == "computed"
  key <- paste(rows$component, rows$argument)
  first <- computed & !duplicated(ifelse(computed, key, NA_character_), incomparables = NA)
  for (i in which(first)) {
    group <- rows$attribute[computed & key == key[i]]
    rows$attribute[i] <- "(computed)"
    rows$values[i] <- sprintf("%d attributes, e.g. %s", length(group), group[grepl("degree_sum$", group)][1])
  }
  rows[!computed | first, , drop = FALSE]
}

# ---- Rows per component ------------------------------------------------------

.option_rows <- function(component, argument, attribute, type, source, values,
                         switchable = FALSE, sets = "") {
  n <- length(attribute)
  if (n == 0) return(NULL)
  data.frame(
    component  = rep(component, n),
    argument   = rep(argument, n),
    attribute  = attribute,
    type       = rep_len(type, n),
    switchable = rep_len(switchable, n),
    source     = rep_len(source, n),
    sets       = rep_len(sets, n),
    values     = rep_len(values, n),
    stringsAsFactors = FALSE
  )
}

.node_options <- function(plot) {
  net <- plot$net
  data_attrs <- .node_attr_names(net)
  columns <- lapply(data_attrs, function(attr) .node_column(attr, net))
  source <- vapply(data_attrs, function(attr) .node_source(attr, net), character(1))
  scale <- lapply(seq_along(data_attrs), function(i) .default_scale(data_attrs[i], columns[[i]]))
  type <- vapply(scale, `[[`, character(1), "type")
  switchable <- vapply(scale, `[[`, logical(1), "switchable")
  values <- vapply(seq_along(data_attrs), function(i) .values_summary(columns[[i]], type[i]), character(1))
  sets <- vapply(data_attrs, function(attr) .attr_sets(attr, plot), character(1))
  computed <- plot$computed
  computed_sets <- if (plot$bipartite) paste(plot$set_types, collapse = ", ") else ""

  color <- rbind(
    .option_rows("mira_node", "color_by", data_attrs, type, source, values, switchable, sets),
    .option_rows("mira_node", "color_by", computed, "continuous", "computed", "computed by MiRA",
                 TRUE, computed_sets),
    if (plot$bipartite) .option_rows("mira_node", "color_by", SET_KEYWORD, "set", "keyword",
                                     paste("one color per set:", paste(plot$set_types, collapse = ", ")))
  )
  numeric <- vapply(columns, .looks_numeric, logical(1))
  size <- rbind(
    .option_rows("mira_node", "size_by", data_attrs[numeric], "continuous", source[numeric],
                 vapply(columns[numeric], .values_summary, character(1), type = "continuous"),
                 sets = sets[numeric]),
    .option_rows("mira_node", "size_by", computed, "continuous", "computed", "computed by MiRA",
                 sets = computed_sets)
  )
  rbind(color, size)
}

.link_options <- function(plot, side) {
  links <- as.data.frame(plot$net$extended)
  is_inter <- links$layer_from != links$layer_to
  links <- links[if (side == "interlayer") is_inter else !is_inter, , drop = FALSE]
  if (!is.null(links[["weight"]])) links <- links[!.zero_weight(links$weight), , drop = FALSE] # not drawn
  if (nrow(links) == 0) return(NULL)
  component <- paste0("mira_", side)
  attrs <- setdiff(names(links), LINK_HIDDEN_COLUMNS)
  color <- .column_rows(component, "color_by", attrs, links, "link")
  weight <- if (!is.null(links[["weight"]])) {
    .option_rows(component, "min_weight", "weight", "number", "link",
                 .values_summary(links$weight, "continuous"))
  }
  rbind(color, weight)
}

.layer_options <- function(plot) {
  layers <- as.data.frame(plot$net$layers)
  attrs <- setdiff(names(layers), LAYER_HIDDEN_COLUMNS)
  rbind(
    .column_rows("mira_layer", "color_by", attrs, layers, "layer"),
    .option_rows("mira_layer", "color_by", LAYER_NAME_COLUMN, "individual", "keyword",
                 sprintf("one color per layer (%d layers)", nrow(layers)))
  )
}

.filter_options <- function(plot) {
  rbind(
    .condition_rows("mira_filter", "nodes", as.data.frame(plot$net$nodes), "node"),
    .condition_rows("mira_filter", "links", as.data.frame(plot$net$extended), "link"),
    .condition_rows("mira_filter", "layers", as.data.frame(plot$net$layers), "layer")
  )
}

.meta_options <- function(plot) {
  measures <- names(META_MEASURE_TYPES)
  values <- c(participation = "number of layers a node is in",
              degree = "links in the meta-network", uniform = "one color or size for all")
  rbind(
    .option_rows("mira_mode_meta", "color_by", measures, META_MEASURE_TYPES, "computed", values),
    .option_rows("mira_mode_meta", "size_by", measures, META_MEASURE_TYPES, "computed", values),
    .condition_rows("mira_mode_meta", "layers", as.data.frame(plot$net$layers), "layer")
  )
}

# color_by rows for the columns of one table, with MiRA's default scale
.column_rows <- function(component, argument, attrs, table, source) {
  rows <- lapply(attrs, function(attr) {
    scale <- .default_scale(attr, table[[attr]])
    .option_rows(component, argument, attr, scale$type, source,
                 .values_summary(table[[attr]], scale$type), scale$switchable)
  })
  do.call(rbind, rows)
}

# Columns a condition can use: every column of the table, by the type of its values
.condition_rows <- function(component, argument, table, source) {
  rows <- lapply(names(table), function(col) {
    column <- table[[col]]
    type <- if (is.logical(column)) "logical" else if (is.numeric(column)) "number" else "text"
    .option_rows(component, argument, col, type, source,
                 .values_summary(column, if (type == "number") "continuous" else "categorical"))
  })
  do.call(rbind, rows)
}

# ---- Attributes --------------------------------------------------------------

# The values MiRA reads for a node attribute: the node column, else the
# state-node column. The nodes' type column reaches MiRA as node_type, so a
# state-node column of the same name (emln's `type`) is its own attribute.
.node_column <- function(attr, net) {
  type_column <- .type_column(net$nodes)
  if (attr == "node_type" && !is.na(type_column)) return(net$nodes[[type_column]])
  if (attr %in% .node_columns(net)) net$nodes[[attr]] else net$state_nodes[[attr]]
}

.node_source <- function(attr, net) {
  if (attr %in% .node_columns(net) || attr == "node_type") "node" else "state node"
}

# Node columns as MiRA has them (the type column renamed to node_type)
.node_columns <- function(net) {
  columns <- names(net$nodes)
  columns[columns %in% .type_column(net$nodes)] <- "node_type"
  columns
}

#' MiRA's default scale for an attribute (js/colorMapper.js)
#' @return list(type = "categorical" | "continuous", switchable = TRUE when numeric)
#' @keywords internal
#' @noRd
.default_scale <- function(name, column) {
  values <- column[!is.na(column)]
  if (is.character(values)) values <- values[nzchar(trimws(values))]
  numeric <- length(values) > 0 && !anyNA(suppressWarnings(as.numeric(as.character(values))))
  continuous_name <- grepl(CONTINUOUS_NAME_PATTERN, name, ignore.case = TRUE)
  categorical_name <- !continuous_name && grepl(CATEGORICAL_NAME_PATTERN, name, ignore.case = TRUE)
  continuous <- numeric && !categorical_name && (length(unique(values)) > 2 || continuous_name)
  list(type = if (continuous) "continuous" else "categorical", switchable = numeric)
}

.values_summary <- function(column, type) {
  values <- column[!is.na(column)]
  if (length(values) == 0) return("no values")
  if (type == "continuous") {
    numbers <- suppressWarnings(as.numeric(as.character(values)))
    range <- signif(range(numbers, na.rm = TRUE), 3)
    n <- length(unique(numbers))
    if (n == 1) return(sprintf("1 value: %s", format(range[1])))
    return(sprintf("%s to %s (%d values)", format(range[1]), format(range[2]), n))
  }
  unique_values <- sort(unique(as.character(values)))
  shown <- utils::head(unique_values, VALUES_SHOWN)
  more <- if (length(unique_values) > VALUES_SHOWN) ", ..." else ""
  sprintf("%d value%s: %s%s", length(unique_values), if (length(unique_values) == 1) "" else "s",
          paste(shown, collapse = ", "), more)
}

# On a bipartite plot, the node sets with values for the attribute
.attr_sets <- function(attr, plot) {
  if (!plot$bipartite) return("")
  net <- plot$net
  types <- as.character(net$nodes[[.type_column(net$nodes)]])
  if (attr == "node_type") return(paste(plot$set_types, collapse = ", "))
  if (attr %in% .node_columns(net)) {
    has <- !is.na(net$nodes[[attr]])
    return(paste(intersect(plot$set_types, types[has]), collapse = ", "))
  }
  state <- as.data.frame(net$state_nodes)
  has <- !is.na(state[[attr]])
  node_types <- types[match(state$node_name[has], net$nodes$node_name)]
  paste(intersect(plot$set_types, node_types), collapse = ", ")
}
