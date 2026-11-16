# Start a plot: a multilayer network to draw in MiRA

Creates a plot of a multilayer network that opens in MiRA, the
browser-based multilayer network visualizer. Describe how it should look
by adding components with `+`, as in ggplot2; printing the plot (typing
its name at the console) opens it in the browser.

## Usage

``` r
mira(
  net,
  bipartite = FALSE,
  setA_type = NULL,
  directed = NULL,
  directed_interlayer = NULL
)
```

## Arguments

- net:

  A multilayer object (created by
  [`emln::create_multilayer_network()`](https://rdrr.io/pkg/emln/man/create_multilayer_network.html)
  or
  [`emln::load_emln()`](https://rdrr.io/pkg/emln/man/load_emln.html)).
  MiRA does not draw links with weight 0 (weight 0 means "no link" in
  MiRA); R warns how many there are.

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
  (default): undirected when `bipartite = TRUE` (bipartite edge lists
  usually store each link once, which would look directed); otherwise
  auto-detected from edge symmetry, as in
  [`plot_mira()`](https://ggmira.ecomplab.com/reference/plot_mira.md). R
  prints which one was chosen.

- directed_interlayer:

  Logical or NULL. Whether interlayer links are directed. If NULL
  (default), inherits from `directed`. Interlayer links are directed
  whenever intralayer links are, so `FALSE` has no effect on a directed
  network.

## Value

A `mira_plot` object.

## Components

Each component sets one part of the plot. Add them in any order:

- [`mira_layout()`](https://ggmira.ecomplab.com/reference/mira_layout.md):
  where the nodes go (the layout algorithm, a seed).

- [`mira_node()`](https://ggmira.ecomplab.com/reference/mira_node.md):
  node color, size, shape, labels.

- [`mira_intralayer()`](https://ggmira.ecomplab.com/reference/mira_intralayer.md):
  the links within layers.

- [`mira_interlayer()`](https://ggmira.ecomplab.com/reference/mira_interlayer.md):
  the links between layers.

- [`mira_layer()`](https://ggmira.ecomplab.com/reference/mira_layer.md):
  layer colors, names and arrangement.

- [`mira_filter()`](https://ggmira.ecomplab.com/reference/mira_filter.md):
  draw only some nodes, links or layers.

- [`mira_camera()`](https://ggmira.ecomplab.com/reference/mira_camera.md):
  rotate, tilt, zoom and pan the view.

- [`mira_legends()`](https://ggmira.ecomplab.com/reference/mira_legends.md):
  which legends are open, and where.

- [`mira_mode_grid()`](https://ggmira.ecomplab.com/reference/mira_mode_grid.md),
  [`mira_mode_meta()`](https://ggmira.ecomplab.com/reference/mira_mode_meta.md)
  and the other `mira_mode_*()`: open the plot in another of MiRA's
  views
  ([mira_mode](https://ggmira.ecomplab.com/reference/mira_mode.md)).

In each element component, `color_by` and `size_by` map an attribute of
the data (a column of the network's tables, or one MiRA computes, such
as a degree); `color`, `size` and `shape` set constants. The colors of a
mapping are chosen in the same component, with `color_values`,
`color_scale`, `color_palette`, `color_reverse` and `color_limits`: see
[mira_scales](https://ggmira.ecomplab.com/reference/mira_scales.md).

Anything not set keeps MiRA's default, and everything can still be
changed in MiRA's interface. When the same setting is given twice, the
later component wins. A later `color` replaces an earlier `color_by` of
the same element, and the other way round.

Components are checked against the network as they are added: settings
that cannot work (per-set values or the bipartite layout without
`bipartite = TRUE`, a layer name that does not exist) are errors; a
column that is not in the network is a warning, and MiRA keeps its
default for that setting.
[`mira_spec()`](https://ggmira.ecomplab.com/reference/mira_spec.md)
shows what a plot sends to MiRA.

MiRA has the final say. When it cannot use a setting it received, it
keeps its default for that setting and shows a notice when the plot
opens, "Some plot settings from R were ignored", with the reasons;
[`mira_save()`](https://ggmira.ecomplab.com/reference/mira_save.md)
gives them as warnings.

## Bipartite networks

`bipartite = TRUE` needs a column in `net$nodes` that says which of two
sets each node is in: `node_type`, or `node_group`, or `type` (what the
networks of
[`emln::load_emln()`](https://rdrr.io/pkg/emln/man/load_emln.html)
have). MiRA knows it as `node_type` whatever its name in the data, so
`mira_node(color_by = "node_type")` works for all three. A condition in
[`mira_filter()`](https://ggmira.ecomplab.com/reference/mira_filter.md)
is evaluated on `net$nodes` itself and uses the column's own name:
`type == "bird"` for a network from
[`load_emln()`](https://rdrr.io/pkg/emln/man/load_emln.html). A network
made with
[`emln::create_multilayer_network()`](https://rdrr.io/pkg/emln/man/create_multilayer_network.html)
has no such column; add one before the plot:

    # plants: the names of the plant nodes
    net$nodes$node_type <- ifelse(net$nodes$node_name %in% plants, "plant", "pollinator")

## What MiRA computes

Besides the columns of the data, nodes can be colored and sized by
degree and strength, which MiRA computes
([`mira_node()`](https://ggmira.ecomplab.com/reference/mira_node.md) has
the names: `intra_degree_sum`, ...).
[`mira_options()`](https://ggmira.ecomplab.com/reference/mira_options.md)
lists everything a network offers.

## See also

[`mira_spec()`](https://ggmira.ecomplab.com/reference/mira_spec.md) to
see what a plot sends to MiRA;
[`print.mira_plot()`](https://ggmira.ecomplab.com/reference/print.mira_plot.md)
for the browser and port options;
[`plot_mira()`](https://ggmira.ecomplab.com/reference/plot_mira.md) to
open a network with MiRA's defaults and no components.

## Examples

``` r
library(emln)
#> 
#> Attaching package: ‘emln’
#> The following object is masked from ‘package:ggmira’:
#> 
#>     plot_multilayer
net <- load_emln(17) # 4 layers; bird and plant nodes
#> Creating state node map
#> Creating extended link list with node IDs

# MiRA's default view
mira(net, bipartite = TRUE, setA_type = "bird")
#> Bipartite network: drawn as undirected. Use directed = TRUE for a directed one.
#> Not opened: R is not interactive. Print the plot in an R session, or give `browser` to open it from a script.

# Directed links, within and between layers
mira(net, bipartite = TRUE, setA_type = "bird",
     directed = TRUE, directed_interlayer = TRUE)
#> Not opened: R is not interactive. Print the plot in an R session, or give `browser` to open it from a script.

# Add components with +
mira(net, bipartite = TRUE, setA_type = "bird") +
  mira_layout("kamada_kawai", seed = 42) +
  mira_node(color_by = "verification_level", size_by = "intra_degree_sum") +
  mira_intralayer(color_by = "type") +
  mira_interlayer(show = TRUE) +
  mira_layer(labels = TRUE)
#> Bipartite network: drawn as undirected. Use directed = TRUE for a directed one.
#> Not opened: R is not interactive. Print the plot in an R session, or give `browser` to open it from a script.

# When done, stop the servers the plots started
httpuv::stopAllServers()
```
