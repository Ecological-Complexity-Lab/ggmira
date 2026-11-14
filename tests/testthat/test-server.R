# The request handler is tested directly, without starting a server.

make_mira_dir <- function() {
  root <- new_tempdir()
  mira <- file.path(root, "MiRA")
  dir.create(file.path(mira, "js"), recursive = TRUE)
  writeLines("<html>MiRA</html>", file.path(mira, "index.html"))
  writeLines("export const x = 1;", file.path(mira, "js", "app.js"))
  # A sibling directory sharing the "MiRA" prefix must not be reachable
  dir.create(file.path(root, "MiRA-secret"))
  writeLines("secret", file.path(root, "MiRA-secret", "key.txt"))
  normalizePath(mira)
}

new_tempdir <- function() {
  dir <- tempfile("ggmira-test-")
  dir.create(dir)
  dir
}

request <- function(app, path) app$call(list(PATH_INFO = path))

test_that("network endpoint serves the network JSON", {
  app <- .mira_app('{"nodes": []}', NULL, make_mira_dir())
  res <- request(app, "/api/network.json")
  expect_equal(res$status, 200L)
  expect_equal(res$body, '{"nodes": []}')
  expect_equal(res$headers[["Content-Type"]], "application/json")
})

test_that("view endpoint is 404 without a view spec (MiRA then shows its default view)", {
  app <- .mira_app("{}", NULL, make_mira_dir())
  expect_equal(request(app, "/api/view.json")$status, 404L)
})

test_that("view endpoint serves the view spec when given", {
  app <- .mira_app("{}", '{"version": 1}', make_mira_dir())
  res <- request(app, "/api/view.json")
  expect_equal(res$status, 200L)
  expect_equal(res$body, '{"version": 1}')
})

test_that("static files are served with their content type", {
  app <- .mira_app("{}", NULL, make_mira_dir())
  index <- request(app, "/")
  expect_equal(index$status, 200L)
  expect_match(index$body, "MiRA")
  expect_match(index$headers[["Content-Type"]], "text/html")
  expect_match(request(app, "/js/app.js")$headers[["Content-Type"]], "javascript")
  expect_equal(request(app, "/missing.js")$status, 404L)
  expect_equal(request(app, "/js")$status, 404L)
})

test_that("paths outside the MiRA directory are forbidden, including prefix siblings", {
  app <- .mira_app("{}", NULL, make_mira_dir())
  expect_equal(request(app, "/../MiRA-secret/key.txt")$status, 403L)
  # A path that does not exist cannot be resolved; it is simply not found
  expect_true(request(app, "/../../no/such/file")$status %in% c(403L, 404L))
})

test_that("mira_path must contain index.html", {
  expect_error(.resolve_mira_path(tempdir()), "does not contain index.html")
  dir <- make_mira_dir()
  expect_equal(.resolve_mira_path(dir), dir)
})

test_that("the app serves the plot as it was when the server started", {
  # print() passes the spec lazily; the handler must not see later changes
  spec <- '{"version": 1}'
  app <- .mira_app('{"nodes": []}', spec, make_mira_dir())
  spec <- '{"version": 2}'
  expect_equal(request(app, "/api/view.json")$body, '{"version": 1}')
})

test_that("the path check holds for Windows paths, which come with backslashes", {
  expect_true(.inside_dir("C:\\Users\\a\\R\\ggmira\\MiRA\\index.html", "C:\\Users\\a\\R\\ggmira\\MiRA"))
  expect_true(.inside_dir("C:\\lib\\MiRA\\js\\app.js", "C:/lib/MiRA/"))
  expect_false(.inside_dir("C:\\lib\\MiRA-secret\\key.txt", "C:\\lib\\MiRA"))
  expect_false(.inside_dir("C:\\lib\\MiRA", "C:\\lib\\MiRA"))
  expect_true(.inside_dir("/lib/MiRA/index.html", "/lib/MiRA"))
  expect_false(.inside_dir("/lib/MiRA-secret/key.txt", "/lib/MiRA"))
})

test_that("printed plots keep the servers of the last ten; the search skips this session's ports", {
  app <- .mira_app("{}", NULL, make_mira_dir())
  before <- httpuv::listServers()
  old <- .printed$servers
  .printed$servers <- list()
  started <- list()
  on.exit({
    for (server in started) if (server$isRunning()) httpuv::stopServer(server)
    .printed$servers <- old
  }, add = TRUE)

  port <- 18200
  for (i in seq_len(MAX_OPEN_PLOTS + 2)) {
    # every search starts at the same port, as every print() does
    server <- .start_server(app, port)
    started <- c(started, list(server$handle))
    .remember_server(server$handle)
  }
  running <- vapply(started, function(server) server$isRunning(), logical(1))
  expect_equal(running, c(FALSE, FALSE, rep(TRUE, MAX_OPEN_PLOTS))) # the two oldest were stopped
  expect_length(httpuv::listServers(), length(before) + MAX_OPEN_PLOTS)
  expect_length(.printed$servers, MAX_OPEN_PLOTS)
  ports <- vapply(started[running], function(server) as.numeric(server$getPort()), numeric(1))
  expect_equal(anyDuplicated(ports), 0L)

  # a server the user stopped is forgotten, not stopped again
  httpuv::stopServer(started[[5]])
  server <- .start_server(app, port)
  started <- c(started, list(server$handle))
  expect_no_error(.remember_server(server$handle))
  expect_length(.printed$servers, MAX_OPEN_PLOTS)
})

