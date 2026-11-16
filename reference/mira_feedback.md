# Send feedback on ggmira

Opens a new issue in ggmira's GitHub repository in the browser, filled
in with your comment, what it is about, and your R session (R, ggmira
and the packages loaded). Check it and click *Submit new issue*. You
need to be signed in to GitHub.

## Usage

``` r
mira_feedback(topic, comment, type = "bug")
```

## Arguments

- topic:

  What the feedback is about: a function (`"mira_node"`), an article
  (`"Getting started"`), MiRA, or anything else.

- comment:

  What is wrong, confusing or missing, and what you expected.

- type:

  `"bug"` (default; wrong or broken), `"unclear"`, `"missing"` or
  `"idea"`.

## Value

The issue link, invisibly. Outside an interactive session the link is
shown instead of opened.

## Details

The documentation has the same: select text on a page and click
*Feedback*, click the speech-bubble icon next to a heading, or use the
*Feedback* button at the bottom right.

## Examples

``` r
if (FALSE) { # \dontrun{
mira_feedback("mira_node", "color_limits seems to be ignored with color_by = \".set\"")
mira_feedback("Getting started", "Step 6 does not say what a link condition is", type = "unclear")
} # }
```
