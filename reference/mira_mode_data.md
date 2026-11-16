# Data: open the plot as the data tables

Opens the plot in MiRA's data mode: the network's tables (nodes, state
nodes, links, layers), with every attribute, sortable and filterable,
and *Export CSV*. A filter set there applies to network, grid and map
modes (its layers also to the layer view), like
[`mira_filter()`](https://ggmira.ecomplab.com/reference/mira_filter.md)
from R. It opens on the nodes table with every row; the other components
of the plot do not apply (see
[mira_mode](https://ggmira.ecomplab.com/reference/mira_mode.md)). In
MiRA, the data button (a table) opens this view.

## Usage

``` r
mira_mode_data()
```

## Value

A component, to add to a plot with `+`.

## Details

![Network 17 in data mode: the nodes table with its
attributes](figures/mira_mode_data.jpg)

## See also

[`mira_filter()`](https://ggmira.ecomplab.com/reference/mira_filter.md)
to filter from R;
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
[`mira_mode_grid()`](https://ggmira.ecomplab.com/reference/mira_mode_grid.md),
[`mira_mode_layer()`](https://ggmira.ecomplab.com/reference/mira_mode_layer.md),
[`mira_mode_map()`](https://ggmira.ecomplab.com/reference/mira_mode_map.md),
[`mira_mode_meta()`](https://ggmira.ecomplab.com/reference/mira_mode_meta.md),
[`mira_node()`](https://ggmira.ecomplab.com/reference/mira_node.md)

## Examples

``` r
library(emln)
net <- load_emln(17)
#> Creating state node map
#> Creating extended link list with node IDs
mira(net, bipartite = TRUE, setA_type = "bird") + mira_mode_data()
#> Bipartite network: drawn as undirected. Use directed = TRUE for a directed one.
#> Not opened: R is not interactive. Print the plot in an R session, or give `browser` to open it from a script.
```
