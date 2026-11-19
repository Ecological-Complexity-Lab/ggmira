test_that("MiRA browser toolbar links open the public pages", {
  index <- paste(readLines(system.file("MiRA", "index.html", package = "ggmira"),
                           warn = FALSE), collapse = "\n")
  manual <- paste(readLines(system.file("MiRA", "docs", "manual.html", package = "ggmira"),
                            warn = FALSE), collapse = "\n")

  expect_match(index, '<button id="feedbackBtn"', fixed = TRUE)
  expect_match(index, '<a href="https://mira.ecomplab.com/about.html" target="_blank" rel="noopener"', fixed = TRUE)
  expect_match(manual, '<a href="https://mira.ecomplab.com/about.html">About</a>', fixed = TRUE)
  expect_match(index, 'id="feedbackForm"', fixed = TRUE)
  expect_match(index, 'id="feedbackName"', fixed = TRUE)
})