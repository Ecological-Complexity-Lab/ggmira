# RStudio's Viewer pane (issue #13): `viewer = TRUE` or
# options(ggmira.viewer = TRUE); the browser outside RStudio; `browser` wins

viewer_net <- function() {
  structure(list(
    nodes = data.frame(node_id = 1:2, node_name = c("a", "b")),
    layers = data.frame(layer_id = 1, layer_name = "L1"),
    extended = data.frame(layer_from = "L1", node_from = "a", layer_to = "L1", node_to = "b", weight = 1),
    state_nodes = data.frame(layer_id = c(1, 1), node_id = 1:2, layer_name = "L1", node_name = c("a", "b"))
  ), class = "multilayer")
}

test_that("the pane opens in RStudio, the browser elsewhere", {
  opened <- list()
  local_mocked_bindings(browseURL = function(url, ...) opened$browser <<- url, .package = "utils")
  url <- "http://localhost:8080?autoload=true"

  old <- options(viewer = function(url) opened$pane <<- url)
  on.exit(options(old), add = TRUE)
  .open_mira(url, browser = NULL, viewer = TRUE)
  expect_equal(opened$pane, "http://localhost:8080?autoload=true&pane=rstudio")
  expect_null(opened$browser)
  .open_mira(url, browser = NULL, viewer = FALSE)
  expect_equal(opened$browser, url)

  opened <- list()
  options(viewer = NULL) # not RStudio
  expect_message(.open_mira(url, browser = NULL, viewer = TRUE), "Not in RStudio: opening MiRA in the browser")
  expect_equal(opened$browser, url)
})

test_that("print(), plot_mira() and plot_multilayer() take `viewer` and the option; `browser` wins", {
  served <- NULL
  local_mocked_bindings(.serve_mira = function(...) {
    served <<- list(...)
    invisible("handle")
  }, .is_interactive = function() TRUE)
  p <- suppressMessages(mira(viewer_net()))

  suppressMessages(print(p))
  expect_false(served$viewer)
  suppressMessages(print(p, viewer = TRUE))
  expect_true(served$viewer)
  suppressMessages(print(p, viewer = TRUE, browser = "firefox"))
  expect_false(served$viewer)

  old <- options(ggmira.viewer = TRUE)
  on.exit(options(old), add = TRUE)
  suppressMessages(print(p))
  expect_true(served$viewer)
  suppressMessages(plot_mira(viewer_net()))
  expect_true(served$viewer)
  suppressMessages(plot_multilayer(viewer_net()))
  expect_true(served$viewer)
  suppressMessages(plot_mira(viewer_net(), viewer = FALSE))
  expect_false(served$viewer)

  expect_error(print(p, viewer = "yes"), "`viewer` must be TRUE or FALSE")
  expect_error(plot_mira(viewer_net(), viewer = NA), "`viewer` must be TRUE or FALSE")
})
