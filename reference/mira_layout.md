# Layout: where the nodes go

Chooses MiRA's network layout, the one setting that places the nodes.
Add it to a plot made with
[`mira()`](https://ggmira.ecomplab.com/reference/mira.md); without it,
MiRA uses its default (the bipartite layout for a bipartite network,
Fruchterman-Reingold otherwise).

## Usage

``` r
mira_layout(type, seed, nested)
```

## Arguments

- type:

  One of `"fruchterman"`, `"kamada_kawai"`, `"bipartite"`, `"circle"`,
  `"grid"`, `"random"`. `"bipartite"` needs
  `mira(..., bipartite = TRUE)`.

- seed:

  A whole number. The same seed and the same data give the same node
  positions, so a figure can be reproduced. Without a seed, a layout
  that starts from random positions (`"fruchterman"`, MiRA's default for
  a network that is not bipartite, among them) differs each time the
  plot opens.

- nested:

  `TRUE` or `FALSE`. Bipartite layout only: sort nodes by degree (nested
  order).

## Value

A component, to add to a plot with `+`.

## See also

[`mira()`](https://ggmira.ecomplab.com/reference/mira.md) to start a
plot;
[`mira_node()`](https://ggmira.ecomplab.com/reference/mira_node.md),
[`mira_intralayer()`](https://ggmira.ecomplab.com/reference/mira_intralayer.md),
[`mira_interlayer()`](https://ggmira.ecomplab.com/reference/mira_interlayer.md)
and
[`mira_layer()`](https://ggmira.ecomplab.com/reference/mira_layer.md)
for the elements it draws.

Other components:
[`mira_camera()`](https://ggmira.ecomplab.com/reference/mira_camera.md),
[`mira_filter()`](https://ggmira.ecomplab.com/reference/mira_filter.md),
[`mira_interlayer()`](https://ggmira.ecomplab.com/reference/mira_interlayer.md),
[`mira_intralayer()`](https://ggmira.ecomplab.com/reference/mira_intralayer.md),
[`mira_layer()`](https://ggmira.ecomplab.com/reference/mira_layer.md),
[`mira_legends()`](https://ggmira.ecomplab.com/reference/mira_legends.md),
[`mira_mode`](https://ggmira.ecomplab.com/reference/mira_mode.md),
[`mira_mode_dashboard()`](https://ggmira.ecomplab.com/reference/mira_mode_dashboard.md),
[`mira_mode_data()`](https://ggmira.ecomplab.com/reference/mira_mode_data.md),
[`mira_mode_grid()`](https://ggmira.ecomplab.com/reference/mira_mode_grid.md),
[`mira_mode_layer()`](https://ggmira.ecomplab.com/reference/mira_mode_layer.md),
[`mira_mode_map()`](https://ggmira.ecomplab.com/reference/mira_mode_map.md),
[`mira_mode_meta()`](https://ggmira.ecomplab.com/reference/mira_mode_meta.md),
[`mira_node()`](https://ggmira.ecomplab.com/reference/mira_node.md)

## Examples

``` r
library(emln)
net <- load_emln(17) # 4 layers; bird and plant nodes
#> Creating state node map
#> Creating extended link list with node IDs
p <- mira(net, bipartite = TRUE, setA_type = "bird")
#> Bipartite network: drawn as undirected. Use directed = TRUE for a directed one.

p + mira_layout("kamada_kawai")
#> Not opened: R is not interactive. Print the plot in an R session, or give `browser` to open it from a script.

# The same node positions every time
p + mira_layout("fruchterman", seed = 42)
#> Not opened: R is not interactive. Print the plot in an R session, or give `browser` to open it from a script.

# Bipartite layout, nodes sorted by degree
p + mira_layout("bipartite", nested = TRUE)
#> Not opened: R is not interactive. Print the plot in an R session, or give `browser` to open it from a script.
```
