# ggmira

Plot multilayer networks in [MiRA](https://mira.ecomplab.com/) from R, and
describe how they should look with code, the way ggplot2 does.

ggmira works with the multilayer objects of the
[emln](https://emln.ecomplab.com/) package: `emln::load_emln()` for the
networks in the EMLN repository, `emln::create_multilayer_network()` for
your own data.

> **Status: development version of the Ecological Complexity Lab.** The
> package includes its own copy of MiRA, so plots open without internet
> access to mira.ecomplab.com.

## Installation

```r
install.packages("emln")
# install.packages("remotes")
remotes::install_github("Ecological-Complexity-Lab/ggmira")
```

The repository is private: `install_github()` needs a GitHub token with
access to it (create one with `usethis::create_github_token()`, store it
with `gitcreds::gitcreds_set()`).

## Beta testing

Thank you for testing ggmira. Please try it on the examples and, above
all, on a network of your own, and report anything that is wrong,
confusing or missing.

**1. Install** (R 4.1 or later). The repository is private, so
`install_github()` needs a GitHub token (once only):

```r
install.packages(c("usethis", "gitcreds", "remotes", "emln", "pkgdown", "rmarkdown"))
usethis::create_github_token()   # create the token on GitHub and copy it
gitcreds::gitcreds_set()         # paste it
remotes::install_github("Ecological-Complexity-Lab/ggmira")
```

To get fixes and new features later, run `install_github()` again and
restart R.

**2. Build the manual.** It is not published yet; build it from a clone of
the repository:

```bash
git clone https://github.com/Ecological-Complexity-Lab/ggmira.git
```

```r
pkgdown::build_site("path/to/ggmira", examples = FALSE)
pkgdown::preview_site("path/to/ggmira")
```

**3. What to try.**

- *Articles › Getting started*: run it step by step.
- *Reference*: run a few examples from each page (`?mira_node`,
  `?mira_scales`, ...). `?ggmira` lists the functions.
- Your own network: build it with `emln::create_multilayer_network()`,
  then make the plot you would want for a paper or a talk.
- Each plot opens in the browser; stop them all with
  `httpuv::stopAllServers()`.

**4. Report** each problem as an issue at
<https://github.com/Ecological-Complexity-Lab/ggmira/issues>, with the code
you ran, what you expected and what happened, and a screenshot of MiRA.
Report also what you could not figure out how to do, even if nothing broke.

## Opening a network

`plot_multilayer()` opens a network in MiRA with MiRA's default view:

```r
library(emln)
library(ggmira)

net <- load_emln(60)
plot_multilayer(net, bipartite = TRUE, setA_type = "pollinator")
```

## Plots as code: `mira()`

`mira()` describes a plot the way ggplot2 does: start from the network and
add components with `+`, one per part of the plot. Printing the plot opens
it in MiRA with those settings already applied; everything can still be
changed in MiRA's interface.

```r
net <- load_emln(14)
mira(net, bipartite = TRUE, setA_type = "pollinator") +
  mira_layout("kamada_kawai", seed = 42) +
  mira_node(color_by = c(pollinator = "intra_degree_sum", plant = NA), size = 8) +
  mira_intralayer(color = "grey40") +
  mira_layer(color_by = ".individual")
```

The components, grouped as in `?ggmira` and the reference index:

- **Elements.** `mira_node()`: `color_by` / `size_by` map a node or
  state-node column, or one MiRA computes (e.g. `"intra_degree_sum"`);
  `color`, `size` and `shape` set constants; `labels`, `label_size` show
  node names; `perspective`. `mira_intralayer()`, `mira_interlayer()`: link
  color and `min_weight`; `arrow_size` (directed networks);
  `mira_interlayer(show = TRUE)` draws interlayer links, `pairs` only those
  between some layers, and `curvature` bends them. `mira_layer()`: layer
  color by a layer column, or `"layer_name"` for one color per layer;
  `labels`, `label_size` show layer names, `set_labels` node set names;
  `stack` and `spacing` arrange the layers.
- **Scales** (`?mira_scales`): `color_values` and `color_scale` in the
  component that maps the attribute.
- **Layout.** `mira_layout()`: layout type; `seed` makes node positions
  reproducible.
- **Camera.** `mira_camera()`: `rotate`, `tilt` (degrees), `zoom`, `pan`.
  MiRA shows the current values under its zoom buttons; set the view with
  the mouse and click *Copy for R* to get the call. Zoom and pan are
  relative to the window, so the view matches exactly only in a window of
  the same size (not across screens or computers), and layers moved one by
  one (Cmd/Ctrl+drag) are not included (see `?mira_camera`).
- **Legends.** `mira_legends()`: legends start minimized; this opens all
  of them or those in `show`, at a `position`; `show = FALSE` hides them.
- **Highlight.** `mira_node(highlight = "Anocau")`: a node and its
  neighbors stand out, as in MiRA's Search Node.
- **Data.** `mira_filter()`: draw only some nodes (`nodes = type == "bird"`,
  or node names) or links (`links = weight > 0.1`), with conditions as in
  `subset()`.

### Color scales

`color_by` chooses what is colored; `color_values` and `color_scale` in the
same component choose the colors:

```r
mira(net) +
  mira_layer(color_by = "layer_name", color_values = c(layer_1 = "red")) +
  mira_node(color_by = "module", color_values = c("1" = "red", "3" = "#1f77b4")) +
  mira_intralayer(color_by = "trophic_level", color_scale = "categorical")
```

- `color_scale`: `"categorical"` (one color per value) or `"continuous"` (a
  gradient, numeric columns only). Without it, MiRA decides from the data.
- `color_values`: colors for some values, named by value (numbers need
  quotes). Values not listed keep MiRA's palette. They give a categorical
  scale.

MiRA keeps one scale per attribute name: if nodes and links are both colored
by `"module"`, they share its colors (see `?mira_scales`).

### More examples

Every function's help page builds a plot step by step on emln network 17
(`?mira_node`, `example(mira_layer)`, ...), and an example file uses every
argument of every component on the same network:

```r
file.edit(system.file("examples", "mira_examples.R", package = "ggmira"))
```

On a bipartite network (`bipartite = TRUE`), `color_by`, `size_by` and
`shape` also take one value per node set, named by `node_type`, as above
(`NA` keeps MiRA's default for that set). A bipartite network is drawn
undirected unless you pass `directed = TRUE`; other networks are detected
from the data.

Anything you leave out keeps MiRA's default. When a setting is given twice,
the later component wins. Settings that cannot work (a bipartite layout on a
network that is not bipartite) are errors; a column that is not in the
network, or a computed attribute MiRA does not have for it (e.g.
`"intra_degree_sum"` on a directed network, which has in and out variants),
is a warning, and MiRA keeps its default. `mira_spec(p)` shows what a plot
`p` sends to MiRA, and typing a component shows the call it stands for.

### Where the data comes from

MiRA reads the four tables of the multilayer object. To map a new variable,
add it as a column to the right one:

| Table | Used by |
|---|---|
| `net$nodes`, `net$state_nodes` | `mira_node(color_by, size_by)` |
| `net$extended` (links) | `mira_intralayer(color_by)`, `mira_interlayer(color_by)` |
| `net$layers` | `mira_layer(color_by)` |

```r
net$extended$log_weight <- log10(net$extended$weight)
mira(net) + mira_intralayer(color_by = "log_weight")
```

Link width and `min_weight` always use the `weight` column.

Each print starts a local server; stop them all with
`httpuv::stopAllServers()`.

## Development

The bundled MiRA in `inst/MiRA` is a copy, made from a MiRA checkout next
to this one (branch `feat/ggmira` until it is merged):

```bash
cd ~/GitHub/ecomplab/MiRA-dev
npm run sync:ggmira   # then commit inst/MiRA here
```

To try MiRA changes before syncing, point a plot to the checkout:

```r
devtools::load_all("~/GitHub/ecomplab/ggmira")
p <- mira(net, bipartite = TRUE) + mira_node(size = 8)
print(p, mira_path = "~/GitHub/ecomplab/MiRA-dev")
```

The documentation site (reference pages and articles) is built with
pkgdown into `docs/`, which is not committed:

```r
pkgdown::build_site(examples = FALSE) # examples shown as code, not run
```

Design notes, decisions and the roadmap live in the
[MiRA repository](https://github.com/Ecological-Complexity-Lab/MiRA)
(`development` branch, `dev/ggmira/`). Please report MiRA issues at
<https://github.com/Ecological-Complexity-Lab/MiRA/issues>.
