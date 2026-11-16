# mira_camera(), mira_legends(), mira_node(highlight).

view_plot <- function() {
  net <- structure(list(
    nodes = data.frame(node_id = 1:4, node_name = c("p1", "p2", "h1", "h2"),
                       node_type = c("parasite", "parasite", "host", "host")),
    layers = data.frame(layer_id = 1:2, layer_name = c("L1", "L2")),
    extended = data.frame(layer_from = c("L1", "L2"), node_from = c("p1", "p1"),
                          layer_to = c("L1", "L2"), node_to = c("h1", "h2"), weight = c(1, 1)),
    state_nodes = data.frame(layer_id = c(1, 1, 2, 2), node_id = c(1, 3, 1, 4),
                             layer_name = c("L1", "L1", "L2", "L2"),
                             node_name = c("p1", "h1", "p1", "h2"))
  ), class = "multilayer")
  suppressMessages(mira(net, bipartite = TRUE, setA_type = "parasite"))
}

test_that("the camera goes to its own section; pan is an array", {
  spec <- mira_spec(view_plot() + mira_camera(rotate = 70, tilt = -15, zoom = 1.5, pan = c(0.1, 0)))
  expect_equal(spec$camera, list(rotate = 70, tilt = -15, zoom = 1.5, pan = list(0.1, 0)))
  expect_match(mira_spec(view_plot() + mira_camera(pan = c(0.1, 0)), json = TRUE),
               '"pan": [\n      0.1,\n      0\n    ]', fixed = TRUE)
})

test_that("camera values are checked against MiRA's limits", {
  expect_error(mira_camera(rotate = "left"), "`rotate` must be a number of degrees")
  expect_error(mira_camera(tilt = 60), "between -45 and 45")
  expect_error(mira_camera(zoom = 0), "between 0.2 and 5")
  expect_error(mira_camera(pan = c(2, 0)), "c\\(x, y\\), each between -1 and 1")
  expect_error(mira_camera(pan = 0.1), "c\\(x, y\\)")
})

test_that("mira_legends() opens all by default, or the ones named", {
  expect_equal(mira_spec(view_plot() + mira_legends())$legend, list(show = "all"))
  spec <- mira_spec(view_plot() + mira_legends(show = c("node_color", "layer_color", "node_color"),
                                               position = "top-right"))
  expect_equal(spec$legend, list(show = list("node_color", "layer_color"), position = "top-right"))
  expect_equal(mira_spec(view_plot() + mira_legends(show = FALSE))$legend, list(show = FALSE))
  expect_match(mira_spec(view_plot() + mira_legends(show = "node_size"), json = TRUE),
               '"show": [\n      "node_size"\n    ]', fixed = TRUE)
})

test_that("legend names and positions are checked", {
  expect_error(mira_legends(show = "node_colour"), '`show` must be "all", FALSE, or legend names')
  expect_equal(mira_spec(view_plot() + mira_legends(show = TRUE))$legend, list(show = "all"))
  expect_error(mira_legends(position = "top-left"), '"bottom-right", "top-right", "bottom-left"')
})

test_that("components print as their call", {
  expect_equal(format(mira_legends()), 'mira_legends(show = "all")')
  expect_equal(format(mira_camera(rotate = 70, pan = c(-0.1, 0.05))),
               "mira_camera(rotate = 70, pan = c(-0.1, 0.05))")
})

test_that("highlight is one node name of the network", {
  expect_equal(mira_spec(view_plot() + mira_node(highlight = "h1"))$node, list(highlight = "h1"))
  expect_error(view_plot() + mira_node(highlight = "x9"), '`highlight` "x9" is not a node name')
  expect_error(mira_node(highlight = c("h1", "h2")), "`highlight` must be one name")
})

test_that("tilt is checked in degrees", {
  expect_error(mira_camera(tilt = 60), "`tilt` must be a number of degrees between -45 and 45")
})

test_that("a later mira_legends() changes only the arguments it gives", {
  p <- view_plot() + mira_legends(show = "node_color")
  expect_equal(mira_spec(p + mira_legends(position = "top-right"))$legend,
               list(show = list("node_color"), position = "top-right"))
  expect_equal(format(mira_legends(position = "top-right")), 'mira_legends(position = "top-right")')
  # without an earlier show: the default, all legends open
  expect_equal(mira_spec(view_plot() + mira_legends(position = "bottom-left"))$legend,
               list(position = "bottom-left", show = "all"))
  # FALSE is a `show` too, and stays
  expect_equal(mira_spec(view_plot() + mira_legends(show = FALSE) + mira_legends(position = "top-right"))$legend,
               list(show = FALSE, position = "top-right"))
})

test_that("a highlighted node hidden by the filter is a warning, in either order", {
  expect_warning(view_plot() + mira_node(highlight = "h1") + mira_filter(nodes = "p1"),
                 'mira_filter\\(\\): the highlighted node "h1" is hidden by `mira_filter\\(nodes\\)`')
  expect_warning(view_plot() + mira_filter(nodes = "p1") + mira_node(highlight = "h1"),
                 "mira_node\\(\\): the highlighted node")
  expect_silent(view_plot() + mira_filter(nodes = c("p1", "h1")) + mira_node(highlight = "h1"))
  expect_silent(view_plot() + mira_node(highlight = "h1") + mira_filter(links = weight > 0))
})

test_that("highlight uses the same unknown-name message as mira_filter(nodes)", {
  expect_error(view_plot() + mira_node(highlight = "x9"),
               '`highlight` "x9" is not a node name \\(node_name values include p1, p2, h1, h2\\)')
})
