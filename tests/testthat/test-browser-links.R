read_bundled <- function(...) {
  paste(readLines(system.file("MiRA", ..., package = "ggmira"), warn = FALSE), collapse = "\n")
}

test_that("MiRA's links to site pages ggmira does not bundle open the website", {
  index <- read_bundled("index.html")
  manual <- read_bundled("docs", "manual.html")

  expect_match(index, '<button id="feedbackBtn"', fixed = TRUE)
  expect_match(index, 'id="feedbackForm"', fixed = TRUE)
  expect_match(index, 'id="feedbackName"', fixed = TRUE)
  expect_match(index, '<a href="https://mira.ecomplab.com/about.html"[^>]*target="_blank"')
  expect_match(manual, '<a href="https://mira.ecomplab.com/about.html"[^>]*target="_blank"[^>]*>About</a>')
  expect_match(manual, '<a href="https://mira.ecomplab.com/data-format.html"')

  # Every relative link to a page points to a bundled file (MiRA's
  # scripts/sync-ggmira.sh makes the others absolute)
  relative_pages <- function(html, dir) {
    hrefs <- regmatches(html, gregexpr('href="[^":#]+\\.html', html))[[1]]
    file.path(dir, sub('^href="', "", hrefs))
  }
  pages <- c(relative_pages(index, "."), relative_pages(manual, "docs"))
  missing <- pages[!file.exists(system.file("MiRA", pages, package = "ggmira"))]
  expect_equal(missing, character(0))
})
