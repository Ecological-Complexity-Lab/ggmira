# Meta-network: open the plot as the network aggregated over layers

Opens the plot in MiRA's meta-network mode: each node once, linked to
the nodes it interacts with in any layer. Arguments not given keep the
values MiRA uses when its meta-network button is clicked.

## Usage

``` r
mira_mode_meta(
  aggregation,
  layout,
  color_by,
  size_by,
  size,
  min_weight,
  nested,
  labels,
  label_size,
  color,
  layers
)
```

## Arguments

- aggregation:

  How links of different layers combine into one: `"occurrence"` (MiRA's
  default: the number of layers with the link), `"weights"` (the sum of
  their weights) or `"union"` (present in any layer).

- layout:

  `"circular"`, `"force"` or `"bipartite"` (two rows, one per node set;
  needs `mira(..., bipartite = TRUE)`). MiRA's default is `"bipartite"`
  for bipartite networks and `"circular"` otherwise.

- color_by:

  Node color: `"uniform"` (MiRA's default: one color), `"participation"`
  (the number of layers a node is in) or `"degree"` (the number of nodes
  it links to in the meta-network). To choose the one color, give
  `color` and leave `color_by` out.

- size_by:

  Node size: `"degree"` (MiRA's default), `"participation"` or
  `"uniform"`.

- size:

  Node size multiplier, between 0.2 and 3 (default 1).

- min_weight:

  Hide links with an aggregated weight below this (a number of 0 or
  more; default 0).

- nested:

  `TRUE` (default) or `FALSE`: sort each row of the bipartite layout by
  degree. Only for bipartite networks (an error otherwise), and only
  used by the `"bipartite"` layout (a warning with another layout).

- labels:

  `TRUE` to show node names (default `FALSE`).

- label_size:

  Size of node names in pixels, a whole number between 8 and 24 (default
  12).

- color:

  One color for every node, or one per node set, named by `node_type`
  (e.g. `c(bird = "orange", plant = "darkgreen")`). A color makes the
  node color uniform, so give `color_by` or `color`, not both (also not
  `color_by = "uniform"` with `color`): a later `color` replaces an
  earlier `color_by`, and the other way round.

- layers:

  Layers to select in the meta-network's *Filter Layers* panel: nodes
  and links not in them are dimmed (not removed, and the meta-network is
  not recomputed). Layer names, or a condition on the columns of
  `net$layers` evaluated like
  [`subset()`](https://rdrr.io/r/base/subset.html) (e.g.
  `layer_name != "layer_1"`, `!layer_name %in% c("layer_1", "layer_2")`,
  `latitude > 0`). `NULL` or `NA` (MiRA's default) = none selected,
  nothing dimmed. Unlike
  [`mira_filter()`](https://ggmira.ecomplab.com/reference/mira_filter.md),
  which the meta-network does not use, nothing is hidden.

## Value

A component, to add to a plot with `+`.

## Details

A plot opens in one view: see
[mira_mode](https://ggmira.ecomplab.com/reference/mira_mode.md) for the
rules (a later `mira_mode_*()` of another view replaces this one, with a
warning). `color_by` and `size_by` here are meta-network measures, not
columns of the data. Node shapes follow `mira_node(shape = )`, with a
shape legend when the node sets have different shapes. The `"force"`
layout is random: it differs each time the plot opens.

![Network 17 as a meta-network: birds in one row, plants in the other,
sized by degree](figures/mira_mode_meta.jpg)

## See also

[mira_mode](https://ggmira.ecomplab.com/reference/mira_mode.md) for the
other views.

Other components:
[`mira_camera()`](https://ggmira.ecomplab.com/reference/mira_camera.md),
[`mira_filter()`](https://ggmira.ecomplab.com/reference/mira_filter.md),
[`mira_interlayer()`](https://ggmira.ecomplab.com/reference/mira_interlayer.md),
[`mira_intralayer()`](https://ggmira.ecomplab.com/reference/mira_intralayer.md),
[`mira_layer()`](https://ggmira.ecomplab.com/reference/mira_layer.md),
[`mira_layout()`](https://ggmira.ecomplab.com/reference/mira_layout.md),
[`mira_legends()`](https://ggmira.ecomplab.com/reference/mira_legends.md),
[`mira_mode`](https://ggmira.ecomplab.com/reference/mira_mode.md),
[`mira_mode_dashboard()`](https://ggmira.ecomplab.com/reference/mira_mode_dashboard.md),
[`mira_mode_data()`](https://ggmira.ecomplab.com/reference/mira_mode_data.md),
[`mira_mode_grid()`](https://ggmira.ecomplab.com/reference/mira_mode_grid.md),
[`mira_mode_layer()`](https://ggmira.ecomplab.com/reference/mira_mode_layer.md),
[`mira_mode_map()`](https://ggmira.ecomplab.com/reference/mira_mode_map.md),
[`mira_node()`](https://ggmira.ecomplab.com/reference/mira_node.md)

## Examples

``` r
library(emln)
net <- load_emln(17) # 4 layers; bird and plant nodes
#> Creating state node map
#> Creating extended link list with node IDs
p <- mira(net, bipartite = TRUE, setA_type = "bird")
#> Bipartite network: drawn as undirected. Use directed = TRUE for a directed one.

# MiRA's meta-network
p + mira_mode_meta()
#> Not opened: R is not interactive. Print the plot in an R session, or give `browser` to open it from a script.

# Links weighted by the sum of weights; nodes colored by the number of
# layers they are in, with their names
p + mira_mode_meta(aggregation = "weights", color_by = "participation",
                   size_by = "degree", size = 1.5, labels = TRUE, label_size = 14)
#> Not opened: R is not interactive. Print the plot in an R session, or give `browser` to open it from a script.

# Only links in at least two layers, in a circle
p + mira_mode_meta(layout = "circular", min_weight = 2)
#> Not opened: R is not interactive. Print the plot in an R session, or give `browser` to open it from a script.

# Two rows not sorted by degree, with a color per node set
p + mira_mode_meta(nested = FALSE, color = c(bird = "orange", plant = "darkgreen"))
#> Not opened: R is not interactive. Print the plot in an R session, or give `browser` to open it from a script.

# Shapes from mira_node(): birds as squares, in a circle
p + mira_node(shape = c(bird = "square", plant = "circle")) +
  mira_mode_meta(layout = "circular")
#> Not opened: R is not interactive. Print the plot in an R session, or give `browser` to open it from a script.

# Dim the nodes and links of layer_1: select the other layers
p + mira_mode_meta(layers = layer_name != "layer_1")
#> Not opened: R is not interactive. Print the plot in an R session, or give `browser` to open it from a script.
p + mira_mode_meta(layers = c("layer_2", "layer_3"))
#> Not opened: R is not interactive. Print the plot in an R session, or give `browser` to open it from a script.
```
