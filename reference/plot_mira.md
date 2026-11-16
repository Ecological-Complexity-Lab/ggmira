# Open a network in MiRA with MiRA's defaults

Converts an EMLN `multilayer` object to JSON and opens MiRA, the
Multilayer Interactive Rendering Application, in the default web
browser, with MiRA's default view, in the view given by `mode`. To
describe how the plot should look in code, use
[`mira()`](https://ggmira.ecomplab.com/reference/mira.md) instead.

## Usage

``` r
plot_mira(
  multilayer,
  bipartite = FALSE,
  setA_type = NULL,
  directed = NULL,
  directed_interlayer = NULL,
  mode = "network",
  port = 8080,
  mira_path = NULL,
  browser = getOption("browser"),
  viewer = getOption("ggmira.viewer", FALSE)
)

plot_multilayer(
  multilayer,
  bipartite = FALSE,
  setA_type = NULL,
  directed = NULL,
  directed_interlayer = NULL,
  port = 8080,
  mira_path = NULL,
  browser = getOption("browser"),
  viewer = getOption("ggmira.viewer", FALSE)
)
```

## Arguments

- multilayer:

  A multilayer object (created by `create_multilayer_network` or
  `load_emln`).

- bipartite:

  Logical. Whether the network is bipartite. Defaults to `FALSE`.
  Bipartite is not auto-detected. When `TRUE`, the nodes table must
  contain a `node_type` column (or `node_group`, or `type`, as in the
  networks of `load_emln`) with exactly two distinct values across the
  network. MiRA knows the column as `node_type`, whatever its name in
  the data.

- setA_type:

  Optional character. The `node_type` value to render as Set A (top row)
  in MiRA's bipartite layout. By ecological convention this is the
  higher trophic level (e.g. `"pollinator"`, `"parasite"`,
  `"disperser"`). Only used when `bipartite = TRUE`.

- directed:

  Logical or NULL. Whether intralayer links are directed. If NULL
  (default), auto-detected by checking intralayer edge symmetry.

- directed_interlayer:

  Logical or NULL. Whether interlayer links are directed. If NULL
  (default), inherits from `directed`. Interlayer links are directed
  whenever intralayer links are, so `FALSE` has no effect on a directed
  network.

- mode:

  The view MiRA opens in: `"network"` (default), `"grid"`, `"map"`
  (needs `latitude` and `longitude` in `net$layers`), `"layer"`,
  `"meta"` (the meta-network), `"dashboard"` or `"data"`; each with
  MiRA's default settings. One view per call: to see a network in two
  views, call `plot_mira()` twice. To set a view's options (grid
  columns, meta-network settings), use
  [`mira()`](https://ggmira.ecomplab.com/reference/mira.md) with
  [`mira_mode_grid()`](https://ggmira.ecomplab.com/reference/mira_mode_grid.md)
  or
  [`mira_mode_meta()`](https://ggmira.ecomplab.com/reference/mira_mode_meta.md).

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

## Value

Invisibly returns the server handle. Use `httpuv::stopServer(handle)` to
stop the server when done. `NULL` when nothing was opened: R is not
interactive (a script, R Markdown) and `browser` was not given.

## Details

The plot is the one MiRA shows for the same network loaded on its
website, with two differences: the legends start minimized (as for every
plot from R;
[`mira_legends()`](https://ggmira.ecomplab.com/reference/mira_legends.md)
opens them), and the map and the layer view are fitted to the layers.

`plot_multilayer()` is the same function without `mode` (always network
mode), under the name emln uses. While emln has a function of that name
too, the package attached last provides it: after
[`library(emln)`](https://emln.ecomplab.com/), write
`ggmira::plot_multilayer()`, or use `plot_mira()`.

**From MiRA back to R.** Change the plot in MiRA, then click MiRA's
**R** button (Copy as R code, next to Save Session): it shows the
[`mira()`](https://ggmira.ecomplab.com/reference/mira.md) code that
draws the current view, starting from this network and these arguments,
to paste into a script. Not for `plot_multilayer()`.

The function:

1.  Converts the multilayer object to MiRA's JSON format (the same
    output as
    [`emln::multilayer_to_json`](https://rdrr.io/pkg/emln/man/multilayer_to_json.html))

2.  Starts a local HTTP server (using `httpuv`) that serves the MiRA app
    and the network JSON

3.  Opens the browser with auto-load enabled

The server runs in the background. Call `httpuv::stopServer(handle)` or
close R to stop it. The JSON data is kept in memory and never written to
disk. MiRA loads its drawing libraries and map tiles from the web, so
the plot needs an internet connection.

`plot_multilayer()` replaces
[`emln::plot_multilayer()`](https://rdrr.io/pkg/emln/man/plot_multilayer.html):
the same arguments and behavior, plus `viewer`.

## Note

MiRA is a browser-based interactive visualization tool for multilayer
networks, available at <https://mira.ecomplab.com/>.

If you use MiRA in published research, please cite:

Nehoray SM, Bloch Y, Pilosof S (2026). Interactively visualizing
biological multilayer networks using MiRA. *arXiv*:2605.09597 \[cs.SI\].
[doi:10.48550/arXiv.2605.09597](https://doi.org/10.48550/arXiv.2605.09597)

Feedback and bug reports:
<https://github.com/Ecological-Complexity-Lab/MiRA/issues>.

## See also

[`mira()`](https://ggmira.ecomplab.com/reference/mira.md) to describe
the plot in code;
[mira_mode](https://ggmira.ecomplab.com/reference/mira_mode.md) for the
views; [`emln::load_emln`](https://rdrr.io/pkg/emln/man/load_emln.html),
[`emln::multilayer_to_json`](https://rdrr.io/pkg/emln/man/multilayer_to_json.html)

## Examples

``` r
library(emln)
net <- load_emln(17)
#> Creating state node map
#> Creating extended link list with node IDs

# Open with MiRA's defaults
plot_mira(net, bipartite = TRUE, setA_type = "bird")
#> Not opened: R is not interactive. Print the plot in an R session, or give `browser` to open it from a script.

# In another view: the meta-network, or the layers side by side
plot_mira(net, bipartite = TRUE, setA_type = "bird", mode = "meta")
#> Not opened: R is not interactive. Print the plot in an R session, or give `browser` to open it from a script.
plot_mira(net, bipartite = TRUE, setA_type = "bird", mode = "grid")
#> Not opened: R is not interactive. Print the plot in an R session, or give `browser` to open it from a script.

# Directed links, on another port
plot_mira(net, bipartite = TRUE, setA_type = "bird",
          directed = TRUE, directed_interlayer = TRUE, port = 9000)
#> Not opened: R is not interactive. Print the plot in an R session, or give `browser` to open it from a script.

# Another browser; a local copy of MiRA, not the bundled one
# plot_mira(net, browser = "chrome", mira_path = "~/MiRA")

# In RStudio's Viewer pane
# plot_mira(net, bipartite = TRUE, setA_type = "bird", viewer = TRUE)

# The same as plot_mira(net, bipartite = TRUE, setA_type = "bird").
# ggmira:: because emln, attached above, has a plot_multilayer() too
ggmira::plot_multilayer(net, bipartite = TRUE, setA_type = "bird")
#> Not opened: R is not interactive. Print the plot in an R session, or give `browser` to open it from a script.

# When done, stop the servers
httpuv::stopAllServers()
```
