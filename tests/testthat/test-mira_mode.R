# mira_mode_*(): the view MiRA opens in; plot_mira(mode).

mode_net <- function(coordinates = FALSE) {
  layers <- data.frame(layer_id = 1:2, layer_name = c("L1", "L2"))
  if (coordinates) layers <- cbind(layers, latitude = c(10, 11), longitude = c(20, 21))
  structure(list(
    nodes = data.frame(node_id = 1:4, node_name = c("p1", "p2", "h1", "h2"),
                       node_type = c("parasite", "parasite", "host", "host")),
    layers = layers,
    extended = data.frame(layer_from = c("L1", "L2"), node_from = c("p1", "p1"),
                          layer_to = c("L1", "L2"), node_to = c("h1", "h2"), weight = c(1, 1)),
    state_nodes = data.frame(layer_id = c(1, 1, 2, 2), node_id = c(1, 3, 1, 4),
                             layer_name = c("L1", "L1", "L2", "L2"),
                             node_name = c("p1", "h1", "p1", "h2"))
  ), class = "multilayer")
}
mode_plot <- function(bipartite = TRUE, coordinates = FALSE) {
  net <- mode_net(coordinates)
  suppressMessages(if (bipartite) mira(net, bipartite = TRUE, setA_type = "parasite") else mira(net))
}

test_that("each mira_mode_*() sends its view in the mode section", {
  expect_equal(mira_spec(mode_plot() + mira_mode_grid(columns = 2))$mode, list(view = "grid", columns = 2))
  expect_equal(mira_spec(mode_plot() + mira_mode_grid())$mode, list(view = "grid"))
  expect_equal(mira_spec(mode_plot(coordinates = TRUE) + mira_mode_map())$mode, list(view = "map"))
  for (view in c("layer", "dashboard", "data", "meta")) {
    piece <- get(paste0("mira_mode_", view))()
    expect_equal(mira_spec(mode_plot() + piece)$mode, list(view = view))
  }
  expect_match(mira_spec(mode_plot() + mira_mode_grid(columns = 2), json = TRUE),
               '"mode": {\n    "view": "grid",\n    "columns": 2\n  }', fixed = TRUE)
})

test_that("mira_mode_meta() sends its settings; one color or one per set", {
  spec <- mira_spec(mode_plot() + mira_mode_meta(aggregation = "weights", layout = "bipartite", color_by = "participation",
                                                 size_by = "degree", size = 1.5, min_weight = 2, nested = FALSE,
                                                 labels = TRUE, label_size = 14))
  expect_equal(spec$mode, list(view = "meta", aggregation = "weights", layout = "bipartite", color_by = "participation",
                               size_by = "degree", size = 1.5, min_weight = 2, nested = FALSE, labels = TRUE,
                               label_size = 14))
  expect_equal(mira_spec(mode_plot() + mira_mode_meta(color = "red"))$mode, list(view = "meta", color = "#ff0000"))
  # color and color_by are one channel, as in the other components
  expect_error(mira_mode_meta(color_by = "degree", color = "red"), "give `color_by` or `color`, not both")
  p <- mode_plot() + mira_mode_meta(color_by = "degree") + mira_mode_meta(color = "red")
  expect_equal(mira_spec(p)$mode, list(view = "meta", color = "#ff0000"))
  spec <- mira_spec(mode_plot() + mira_mode_meta(color = c(parasite = "red", host = "blue")))
  expect_equal(spec$mode$color, list(parasite = "#ff0000", host = "#0000ff"))
})

test_that("views print as their call", {
  expect_equal(format(mira_mode_grid(columns = 3)), "mira_mode_grid(columns = 3)")
  expect_equal(format(mira_mode_data()), "mira_mode_data()")
  expect_equal(format(mira_mode_meta(layout = "circular", labels = TRUE)),
               'mira_mode_meta(layout = "circular", labels = TRUE)')
})

test_that("arguments are checked", {
  expect_error(mira_mode_grid(columns = 9), "`columns` must be a whole number between 1 and 8")
  expect_error(mira_mode_grid(columns = 1.5), "whole number")
  expect_error(mira_mode_meta(aggregation = "sum"), '"occurrence", "weights", "union"')
  expect_error(mira_mode_meta(layout = "two-row"), '"circular", "force", "bipartite"')
  expect_error(mira_mode_meta(color_by = "module"), '"participation", "degree", "uniform"')
  expect_error(mira_mode_meta(size = 5), "between 0.2 and 3")
  expect_error(mira_mode_meta(min_weight = -1), "0 or more")
  expect_error(mira_mode_meta(label_size = 30), "between 8 and 24")
  expect_error(mira_mode_meta(labels = "yes"), "TRUE or FALSE")
})

test_that("checks against the network: map coordinates, bipartite-only settings, set names", {
  expect_error(mode_plot() + mira_mode_map(), "the map needs the layers' coordinates")
  expect_error(mode_plot(bipartite = FALSE) + mira_mode_meta(layout = "bipartite"),
               'layout = "bipartite" needs mira\\(..., bipartite = TRUE\\)')
  expect_error(mode_plot(bipartite = FALSE) + mira_mode_meta(nested = TRUE), "`nested` needs mira")
  expect_error(mode_plot() + mira_mode_meta(color = c(bird = "red")), "names must be node_type values")
  expect_warning(mode_plot() + mira_mode_meta(layout = "circular", nested = FALSE),
                 '`nested` is used only by layout = "bipartite"')
  expect_warning(mode_plot() + mira_mode_meta(layout = "force") + mira_mode_meta(nested = TRUE),
                 "used only by")
  expect_silent(mode_plot() + mira_mode_meta(nested = FALSE))
})

test_that("one view per plot: another view replaces the earlier one, with a warning", {
  expect_warning(p <- mode_plot() + mira_mode_meta(labels = TRUE) + mira_mode_grid(columns = 2),
                 "mira_mode_grid\\(\\) replaces mira_mode_meta\\(\\): a plot opens in one view")
  expect_equal(mira_spec(p)$mode, list(view = "grid", columns = 2))
  # the same view: arguments merge, no warning
  expect_silent(p <- mode_plot() + mira_mode_meta(labels = TRUE) + mira_mode_meta(size = 2))
  expect_equal(mira_spec(p)$mode, list(view = "meta", labels = TRUE, size = 2))
})

test_that("mira_camera() with another view is a warning, in either order, once", {
  expect_warning(mode_plot() + mira_camera(rotate = 10) + mira_mode_grid(),
                 "mira_mode_grid\\(\\): mira_camera\\(\\) has no effect in mira_mode_grid\\(\\)")
  expect_warning(mode_plot() + mira_mode_meta() + mira_camera(zoom = 2), "mira_camera\\(\\): mira_camera\\(\\) has no effect")
  p <- suppressWarnings(mode_plot() + mira_mode_meta() + mira_camera(zoom = 2))
  expect_silent(p + mira_node(size = 5))
  expect_silent(mode_plot() + mira_camera(zoom = 2) + mira_node(size = 5))
})

test_that("mira_filter() with a view other than network, grid or map is a warning, once", {
  expect_warning(mode_plot() + mira_filter(nodes = "p1") + mira_mode_meta(),
                 paste0("mira_mode_meta\\(\\): mira_filter\\(\\) is not applied in the meta-network, ",
                        ".*network, grid and map modes; to dim layers .* mira_mode_meta\\(layers = \\)"))
  expect_warning(mode_plot() + mira_mode_data() + mira_filter(links = weight > 0),
                 "mira_filter\\(\\): mira_filter\\(\\) is not applied in data mode, which shows the whole network; MiRA's data filter works in network, grid and map modes$")
  expect_silent(mode_plot(coordinates = TRUE) + mira_filter(nodes = "p1") + mira_mode_map())
  expect_silent(mode_plot() + mira_filter(nodes = "p1") + mira_mode_grid())
  p <- suppressWarnings(mode_plot() + mira_mode_layer() + mira_filter(nodes = "p1"))
  expect_silent(p + mira_node(size = 5))
})

test_that("the highlight warning comes once, when the filter or the highlight is added", {
  p <- suppressWarnings(mode_plot() + mira_node(highlight = "h1") + mira_filter(nodes = "p1"))
  expect_silent(p + mira_layout("circle"))
})

test_that("plot_mira() checks the mode, and the map's coordinates, before opening", {
  expect_error(plot_mira(mode_net(), mode = "globe"), '`mode` must be one of "network", "grid", "map"')
  expect_error(plot_mira(mode_net(), mode = "map"), '"map" needs the layers\' coordinates')
  # not interactive: nothing opens
  expect_null(suppressMessages(plot_mira(mode_net(coordinates = TRUE), mode = "map")))
  expect_identical(formals(plot_multilayer)$mode, NULL)
})

test_that("mira_mode_meta(layers = ) takes layer names or a condition on net$layers", {
  layers_of <- function(piece, plot = mode_plot()) mira_spec(plot + piece)$mode$layers
  expect_equal(layers_of(mira_mode_meta(layers = c("L2", "L1", "L2"))), list("L2", "L1"))
  expect_equal(layers_of(mira_mode_meta(layers = layer_name != "L1")), list("L2"))
  expect_equal(layers_of(mira_mode_meta(layers = !layer_name %in% c("L1"))), list("L2"))
  expect_equal(layers_of(mira_mode_meta(layers = latitude > 10), mode_plot(coordinates = TRUE)), list("L2"))
  keep <- "L1"
  expect_equal(layers_of(mira_mode_meta(layers = layer_name == keep)), list("L1"))
  expect_equal(layers_of(mira_mode_meta(layers = NULL)), list())
  expect_equal(layers_of(mira_mode_meta(layers = NA)), list())
  # a JSON array, also for one name or none (whitespace removed from the printed JSON)
  json_of <- function(layers) gsub("\\s", "", mira_spec(mode_plot() + mira_mode_meta(layers = layers), json = TRUE))
  expect_match(json_of("L1"), '"layers":["L1"]', fixed = TRUE)
  expect_match(json_of(NULL), '"layers":[]', fixed = TRUE)
  # a later meta component keeps the layers; a later layers replaces them
  p <- mode_plot() + mira_mode_meta(layers = "L1") + mira_mode_meta(size = 2)
  expect_equal(mira_spec(p)$mode$layers, list("L1"))
  expect_equal(mira_spec(p + mira_mode_meta(layers = "L2"))$mode$layers, list("L2"))
})

test_that("mira_mode_meta(layers = ) checks names and conditions against the network", {
  expect_error(mode_plot() + mira_mode_meta(layers = c("L1", "L9")),
               'mira_mode_meta\\(\\): `layers` "L9" is not a layer name \\(layer_name values: L1, L2\\)')
  expect_error(mode_plot() + mira_mode_meta(layers = no_such_column > 1),
               "mira_mode_meta\\(\\): `layers` could not be evaluated on the columns of net\\$layers")
  expect_error(mode_plot() + mira_mode_meta(layers = 1), "must be layer names or a condition")
  expect_error(mode_plot() + mira_mode_meta(layers = c("L1", NA)), "names must not be NA")
  expect_warning(mode_plot() + mira_mode_meta(layers = layer_name == "none"),
                 "mira_mode_meta\\(\\): `layers` keeps no layers; nothing is dimmed")
})

test_that("a mira_mode_meta() component with layers prints its condition", {
  expect_output(print(mira_mode_meta(layers = layer_name != "L1")), 'mira_mode_meta\\(layers = layer_name != "L1"\\)')
})
