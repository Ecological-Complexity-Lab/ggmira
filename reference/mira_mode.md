# Views: open the plot in another of MiRA's views

MiRA shows a network in several views, each opened by a button in MiRA's
toolbar. MiRA calls them *modes*, hence the functions' names; this
documentation says *view*, and both words mean the same thing. A
`mira_mode_*()` component opens the plot in that view; without one, MiRA
opens in the network view (network mode), the stack of layers.
Everything can still be changed in MiRA, including the view.

- [`mira_mode_grid()`](https://ggmira.ecomplab.com/reference/mira_mode_grid.md):
  the layers side by side.

- [`mira_mode_map()`](https://ggmira.ecomplab.com/reference/mira_mode_map.md):
  the layers on a geographic map.

- [`mira_mode_layer()`](https://ggmira.ecomplab.com/reference/mira_mode_layer.md):
  one bubble per layer, linked by shared nodes and interlayer links.

- [`mira_mode_meta()`](https://ggmira.ecomplab.com/reference/mira_mode_meta.md):
  the network aggregated over layers.

- [`mira_mode_dashboard()`](https://ggmira.ecomplab.com/reference/mira_mode_dashboard.md):
  summary charts.

- [`mira_mode_data()`](https://ggmira.ecomplab.com/reference/mira_mode_data.md):
  the data tables.

## Details

**One view per plot.** A plot opens in one view. A later `mira_mode_*()`
of another view replaces the earlier one, with a warning; a later one of
the same view changes only the arguments it gives. To show a network in
two views, make two plots. To open a network in any view with MiRA's
defaults, use
[`plot_mira()`](https://ggmira.ecomplab.com/reference/plot_mira.md) with
`mode`.

**What applies where.** The other components of the plot apply in the
views where MiRA uses them:

|  |  |  |  |  |  |  |
|----|----|----|----|----|----|----|
| Component | network | grid | map | layer | meta | dashboard, data |
| [`mira_layout()`](https://ggmira.ecomplab.com/reference/mira_layout.md) | yes | yes | yes | inside the bubbles |  |  |
| [`mira_node()`](https://ggmira.ecomplab.com/reference/mira_node.md) | yes | yes | yes |  | shapes |  |
| [`mira_intralayer()`](https://ggmira.ecomplab.com/reference/mira_intralayer.md) | yes | yes | yes |  |  |  |
| [`mira_interlayer()`](https://ggmira.ecomplab.com/reference/mira_interlayer.md) | yes |  | yes |  |  |  |
| [`mira_layer()`](https://ggmira.ecomplab.com/reference/mira_layer.md) colors | yes | yes | yes | `color_by` |  |  |
| `mira_node(highlight = )` | yes | yes | yes |  | yes |  |
| [`mira_filter()`](https://ggmira.ecomplab.com/reference/mira_filter.md) | yes | yes | yes | `layers` only |  |  |
| [`mira_camera()`](https://ggmira.ecomplab.com/reference/mira_camera.md) | yes |  |  |  |  |  |
| [`mira_legends()`](https://ggmira.ecomplab.com/reference/mira_legends.md) | yes | yes | yes | `position`, `show = FALSE` | `position`, `show = FALSE` |  |

R warns when
[`mira_filter()`](https://ggmira.ecomplab.com/reference/mira_filter.md)
or
[`mira_camera()`](https://ggmira.ecomplab.com/reference/mira_camera.md)
is combined with a view that does not use it. The meta-network has its
own layer filter, which dims the other layers instead:
`mira_mode_meta(layers = )`. The layer view and the meta-network have
their own legends, which start open; the legend names of
[`mira_legends()`](https://ggmira.ecomplab.com/reference/mira_legends.md)
are those of the network, grid and map views.

## See also

[`plot_mira()`](https://ggmira.ecomplab.com/reference/plot_mira.md) to
open a network in a view with MiRA's defaults.

Other components:
[`mira_camera()`](https://ggmira.ecomplab.com/reference/mira_camera.md),
[`mira_filter()`](https://ggmira.ecomplab.com/reference/mira_filter.md),
[`mira_interlayer()`](https://ggmira.ecomplab.com/reference/mira_interlayer.md),
[`mira_intralayer()`](https://ggmira.ecomplab.com/reference/mira_intralayer.md),
[`mira_layer()`](https://ggmira.ecomplab.com/reference/mira_layer.md),
[`mira_layout()`](https://ggmira.ecomplab.com/reference/mira_layout.md),
[`mira_legends()`](https://ggmira.ecomplab.com/reference/mira_legends.md),
[`mira_mode_dashboard()`](https://ggmira.ecomplab.com/reference/mira_mode_dashboard.md),
[`mira_mode_data()`](https://ggmira.ecomplab.com/reference/mira_mode_data.md),
[`mira_mode_grid()`](https://ggmira.ecomplab.com/reference/mira_mode_grid.md),
[`mira_mode_layer()`](https://ggmira.ecomplab.com/reference/mira_mode_layer.md),
[`mira_mode_map()`](https://ggmira.ecomplab.com/reference/mira_mode_map.md),
[`mira_mode_meta()`](https://ggmira.ecomplab.com/reference/mira_mode_meta.md),
[`mira_node()`](https://ggmira.ecomplab.com/reference/mira_node.md)
