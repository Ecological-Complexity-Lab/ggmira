# What a plot sends to MiRA

Shows the settings a plot sends to MiRA: those of its components, after
merging. Useful to check a plot before opening it.

## Usage

``` r
mira_spec(x, json = FALSE)
```

## Arguments

- x:

  A `mira_plot`.

- json:

  `FALSE` (default) for an R list, `TRUE` for the JSON string MiRA
  receives.

## Value

A list, or a JSON string.

## Details

The list has one element per part of the plot that was set (`layout`,
`node`, `intralayer`, `interlayer`, `layer`, `filter`, `camera`,
`legend`, `mode`), each with the arguments given, and `version`, the
version of the format. Some settings are shown as MiRA receives them,
not as they were written:

- colors as `"#rrggbb"`;

- a
  [`mira_filter()`](https://ggmira.ecomplab.com/reference/mira_filter.md)
  condition as the names it keeps (node names, layer names, links as
  layer and node names);

- `color_values`, `color_scale`, `color_palette`, `color_reverse` and
  `color_limits` under `scales`, one entry per attribute name, merged
  over the components
  ([mira_scales](https://ggmira.ecomplab.com/reference/mira_scales.md));
  one color per layer under `layer$colors`.

The network itself is not included. A plot with no components sends only
`version`: MiRA's default view.

## Examples

``` r
library(emln)
net <- load_emln(17) # 4 layers; bird and plant nodes
#> Creating state node map
#> Creating extended link list with node IDs
p <- mira(net, bipartite = TRUE, setA_type = "bird")
#> Bipartite network: drawn as undirected. Use directed = TRUE for a directed one.

mira_spec(p + mira_node(color = "red"))
#> $version
#> [1] 1
#> 
#> $node
#> $node$color
#> [1] "#ff0000"
#> 
#> 
mira_spec(p + mira_node(color = "red"), json = TRUE)
#> [1] "{\n  \"version\": 1,\n  \"node\": {\n    \"color\": \"#ff0000\"\n  }\n}"
```
