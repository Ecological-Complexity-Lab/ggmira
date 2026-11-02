#' ggmira: Plot multilayer networks in MiRA from R
#'
#' ggmira draws multilayer networks in MiRA, the browser-based multilayer
#' network visualizer, and describes how they should look with code, the way
#' ggplot2 does: start from the network with [mira()], add components with
#' `+`, and print the plot to open it in the browser. Everything can still
#' be changed in MiRA's interface.
#'
#' @section Plot basics:
#' - [mira()]: start a plot from a multilayer network.
#' - `+`: add a component to a plot.
#' - [print.mira_plot()]: open the plot in the browser (typing its name
#'   does this too).
#' - [mira_spec()]: what the plot sends to MiRA.
#'
#' @section Elements (nodes, links, layers):
#' - [mira_node()]: node color, size, shape and labels.
#' - [mira_intralayer()]: the links within layers.
#' - [mira_interlayer()]: the links between layers.
#' - [mira_layer()]: layer colors, names and arrangement.
#'
#' @section Scales:
#' - [mira_scales]: how values become colors (`color_values`,
#'   `color_scale`) and sizes.
#'
#' @section Layout:
#' - [mira_layout()]: where the nodes go.
#'
#' @section Data (what is drawn):
#' - [mira_filter()]: draw only some nodes or links.
#'
#' @section Opening a network with MiRA's defaults:
#' - [plot_multilayer()]: open a network with no components.
#'
#' @section Data:
#' ggmira works with the multilayer objects of the emln package
#' (`emln::load_emln()`, `emln::create_multilayer_network()`). MiRA reads
#' their four tables; a column added to `net$nodes`, `net$state_nodes`,
#' `net$extended` or `net$layers` can be mapped like any other.
#'
#' The full list of functions: `help(package = "ggmira")`. Please report
#' MiRA issues at <https://github.com/Ecological-Complexity-Lab/MiRA/issues>.
#'
#' @keywords internal
"_PACKAGE"
