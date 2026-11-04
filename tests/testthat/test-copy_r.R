# MiRA's Copy as R code: R sends its own text (the mira() call, filter
# conditions) with the spec; with Chrome, the code MiRA shows gives the
# plot's spec back.

copy_net <- function() {
  structure(list(
    nodes = data.frame(node_id = 1:4, node_name = c("p1", "p2", "h1", "h2"),
                       node_type = c("parasite", "parasite", "host", "host"),
                       size = c(1, 2, 3, 4)),
    layers = data.frame(layer_id = 1:2, layer_name = c("L1", "L2")),
    extended = data.frame(layer_from = c("L1", "L2", "L1"), node_from = c("p1", "p1", "p2"),
                          layer_to = c("L1", "L2", "L1"), node_to = c("h1", "h2", "h2"),
                          weight = c(1, 1, 2), type = c("a", "b", "a")),
    state_nodes = data.frame(layer_id = c(1, 1, 1, 2, 2), node_id = c(1, 2, 3, 1, 4),
                             layer_name = c("L1", "L1", "L1", "L2", "L2"),
                             node_name = c("p1", "p2", "h1", "p1", "h2"))
  ), class = "multilayer")
}

test_that("the view MiRA receives has R's text: the mira() call and filter conditions", {
  net <- copy_net()
  p <- suppressMessages(mira(net, bipartite = TRUE, setA_type = "parasite"))
  expect_equal(p$r_call, 'mira(net, bipartite = TRUE, setA_type = "parasite")')
  keep <- "p1"
  p <- p + mira_filter(nodes = node_name %in% keep)
  json <- .view_json(p)
  expect_match(json, '"mira": "mira(net, bipartite = TRUE, setA_type = \\"parasite\\")"', fixed = TRUE)
  expect_match(json, '"nodes": "node_name %in% keep"', fixed = TRUE)
  # not a setting: mira_spec() is unchanged
  expect_null(mira_spec(p)$r)
  # a later filter replaces the argument; NULL clears it
  expect_null((p + mira_filter(nodes = NULL))$r_filter$nodes)
  # a call that was not typed (the network deparsed) is not sent
  long <- do.call(mira, list(net, bipartite = TRUE, setA_type = "parasite"))
  expect_null(long$r_call)
  expect_no_match(.view_json(long), '"mira":', fixed = TRUE)
})

test_that("plot_mira() sends the mira() call of the same plot, for MiRA's R button", {
  served <- NULL
  local_mocked_bindings(.serve_mira = function(...) {
    served <<- list(...)
    invisible("handle")
  }, .should_serve = function(...) TRUE)
  mira_call <- function() regmatches(served$view_json, regexpr('"mira": "[^\n]*"', served$view_json))
  net <- copy_net() # each link listed once: auto-detected as directed
  undirected <- net
  undirected$extended <- rbind(net$extended, transform(net$extended, node_from = node_to, node_to = node_from))

  suppressMessages(plot_mira(undirected, bipartite = TRUE, setA_type = "parasite", port = 9000))
  expect_equal(mira_call(), '"mira": "mira(undirected, bipartite = TRUE, setA_type = \\"parasite\\")"')
  expect_no_match(served$view_json, '"mode"', fixed = TRUE) # network mode: no other settings
  suppressMessages(plot_mira(net, mode = "grid"))
  expect_equal(mira_call(), '"mira": "mira(net)"')
  expect_match(served$view_json, '"view": "grid"', fixed = TRUE)
  # mira() draws a bipartite network undirected unless told; plot_mira() auto-detects
  suppressMessages(plot_mira(net, bipartite = TRUE))
  expect_equal(mira_call(), '"mira": "mira(net, bipartite = TRUE, directed = TRUE)"')
  suppressMessages(plot_mira(net, bipartite = TRUE, directed = FALSE))
  expect_equal(mira_call(), '"mira": "mira(net, bipartite = TRUE, directed = FALSE)"')
})

test_that("the code MiRA shows gives the plot's spec back", {
  skip_on_cran()
  skip_if_not_installed("chromote")
  skip_if(is.null(chromote::find_chrome()), "Chrome not found")
  skip_if_offline() # MiRA loads its libraries from the internet

  net <- copy_net()
  p <- suppressMessages(mira(net, bipartite = TRUE, setA_type = "parasite")) +
    mira_layout("circle", seed = 3) +
    mira_node(color_by = "size", color_palette = "magma", size = 14, labels = TRUE) +
    mira_intralayer(color_by = "type", color_values = c(a = "#ff0000")) +
    mira_interlayer(show = TRUE, curvature = 0.5) +
    mira_layer(labels = TRUE, stack = "vertical") +
    mira_filter(nodes = size > 1) +
    mira_camera(rotate = 20, zoom = 1.5) +
    mira_legends(show = "node_color", position = "top-right")

  app <- .mira_app(p$network_json, .view_json(p), .resolve_mira_path(NULL))
  server <- .start_server(app, SAVE_PORT)
  on.exit(httpuv::stopServer(server$handle), add = TRUE)
  browser <- chromote::ChromoteSession$new(width = 1200, height = 800)
  on.exit(browser$close(), add = TRUE)
  deadline <- Sys.time() + 60
  .wait_for(browser$Page$navigate(sprintf("http://localhost:%d/?autoload=true&save=true", server$port),
                                  wait_ = FALSE), deadline, "test")
  status <- .wait_for_status(browser, deadline, "test")
  expect_equal(unlist(status$warnings), NULL)

  read_code <- "document.getElementById('copyRCodeBtn').click(); document.querySelector('#rCodePanel pre').innerText"
  result <- .wait_for(browser$Runtime$evaluate(read_code, returnByValue = TRUE, wait_ = FALSE), deadline, "test")
  code <- result$result$value
  expect_match(code, 'mira(net, bipartite = TRUE, setA_type = "parasite") +', fixed = TRUE)
  expect_match(code, "mira_filter(nodes = size > 1)", fixed = TRUE)

  copied <- suppressMessages(eval(parse(text = code)))
  expect_equal(mira_spec(copied), mira_spec(p))
})
