# mira_feedback(): beta testers' feedback from R, as a filled-in GitHub
# issue (the same as the Feedback button of the documentation pages,
# pkgdown/extra.js).

FEEDBACK_REPO <- "https://github.com/Ecological-Complexity-Lab/ggmira"
FEEDBACK_LABEL <- "beta-feedback"
FEEDBACK_TYPES <- c("bug", "unclear", "missing", "idea")
FEEDBACK_TITLE_CHARS <- 60  # characters of the comment in the issue title
FEEDBACK_SESSION_CHARS <- 2500 # of sessionInfo(): GitHub drops longer links

#' Send feedback on ggmira (beta testing)
#'
#' Opens a new issue in ggmira's GitHub repository in the browser, filled
#' in with your comment, what it is about, and your R session (R, ggmira
#' and the packages loaded). Check it and click *Submit new issue*. You need
#' to be signed in to GitHub.
#'
#' The documentation has the same: select text on a page and click
#' *Feedback*, click the speech-bubble icon next to a heading, or use the
#' *Feedback* button at the bottom right.
#'
#' @param topic What the feedback is about: a function (`"mira_node"`), an
#'   article (`"Getting started"`), MiRA, or anything else.
#' @param comment What is wrong, confusing or missing, and what you
#'   expected.
#' @param type `"bug"` (default; wrong or broken), `"unclear"`,
#'   `"missing"` or `"idea"`.
#' @return The issue link, invisibly. Outside an interactive session the
#'   link is shown instead of opened.
#' @export
#' @examples
#' \dontrun{
#' mira_feedback("mira_node", "color_limits seems to be ignored with color_by = \".set\"")
#' mira_feedback("Getting started", "Step 6 does not say what a link condition is", type = "unclear")
#' }
mira_feedback <- function(topic, comment, type = "bug") {
  fn <- "mira_feedback"
  for (arg in c("topic", "comment")) {
    value <- get(arg)
    if (!is.character(value) || !.is_scalar(value) || is.na(value) || !nzchar(trimws(value))) {
      .abort_arg(fn, arg, "must be a non-empty string")
    }
  }
  if (!is.character(type) || !.is_scalar(type) || !type %in% FEEDBACK_TYPES) {
    .abort_arg(fn, "type", sprintf("must be one of %s", paste0('"', FEEDBACK_TYPES, '"', collapse = ", ")))
  }
  url <- .feedback_url(topic, comment, type)
  if (.is_interactive()) {
    utils::browseURL(url)
  } else {
    message("Open this link to send the feedback: ", url)
  }
  invisible(url)
}

.feedback_url <- function(topic, comment, type, session = .session_text()) {
  short <- gsub("\\s+", " ", trimws(comment))
  if (nchar(short) > FEEDBACK_TITLE_CHARS) short <- paste0(substr(short, 1, FEEDBACK_TITLE_CHARS), "\u2026")
  title <- sprintf("[beta] [%s] %s", topic, short)
  body <- paste0(
    "**Topic:** ", topic, "  \n",
    "**Type:** ", type, "  \n",
    "**ggmira:** ", as.character(utils::packageVersion("ggmira")), " (from R)\n\n",
    trimws(comment), "\n\n",
    "<details><summary>R session</summary>\n\n```\n", session, "\n```\n</details>"
  )
  encode <- function(x) utils::URLencode(enc2utf8(x), reserved = TRUE)
  sprintf("%s/issues/new?title=%s&body=%s&labels=%s", FEEDBACK_REPO, encode(title), encode(body),
          encode(paste(FEEDBACK_LABEL, type, sep = ",")))
}

.session_text <- function() {
  text <- paste(utils::capture.output(print(utils::sessionInfo())), collapse = "\n")
  if (nchar(text) > FEEDBACK_SESSION_CHARS) text <- paste0(substr(text, 1, FEEDBACK_SESSION_CHARS), "\n...")
  text
}
