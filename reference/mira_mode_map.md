# Map: open the plot with the layers on a geographic map

Opens the plot in MiRA's map mode: each layer at its coordinates on a
satellite map, fitted to the layers. Clicking a location (or its name in
the *Select Layers* panel) draws that layer's network over the map, as
drawn in network mode.
[`mira_filter()`](https://ggmira.ecomplab.com/reference/mira_filter.md)
applies. In MiRA, the map button opens this view.

## Usage

``` r
mira_mode_map()
```

## Value

A component, to add to a plot with `+`.

## Details

The map needs the layers' coordinates: `latitude` and `longitude`
columns in `net$layers`, with both values for at least one layer.
Without them R stops with an error. The map's settings (opacity, street
map, which layers are drawn) are not available from R yet; the map opens
with MiRA's defaults.

A plot opens in one view: see
[mira_mode](https://ggmira.ecomplab.com/reference/mira_mode.md) for the
rules and for what applies in each view.

![Network 17 in map mode: the Galapagos, with the layers' two islands
marked](figures/mira_mode_map.jpg)

## See also

[mira_mode](https://ggmira.ecomplab.com/reference/mira_mode.md) for the
other views;
[`mira_mode_layer()`](https://ggmira.ecomplab.com/reference/mira_mode_layer.md),
which also places the layers on the map.

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
[`mira_mode_meta()`](https://ggmira.ecomplab.com/reference/mira_mode_meta.md),
[`mira_node()`](https://ggmira.ecomplab.com/reference/mira_node.md)

## Examples

``` r
library(emln)
net <- load_emln(17) # 4 layers on two islands of the Galapagos
#> Creating state node map
#> Creating extended link list with node IDs
net$layers[, c("layer_name", "latitude", "longitude")]
#> # A tibble: 4 × 3
#>   layer_name latitude longitude
#>   <chr>         <dbl>     <dbl>
#> 1 layer_1      -0.909     -89.6
#> 2 layer_2      -0.909     -89.6
#> 3 layer_3      -0.533     -90.4
#> 4 layer_4      -0.533     -90.4
p <- mira(net, bipartite = TRUE, setA_type = "bird")
#> Bipartite network: drawn as undirected. Use directed = TRUE for a directed one.
p + mira_mode_map()
#> Not opened: R is not interactive. Print the plot in an R session, or give `browser` to open it from a script.
```
