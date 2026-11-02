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
  expect_silent(toy_plot() + mira_node(color_by = "inter_strength_mean"))
})

# ---- Computed attributes ----

test_that("a computed name MiRA will not have is a warning with the variants it has", {
  directed <- suppressMessages(mira(toy_net(), bipartite = TRUE, directed = TRUE))
  expect_warning(directed + mira_node(size_by = "intra_degree_sum"),
                 paste0('"intra_degree_sum" is not computed by MiRA for this network; MiRA keeps ',
                        'its default \\(did you mean "intra_in_degree_sum" or "intra_out_degree_sum"\\?\\)'))
  expect_silent(directed + mira_node(size_by = "intra_in_degree_sum"))
  expect_silent(directed + mira_node(color_by = "inter_out_strength")) # directed network: inter too
  expect_warning(toy_plot() + mira_node(color_by = c(parasite = "intra_in_degree")),
                 'did you mean "intra_degree"')
})

test_that("interlayer attributes need interlayer links with a weight", {
  net <- toy_net()
  net$extended$weight[4] <- 0 # MiRA drops weight-0 links
  p <- suppressMessages(mira(net, bipartite = TRUE))
  expect_warning(p + mira_node(size_by = "inter_degree_sum"), "the network has no interlayer links")
  expect_silent(p + mira_node(size_by = "intra_degree_sum"))
})

test_that("directed flags follow MiRA: directed_interlayer, and logical directed columns", {
  p <- suppressMessages(mira(toy_net(), bipartite = TRUE, directed_interlayer = TRUE))
  expect_silent(p + mira_node(size_by = "inter_in_degree_sum") + mira_node(size_by = "intra_degree_sum"))
  net <- toy_net()
  net$layers$directed <- c(TRUE, FALSE)
  p <- suppressMessages(mira(net, bipartite = TRUE))
  expect_silent(p + mira_node(size_by = "intra_in_degree_sum"))
  net$layers$directed <- c("TRUE", "FALSE") # text is not true in MiRA
  p <- suppressMessages(mira(net, bipartite = TRUE))
  expect_silent(p + mira_node(size_by = "intra_degree_sum"))
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

# ---- Stage 1: labels, layer display, pairs, color scales ----

test_that("display settings go to their sections", {
  p <- toy_plot() +
    mira_node(labels = TRUE, label_size = 14, perspective = FALSE) +
    mira_layer(labels = TRUE, label_size = 20, set_labels = TRUE, stack = "vertical", spacing = 200) +
    mira_interlayer(curvature = 0.6)
  spec <- mira_spec(p)
  expect_equal(spec$node, list(labels = TRUE, label_size = 14, perspective = FALSE))
  expect_equal(spec$layer, list(labels = TRUE, label_size = 20, set_labels = TRUE,
                                stack = "vertical", spacing = 200))
  expect_equal(spec$interlayer, list(curvature = 0.6))
})

test_that("set_labels needs bipartite = TRUE", {
  expect_error(toy_plot(bipartite = FALSE) + mira_layer(set_labels = TRUE), "needs mira\\(..., bipartite = TRUE\\)")
  expect_silent(toy_plot(bipartite = FALSE) + mira_layer(set_labels = FALSE))
})

test_that("arrow_size on an undirected network is a warning", {
  expect_warning(toy_plot() + mira_intralayer(arrow_size = 2), "undirected, so MiRA draws no arrowheads")
  directed <- suppressMessages(mira(toy_net(), bipartite = TRUE, directed = TRUE))
  expect_silent(directed + mira_intralayer(arrow_size = 2))
})

test_that("pairs turn interlayer links on unless show is given", {
  expect_equal(mira_spec(toy_plot() + mira_interlayer(pairs = c("L1", "L2")))$interlayer,
               list(show = TRUE, pairs = list(list("L1", "L2"))))
  p <- toy_plot() + mira_interlayer(pairs = c("L1", "L2"), show = FALSE)
  expect_false(mira_spec(p)$interlayer$show)
  expect_match(mira_spec(p, json = TRUE), '"pairs": [\n      [\n        "L1",\n        "L2"\n      ]\n    ]',
               fixed = TRUE)
})

test_that("pairs must be layer names; a pair without interlayer links is a warning", {
  expect_error(toy_plot() + mira_interlayer(pairs = c("L1", "L9")),
               "`pairs` must use layer_name values \\(L1, L2\\); not: L9")
  expect_warning(toy_plot() + mira_interlayer(pairs = c("L2", "L2")), 'no interlayer links between "L2" and "L2"')
  expect_silent(toy_plot() + mira_interlayer(pairs = c("L2", "L1")))
})

test_that("color_values and color_scale become a scale for the color_by attribute", {
  p <- toy_plot() + mira_node(color_by = "module", color_values = c("1" = "red"))
  spec <- mira_spec(p)
  expect_equal(spec$node, list(color_by = "module"))
  expect_equal(spec$scales, list(module = list(type = "categorical", values = list("1" = "#ff0000"))))
  p <- toy_plot() + mira_intralayer(color_by = "kind", color_scale = "categorical")
  expect_equal(mira_spec(p)$scales, list(kind = list(type = "categorical")))
})

test_that("per-set color_values follow each set's color_by; shared ones apply to every set", {
  p <- toy_plot() + mira_node(color_by = c(parasite = "module", host = "guild"),
                              color_values = list(parasite = c("1" = "red"), host = c(a = "blue")))
  expect_equal(names(mira_spec(p)$scales), c("module", "guild"))
  p <- toy_plot() + mira_node(color_by = c(parasite = "module", host = "abundance"), color_scale = "categorical")
  expect_equal(mira_spec(p)$scales, list(module = list(type = "categorical"), abundance = list(type = "categorical")))
  expect_error(toy_plot() + mira_node(color_by = "module", color_values = list(parasite = c("1" = "red"))),
               "per-set `color_values` and `color_scale` need a per-set `color_by`")
  expect_error(toy_plot() + mira_node(color_by = c(parasite = "module", host = NA),
                                      color_values = list(host = c(a = "red"))),
               'need a column in `color_by` for "host"')
})

test_that("color_values need a categorical scale and a column in color_by", {
  expect_error(toy_plot() + mira_node(color_by = "module", color_scale = "continuous", color_values = c("1" = "red")),
               'need a categorical scale, not color_scale = "continuous"')
  expect_error(toy_plot() + mira_node(color_values = c("1" = "red")), "need a column in `color_by`")
  expect_error(toy_plot() + mira_node(color_by = ".set", color_values = c("1" = "red")), "need a column in `color_by`")
})

test_that("color_values may come in a later piece; a new color_by drops the earlier ones", {
  p <- toy_plot() + mira_node(color_by = "module") + mira_node(color_values = c("2" = "red"))
  expect_equal(mira_spec(p)$scales$module$values, list("2" = "#ff0000"))
  p <- p + mira_node(color_by = "abundance")
  expect_null(mira_spec(p)$scales)
  p <- toy_plot() + mira_node(color_by = "module", color_values = c("2" = "red")) + mira_node(color = "blue")
  expect_null(mira_spec(p)$scales)
})

test_that("values not in the column and continuous text columns are warnings", {
  expect_warning(toy_plot() + mira_node(color_by = "module", color_values = c("1" = "red", "9" = "red")),
                 '"9" is not a value of "module"')
  expect_warning(toy_plot() + mira_node(color_by = "guild", color_scale = "continuous"),
                 '"guild" is not numeric; MiRA uses a categorical scale')
  expect_warning(toy_plot() + mira_layer(color_by = "habitat", color_values = c(cold = "blue")),
                 '"cold" is not a value of "habitat"')
  expect_silent(toy_plot() + mira_node(color_by = "intra_degree", color_values = c("3" = "red")))
})

test_that("the same attribute in two pieces is merged; disagreements warn and the later piece wins", {
  net <- toy_net()
  net$extended$module <- c(1, 2, 1, 2)
  p <- suppressMessages(mira(net, bipartite = TRUE)) +
    mira_node(color_by = "module", color_values = c("1" = "red"))
  q <- p + mira_intralayer(color_by = "module", color_values = c("2" = "blue"))
  expect_equal(mira_spec(q)$scales$module$values, list("1" = "#ff0000", "2" = "#0000ff"))
  expect_warning(q <- p + mira_intralayer(color_by = "module", color_values = c("1" = "blue")),
                 'color_values "1" for "module" replaces the setting in mira_node\\(\\)')
  expect_equal(mira_spec(q)$scales$module$values, list("1" = "#0000ff"))
  p <- suppressMessages(mira(net, bipartite = TRUE)) +
    mira_intralayer(color_by = "module", color_scale = "categorical")
  expect_warning(q <- p + mira_interlayer(color_by = "module", color_scale = "continuous"),
                 'color_scale "continuous" for "module" replaces the setting in mira_intralayer\\(\\)')
  expect_equal(mira_spec(q)$scales, list(module = list(type = "continuous")))
})

test_that("a continuous scale and color_values for the same attribute are an error across pieces", {
  net <- toy_net()
  net$extended$module <- c(1, 2, 1, 2)
  p <- suppressMessages(mira(net, bipartite = TRUE))
  expect_error(p + mira_node(color_by = "module", color_values = c("1" = "red")) +
                 mira_intralayer(color_by = "module", color_scale = "continuous"),
               'color_scale = "continuous" for "module" cannot be combined with the color_values in mira_node\\(\\)')
  expect_error(p + mira_intralayer(color_by = "module", color_scale = "continuous") +
                 mira_node(color_by = "module", color_values = c("1" = "red")),
               'color_values for "module" cannot be combined with color_scale = "continuous" in mira_intralayer\\(\\)')
  # and within one section, from two pieces
  expect_error(p + mira_node(color_by = "module", color_values = c("1" = "red")) +
                 mira_node(color_scale = "continuous"),
               "need a categorical scale")
})

test_that("two sets giving the same attribute different colors warn; the later set wins", {
  expect_warning(
    p <- toy_plot() + mira_node(color_by = c(parasite = "module", host = "module"),
                                color_values = list(parasite = c("1" = "red"), host = c("1" = "blue"))),
    'mira_node\\(\\): color_values "1" for "module" replaces the setting for set "parasite"')
  expect_equal(mira_spec(p)$scales$module$values, list("1" = "#0000ff"))
  expect_error(toy_plot() + mira_node(color_by = c(parasite = "module", host = "module"),
                                      color_values = list(parasite = c("1" = "red")),
                                      color_scale = list(host = "continuous")),
               'cannot be combined with the color_values for set "parasite"')
  # different attributes, or the same colors: no warning
  expect_silent(toy_plot() + mira_node(color_by = c(parasite = "module", host = "abundance"),
                                       color_values = list(parasite = c("1" = "red"), host = c("5" = "blue"))))
  expect_silent(toy_plot() + mira_node(color_by = c(parasite = "module", host = "module"),
                                       color_values = list(parasite = c("1" = "red"), host = c("1" = "red"))))
})

test_that("a later piece without scale settings repeats no warning and keeps the winner", {
  net <- toy_net()
  net$extended$module <- c(1, 2, 1, 2)
  expect_warning(p <- toy_plot() + mira_node(color_by = "module", color_values = c("9" = "red")),
                 '"9" is not a value')
  expect_silent(p + mira_node(color_scale = "categorical"))
  expect_silent(p + mira_node(size = 10))
  p <- suppressMessages(mira(net, bipartite = TRUE)) +
    mira_node(color_by = "module", color_values = c("1" = "red"))
  expect_warning(p <- p + mira_intralayer(color_by = "module", color_values = c("1" = "blue")))
  expect_silent(p <- p + mira_node(color_scale = "categorical"))
  expect_equal(mira_spec(p)$scales$module$values, list("1" = "#0000ff"))
})

test_that("repeating the same color_by keeps the color_values; a different one drops them", {
  p <- toy_plot() + mira_node(color_by = "module", color_values = c("1" = "red"))
  expect_equal(mira_spec(p + mira_node(color_by = "module"))$scales$module$values, list("1" = "#ff0000"))
  expect_null(mira_spec(p + mira_node(color_by = "abundance"))$scales)
  expect_null(mira_spec(p + mira_node(color = "blue"))$scales)
})

test_that('color_values of "node_type" are checked against the type column, whatever its name', {
  net <- toy_net()
  names(net$nodes)[names(net$nodes) == "node_type"] <- "type"
  p <- suppressMessages(mira(net, bipartite = TRUE, setA_type = "parasite"))
  expect_warning(p + mira_node(color_by = "node_type", color_values = c(parasite = "red", zzz = "blue")),
                 '"zzz" is not a value of "node_type"')
  expect_silent(p + mira_node(color_by = "node_type", color_values = c(parasite = "red")))
})

test_that("links colored by weight send neither the mapping nor a scale", {
  expect_warning(p <- toy_plot() + mira_intralayer(color_by = "weight", color_values = c("1" = "red")),
                 "not available in MiRA yet")
  spec <- mira_spec(p)
  expect_null(spec$intralayer)
  expect_null(spec$scales)
})

test_that('color_by = "layer_name" with color_values sends per-layer colors', {
  p <- toy_plot() + mira_layer(color_by = "layer_name", color_values = c(L2 = "orange"))
  spec <- mira_spec(p)
  expect_equal(spec$layer, list(color_by = ".individual", colors = list(L2 = "#ffa500")))
  expect_null(spec$scales)
  expect_error(toy_plot() + mira_layer(color_by = "layer_name", color_values = c(L9 = "red")),
               "must use layer_name values \\(L1, L2\\); not: L9")
  expect_error(toy_plot() + mira_layer(color_by = "layer_name", color_scale = "categorical"),
               "does not apply to one color per layer")
})
