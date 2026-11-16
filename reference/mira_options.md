# What each component can be set to, for a network

Lists the attributes a network offers to each component's arguments: the
columns and computed attributes `color_by` and `size_by` take, the
columns conditions in
[`mira_filter()`](https://ggmira.ecomplab.com/reference/mira_filter.md)
and `mira_mode_meta(layers = )` can use, and the measures of the
meta-network. For each, the type MiRA gives it and a summary of its
values, to choose a mapping and write `color_values` before making the
plot.

## Usage

``` r
mira_options(net, ...)
```

## Arguments

- net:

  A multilayer network from emln (as for
  [`mira()`](https://ggmira.ecomplab.com/reference/mira.md)).

- ...:

  Arguments of
  [`mira()`](https://ggmira.ecomplab.com/reference/mira.md):
  `bipartite`, `setA_type`, `directed`, `directed_interlayer`.

## Value

A data frame of class `mira_options`, one row per argument and
attribute, with columns `component`, `argument`, `attribute`, `type`,
`switchable`, `source` (`"node"`, `"state node"`, `"link"`, `"layer"`,
`"computed"` by MiRA, or `"keyword"`), `sets` (on a bipartite network,
the node sets that have the attribute) and `values`. It prints grouped
by component, with MiRA's computed node attributes on one line (the data
frame has a row for each), and with the sets only when they differ
between attributes. Filter it as a data frame, keeping all its columns:
rows chosen with `opts[opts$argument == "size_by", ]` print as the table
does; for some columns only, use `as.data.frame(opts)`.

## Details

Columns MiRA does not offer are left out (the ones that identify rows,
`weight`, the coordinates; see
[`mira_node()`](https://ggmira.ecomplab.com/reference/mira_node.md)).
The node type column is listed as `node_type`, MiRA's name for it,
whatever it is called in `net$nodes`; conditions in
[`mira_filter()`](https://ggmira.ecomplab.com/reference/mira_filter.md)
use the name in the data.

Give the same arguments as to
[`mira()`](https://ggmira.ecomplab.com/reference/mira.md): they decide
what MiRA computes (in- and out-degree only on a directed network) and
whether nodes can be set per set (`bipartite = TRUE`).

**Types.** `"categorical"` (one color per value) or `"continuous"` (a
gradient) is the scale MiRA picks by default: numbers with more than two
values, or with a name such as `abundance` or `degree`, are continuous,
unless the name marks groups (`module`, `cluster`); text is categorical.
Where `switchable` is `TRUE`, `color_scale` can choose the other one
(see
[mira_scales](https://ggmira.ecomplab.com/reference/mira_scales.md)).
The type also decides the palettes `color_palette` can name: categorical
ones (`"Okabe-Ito"`, `"Set1"`, ...) or continuous ones (`"magma"`,
`"RdBu"`, ...). `"set"` and `"individual"` are keywords: one color per
node set, one color per layer. Columns for conditions have the type of
their values: `"number"`, `"text"` or `"logical"`.

## See also

[`mira()`](https://ggmira.ecomplab.com/reference/mira.md) to start a
plot;
[`mira_node()`](https://ggmira.ecomplab.com/reference/mira_node.md) and
the other components for the arguments;
[mira_scales](https://ggmira.ecomplab.com/reference/mira_scales.md) for
`color_values`, `color_scale`, `color_palette`, `color_reverse` and
`color_limits`.

## Examples

``` r
library(emln)
net <- load_emln(17) # 4 layers; bird and plant nodes
#> Creating state node map
#> Creating extended link list with node IDs

mira_options(net, bipartite = TRUE, setA_type = "bird")
#> mira_node()
#>   color_by    node_type           categorical  node        2 values: bird, plant
#>               taxa_verified       categorical  node        2 values: FALSE, TRUE
#>               verification_level  categorical  node        3 values: family, ...
#>               type                categorical  state node  2 values: bird, plant
#>               (computed)          continuous*  computed    12 attributes, e.g...
#>               .set                set          keyword     one color per set:...
#>   size_by     (computed)          continuous   computed    12 attributes, e.g...
#> mira_intralayer()
#>   color_by    type                categorical  link        2 values: pollinat...
#>   min_weight  weight              number       link        0.00285 to 1 (180 ...
#> mira_interlayer()
#>   color_by    type                categorical  link        1 value: interlayer
#>   min_weight  weight              number       link        0.416 to 0.89 (15 ...
#> mira_layer()
#>   color_by    interaction_type    categorical  layer       2 values: pollinat...
#>               location            categorical  layer       2 values: San Cris...
#>               layer_name          individual   keyword     one color per laye...
#> mira_filter()
#>   nodes       node_id             number       node        1 to 129 (129 values)
#>               node_name           text         node        129 values: Acacia...
#>               type                text         node        2 values: bird, plant
#>               taxa_verified       text         node        2 values: FALSE, TRUE
#>               verification_level  text         node        3 values: family, ...
#>   links       layer_from          text         link        4 values: layer_1,...
#>               node_from           text         link        126 values: Acacia...
#>               layer_to            text         link        4 values: layer_1,...
#>               node_to             text         link        13 values: Camarhy...
#>               weight              number       link        0.00285 to 1 (195 ...
#>               type                text         link        3 values: interlay...
#>   layers      layer_id            number       layer       1 to 4 (4 values)
#>               name                text         layer       4 values: pollinat...
#>               interaction_type    text         layer       2 values: pollinat...
#>               location            text         layer       2 values: San Cris...
#>               latitude            number       layer       -0.909 to -0.533 (...
#>               longitude           number       layer       -90.4 to -89.6 (2 ...
#>               layer_name          text         layer       4 values: layer_1,...
#> mira_mode_meta()
#>   color_by    participation       continuous   computed    number of layers a...
#>               degree              continuous   computed    links in the meta-...
#>               uniform             constant     computed    one color or size ...
#>   size_by     participation       continuous   computed    number of layers a...
#>               degree              continuous   computed    links in the meta-...
#>               uniform             constant     computed    one color or size ...
#>   layers      layer_id            number       layer       1 to 4 (4 values)
#>               name                text         layer       4 values: pollinat...
#>               interaction_type    text         layer       2 values: pollinat...
#>               location            text         layer       2 values: San Cris...
#>               latitude            number       layer       -0.909 to -0.533 (...
#>               longitude           number       layer       -90.4 to -89.6 (2 ...
#>               layer_name          text         layer       4 values: layer_1,...
#> * MiRA's default scale; color_scale can choose the other (see ?mira_scales)
#> nodes  intralayer links  interlayer links  layers 

# Only what can size nodes
opts <- mira_options(net, bipartite = TRUE)
opts[opts$argument == "size_by", ]
#> mira_node()
#>   size_by  (computed)     continuous  computed  12 attributes, e.g. intra_deg...
#> mira_mode_meta()
#>   size_by  participation  continuous  computed  number of layers a node is in
#>            degree         continuous  computed  links in the meta-network
#>            uniform        constant    computed  one color or size for all
#> nodes 
```
