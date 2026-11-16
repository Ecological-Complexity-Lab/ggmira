# ggmira: Plot multilayer networks in MiRA from R

ggmira draws multilayer networks in MiRA, the browser-based multilayer
network visualizer, and describes how they should look with code, the
way ggplot2 does: start from the network with
[`mira()`](https://ggmira.ecomplab.com/reference/mira.md), add
components with `+`, and print the plot to open it in the browser.
Everything can still be changed in MiRA's interface.

## Plot basics

- [`mira()`](https://ggmira.ecomplab.com/reference/mira.md): start a
  plot from a multilayer network. Or start in MiRA:
  [`plot_mira()`](https://ggmira.ecomplab.com/reference/plot_mira.md)
  opens a network with MiRA's defaults, and MiRA's R button gives the
  [`mira()`](https://ggmira.ecomplab.com/reference/mira.md) code for the
  view made there.

- `+`: add a component to a plot.

- [`print.mira_plot()`](https://ggmira.ecomplab.com/reference/print.mira_plot.md):
  open the plot in the browser (typing its name does this too). MiRA's R
  button copies the view back as R code.

- [`mira_save()`](https://ggmira.ecomplab.com/reference/mira_save.md):
  save the plot as a PNG, JPG or PDF file, without opening a window.

- [`mira_spec()`](https://ggmira.ecomplab.com/reference/mira_spec.md):
  what the plot sends to MiRA.

- [`mira_options()`](https://ggmira.ecomplab.com/reference/mira_options.md):
  what each component can be set to, for a network.

## Elements (nodes, links, layers)

- [`mira_node()`](https://ggmira.ecomplab.com/reference/mira_node.md):
  node color, size, shape, labels and a highlighted node.

- [`mira_intralayer()`](https://ggmira.ecomplab.com/reference/mira_intralayer.md):
  the links within layers.

- [`mira_interlayer()`](https://ggmira.ecomplab.com/reference/mira_interlayer.md):
  the links between layers.

- [`mira_layer()`](https://ggmira.ecomplab.com/reference/mira_layer.md):
  layer colors, names and arrangement.

## Scales

- [mira_scales](https://ggmira.ecomplab.com/reference/mira_scales.md):
  how values become colors (`color_values`, `color_scale`,
  `color_palette`, `color_reverse`, `color_limits`) and sizes.

## Layout

- [`mira_layout()`](https://ggmira.ecomplab.com/reference/mira_layout.md):
  where the nodes go.

## Camera

- [`mira_camera()`](https://ggmira.ecomplab.com/reference/mira_camera.md):
  rotate, tilt, zoom and pan the view.

## Legends

- [`mira_legends()`](https://ggmira.ecomplab.com/reference/mira_legends.md):
  which legends are open, and where.

## Data (what is drawn)

- [`mira_filter()`](https://ggmira.ecomplab.com/reference/mira_filter.md):
  draw only some nodes, links or layers (network, grid and map views;
  `layers` also in the layer view).

## Views (MiRA's modes)

One view per plot; the other components still apply where MiRA uses them
([mira_mode](https://ggmira.ecomplab.com/reference/mira_mode.md): the
rules, and what applies in each view).

- [`mira_mode_grid()`](https://ggmira.ecomplab.com/reference/mira_mode_grid.md):
  the layers side by side.

- [`mira_mode_map()`](https://ggmira.ecomplab.com/reference/mira_mode_map.md):
  the layers on a geographic map.

- [`mira_mode_layer()`](https://ggmira.ecomplab.com/reference/mira_mode_layer.md):
  one bubble per layer.

- [`mira_mode_meta()`](https://ggmira.ecomplab.com/reference/mira_mode_meta.md):
  the network aggregated over layers; `layers` dims the nodes and links
  of the other layers.

- [`mira_mode_dashboard()`](https://ggmira.ecomplab.com/reference/mira_mode_dashboard.md):
  summary charts.

- [`mira_mode_data()`](https://ggmira.ecomplab.com/reference/mira_mode_data.md):
  the data tables.

## Opening a network with MiRA's defaults

- [`plot_mira()`](https://ggmira.ecomplab.com/reference/plot_mira.md):
  open a network with no components, in any view
  ([`plot_multilayer()`](https://ggmira.ecomplab.com/reference/plot_mira.md)
  is the same, in the network view).

## Feedback

- [`mira_feedback()`](https://ggmira.ecomplab.com/reference/mira_feedback.md):
  send feedback as a filled-in GitHub issue (with a GitHub account). The
  documentation pages have a *Feedback* button too.

## Networks

ggmira works with the multilayer objects of the emln package
([`emln::load_emln()`](https://rdrr.io/pkg/emln/man/load_emln.html),
[`emln::create_multilayer_network()`](https://rdrr.io/pkg/emln/man/create_multilayer_network.html)).
MiRA reads their four tables; a column added to `net$nodes`,
`net$state_nodes`, `net$extended` or `net$layers` can be mapped like any
other.

The full list of functions:
[`help(package = "ggmira")`](https://ggmira.ecomplab.com/reference).
Please report MiRA issues at
<https://github.com/Ecological-Complexity-Lab/MiRA/issues>.

## See also

Useful links:

- <https://github.com/Ecological-Complexity-Lab/ggmira>

## Author

**Maintainer**: Geut Galai <geutg@post.bgu.ac.il>

Authors:

- Shai Pilosof <pilos@bgu.ac.il>
  ([ORCID](https://orcid.org/0000-0003-0430-5568))

- Shir Miryam Nehoray ([ORCID](https://orcid.org/0009-0001-8453-4426))
