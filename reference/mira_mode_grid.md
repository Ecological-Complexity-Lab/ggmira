# Grid: open the plot with the layers side by side

Opens the plot in MiRA's grid mode: one panel per layer, each with its
own nodes and links, as drawn in network mode (positions, colors, sizes,
shapes, layer colors, node names, the highlighted node). Interlayer
links are not drawn.
[`mira_filter()`](https://ggmira.ecomplab.com/reference/mira_filter.md)
applies: layers and nodes it drops are not drawn, and the remaining
layers fill the grid. In MiRA, the grid button (four squares) opens this
view.

## Usage

``` r
mira_mode_grid(columns)
```

## Arguments

- columns:

  Number of columns of layers, a whole number between 1 and 8. MiRA's
  default is the square root of the number of layers, rounded up.

## Value

A component, to add to a plot with `+`.

## Details

A plot opens in one view: see
[mira_mode](https://ggmira.ecomplab.com/reference/mira_mode.md) for the
rules and for what applies in each view.

![Network 17 in grid mode: four layer panels, birds as squares and
plants as circles](figures/mira_mode_grid.jpg)

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
p <- mira(net, bipartite = TRUE, setA_type = "bird") +
  mira_node(color_by = "verification_level")
#> Bipartite network: drawn as undirected. Use directed = TRUE for a directed one.

# MiRA's default columns (here 2), then all layers in one row
p + mira_mode_grid()
#> Not opened: R is not interactive. Print the plot in an R session, or give `browser` to open it from a script.
p + mira_mode_grid(columns = 4)
#> Not opened: R is not interactive. Print the plot in an R session, or give `browser` to open it from a script.

# The filter applies in the grid
p + mira_filter(nodes = type == "plant" | node_name == "Geospiza_fortis") +
  mira_mode_grid()
#> Not opened: R is not interactive. Print the plot in an R session, or give `browser` to open it from a script.
```
