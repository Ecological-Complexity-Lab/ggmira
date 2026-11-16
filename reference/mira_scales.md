# Scales: how data values become colors and sizes

A scale turns the values of a mapped attribute into colors or sizes. In
ggmira the scale lives in the component that maps the attribute: in
[`mira_node()`](https://ggmira.ecomplab.com/reference/mira_node.md),
[`mira_intralayer()`](https://ggmira.ecomplab.com/reference/mira_intralayer.md),
[`mira_interlayer()`](https://ggmira.ecomplab.com/reference/mira_interlayer.md)
and
[`mira_layer()`](https://ggmira.ecomplab.com/reference/mira_layer.md),
`color_by` chooses what is colored, and five arguments in the same call
choose the colors: `color_scale` (one color per value, or a gradient),
`color_palette` and `color_reverse` (which colors), `color_limits` (the
ends of a gradient) and `color_values` (colors given by hand).

## Color

- `color_scale = "categorical"` gives each value its own color (MiRA's
  Dark2 palette); `"continuous"` a gradient (Viridis, from the column's
  minimum to its maximum; numeric columns only). Without it, MiRA
  decides from the data: text gets one color per value; numbers get a
  gradient when they have more than two values or a name that sounds
  like a measure (containing `weight`, `abundance`, `degree`,
  `strength`, `mass`, `size` or `value`), unless the name marks groups
  (`module`, `group`, `cluster`, `community`, `partition`).
  [`mira_options()`](https://ggmira.ecomplab.com/reference/mira_options.md)
  shows the type MiRA picks for each attribute.

- `color_palette` chooses the palette by name (matched without case):

  - categorical: `"Dark2"` (MiRA's default), `"Set1"`, `"Set2"`,
    `"Set3"`, `"Paired"`, `"Accent"`, `"Okabe-Ito"` (colorblind-safe).
    Columns with more values than colors reuse them, so two values can
    share a color (the palettes have 8 to 12 colors).

  - continuous, sequential: `"viridis"` (MiRA's default), `"magma"`,
    `"cividis"` (colorblind-optimized), `"Blues"`, `"Greens"`, `"Reds"`,
    `"Purples"`, `"Oranges"`, `"Greys"`, `"YlOrRd"`, `"YlGnBu"`.

  - continuous, diverging (two sides of a middle): `"RdBu"`, `"RdYlBu"`,
    `"Spectral"`, `"PiYG"`, `"BrBG"`, `"PuOr"`.

  A categorical palette gives a categorical scale and a continuous one a
  gradient, so `color_scale` is not needed with it.
  `color_reverse = TRUE` reverses the palette (light to dark, or the two
  sides of a diverging one). In MiRA, the legend has the same choices.

- `color_limits = c(min, max)` sets the ends of a gradient instead of
  the data's range, so several plots can share one scale (e.g. 0 to 1
  for proportions); values outside take the end colors. With a diverging
  palette, limits centered on 0 put the middle color at 0. It gives a
  continuous scale.

- Palettes and limits need no values, so they also work for the
  attributes MiRA computes (`intra_degree_sum`, ...).

- `color_values` sets the colors of some values, named by value:
  `c("1" = "red", "3" = "#1f77b4")` (numbers need quotes as names).
  Values not listed keep the palette's color. It gives a categorical
  scale, so it cannot be combined with `color_scale = "continuous"`.

- On a bipartite network,
  [`mira_node()`](https://ggmira.ecomplab.com/reference/mira_node.md)
  takes all five per node set: `color_scale = c(bird = "continuous")`,
  `color_palette = c(bird = "magma")`, `color_reverse = c(bird = TRUE)`,
  `color_limits = list(bird = c(0, 10))`,
  `color_values = list(plant = c(species = "blue"))`. They differ
  between the sets only when the sets are colored by different
  attributes (one scale per attribute name, below).

- Two special mappings take colors named by element rather than by
  value:
  `mira_layer(color_by = "layer_name", color_values = c(L1 = "red"))`
  colors layers one by one, and
  `mira_node(color_by = ".set", color_values = c(bird = "red"))` colors
  the two node sets. These two are not scales: they take `color_values`
  only, and `color_scale`, `color_palette`, `color_reverse` and
  `color_limits` with them are errors.

**One scale per attribute name.** MiRA keeps one color scale (type,
palette, reversal, limits and colors) per attribute name, used wherever
that attribute colors nodes, links or layers (as in MiRA's legends,
where changing a color changes it for every element). So when two
components color by the same attribute name, their settings are merged:
a value that appears in both tables (node `module` 1 and link
`module` 1) has one color. If the components disagree (a value given two
colors, or two scale types), the later one wins, with a warning; a
continuous scale cannot be combined with `color_values` for the same
attribute (an error). A `color`, or a `color_by` of a different column,
drops that component's earlier `color_values` and `color_scale`.

## Size

`mira_node(size_by = )` sizes nodes by a numeric attribute, scaled by
MiRA from the smallest to the largest value; `size` sets the base size
(and the only size, without `size_by`). Link width always follows the
`weight` column, which is why `weight` cannot color links. A size range
from R is planned.

## See also

[`mira()`](https://ggmira.ecomplab.com/reference/mira.md) for how
components combine.

## Examples

``` r
library(emln)
net <- load_emln(17) # 4 layers; bird and plant nodes
#> Creating state node map
#> Creating extended link list with node IDs
p <- mira(net, bipartite = TRUE, setA_type = "bird")
#> Bipartite network: drawn as undirected. Use directed = TRUE for a directed one.

# Colors of some values; the others keep MiRA's palette
p + mira_node(color_by = "verification_level",
              color_values = c(species = "#1f77b4", genus = "orange"))
#> Not opened: R is not interactive. Print the plot in an R session, or give `browser` to open it from a script.

# The same numeric attribute as a gradient, or one color per value
p + mira_node(color_by = "intra_degree_sum", color_scale = "continuous")
#> Not opened: R is not interactive. Print the plot in an R session, or give `browser` to open it from a script.
p + mira_node(color_by = "intra_degree_sum", color_scale = "categorical")
#> Not opened: R is not interactive. Print the plot in an R session, or give `browser` to open it from a script.

# A palette, reversed; a gradient with fixed ends
p + mira_node(color_by = "verification_level", color_palette = "Okabe-Ito")
#> Not opened: R is not interactive. Print the plot in an R session, or give `browser` to open it from a script.
p + mira_node(color_by = "intra_degree_sum", color_palette = "magma", color_reverse = TRUE)
#> Not opened: R is not interactive. Print the plot in an R session, or give `browser` to open it from a script.
p + mira_node(color_by = "intra_degree_sum", color_palette = "cividis", color_limits = c(0, 30))
#> Not opened: R is not interactive. Print the plot in an R session, or give `browser` to open it from a script.
p + mira_intralayer(color_by = "type", color_palette = "Set1")
#> Not opened: R is not interactive. Print the plot in an R session, or give `browser` to open it from a script.

# Per node set
p + mira_node(color_by = c(bird = "intra_degree_sum", plant = "verification_level"),
              color_scale = c(bird = "continuous"),
              color_values = list(plant = c(species = "blue")))
#> Not opened: R is not interactive. Print the plot in an R session, or give `browser` to open it from a script.

# One color per layer; the colors of the two node sets
p + mira_layer(color_by = "layer_name", color_values = c(layer_1 = "orange"))
#> Not opened: R is not interactive. Print the plot in an R session, or give `browser` to open it from a script.
p + mira_node(color_by = ".set", color_values = c(bird = "red", plant = "green"))
#> Not opened: R is not interactive. Print the plot in an R session, or give `browser` to open it from a script.

# Size by an attribute, from a base size
p + mira_node(size_by = "intra_degree_sum", size = 6)
#> Not opened: R is not interactive. Print the plot in an R session, or give `browser` to open it from a script.
```
