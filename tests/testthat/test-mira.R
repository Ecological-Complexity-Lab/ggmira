# mira() plots: adding pieces, the spec, checks against the network, print.

toy_net <- function() {
  structure(list(
    nodes = data.frame(node_id = 1:4, node_name = c("p1", "p2", "h1", "h2"),
                       node_type = c("parasite", "parasite", "host", "host"),
                       mass = c(1, 2, 3, 4), guild = c("a", "b", "a", "b")),
    layers = data.frame(layer_id = 1:2, layer_name = c("L1", "L2"),
                        habitat = c("wet", "dry")),
    extended = data.frame(layer_from = c("L1", "L1", "L2", "L1"),
                          node_from = c("p1", "p2", "p1", "p1"),
                          layer_to = c("L1", "L1", "L2", "L2"),
                          node_to = c("h1", "h2", "h2", "p1"),
                          weight = c(1, 0.5, 1, 1), kind = c("x", "y", "x", "z")),
    state_nodes = data.frame(layer_id = c(1, 1, 1, 1, 2, 2), node_id = c(1, 2, 3, 4, 1, 4),
                             layer_name = c("L1", "L1", "L1", "L1", "L2", "L2"),
                             node_name = c("p1", "p2", "h1", "h2", "p1", "h2"),
                             abundance = c(5, 6, 7, 8, 9, 10), module = c(1, 1, 2, 2, 1, 1),
                             sample_size = c("", "6", "63", NA, "8", "9"))
  ), class = "multilayer")
}

toy_plot <- function(bipartite = TRUE) {
  set_a <- if (bipartite) "parasite" else NULL
  suppressMessages(mira(toy_net(), bipartite = bipartite, setA_type = set_a))
}

# ---- mira() and the spec ----

test_that("mira() makes a plot with the network JSON and an empty spec", {
  p <- toy_plot()
  expect_s3_class(p, "mira_plot")
  expect_identical(p$network_json,
                   suppressMessages(.network_json(toy_net(), bipartite = TRUE, setA_type = "parasite",
                                                  directed = FALSE)))
  expect_equal(p$set_types, c("parasite", "host"))
  expect_equal(mira_spec(p), list(version = 1))
  expect_equal(mira_spec(p, json = TRUE), '{\n  "version": 1\n}')
})

test_that("a bipartite network is undirected unless directed is given", {
  net <- toy_net() # links stored one way, so auto-detection would say directed
  expect_message(p <- mira(net, bipartite = TRUE), "drawn as undirected")
  expect_match(p$network_json, '"directed": false', fixed = TRUE)
  p <- suppressMessages(mira(net, bipartite = TRUE, directed = TRUE))
  expect_match(p$network_json, '"directed": true', fixed = TRUE)
  expect_message(p <- mira(net), "Auto-detected directed")
  expect_match(p$network_json, '"directed": true', fixed = TRUE)
})

test_that("mira() checks the network like plot_multilayer()", {
  expect_error(mira(list()), "multilayer object")
  expect_null(toy_plot(bipartite = FALSE)$set_types)
})

test_that("pieces add sections to the spec", {
  p <- toy_plot() +
    mira_layout("kamada_kawai", seed = 42) +
    mira_node(color_by = c(parasite = "module", host = NA), size = 10) +
    mira_interlayer(color = "red")
  expect_equal(mira_spec(p), list(
    version = 1,
    layout = list(type = "kamada_kawai", seed = 42),
    node = list(color_by = list(parasite = "module", host = NULL), size = 10),
    interlayer = list(color = "#ff0000")
  ))
})

test_that("later pieces override earlier ones field by field", {
  p <- toy_plot() + mira_node(size = 5, shape = "square") + mira_node(size = 12)
  expect_equal(mira_spec(p)$node, list(size = 12, shape = "square"))
})

test_that("a later color replaces an earlier color_by, and the other way round", {
  p <- toy_plot() + mira_node(color_by = "module") + mira_node(color = "blue")
  expect_equal(mira_spec(p)$node, list(color = "#0000ff"))
  p <- toy_plot() + mira_intralayer(color = "blue") + mira_intralayer(color_by = "kind")
  expect_equal(mira_spec(p)$intralayer, list(color_by = "kind"))
})

test_that("an empty piece or NULL leaves the plot unchanged", {
  p <- toy_plot()
  expect_equal(mira_spec(p + mira_node()), list(version = 1))
  expect_identical(p + NULL, p)
})

test_that("only pieces can be added, and only to a plot", {
  expect_error(toy_plot() + 1, "Only mira_\\*\\(\\) pieces")
  expect_error(mira_node(size = 5) + toy_plot(), "starts with mira\\(net\\)")
})

test_that("the JSON has null for defaults and objects for per-set values", {
  p <- toy_plot() + mira_node(color_by = NA, shape = c(parasite = "circle", host = "square"))
  json <- mira_spec(p, json = TRUE)
  expect_match(json, '"color_by": null', fixed = TRUE)
  expect_match(json, '"shape": {\n      "parasite": "circle",\n      "host": "square"\n    }',
               fixed = TRUE)
  expect_error(mira_spec(list()), "must be a mira plot")
})

# ---- Checks against the network ----

test_that("per-set values need bipartite = TRUE", {
  expect_error(toy_plot(bipartite = FALSE) + mira_node(color_by = c(parasite = "module")),
               "mira_node\\(\\): `color_by` per-set values need mira\\(..., bipartite = TRUE\\)")
  expect_error(toy_plot(bipartite = FALSE) + mira_node(shape = c(host = "square")),
               "`shape` per-set values")
})

test_that("per-set names must be node_type values", {
  expect_error(toy_plot() + mira_node(size_by = c(parasite = "mass", plant = NA)),
               "`size_by` names must be node_type values \\(parasite, host\\); not: plant")
  expect_silent(toy_plot() + mira_node(size_by = c(host = "mass")))
})

test_that("the bipartite layout and .set need bipartite = TRUE", {
  expect_error(toy_plot(bipartite = FALSE) + mira_layout("bipartite"),
               'mira_layout\\(\\): type = "bipartite" needs')
  expect_error(toy_plot(bipartite = FALSE) + mira_node(color_by = ".set"),
               'color_by = ".set" needs')
  expect_silent(toy_plot() + mira_layout("bipartite") + mira_node(color_by = ".set"))
})

test_that("node columns, state-node columns and computed attributes are accepted", {
  expect_silent(toy_plot() + mira_node(color_by = "guild"))
  expect_silent(toy_plot() + mira_node(color_by = "node_type"))
  expect_silent(toy_plot() + mira_node(size_by = "abundance"))
  expect_silent(toy_plot() + mira_node(size_by = "intra_degree_sum"))
  expect_silent(toy_plot() + mira_node(color_by = "inter_in_strength_mean"))
})

test_that("an unknown column is a warning and the setting is still sent", {
  expect_warning(p <- toy_plot() + mira_node(color_by = "modul"),
                 'mira_node\\(\\): `color_by`: "modul" is not a node or state-node column')
  expect_equal(mira_spec(p)$node$color_by, "modul")
  expect_warning(toy_plot() + mira_node(color_by = "node_name"), "not a node or state-node column")
  expect_warning(toy_plot() + mira_intralayer(color_by = "type"), '"type" is not a link column')
  expect_warning(toy_plot() + mira_layer(color_by = "climate"), '"climate" is not a layer column')
})

test_that("a keyword without its dot gets a hint where the keyword works", {
  expect_warning(toy_plot() + mira_layer(color_by = "individual"),
                 'not a layer column; MiRA keeps its default \\(did you mean ".individual"\\?\\)')
  expect_warning(toy_plot() + mira_layer(color_by = "Individual"), 'did you mean ".individual"')
  expect_warning(toy_plot() + mira_node(color_by = "set"), 'did you mean ".set"')
})

test_that("no keyword hint where the keyword would not work", {
  no_hint <- function(expr) {
    msg <- tryCatch(expr, warning = conditionMessage)
    expect_match(msg, "MiRA keeps its default$")
  }
  no_hint(toy_plot(bipartite = FALSE) + mira_node(color_by = "set"))
  no_hint(toy_plot() + mira_node(color_by = c(parasite = "set")))
  no_hint(toy_plot() + mira_node(size_by = "set"))
  no_hint(toy_plot() + mira_intralayer(color_by = "individual"))
  no_hint(toy_plot() + mira_node(color_by = "individual"))
})

test_that("size_by on a non-numeric column is a warning", {
  expect_warning(toy_plot() + mira_node(size_by = "guild"), '"guild" is not numeric')
})

test_that("numbers stored as text count as numeric, as in MiRA", {
  expect_silent(toy_plot() + mira_node(size_by = "sample_size"))
})

test_that("link color by weight is a warning (not available in MiRA yet)", {
  expect_warning(toy_plot() + mira_interlayer(color_by = "weight"), "by `weight` is not available")
})

test_that("link and layer columns are accepted", {
  expect_silent(toy_plot() + mira_intralayer(color_by = "kind") + mira_interlayer(color_by = "kind"))
  expect_silent(toy_plot() + mira_layer(color_by = "habitat"))
  expect_silent(toy_plot() + mira_layer(color_by = ".individual"))
})

test_that("a legacy node_group column counts as node_type", {
  net <- toy_net()
  names(net$nodes)[names(net$nodes) == "node_type"] <- "node_group"
  p <- suppressMessages(mira(net, bipartite = TRUE))
  expect_equal(p$set_types, c("parasite", "host"))
  expect_silent(p + mira_node(color_by = "node_type"))
})

# ---- print ----

test_that("printing serves the network and the view spec", {
  served <- NULL
  local_mocked_bindings(.serve_mira = function(...) {
    served <<- list(...)
    invisible("handle")
  })
  p <- toy_plot() + mira_node(size = 10)
  expect_equal(suppressMessages(print(p, port = 9000)), "handle")
  expect_identical(served[[1]], p$network_json)
  expect_identical(served$view_json, mira_spec(p, json = TRUE))
  expect_equal(served$port, 9000)
})
