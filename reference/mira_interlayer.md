# Interlayer links: show, color, curvature and layer pairs

Styles the links between layers: whether they are drawn (`show`; MiRA
hides them by default), their color, a weight filter, how much they
curve, and between which layers they are shown (`pairs`). Add it to a
plot made with
[`mira()`](https://ggmira.ecomplab.com/reference/mira.md).

## Usage

``` r
mira_interlayer(
  show,
  color_by,
  color,
  min_weight,
  curvature,
  pairs,
  color_values,
  color_scale,
  color_palette,
  color_reverse,
  color_limits
)
```

## Arguments

- show:

  `TRUE` or `FALSE`: draw interlayer links.

- color_by:

  Link column to color interlayer links by. `NULL` or `NA` = default.

- color:

  A constant link color: a color name or `"#rrggbb"`. Give `color_by` or
  `color`, not both.

- min_weight:

  Hide links with weight below this value (0 or more, in the units of
  the data's `weight` column).

- curvature:

  Curvature of interlayer links, between 0 (straight) and 1 (0.35 =
  MiRA's default).

- pairs:

  Show only the interlayer links between these pairs of layers:
  `list(c("L1", "L2"), c("L2", "L3"))`, by `layer_name`; one pair may be
  given as a vector, `c("L1", "L2")`. The order within a pair does not
  matter. Also turns interlayer links on, unless the same call gives
  `show = FALSE`. A pair of layers with no links between them draws
  nothing. A later `pairs` replaces an earlier one; there is no value
  that shows all pairs again.

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

## Details

Interlayer links are drawn only with `show = TRUE` or `pairs`: the other
arguments alone style links that stay hidden (a `color_by` still shows
its legend).

## See also

[`mira_intralayer()`](https://ggmira.ecomplab.com/reference/mira_intralayer.md)
for the links within layers;
[mira_scales](https://ggmira.ecomplab.com/reference/mira_scales.md) for
`color_values` and `color_scale`.

Other components:
[`mira_camera()`](https://ggmira.ecomplab.com/reference/mira_camera.md),
[`mira_filter()`](https://ggmira.ecomplab.com/reference/mira_filter.md),
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

# Show interlayer links (hidden by default)
p + mira_interlayer(show = TRUE)
#> Not opened: R is not interactive. Print the plot in an R session, or give `browser` to open it from a script.

# One color, more curved; hide links with weight below 0.5
p + mira_interlayer(show = TRUE, color = "red", curvature = 0.8, min_weight = 0.5)
#> Not opened: R is not interactive. Print the plot in an R session, or give `browser` to open it from a script.

# Only between some layers (this also shows them)
p + mira_interlayer(pairs = list(c("layer_1", "layer_2")))
#> Not opened: R is not interactive. Print the plot in an R session, or give `browser` to open it from a script.

# Color by a link column, and choose the colors (see ?mira_scales)
p + mira_interlayer(show = TRUE, color_by = "type",
                    color_values = c(interlayer = "black"))
#> Not opened: R is not interactive. Print the plot in an R session, or give `browser` to open it from a script.
p + mira_interlayer(show = TRUE, color_by = "type", color_scale = "categorical")
#> Not opened: R is not interactive. Print the plot in an R session, or give `browser` to open it from a script.
```
