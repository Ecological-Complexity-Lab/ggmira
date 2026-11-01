# ggmira

Plot multilayer networks in [MiRA](https://mira.ecomplab.com/) from R.

Internal development version (Ecological Complexity Lab).

```r
library(emln)
library(ggmira)

net <- load_emln(60)
plot_multilayer(net, bipartite = TRUE, setA_type = "pollinator")
```

During development, point to a local MiRA checkout:

```r
devtools::load_all("~/GitHub/ecomplab/ggmira")
plot_multilayer(net, bipartite = TRUE, mira_path = "~/GitHub/ecomplab/MiRA-dev")
```

## Plots as code: `mira()`

`mira()` describes a plot the way ggplot2 does: start from the network and
add pieces with `+`. Printing the plot opens it in MiRA with those settings
already applied; everything can still be changed in MiRA's interface.

```r
net <- load_emln(14)
mira(net, bipartite = TRUE, setA_type = "pollinator") +
  mira_layout("kamada_kawai", seed = 42) +
  mira_node(color_by = c(pollinator = "intra_degree_sum", plant = NA), size = 8) +
  mira_intralayer(color = "grey40") +
  mira_layer(color_by = ".individual")
```

- `mira_layout()`: layout type; `seed` makes node positions reproducible.
- `mira_node()`: `color_by` / `size_by` map a node or state-node column, or
  one MiRA computes (e.g. `"intra_degree_sum"`); `color`, `size` and `shape`
  set constants.
- `mira_intralayer()`, `mira_interlayer()`: link color and `min_weight`;
  `mira_interlayer(show = TRUE)` draws interlayer links.
- `mira_layer()`: layer color by a layer column, or `".individual"` for one
  color per layer.

On a bipartite network (`bipartite = TRUE`), `color_by`, `size_by` and
`shape` also take one value per node set, named by `node_type`, as above
(`NA` keeps MiRA's default for that set). A bipartite network is drawn
undirected unless you pass `directed = TRUE`; other networks are detected
from the data.

Anything you leave out keeps MiRA's default. When a setting is given twice,
the later piece wins. Settings that cannot work (a bipartite layout on a
network that is not bipartite) are errors; a column that is not in the
network is a warning, and MiRA keeps its default. `mira_spec(p)` shows what
a plot `p` sends to MiRA.

Design notes, decisions and the roadmap live in the MiRA repository
(`development` branch, `dev/ggmira/`).
