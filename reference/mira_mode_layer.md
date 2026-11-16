# Layer view: open the plot with one bubble per layer

Opens the plot in MiRA's layer view: each layer is a bubble, with its
network drawn inside (positions from
[`mira_layout()`](https://ggmira.ecomplab.com/reference/mira_layout.md))
and the layer's color from
[`mira_layer()`](https://ggmira.ecomplab.com/reference/mira_layer.md);
bubbles are linked by the nodes the layers share and by interlayer
links. When the layers have coordinates (`latitude` and `longitude` in
`net$layers`) the bubbles are placed on a map, fitted so that none is
under MiRA's panels; otherwise they are placed by a force layout. In
MiRA, the layer view button opens this view.

## Usage

``` r
mira_mode_layer()
```

## Value

A component, to add to a plot with `+`.

## Details

Bubble colors follow `mira_layer(color_by = )`, one color per layer or a
layer column, with the same colors and legend as in network mode; in
MiRA, choosing a layer column in either view changes both. The layer
view's other settings (bubble size, colors by node count or edge
density, links between bubbles, labels) are not available from R yet; it
opens with MiRA's defaults. `mira_filter(layers = )` applies: only the
layers it keeps are bubbles; its `nodes` and `links` do not (a bubble is
a whole layer).

A plot opens in one view: see
[mira_mode](https://ggmira.ecomplab.com/reference/mira_mode.md) for the
rules and for what applies in each view.

![Network 17 in the layer view: four bubbles on the map of the
Galapagos, linked](figures/mira_mode_layer.jpg)

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
[`mira_mode_map()`](https://ggmira.ecomplab.com/reference/mira_mode_map.md),
[`mira_mode_meta()`](https://ggmira.ecomplab.com/reference/mira_mode_meta.md),
[`mira_node()`](https://ggmira.ecomplab.com/reference/mira_node.md)

## Examples

``` r
library(emln)
net <- load_emln(17) # 4 layers on two islands: bubbles on the map
#> Creating state node map
#> Creating extended link list with node IDs
p <- mira(net, bipartite = TRUE, setA_type = "bird")
#> Bipartite network: drawn as undirected. Use directed = TRUE for a directed one.
p + mira_mode_layer()
#> Not opened: R is not interactive. Print the plot in an R session, or give `browser` to open it from a script.

# Bubbles in the layers' colors
p + mira_layer(color_by = "layer_name",
               color_values = c(layer_1 = "orange", layer_3 = "purple")) +
  mira_mode_layer()
#> Not opened: R is not interactive. Print the plot in an R session, or give `browser` to open it from a script.

# Bubbles colored by a layer column, as the layers are in network mode
p + mira_layer(color_by = "location") + mira_mode_layer()
#> Not opened: R is not interactive. Print the plot in an R session, or give `browser` to open it from a script.
```
