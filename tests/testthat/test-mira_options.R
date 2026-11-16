# mira_options(): what each component can be set to, from the network

# Two layers, parasites and hosts; node, state-node, link and layer columns
options_net <- function() {
  structure(list(
    nodes = data.frame(node_id = 1:4, node_name = c("p1", "p2", "h1", "h2"),
                       node_type = c("parasite", "parasite", "host", "host"),
                       habitat = c("a", "b", "a", "b")),
    layers = data.frame(layer_id = 1:2, layer_name = c("L1", "L2"), season = c("wet", "dry")),
    extended = data.frame(layer_from = c("L1", "L1", "L2", "L1"),
                          node_from = c("p1", "p2", "p1", "p1"),
                          layer_to = c("L1", "L1", "L2", "L2"),
                          node_to = c("h1", "h2", "h2", "p1"),
                          weight = c(1, 0.5, 1, 1), kind = c("x", "y", "x", "z")),
    state_nodes = data.frame(layer_id = c(1, 1, 1, 1, 2, 2), node_id = c(1, 2, 3, 4, 1, 4),
                             layer_name = c("L1", "L1", "L1", "L1", "L2", "L2"),
                             node_name = c("p1", "p2", "h1", "h2", "p1", "h2"),
                             abundance = c(5, 6, 7, 8, 9, 10), module = c(1, 1, 2, 2, 1, 1))
  ), class = "multilayer")
}

toy_options <- function(...) mira_options(options_net(), ...)

test_that("node attributes: data columns, computed ones and .set on a bipartite network", {
  opts <- toy_options(bipartite = TRUE)
  color <- opts[opts$component == "mira_node" & opts$argument == "color_by", ]
  expect_true(all(c("module", "abundance", "intra_degree_sum", ".set") %in% color$attribute))
  expect_equal(color$source[color$attribute == "intra_degree_sum"], "computed")
  expect_equal(color$type[color$attribute == ".set"], "set")
  expect_false(".set" %in% toy_options()$attribute)
})

test_that("the type is MiRA's default scale; numbers can switch", {
  color <- toy_options()
  color <- color[color$component == "mira_node" & color$argument == "color_by", ]
  row <- function(attr) color[color$attribute == attr, ]
  expect_equal(row("module")$type, "categorical") # a partition name stays categorical
  expect_true(row("module")$switchable)
  expect_equal(row("abundance")$type, "continuous")
})

test_that("MiRA's colorMapper rule", {
  expect_equal(.default_scale("x", c(1, 2, 3))$type, "continuous")
  expect_equal(.default_scale("x", c(1, 2))$type, "categorical")       # two values
  expect_equal(.default_scale("mass", c(1, 2))$type, "continuous")     # a continuous name
  expect_equal(.default_scale("module", 1:10)$type, "categorical")     # a group name
  expect_equal(.default_scale("module_size", 1:10)$type, "continuous") # continuous wins
  expect_equal(.default_scale("habitat", c("a", "b", "c")),
               list(type = "categorical", switchable = FALSE))
  expect_true(.default_scale("x", c("1", "2", "3"))$switchable)       # numbers as text
})

test_that("size_by lists numeric attributes only", {
  opts <- toy_options()
  size <- opts$attribute[opts$component == "mira_node" & opts$argument == "size_by"]
  expect_true("abundance" %in% size)
  expect_false(any(c("habitat", "node_type") %in% size))
})

test_that("links, layers, filters and the meta-network are listed", {
  opts <- toy_options()
  expect_true("min_weight" %in% opts$argument[opts$component == "mira_intralayer"])
  expect_false("weight" %in% opts$attribute[opts$component == "mira_intralayer" & opts$argument == "color_by"])
  expect_true("layer_name" %in% opts$attribute[opts$component == "mira_layer"])
  expect_setequal(opts$attribute[opts$component == "mira_filter" & opts$argument == "links"],
                  names(options_net()$extended))
  meta <- opts[opts$component == "mira_mode_meta", ]
  expect_true(all(c("participation", "degree", "uniform") %in% meta$attribute))
  expect_setequal(meta$attribute[meta$argument == "layers"], names(options_net()$layers))
})

test_that("directed networks list in- and out-degree, as mira() computes", {
  opts <- toy_options(directed = TRUE)
  expect_true("intra_in_degree" %in% opts$attribute)
  expect_false("intra_degree" %in% opts$attribute)
})

test_that("values: a range for numbers, the values for categories", {
  expect_equal(.values_summary(c(1, 5, NA, 3), "continuous"), "1 to 5 (3 values)")
  expect_equal(.values_summary(c(2, 2), "continuous"), "1 value: 2")
  expect_equal(.values_summary(c("b", "a", "b"), "categorical"), "2 values: a, b")
  expect_equal(.values_summary(letters, "categorical"), "26 values: a, b, c, d, e, ...")
  expect_equal(.values_summary(c(NA, NA), "categorical"), "no values")
})

test_that("it prints grouped by component, computed attributes on one line", {
  out <- capture.output(print(toy_options()))
  expect_true("mira_node()" %in% out)
  expect_true("mira_mode_meta()" %in% out)
  expect_equal(sum(grepl("\\(computed\\)", out)), 2) # color_by and size_by
  expect_true(any(grepl("color_scale can choose the other", out)))
})

test_that("sets: the node sets that have the attribute, on a bipartite network", {
  net <- options_net()
  net$nodes$host_range <- c(NA, NA, "narrow", "wide") # hosts only
  opts <- mira_options(net, bipartite = TRUE)
  color <- opts[opts$component == "mira_node" & opts$argument == "color_by", ]
  expect_equal(color$sets[color$attribute == "host_range"], "host")
  expect_equal(color$sets[color$attribute == "habitat"], "parasite, host")
  expect_equal(unique(toy_options()$sets), "") # not bipartite: no sets
})

test_that("colors: by element where the console has colors, none otherwise", {
  plain <- capture.output(print(toy_options()))
  expect_false(any(grepl("\033[", plain, fixed = TRUE)))
  old <- options(cli.num_colors = 256)
  colored <- capture.output(print(toy_options()))
  options(old)
  expect_true(any(grepl("\033[", colored, fixed = TRUE)))
  expect_equal(cli::ansi_strip(colored[seq_along(plain)]), plain) # the same text and alignment
  expect_equal(.row_element(c("mira_node", "mira_filter", "mira_filter", "mira_interlayer", "mira_mode_meta",
                              "mira_mode_meta"),
                            c("color_by", "nodes", "links", "color_by", "color_by", "layers")),
               c("node", "node", "intralayer link", "interlayer link", "node", "layer"))
})

test_that("the printed sets column shows only when the sets differ", {
  same <- capture.output(print(toy_options(bipartite = TRUE)))
  expect_false(any(grepl("parasite, host", same[!grepl("one color per set", same)])))
  net <- options_net()
  net$nodes$host_range <- c(NA, NA, "narrow", "wide")
  differ <- capture.output(print(mira_options(net, bipartite = TRUE)))
  expect_true(any(grepl("host_range.*host ", differ)))
})
