# Layers: color, names and arrangement

Styles the layers: their color (by a layer column, one per layer, or one
constant), their names and the node set names, and how they are stacked
and spaced. Add it to a plot made with
[`mira()`](https://ggmira.ecomplab.com/reference/mira.md).

## Usage

``` r
mira_layer(
  color_by,
  color,
  color_values,
  color_scale,
  labels,
  label_size,
  set_labels,
  stack,
  spacing,
  color_palette,
  color_reverse,
  color_limits
)
```

## Arguments

- color_by:

  Layer column to color layers by (a column of `net$layers`), or
  `"layer_name"` for one color per layer (`".individual"` works too).
  `NULL` or `NA` = default.

- color:

  A constant layer color: a color name or `"#rrggbb"`. Give `color_by`
  or `color`, not both.

- color_values:

  Colors for values of the `color_by` column, named by value. With
  `color_by = "layer_name"`, named by layer:
  `c(L1 = "red", L3 = "#1f77b4")`; layers not listed keep MiRA's color.
  See
  [mira_scales](https://ggmira.ecomplab.com/reference/mira_scales.md).

- color_scale:

  `"categorical"` or `"continuous"`. Not with `color_by = "layer_name"`.
  See
  [mira_scales](https://ggmira.ecomplab.com/reference/mira_scales.md).

- labels:

  `TRUE` or `FALSE`: show layer names.

- label_size:

  Layer name size, a whole number between 8 and 32 (14 = MiRA's
  default). Used when layer names are shown.

- set_labels:

  `TRUE` or `FALSE`: show node set names (bipartite layout only; needs
  `mira(..., bipartite = TRUE)`).

- stack:

  `"horizontal"` or `"vertical"`: how layers are stacked.

- spacing:

  Space between layers, a whole number between 100 and 600 (300 = MiRA's
  default).

- color_palette:

  A named palette for the `color_by` scale: categorical (`"Okabe-Ito"`,
  ...) or continuous (`"magma"`, ...); see
  [mira_scales](https://ggmira.ecomplab.com/reference/mira_scales.md)
  for the list.

- color_reverse:

  `TRUE` reverses the palette.

- color_limits:

  `c(min, max)`: the gradient runs from `min` to `max` instead of the
  data's range; values outside take the end colors. Gives a continuous
  scale.

## Value

A component, to add to a plot with `+`.

## Details

Layer colors are used in the network, grid and map views. In the layer
view
([`mira_mode_layer()`](https://ggmira.ecomplab.com/reference/mira_mode_layer.md))
the bubbles follow `color_by`, not a constant `color`. One color per
layer (`color_by = "layer_name"`) is not a scale: its colors are given
with `color_values`, and `color_scale`, `color_palette`, `color_reverse`
and `color_limits` with it are errors.

## See also

[mira_scales](https://ggmira.ecomplab.com/reference/mira_scales.md) for
`color_values` and `color_scale`.

Other components:
[`mira_camera()`](https://ggmira.ecomplab.com/reference/mira_camera.md),
[`mira_filter()`](https://ggmira.ecomplab.com/reference/mira_filter.md),
[`mira_interlayer()`](https://ggmira.ecomplab.com/reference/mira_interlayer.md),
[`mira_intralayer()`](https://ggmira.ecomplab.com/reference/mira_intralayer.md),
[`mira_layout()`](https://ggmira.ecomplab.com/reference/mira_layout.md),
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

# Color by a layer column, or one color for all
p + mira_layer(color_by = "interaction_type")
#> Not opened: R is not interactive. Print the plot in an R session, or give `browser` to open it from a script.
p + mira_layer(color = "#e5e7eb")
#> Not opened: R is not interactive. Print the plot in an R session, or give `browser` to open it from a script.

# One color per layer, two of them set by hand
p + mira_layer(color_by = "layer_name",
               color_values = c(layer_1 = "orange", layer_3 = "#9467bd"))
#> Not opened: R is not interactive. Print the plot in an R session, or give `browser` to open it from a script.

# Choose the colors of a column (see ?mira_scales)
p + mira_layer(color_by = "interaction_type", color_scale = "categorical",
               color_values = c("seed-dispersal" = "#17becf"))
#> Not opened: R is not interactive. Print the plot in an R session, or give `browser` to open it from a script.

# Layer names and node set names
p + mira_layer(labels = TRUE, label_size = 18, set_labels = TRUE)
#> Not opened: R is not interactive. Print the plot in an R session, or give `browser` to open it from a script.

# Stack the layers top to bottom, closer together
p + mira_layer(stack = "vertical", spacing = 250)
#> Not opened: R is not interactive. Print the plot in an R session, or give `browser` to open it from a script.
```
