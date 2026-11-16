# Nodes: color, size, shape and labels

Maps node color and size to node attributes (`color_by`, `size_by`), or
sets them to constants (`color`, `size`, `shape`), and shows node names.
Add it to a plot made with
[`mira()`](https://ggmira.ecomplab.com/reference/mira.md). Anything not
given keeps MiRA's default.

## Usage

``` r
mira_node(
  color_by,
  color,
  size_by,
  size,
  shape,
  labels,
  label_size,
  perspective,
  color_values,
  color_scale,
  highlight,
  color_palette,
  color_reverse,
  color_limits
)
```

## Arguments

- color_by:

  Column to color nodes by: a node or state-node column (e.g.
  `"module"`) or a MiRA-computed attribute (e.g. `"intra_degree_sum"`).
  `".set"` colors by set membership (bipartite networks). `NULL` or `NA`
  = MiRA's default.

- color:

  A constant node color: a color name (`"red"`) or `"#rrggbb"`. Give
  `color_by` or `color`, not both. Colors are opaque: the transparency
  of a color such as `"#ff000080"` is ignored, with a warning (here and
  in every other color argument).

- size_by:

  Numeric column to size nodes by. `NULL` or `NA` = default.

- size:

  Base node size, a whole number between 3 and 25 (10 = MiRA's default).

- shape:

  `"circle"`, `"square"`, `"triangle"` or `"diamond"`. Every shape has
  the circle's area, so node sizes stay comparable.

- labels:

  `TRUE` or `FALSE`: show node names.

- label_size:

  Node name size, a whole number between 8 and 24 (12 = MiRA's default).
  Used when node names are shown.

- perspective:

  `TRUE` or `FALSE`: draw nodes in the layers' 3D perspective (MiRA's
  default) or flat.

- color_values:

  Colors for values of the `color_by` column, named by value:
  `c("1" = "red", "3" = "#1f77b4")`. Values not listed keep MiRA's
  palette. Gives a categorical scale. Per set:
  `list(pollinator = c(...))`. With `color_by = ".set"`, the colors of
  the sets: `c(pollinator = "red", plant = "green")`. See
  [mira_scales](https://ggmira.ecomplab.com/reference/mira_scales.md).

- color_scale:

  `"categorical"` (one color per value) or `"continuous"` (a gradient;
  numeric columns only). Without it, MiRA decides from the data. Per
  set: `c(pollinator = "continuous")`. See
  [mira_scales](https://ggmira.ecomplab.com/reference/mira_scales.md).

- highlight:

  A node name: the node and its neighbors stand out in every layer and
  the rest is dimmed, as when the node is picked in MiRA's Search Node.
  The banner "Selected node" clears it.

- color_palette:

  A named palette for the `color_by` scale: a categorical one
  (`"Okabe-Ito"`, `"Set1"`, ...) gives one color per value, a continuous
  one (`"magma"`, `"RdBu"`, ...) a gradient. Names are matched without
  case; the list is in
  [mira_scales](https://ggmira.ecomplab.com/reference/mira_scales.md).
  Per set: `c(pollinator = "magma")`.

- color_reverse:

  `TRUE` reverses the palette. Per set: `c(pollinator = TRUE)`.

- color_limits:

  `c(min, max)`: the gradient runs from `min` to `max` instead of the
  data's range, so several plots can share one scale; values outside
  take the end colors. Gives a continuous scale. Per set:
  `list(pollinator = c(0, 10))`.

## Value

A component, to add to a plot with `+`.

## Details

**Per set.** On a bipartite network (`mira(..., bipartite = TRUE)`),
`color_by`, `size_by`, `shape`, `color_scale`, `color_palette` and
`color_reverse` also take a vector named by the `node_type` values,
giving each set its own setting, e.g.
`color_by = c(pollinator = "module", plant = NA)`; `color_values` and
`color_limits` take a list named the same way,
`list(pollinator = c("1" = "red"))`. A set that is not named keeps
MiRA's default, and a later per-set value replaces an earlier one whole:
name both sets in one call. The scale settings of the two sets differ
only when the sets are colored by different attributes, because MiRA
keeps one scale per attribute name
([mira_scales](https://ggmira.ecomplab.com/reference/mira_scales.md)).
When color or size is per set and `shape` is not given, MiRA draws one
set as circles and the other as squares.

**Computed attributes.** MiRA computes each node's degree (its number of
links) and strength (the sum of their weights), within layers (`intra_`)
and between layers (`inter_`, when the network has interlayer links).
For each node in each layer (a state node): `intra_degree`,
`intra_strength`, `inter_degree`, `inter_strength`. For each node over
all its layers, their sum and their mean: `intra_degree_sum`,
`intra_degree_mean`, and so on. On a directed network the names carry
the direction instead: `intra_in_degree`, `intra_out_degree`,
`intra_in_strength_sum`, ... R warns when a name is not computed for the
network, and suggests the ones that are;
[`mira_options()`](https://ggmira.ecomplab.com/reference/mira_options.md)
lists them.

**Columns that cannot be mapped.** MiRA does not offer the columns that
identify the rows: `node_id`, `node_name`, `layer_id`, `layer_name` and
`layers_present` for nodes; `layer_from`, `node_from`, `layer_to`,
`node_to`, `weight` and `directed` for links; `layer_id`, `bipartite`,
`latitude` and `longitude` for layers. To map one, copy it to a column
of another name (`net$layers$lat <- net$layers$latitude`).

## See also

[mira_scales](https://ggmira.ecomplab.com/reference/mira_scales.md) for
`color_values`, `color_scale` and sizes;
[`mira()`](https://ggmira.ecomplab.com/reference/mira.md) for how
components combine.

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
[`mira_mode_meta()`](https://ggmira.ecomplab.com/reference/mira_mode_meta.md)

## Examples

``` r
library(emln)
net <- load_emln(17) # 4 layers; bird and plant nodes
#> Creating state node map
#> Creating extended link list with node IDs
p <- mira(net, bipartite = TRUE, setA_type = "bird")
#> Bipartite network: drawn as undirected. Use directed = TRUE for a directed one.

# Map color and size to attributes
p + mira_node(color_by = "verification_level", size_by = "intra_degree_sum")
#> Not opened: R is not interactive. Print the plot in an R session, or give `browser` to open it from a script.

# Constants
p + mira_node(color = "steelblue", size = 8, shape = "triangle")
#> Not opened: R is not interactive. Print the plot in an R session, or give `browser` to open it from a script.

# One setting per node set
p + mira_node(color_by = c(bird = "intra_degree_sum", plant = NA),
              shape = c(bird = "diamond", plant = "circle"))
#> Not opened: R is not interactive. Print the plot in an R session, or give `browser` to open it from a script.

# Node names; flat nodes
p + mira_node(labels = TRUE, label_size = 10, perspective = FALSE)
#> Not opened: R is not interactive. Print the plot in an R session, or give `browser` to open it from a script.

# Highlight a node and its neighbors
p + mira_node(highlight = "Geospiza_fortis")
#> Not opened: R is not interactive. Print the plot in an R session, or give `browser` to open it from a script.

# Choose the colors (see ?mira_scales)
p + mira_node(color_by = "verification_level",
              color_values = c(species = "#1f77b4", genus = "orange"))
#> Not opened: R is not interactive. Print the plot in an R session, or give `browser` to open it from a script.
p + mira_node(color_by = "intra_degree_sum", color_scale = "categorical")
#> Not opened: R is not interactive. Print the plot in an R session, or give `browser` to open it from a script.
```
