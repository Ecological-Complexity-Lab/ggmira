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
