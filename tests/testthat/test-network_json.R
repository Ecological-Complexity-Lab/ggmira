# ggmira's converter is a copy of emln::multilayer_to_json(). These tests
# make sure the two give byte-identical JSON, so the copies cannot drift.

emln_json <- function(net, ...) {
  suppressMessages(emln::multilayer_to_json(net, ...))
}
ggmira_json <- function(net, ...) {
  suppressMessages(.network_json(net, ...))
}

test_that("JSON is identical to emln::multilayer_to_json() on emln datasets", {
  skip_if_not_installed("emln")
  # load_emln() needs emln attached (it reads its lazy-loaded datasets
  # without the emln:: prefix)
  suppressPackageStartupMessages(library(emln))
  cases <- list(
    list(id = 1,  args = list(bipartite = TRUE, setA_type = "frugivore")),
    list(id = 14, args = list(bipartite = TRUE)),
    list(id = 60, args = list(bipartite = FALSE)),
    list(id = 23, args = list(bipartite = TRUE, setA_type = "parasite",
                              directed = TRUE, directed_interlayer = FALSE))
  )
  for (case in cases) {
    net <- suppressMessages(emln::load_emln(case$id))
    expect_identical(
      do.call(ggmira_json, c(list(net), case$args)),
      do.call(emln_json, c(list(net), case$args)),
      label = paste("emln dataset", case$id)
    )
  }
})

test_that("JSON is identical with interlayer links, NA attributes and auto-detected direction", {
  skip_if_not_installed("emln")
  net <- structure(list(
    nodes = data.frame(node_id = 1:3, node_name = c("a", "b", "c"),
                       node_type = c("x", "y", "y"), mass = c(1.5, NA, 3)),
    layers = data.frame(layer_id = 1:2, layer_name = c("L1", "L2")),
    extended = data.frame(layer_from = c("L1", "L1", "L1"), node_from = c("a", "b", "a"),
                          layer_to = c("L1", "L1", "L2"), node_to = c("b", "a", "a"),
                          weight = c(1, 1, 0.5)),
    state_nodes = data.frame(layer_id = c(1, 1, 2), node_id = c(1, 2, 1),
                             layer_name = c("L1", "L1", "L2"), node_name = c("a", "b", "a"),
                             abundance = c(10, NA, 4))
  ), class = "multilayer")
  expect_identical(ggmira_json(net), emln_json(net))
  expect_identical(ggmira_json(net, bipartite = TRUE, setA_type = "y"),
                   emln_json(net, bipartite = TRUE, setA_type = "y"))
})

test_that("input checks match emln", {
  expect_error(.network_json(list()), "multilayer object")
  net <- structure(list(nodes = data.frame(node_name = "a")), class = "multilayer")
  expect_error(.network_json(net, bipartite = TRUE), "no `node_type`")
})

test_that("links with weight 0, which MiRA does not draw, give a warning", {
  net <- function(weight) structure(list(extended = data.frame(layer_from = "L1", weight = weight)),
                                    class = "multilayer")
  expect_warning(.warn_zero_weight(net(c(1, 0, 0.5, 0)), "mira"),
                 'mira\\(\\): MiRA treats weight 0 as "no link": 2 of 4 links have weight 0')
  expect_warning(.warn_zero_weight(net(c("0", "1")), "plot_mira"), "plot_mira\\(\\): .*1 of 2 links") # as in MiRA
  expect_warning(.warn_zero_weight(net(c(NA, 0, 1)), "mira"), "1 of 3 links")
  expect_no_warning(.warn_zero_weight(net(c(1, 0.5)), "mira"))
  no_weight <- structure(list(extended = data.frame(layer_from = "L1")), class = "multilayer")
  expect_no_warning(.warn_zero_weight(no_weight, "mira"))
})
