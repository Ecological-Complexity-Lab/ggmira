# mira_filter(): conditions and names, evaluated against the network.

filter_net <- function() {
  structure(list(
    nodes = data.frame(node_id = 1:4, node_name = c("p1", "p2", "h1", "h2"),
                       node_type = c("parasite", "parasite", "host", "host"),
                       mass = c(1, 2, NA, 4)),
    layers = data.frame(layer_id = 1:2, layer_name = c("L1", "L2")),
    extended = data.frame(layer_from = c("L1", "L1", "L2", "L1"),
                          node_from = c("p1", "p2", "p1", "p1"),
                          layer_to = c("L1", "L1", "L2", "L2"),
                          node_to = c("h1", "h2", "h2", "p1"),
                          weight = c(1, 0.5, 1, 1)),
    state_nodes = data.frame(layer_id = c(1, 1, 1, 1, 2, 2), node_id = c(1, 2, 3, 4, 1, 4),
                             layer_name = c("L1", "L1", "L1", "L1", "L2", "L2"),
                             node_name = c("p1", "p2", "h1", "h2", "p1", "h2"))
  ), class = "multilayer")
}

filter_plot <- function() suppressMessages(mira(filter_net(), bipartite = TRUE, setA_type = "parasite"))

test_that("a filter prints as the call, with its conditions", {
  expect_equal(format(mira_filter(nodes = node_type == "host", links = weight > 0.5)),
               'mira_filter(nodes = node_type == "host", links = weight > 0.5)')
  expect_equal(format(mira_filter(nodes = NULL)), "mira_filter(nodes = NA)")
})

test_that("node conditions and names become node names", {
  spec <- mira_spec(filter_plot() + mira_filter(nodes = node_type == "host"))
  expect_equal(spec$filter, list(nodes = list("h1", "h2")))
  spec <- mira_spec(filter_plot() + mira_filter(nodes = c("p2", "h1", "h1")))
  expect_equal(spec$filter$nodes, list("p2", "h1"))
  # NA drops the row, as in subset()
  expect_equal(mira_spec(filter_plot() + mira_filter(nodes = mass > 1))$filter$nodes, list("p2", "h2"))
})

test_that("link conditions become [layer_from, node_from, layer_to, node_to]", {
  spec <- mira_spec(filter_plot() + mira_filter(links = weight == 1 & layer_from == layer_to))
  expect_equal(spec$filter$links, list(list("L1", "p1", "L1", "h1"), list("L2", "p1", "L2", "h2")))
  expect_match(mira_spec(filter_plot() + mira_filter(links = weight < 1), json = TRUE),
               '"links": [\n      [\n        "L1",\n        "p2",\n        "L1",\n        "h2"\n      ]\n    ]',
               fixed = TRUE)
})

test_that("conditions see the caller's variables, inside functions too", {
  keep <- "p1"
  expect_equal(mira_spec(filter_plot() + mira_filter(nodes = node_name %in% keep))$filter$nodes, list("p1"))
  f <- function(min) filter_plot() + mira_filter(links = weight >= min)
  expect_length(mira_spec(f(1))$filter$links, 3)
})

test_that("nodes and links combine; a later filter replaces the same argument only", {
  p <- filter_plot() + mira_filter(nodes = node_type == "host") + mira_filter(links = weight < 1)
  expect_equal(names(mira_spec(p)$filter), c("nodes", "links"))
  p <- p + mira_filter(nodes = "p1")
  expect_equal(mira_spec(p)$filter$nodes, list("p1"))
  expect_length(mira_spec(p)$filter$links, 1)
  expect_null(mira_spec(p + mira_filter(nodes = NULL))$filter$nodes)
  expect_match(mira_spec(p + mira_filter(nodes = NA), json = TRUE), '"nodes": null', fixed = TRUE)
})

test_that("unknown names, missing columns and other values are errors", {
  expect_error(filter_plot() + mira_filter(nodes = c("p1", "x9")),
               '`nodes` "x9" is not a node name \\(node_name values include p1, p2, h1, h2\\)')
  expect_error(filter_plot() + mira_filter(nodes = colour == "red"),
               "`nodes` could not be evaluated on the columns of net\\$nodes: object 'colour' not found")
  expect_error(filter_plot() + mira_filter(nodes = 1:2), "must be node names or a condition")
  expect_error(filter_plot() + mira_filter(links = "p1"), "must be a condition on the columns of net\\$extended")
  expect_error(filter_plot() + mira_filter(links = TRUE), "TRUE or FALSE for each link")
})

test_that("a filter that keeps nothing is a warning", {
  expect_warning(p <- filter_plot() + mira_filter(nodes = mass > 100), "keeps no nodes")
  expect_equal(mira_spec(p)$filter$nodes, list())
  expect_match(mira_spec(p, json = TRUE), '"nodes": \\[\\s*\\]') # an empty array
  expect_warning(filter_plot() + mira_filter(links = weight > 5), "keeps no links")
})
