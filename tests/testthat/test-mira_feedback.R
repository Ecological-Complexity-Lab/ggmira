# mira_feedback(): a filled-in GitHub issue link

test_that("the link opens a new issue with the topic, type, comment and session", {
  url <- .feedback_url("mira_node", "color_limits is ignored\nwith .set", "bug", session = "R version 4.5.0")
  expect_match(url, "^https://github.com/Ecological-Complexity-Lab/ggmira/issues/new\\?title=")
  decoded <- utils::URLdecode(url)
  expect_match(decoded, "title=[beta] [mira_node] color_limits is ignored with .set&", fixed = TRUE)
  expect_match(decoded, "**Topic:** mira_node", fixed = TRUE)
  expect_match(decoded, "color_limits is ignored\nwith .set", fixed = TRUE)
  expect_match(decoded, "R version 4.5.0", fixed = TRUE)
  expect_match(decoded, "&labels=beta-feedback,bug$")
  # a long comment is shortened in the title only
  long <- strrep("word ", 30)
  title <- regmatches(utils::URLdecode(.feedback_url("x", long, "idea", "")),
                      regexpr("title=[^&]*", utils::URLdecode(.feedback_url("x", long, "idea", ""))))
  expect_lt(nchar(title), 90)
  expect_match(utils::URLdecode(.feedback_url("x", long, "idea", "")), trimws(long), fixed = TRUE)
})

test_that("outside an interactive session the link is shown, not opened", {
  local_mocked_bindings(.is_interactive = function() FALSE)
  expect_message(url <- mira_feedback("Getting started", "Step 6 is unclear", type = "unclear"),
                 "Open this link to send the feedback: https://github.com/")
  expect_match(url, "labels=beta-feedback%2Cunclear$")
})

test_that("arguments are checked", {
  expect_error(mira_feedback("", "x"), "`topic` must be a non-empty string")
  expect_error(mira_feedback("mira_node", NA_character_), "`comment` must be a non-empty string")
  expect_error(mira_feedback("mira_node", "x", type = "praise"), '`type` must be one of "bug", "unclear", "missing", "idea"')
})
