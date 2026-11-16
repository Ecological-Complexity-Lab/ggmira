# Open a mira plot in the browser

Starts a local server with the network and its view spec and opens MiRA.
Typing a plot's name at the console does this; call
[`print()`](https://rdrr.io/r/base/print.html) to choose the port or the
browser, or to open the plot in RStudio's Viewer pane (`viewer = TRUE`,
or `options(ggmira.viewer = TRUE)` for every plot). Each print starts a
new server (on the next free port when `port` is taken), and shows where
MiRA is served from, the plot's address
(`http://localhost:8080?autoload=true`) and where to report issues. MiRA
loads its drawing libraries from the web, so the plot needs an internet
connection.

## Usage

``` r
# S3 method for class 'mira_plot'
print(
  x,
  port = 8080,
  mira_path = NULL,
  browser = getOption("browser"),
  viewer = getOption("ggmira.viewer", FALSE),
  ...
)
```

## Arguments

- x:

  A `mira_plot`.

- port:

  Integer. Port for the local HTTP server. Default is 8080.

- mira_path:

  Character. Path to the MiRA web-app directory. If NULL (default), uses
  the copy bundled with the package
  (`system.file("MiRA", package = "ggmira")`).

- browser:

  Choose the specific browser to open MiRA in. Defaults to the system
  default via `getOption("browser")`. A command that opens a page, as
  for [`browseURL`](https://rdrr.io/r/utils/browseURL.html): a browser's
  name where that is a command (e.g. "firefox" on Linux), or on macOS
  "open -a Firefox". "chrome" works on macOS too. When R is not
  interactive (a script), a plot opens only when `browser` is given.

- viewer:

  `TRUE` to open MiRA in RStudio's Viewer pane instead of the browser
  (outside RStudio, the browser opens). Defaults to `FALSE`, or to
  `getOption("ggmira.viewer")`: put `options(ggmira.viewer = TRUE)` in
  your `.Rprofile` to always use the pane (the option must be `TRUE` or
  `FALSE`; anything else is an error). A `browser` given in the call
  wins. MiRA needs room (at least 1024 x 600 pixels): maximize the pane,
  or click its *Show in new window* button to move the plot to the
  browser.

- ...:

  Not used.

## Value

Invisibly, the server handle. Stop it with `httpuv::stopServer(handle)`,
or stop all servers with
[`httpuv::stopAllServers()`](https://rstudio.github.io/httpuv/reference/stopAllServers.html).
`NULL` when nothing was opened (R is not interactive and `browser` was
not given).

## Details

**In a script.** When R is not interactive (`Rscript`, R Markdown,
`R CMD check`) nothing opens and
[`print()`](https://rdrr.io/r/base/print.html) returns `NULL`, with a
message: no one would see the plot, and its server would stop with the
script. Use
[`mira_save()`](https://ggmira.ecomplab.com/reference/mira_save.md) for
a file, or give `browser` to open the plot anyway.

In MiRA, the plot can still be changed. MiRA's **R** button (Copy as R
code, next to Save Session) shows the ggmira code for the current view,
starting with the
[`mira()`](https://ggmira.ecomplab.com/reference/mira.md) call that made
the plot, to paste into a script. What R cannot set is listed in
comments under the code. By default the code ends with
`print(p, viewer = TRUE)`, which opens the plot in RStudio's Viewer
pane; untick the box under the code for the browser.

Every printed plot is served by its own small server, on its own port.
ggmira keeps the servers of the 10 most recent plots and stops older
ones: an older plot stays on screen, but reloading its page fails. Print
it again to reopen it.

## Examples

``` r
library(emln)
net <- load_emln(17) # 4 layers; bird and plant nodes
#> Creating state node map
#> Creating extended link list with node IDs
p <- mira(net, bipartite = TRUE, setA_type = "bird")
#> Bipartite network: drawn as undirected. Use directed = TRUE for a directed one.

p        # the same as print(p)
#> Not opened: R is not interactive. Print the plot in an R session, or give `browser` to open it from a script.

print(p, port = 9000)            # another port
#> Not opened: R is not interactive. Print the plot in an R session, or give `browser` to open it from a script.
# print(p, browser = "chrome")   # another browser
# print(p, viewer = TRUE)        # RStudio's Viewer pane
# options(ggmira.viewer = TRUE)  # the pane for every plot
# print(p, mira_path = "~/MiRA") # a local copy of MiRA, not the bundled one

# When done, stop the servers the plots started
httpuv::stopAllServers()
```
