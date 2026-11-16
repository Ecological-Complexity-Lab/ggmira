# Legends: which are open, and where

A plot opens with every legend minimized (a button "Expand ... Legend").
`mira_legends()` opens them: all of them, or the ones named in `show`. A
legend appears only when its attribute is mapped (e.g. `node_size` needs
`mira_node(size_by = )`). In MiRA, legends can still be expanded,
minimized and dragged.

## Usage

``` r
mira_legends(show = "all", position)
```

## Arguments

- show:

  `"all"` (default; `TRUE` is the same), the legends to open (the others
  stay minimized): `"node_color"`, `"node_size"`, `"node_shape"`,
  `"intralayer_color"`, `"interlayer_color"`, `"layer_color"`; or
  `FALSE` to hide the legend panel (MiRA's legend button shows it
  again). With per-set colors or sizes, `"node_color"` and `"node_size"`
  open both sets' legends.

- position:

  Where the legends are: `"bottom-right"` (MiRA's default),
  `"top-right"` or `"bottom-left"`.

## Value

A component, to add to a plot with `+`.

## Details

These are the legends of network mode, which the grid and the map share.
The meta-network and the layer view have their own legends, which start
open: there, `position` and `show = FALSE` apply, and legend names in
`show` do not. A legend describes the whole network, also when
[`mira_filter()`](https://ggmira.ecomplab.com/reference/mira_filter.md)
draws part of it.

A later `mira_legends()` changes only the arguments it gives:
`mira_legends(position = "top-right")` moves the legends and leaves an
earlier `show` as it was. With no earlier `show` it opens all of them,
as `mira_legends()` does.

## See also

Other components:
[`mira_camera()`](https://ggmira.ecomplab.com/reference/mira_camera.md),
[`mira_filter()`](https://ggmira.ecomplab.com/reference/mira_filter.md),
[`mira_interlayer()`](https://ggmira.ecomplab.com/reference/mira_interlayer.md),
[`mira_intralayer()`](https://ggmira.ecomplab.com/reference/mira_intralayer.md),
[`mira_layer()`](https://ggmira.ecomplab.com/reference/mira_layer.md),
[`mira_layout()`](https://ggmira.ecomplab.com/reference/mira_layout.md),
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
p <- mira(net, bipartite = TRUE, setA_type = "bird") +
  mira_node(color_by = "verification_level", size_by = "intra_degree_sum") +
  mira_layer(color_by = "interaction_type")
#> Bipartite network: drawn as undirected. Use directed = TRUE for a directed one.

# Open every legend
p + mira_legends()
#> Not opened: R is not interactive. Print the plot in an R session, or give `browser` to open it from a script.

# Open two, at the top right
p + mira_legends(show = c("node_color", "layer_color"), position = "top-right")
#> Not opened: R is not interactive. Print the plot in an R session, or give `browser` to open it from a script.

# No legends
p + mira_legends(show = FALSE)
#> Not opened: R is not interactive. Print the plot in an R session, or give `browser` to open it from a script.
```
