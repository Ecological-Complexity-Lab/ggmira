# Intralayer links: color, weight filter and arrowheads

Styles the links within layers: color by a link column (`color_by`) or
one constant (`color`), hide weak links (`min_weight`), size arrowheads
(`arrow_size`). Add it to a plot made with
[`mira()`](https://ggmira.ecomplab.com/reference/mira.md).

## Usage

``` r
mira_intralayer(
  color_by,
  color,
  min_weight,
  arrow_size,
  color_values,
  color_scale,
  color_palette,
  color_reverse,
  color_limits
)
```

## Arguments

- color_by:

  Link column to color intralayer links by (a column of `net$extended`,
  e.g. `"type"`; not `weight`, which sets the links' width). `NULL` or
  `NA` = default.

- color:

  A constant link color: a color name or `"#rrggbb"`. Give `color_by` or
  `color`, not both.

- min_weight:

  Hide links with weight below this value (0 or more, in the units of
  the data's `weight` column).

- arrow_size:

  Arrowhead size, between 0 and 3 (1 = MiRA's default). Directed
  networks only. MiRA has one arrowhead size, so this also sizes the
  arrowheads of directed interlayer links.

- color_values:

  Colors for values of the `color_by` column, named by value. See
  [mira_scales](https://ggmira.ecomplab.com/reference/mira_scales.md).

- color_scale:

  `"categorical"` or `"continuous"`. See
  [mira_scales](https://ggmira.ecomplab.com/reference/mira_scales.md).

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

## See also

[`mira_interlayer()`](https://ggmira.ecomplab.com/reference/mira_interlayer.md)
for the links between layers;
[mira_scales](https://ggmira.ecomplab.com/reference/mira_scales.md) for
`color_values` and `color_scale`.

Other components:
[`mira_camera()`](https://ggmira.ecomplab.com/reference/mira_camera.md),
[`mira_filter()`](https://ggmira.ecomplab.com/reference/mira_filter.md),
[`mira_interlayer()`](https://ggmira.ecomplab.com/reference/mira_interlayer.md),
[`mira_layer()`](https://ggmira.ecomplab.com/reference/mira_layer.md),
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

# Color by a link column
p + mira_intralayer(color_by = "type")
#> Not opened: R is not interactive. Print the plot in an R session, or give `browser` to open it from a script.

# One color; hide links with weight below 0.05
p + mira_intralayer(color = "grey60", min_weight = 0.05)
#> Not opened: R is not interactive. Print the plot in an R session, or give `browser` to open it from a script.

# Choose the colors (see ?mira_scales)
p + mira_intralayer(color_by = "type", color_values = c(pollination = "#d62728"))
#> Not opened: R is not interactive. Print the plot in an R session, or give `browser` to open it from a script.
p + mira_intralayer(color_by = "type", color_scale = "categorical")
#> Not opened: R is not interactive. Print the plot in an R session, or give `browser` to open it from a script.

# Arrowheads, on a directed network
mira(net, bipartite = TRUE, setA_type = "bird", directed = TRUE) +
  mira_intralayer(arrow_size = 0.5)
#> Not opened: R is not interactive. Print the plot in an R session, or give `browser` to open it from a script.
```
