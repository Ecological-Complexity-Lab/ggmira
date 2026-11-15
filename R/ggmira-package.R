#' ggmira: Plot multilayer networks in MiRA from R
#'
#' ggmira draws multilayer networks in MiRA, the browser-based multilayer
#' network visualizer, and describes how they should look with code, the way
#' ggplot2 does: start from the network with [mira()], add components with
#' `+`, and print the plot to open it in the browser. Everything can still
#' be changed in MiRA's interface.
#'
#' @section Plot basics:
#' - [mira()]: start a plot from a multilayer network. Or start in MiRA:
#'   [plot_mira()] opens a network with MiRA's defaults, and MiRA's R button
#'   gives the `mira()` code for the view made there.
#' - `+`: add a component to a plot.
#' - [print.mira_plot()]: open the plot in the browser (typing its name
#'   does this too). MiRA's R button copies the view back as R code.
#' - [mira_save()]: save the plot as a PNG, JPG or PDF file, without
#'   opening a window.
#' - [mira_spec()]: what the plot sends to MiRA.
#' - [mira_options()]: what each component can be set to, for a network.
#'
#' @section Elements (nodes, links, layers):
#' - [mira_node()]: node color, size, shape, labels and a highlighted node.
#' - [mira_intralayer()]: the links within layers.
#' - [mira_interlayer()]: the links between layers.
#' - [mira_layer()]: layer colors, names and arrangement.
#'
#' @section Scales:
#' - [mira_scales]: how values become colors (`color_values`,
#'   `color_scale`, `color_palette`, `color_reverse`, `color_limits`) and
#'   sizes.
#'
#' @section Layout:
#' - [mira_layout()]: where the nodes go.
#'
#' @section Camera:
#' - [mira_camera()]: rotate, tilt, zoom and pan the view.
#'
#' @section Legends:
#' - [mira_legends()]: which legends are open, and where.
#'
#' @section Data (what is drawn):
#' - [mira_filter()]: draw only some nodes, links or layers (network, grid
#'   and map views; `layers` also in the layer view).
#'
#' @section Views (MiRA's modes):
#' One view per plot; the other components still apply where MiRA uses
#' them ([mira_mode]: the rules, and what applies in each view).
#' - [mira_mode_grid()]: the layers side by side.
#' - [mira_mode_map()]: the layers on a geographic map.
#' - [mira_mode_layer()]: one bubble per layer.
#' - [mira_mode_meta()]: the network aggregated over layers; `layers` dims
#'   the nodes and links of the other layers.
#' - [mira_mode_dashboard()]: summary charts.
#' - [mira_mode_data()]: the data tables.
#'
#' @section Opening a network with MiRA's defaults:
#' - [plot_mira()]: open a network with no components, in any view
#'   (`plot_multilayer()` is the same, in the network view).
#'
#' @section Feedback:
#' - [mira_feedback()]: send feedback as a filled-in GitHub issue (with a
#'   GitHub account). The documentation pages have a *Feedback* button too.
#'
#' @section Networks:
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
