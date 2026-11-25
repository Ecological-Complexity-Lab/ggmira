# A mira plot: the network plus a view spec built from mira_*() components.
# Printing it serves both to MiRA, which applies the spec when it loads
# (MiRA side: js/rBridge.js and js/viewSpec.js).

VIEW_SPEC_VERSION <- 1

#' Start a plot: a multilayer network to draw in MiRA
#'
#' Creates a plot of a multilayer network that opens in MiRA, the
#' browser-based multilayer network visualizer. Describe how it should look
#' by adding components with `+`, as in ggplot2; printing the plot (typing
#' its name at the console) opens it in the browser.
#'
#' @section Components:
#' Each component sets one part of the plot. Add them in any order:
#'
#' - [mira_layout()]: where the nodes go (the layout algorithm, a seed).
#' - [mira_node()]: node color, size, shape, labels.
#' - [mira_intralayer()]: the links within layers.
#' - [mira_interlayer()]: the links between layers.
#' - [mira_layer()]: layer colors, names and arrangement.
#' - [mira_filter()]: draw only some nodes, links or layers.
#' - [mira_camera()]: rotate, tilt, zoom and pan the view.
#' - [mira_legends()]: which legends are open, and where.
#' - [mira_mode_grid()], [mira_mode_meta()] and the other `mira_mode_*()`:
#'   open the plot in another of MiRA's views ([mira_mode]).
#'
#' In each element component, `color_by` and `size_by` map an attribute of the data (a column
#' of the network's tables, or one MiRA computes, such as a degree); `color`,
#' `size` and `shape` set constants. The colors of a mapping are chosen in
#' the same component, with `color_values`, `color_scale`, `color_palette`,
#' `color_reverse` and `color_limits`: see [mira_scales].
#'
#' Anything not set keeps MiRA's default, and everything can still be
#' changed in MiRA's interface. When the same setting is given twice, the
#' later component wins. A later `color` replaces an earlier `color_by` of
#' the same element, and the other way round.
#'
#' Components are checked against the network as they are added: settings
#' that cannot work (per-set values or the bipartite layout without
#' `bipartite = TRUE`, a layer name that does not exist) are errors; a column
#' that is not in the network is a warning, and MiRA keeps its default for
#' that setting. [mira_spec()] shows what a plot sends to MiRA.
#'
#' MiRA has the final say. When it cannot use a setting it received, it
#' keeps its default for that setting and shows a notice when the plot
#' opens, "Some plot settings from R were ignored", with the reasons;
#' [mira_save()] gives them as warnings.
#'
#' @section Bipartite networks:
#' `bipartite = TRUE` needs a column in `net$nodes` that says which of two
#' sets each node is in: `node_type`, or `node_group`, or `type` (what the
#' networks of `emln::load_emln()` have). MiRA knows it as `node_type`
#' whatever its name in the data, so `mira_node(color_by = "node_type")`
#' works for all three. A condition in [mira_filter()] is evaluated on
#' `net$nodes` itself and uses the column's own name: `type == "bird"` for
#' a network from `load_emln()`. A network made with
#' `emln::create_multilayer_network()` has no such column; add one before
#' the plot:
#'
#' ```r
#' # plants: the names of the plant nodes
#' net$nodes$node_type <- ifelse(net$nodes$node_name %in% plants, "plant", "pollinator")
#' ```
#'
#' @section What MiRA computes:
#' Besides the columns of the data, nodes can be colored and sized by
#' degree and strength, which MiRA computes ([mira_node()] has the names:
#' `intra_degree_sum`, ...). [mira_options()] lists everything a network
#' offers.
#'
#' @inheritParams plot_mira
#' @param net A multilayer object (created by `emln::create_multilayer_network()`
#'   or `emln::load_emln()`). MiRA does not draw links with weight 0 (weight
#'   0 means "no link" in MiRA); R warns how many there are. MiRA also
#'   ignores self-loops (a node linked to itself within a layer): it neither
#'   draws them nor counts them in degree, strength, density or layer
#'   similarity, and R warns how many there are.
#' @param directed Logical or NULL. Whether intralayer links are directed.
#'   If NULL (default): undirected when `bipartite = TRUE` (bipartite edge
#'   lists usually store each link once, which would look directed);
#'   otherwise auto-detected from edge symmetry, as in [plot_mira()]. R
#'   prints which one was chosen.
#' @return A `mira_plot` object.
#' @seealso [mira_spec()] to see what a plot sends to MiRA;
#'   [print.mira_plot()] for the browser and port options;
#'   [plot_mira()] to open a network with MiRA's defaults and no
#'   components.
#' @export
#' @examplesIf requireNamespace("emln", quietly = TRUE)
#' library(emln)
#' net <- load_emln(17) # 4 layers; bird and plant nodes
#'
#' # MiRA's default view
#' mira(net, bipartite = TRUE, setA_type = "bird")
#'
#' # Directed links, within and between layers
#' mira(net, bipartite = TRUE, setA_type = "bird",
#'      directed = TRUE, directed_interlayer = TRUE)
#'
#' # Add components with +
#' mira(net, bipartite = TRUE, setA_type = "bird") +
#'   mira_layout("kamada_kawai", seed = 42) +
#'   mira_node(color_by = "verification_level", size_by = "intra_degree_sum") +
#'   mira_intralayer(color_by = "type") +
#'   mira_interlayer(show = TRUE) +
#'   mira_layer(labels = TRUE)
#'
#' # When done, stop the servers the plots started
#' httpuv::stopAllServers()
mira <- function(net, bipartite = FALSE, setA_type = NULL, directed = NULL,
                 directed_interlayer = NULL) {
  # Bipartite edge lists usually store each link once (e.g. pollinator ->
  # plant), which the auto-detection would read as directed
  if (isTRUE(bipartite) && is.null(directed)) {
    directed <- FALSE
    message("Bipartite network: drawn as undirected. Use directed = TRUE for a directed one.")
  }
  .warn_zero_weight(net, "mira")
  .warn_self_loops(net, "mira")
  network_json <- .network_json(
    net,
    bipartite           = bipartite,
    setA_type           = setA_type,
    directed            = directed,
    directed_interlayer = directed_interlayer
  )
  structure(list(
    net          = net,
    network_json = network_json,
    bipartite    = bipartite,
    set_types    = if (bipartite) .node_types(net$nodes) else NULL,
    computed     = .computed_node_attrs(net, network_json, directed_interlayer),
    spec         = list(),
    scale_order  = character(), # color scale settings (section, attribute, part), the latest last
    r_call       = .mira_call_text(sys.call()), # for Copy as R code in MiRA
    r_filter     = list()                       # mira_filter() conditions as written
  ), class = "mira_plot")
}

# A call longer than this was not typed (e.g. do.call() with the network
# itself): MiRA then starts its code with mira(net)
MAX_CALL_CHARS <- 500

.mira_call_text <- function(call) {
  text <- deparse1(call)
  if (nchar(text) > MAX_CALL_CHARS) NULL else text
}

#' Add a component to a mira plot
#'
#' @param e1 A `mira_plot`.
#' @param e2 A component (from a `mira_*()` function), or `NULL` (no change).
#' @return The `mira_plot` with the component added.
#' @keywords internal
#' @export
`+.mira_plot` <- function(e1, e2) {
  if (!inherits(e1, "mira_plot")) {
    stop("A mira plot starts with mira(net); add components after it.", call. = FALSE)
  }
  if (is.null(e2)) return(e1)
  if (!inherits(e2, "mira_piece")) {
    stop("Only mira_*() components (e.g. mira_node()) can be added to a mira plot.", call. = FALSE)
  }
  e1 <- .record_filter_text(e1, e2) # before the conditions become names
  e2 <- .resolve_filter(e2, e1) # conditions -> names, against this network
  e2 <- .resolve_meta_layers(e2, e1) # the same, for mira_mode_meta(layers = )
  .validate_piece(e2, e1)
  e1$spec <- .replace_mode(e1$spec, e2) # one view per plot
  e1$spec <- .merge_piece(e1$spec, e2)
  .warn_hidden_highlight(e1$spec, e2)
  .warn_view_only(e1$spec, e2)
  .update_scales(e1, e2)
}

#' Open a mira plot in the browser
#'
#' Starts a local server with the network and its view spec and opens MiRA.
#' Typing a plot's name at the console does this; call `print()` to choose
#' the port or the browser, or to open the plot in RStudio's Viewer pane
#' (`viewer = TRUE`, or `options(ggmira.viewer = TRUE)` for every plot).
#' Each print starts a new server (on the next free
#' port when `port` is taken), and shows where MiRA is served from, the
#' plot's address (`http://localhost:8080?autoload=true`) and where to
#' report issues. MiRA loads its drawing libraries from the web, so the
#' plot needs an internet connection.
#'
#' **In a script.** When R is not interactive (`Rscript`, R Markdown,
#' `R CMD check`) nothing opens and `print()` returns `NULL`, with a
#' message: no one would see the plot, and its server would stop with the
#' script. Use [mira_save()] for a file, or give `browser` to open the plot
#' anyway.
#'
#' In MiRA, the plot can still be changed. MiRA's **R** button (Copy as R
#' code, next to Save Session) shows the ggmira code for the current view,
#' starting with the `mira()` call that made the plot, to paste into a
#' script. What R cannot set is listed in comments under the code. By
#' default the code ends with `print(p, viewer = TRUE)`, which opens the
#' plot in RStudio's Viewer pane; untick the box under the code for the
#' browser.
#'
#' Every printed plot is served by its own small server, on its own port.
#' ggmira keeps the servers of the 10 most recent plots and stops older
#' ones: an older plot stays on screen, but reloading its page fails. Print
#' it again to reopen it.
#'
#' @param x A `mira_plot`.
#' @inheritParams plot_mira
#' @param ... Not used.
#' @return Invisibly, the server handle. Stop it with
#'   `httpuv::stopServer(handle)`, or stop all servers with
#'   `httpuv::stopAllServers()`. `NULL` when nothing was opened (R is not
#'   interactive and `browser` was not given).
#' @export
#' @examplesIf requireNamespace("emln", quietly = TRUE)
#' library(emln)
#' net <- load_emln(17) # 4 layers; bird and plant nodes
#' p <- mira(net, bipartite = TRUE, setA_type = "bird")
#'
#' p        # the same as print(p)
#'
#' print(p, port = 9000)            # another port
#' # print(p, browser = "chrome")   # another browser
#' # print(p, viewer = TRUE)        # RStudio's Viewer pane
#' # options(ggmira.viewer = TRUE)  # the pane for every plot
#' # print(p, mira_path = "~/MiRA") # a local copy of MiRA, not the bundled one
#'
#' # When done, stop the servers the plots started
#' httpuv::stopAllServers()
print.mira_plot <- function(x, port = 8080, mira_path = NULL,
                            browser = getOption("browser"),
                            viewer = getOption("ggmira.viewer", FALSE), ...) {
  viewer <- .use_viewer(viewer, !missing(browser), "print")
  if (!.should_serve(browser_given = !missing(browser))) return(invisible(NULL))
  message("Please report issues at ",
          "https://github.com/Ecological-Complexity-Lab/MiRA/issues")
  .serve_mira(x$network_json, view_json = .view_json(x), port = port,
              mira_path = mira_path, browser = browser, viewer = viewer)
}

#' What a plot sends to MiRA
#'
#' Shows the settings a plot sends to MiRA: those of its components, after
#' merging. Useful to check a plot before opening it.
#'
#' The list has one element per part of the plot that was set (`layout`,
#' `node`, `intralayer`, `interlayer`, `layer`, `filter`, `camera`,
#' `legend`, `mode`), each with the arguments given, and `version`, the
#' version of the format. Some settings are shown as MiRA receives them, not
#' as they were written:
#' - colors as `"#rrggbb"`;
#' - a [mira_filter()] condition as the names it keeps (node names, layer
#'   names, links as layer and node names);
#' - `color_values`, `color_scale`, `color_palette`, `color_reverse` and
#'   `color_limits` under `scales`, one entry per attribute name, merged
#'   over the components ([mira_scales]); one color per layer under
#'   `layer$colors`.
#'
#' The network itself is not included. A plot with no components sends only
#' `version`: MiRA's default view.
#'
#' @param x A `mira_plot`.
#' @param json `FALSE` (default) for an R list, `TRUE` for the JSON string
#'   MiRA receives.
#' @return A list, or a JSON string.
#' @export
#' @examplesIf requireNamespace("emln", quietly = TRUE)
#' library(emln)
#' net <- load_emln(17) # 4 layers; bird and plant nodes
#' p <- mira(net, bipartite = TRUE, setA_type = "bird")
#'
#' mira_spec(p + mira_node(color = "red"))
#' mira_spec(p + mira_node(color = "red"), json = TRUE)
mira_spec <- function(x, json = FALSE) {
  if (!inherits(x, "mira_plot")) stop("`x` must be a mira plot (from mira()).", call. = FALSE)
  spec <- c(list(version = VIEW_SPEC_VERSION), .spec_for_mira(x))
  if (isTRUE(json)) .to_json(spec) else spec
}

#' Merge a component into the spec: its fields replace the same fields
#'
#' `color` and `color_by` are one channel, so a later `color` removes an
#' earlier `color_by` in the same section, and the other way round. A
#' `color`, or a `color_by` of a different column, also removes earlier
#' `color_values` / `color_scale` (they belong to the earlier mapping),
#' unless the piece gives them too. `pairs` turns interlayer links on unless
#' the piece gives `show`. Legends given only a `position` open all.
#' @keywords internal
#' @noRd
.merge_piece <- function(spec, piece) {
  fields <- piece$fields
  if (length(fields) == 0) return(spec)
  section <- spec[[piece$section]]
  if (is.null(section)) section <- list()
  new_mapping <- "color_by" %in% names(fields) && !identical(fields$color_by, section$color_by)
  if ("color" %in% names(fields)) section[["color_by"]] <- NULL
  if ("color_by" %in% names(fields)) section[["color"]] <- NULL
  if ("color" %in% names(fields) || new_mapping) {
    for (field in setdiff(COLOR_SCALE_FIELDS, names(fields))) section[[field]] <- NULL
  }
  if ("pairs" %in% names(fields) && !"show" %in% names(fields)) section$show <- TRUE
  for (field in names(fields)) section[field] <- list(fields[[field]]) # keeps NULL values
  # mira_legends(position = ) with no `show` so far: its default, all legends open
  if (piece$section == "legend" && is.null(section$show)) section$show <- LEGEND_ALL
  spec[[piece$section]] <- section
  spec
}

#' The view spec as MiRA receives it
#'
#' The spec, and in `r` R's own text for MiRA's Copy as R code button: the
#' mira() call and the mira_filter() conditions as written (not settings;
#' view-spec.md).
#' @keywords internal
#' @noRd
.view_json <- function(plot) {
  spec <- mira_spec(plot)
  r <- list(mira = plot$r_call, filter = if (length(plot$r_filter) > 0) plot$r_filter)
  r <- Filter(Negate(is.null), r)
  if (length(r) > 0) spec$r <- r
  .to_json(spec)
}

# A later mira_filter() replaces the same argument; NULL / NA clears it
.record_filter_text <- function(plot, piece) {
  if (piece$section != "filter") return(plot)
  for (arg in names(piece$fields)) {
    condition <- piece$fields[[arg]]
    plot$r_filter[[arg]] <- if (is.null(condition)) NULL else deparse1(condition$expr)
  }
  plot
}
