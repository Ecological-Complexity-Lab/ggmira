# Filter: draw only some nodes, links or layers

Keeps part of the network: some nodes, some links, some layers, or a
combination. Each argument takes a condition on the columns of the
network's tables, evaluated like
[`subset()`](https://rdrr.io/r/base/subset.html): `nodes` on
`net$nodes`, `links` on `net$extended`, `layers` on `net$layers`.
Variables of your session can be used too. `nodes` also takes node
names, and `layers` layer names.

## Usage

``` r
mira_filter(nodes, links, layers)
```

## Arguments

- nodes:

  A condition on the columns of `net$nodes` (e.g. `type == "bird"`), or
  node names. `NULL` or `NA` = no node filter.

- links:

  A condition on the columns of `net$extended` (e.g. `weight > 0.05`,
  `layer_from == "layer_1"`). `NULL` or `NA` = no link filter.

- layers:

  A condition on the columns of `net$layers` (e.g. `latitude > -0.6`),
  or layer names. `NULL` or `NA` = no layer filter.

## Value

A component, to add to a plot with `+`.

## Details

A hidden node hides its links; a hidden layer hides its nodes and links,
and the other layers close up the stack. Filters combine: a link is
drawn when it passes `links`, both its nodes pass `nodes` and both its
layers pass `layers`. A later `mira_filter()` replaces the same argument
of an earlier one, so combine two conditions on nodes in one:
`nodes = A & B`. `NULL` or `NA` written in the call removes an earlier
filter (`mira_filter(nodes = NULL)`); a variable that holds `NULL` is an
error.

Rows where a condition is `NA` are dropped. MiRA shows "Data filter
active" with a button that removes the filter. The legends still
describe the whole network.

Conditions use the columns as they are named in the tables. On a
bipartite network from
[`emln::load_emln()`](https://rdrr.io/pkg/emln/man/load_emln.html) the
node sets are in `type` (`nodes = type == "bird"`), although MiRA, and
[`mira_options()`](https://ggmira.ecomplab.com/reference/mira_options.md),
call that column `node_type`.

A condition is evaluated where `mira_filter()` is called, like
[`subset()`](https://rdrr.io/r/base/subset.html): inside a function, it
sees that function's variables. A function that passes its arguments on
through `...` does not see its caller's variables; pass values, not
names, through such a wrapper. A node that `mira_node(highlight = )`
highlights must pass the filter, or MiRA highlights nothing (a warning).
MiRA filters in network, grid and map modes; the layer view applies
`layers` only (each bubble stands for a whole layer). In the other views
([mira_mode](https://ggmira.ecomplab.com/reference/mira_mode.md)) the
whole network is shown, with a warning. The meta-network has its own
layer filter, which dims layers instead: `mira_mode_meta(layers = )`.

## See also

[`mira_intralayer()`](https://ggmira.ecomplab.com/reference/mira_intralayer.md)
and
[`mira_interlayer()`](https://ggmira.ecomplab.com/reference/mira_interlayer.md)
for `min_weight`, which hides weak links without a filter.

Other components:
[`mira_camera()`](https://ggmira.ecomplab.com/reference/mira_camera.md),
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

# Nodes by a condition on their columns
p + mira_filter(nodes = verification_level == "species")
#> Not opened: R is not interactive. Print the plot in an R session, or give `browser` to open it from a script.

# Nodes by name
p + mira_filter(nodes = c("Geospiza_fortis", "Opuntia_echios"))
#> Not opened: R is not interactive. Print the plot in an R session, or give `browser` to open it from a script.

# Links by a condition: strong links, or the links of one layer
p + mira_filter(links = weight > 0.1)
#> Not opened: R is not interactive. Print the plot in an R session, or give `browser` to open it from a script.
p + mira_filter(links = layer_from == "layer_1" & layer_to == "layer_1")
#> Not opened: R is not interactive. Print the plot in an R session, or give `browser` to open it from a script.

# Both, in one call; a variable of your session
keep <- c("species", "genus")
p + mira_filter(nodes = verification_level %in% keep, links = weight > 0.05)
#> Not opened: R is not interactive. Print the plot in an R session, or give `browser` to open it from a script.

# Layers by name, or by a condition on net$layers
p + mira_filter(layers = c("layer_1", "layer_3"))
#> Not opened: R is not interactive. Print the plot in an R session, or give `browser` to open it from a script.
p + mira_filter(layers = latitude > -0.6)
#> Not opened: R is not interactive. Print the plot in an R session, or give `browser` to open it from a script.
```
