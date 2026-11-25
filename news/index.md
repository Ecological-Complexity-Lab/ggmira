# Changelog

## ggmira (development version)

- MiRA now ignores self-loops (a node linked to itself within a layer):
  they are not drawn and not counted in degree, strength, density or
  layer similarity. Before, density counted them, so a layer’s density
  could be above 1.
  [`mira()`](https://ggmira.ecomplab.com/reference/mira.md),
  [`plot_mira()`](https://ggmira.ecomplab.com/reference/plot_mira.md)
  and
  [`plot_multilayer()`](https://ggmira.ecomplab.com/reference/plot_mira.md)
  warn how many self-loops a network has.
- In MiRA’s manual, the links to the tutorials and the data format page
  open the MiRA website; before, they led to pages that ggmira does not
  include.
- `inst/MiRA` is now only changed by syncing from MiRA, and a check
  fails if it was edited by hand (see `.github/CONTRIBUTING.md`).

## ggmira 1.0.0 (2026-11-19)

- Fixed browser access on Windows
  ([\#36](https://github.com/Ecological-Complexity-Lab/ggmira/issues/36)).
- Fixed buttons in the browser
  ([\#35](https://github.com/Ecological-Complexity-Lab/ggmira/issues/35)).
- Smaller package: only the images used by MiRA’s app are bundled
  ([\#34](https://github.com/Ecological-Complexity-Lab/ggmira/issues/34)).
- Bundled MiRA 1.2; in RStudio’s Viewer pane the top bar now shows only
  the lab logo, leaving room for the plot
  ([\#33](https://github.com/Ecological-Complexity-Lab/ggmira/issues/33));
  removed the small-window warning.

## ggmira 0.9.0 (2026-11-15)

The first release. ggmira draws multilayer networks in
[MiRA](https://mira.ecomplab.com/), the browser-based multilayer network
visualizer, with a ggplot2-like syntax: start from a network with
[`mira()`](https://ggmira.ecomplab.com/reference/mira.md) and add
components with `+`.

- **Elements:**
  [`mira_node()`](https://ggmira.ecomplab.com/reference/mira_node.md),
  [`mira_intralayer()`](https://ggmira.ecomplab.com/reference/mira_intralayer.md),
  [`mira_interlayer()`](https://ggmira.ecomplab.com/reference/mira_interlayer.md)
  and
  [`mira_layer()`](https://ggmira.ecomplab.com/reference/mira_layer.md)
  map colors and sizes to the data’s attributes, or set constants,
  shapes and names. Bipartite networks take settings per node set.
- **Scales:** `color_scale`, `color_values`, `color_palette`,
  `color_reverse` and `color_limits` in each element
  ([`?mira_scales`](https://ggmira.ecomplab.com/reference/mira_scales.md)).
- **Layout, camera and legends:**
  [`mira_layout()`](https://ggmira.ecomplab.com/reference/mira_layout.md),
  [`mira_camera()`](https://ggmira.ecomplab.com/reference/mira_camera.md),
  [`mira_legends()`](https://ggmira.ecomplab.com/reference/mira_legends.md).
- **Filters:**
  [`mira_filter()`](https://ggmira.ecomplab.com/reference/mira_filter.md)
  draws only some nodes, links or layers.
- **Views:** the plot can open in any of MiRA’s views:
  [`mira_mode_grid()`](https://ggmira.ecomplab.com/reference/mira_mode_grid.md),
  [`mira_mode_map()`](https://ggmira.ecomplab.com/reference/mira_mode_map.md),
  [`mira_mode_layer()`](https://ggmira.ecomplab.com/reference/mira_mode_layer.md),
  [`mira_mode_meta()`](https://ggmira.ecomplab.com/reference/mira_mode_meta.md),
  [`mira_mode_dashboard()`](https://ggmira.ecomplab.com/reference/mira_mode_dashboard.md),
  [`mira_mode_data()`](https://ggmira.ecomplab.com/reference/mira_mode_data.md).
- **Files:**
  [`mira_save()`](https://ggmira.ecomplab.com/reference/mira_save.md)
  saves a plot as a PNG, JPG or PDF file, without opening a window.
- **Back to R:** MiRA’s R button gives the ggmira code for the view on
  screen, changes made in MiRA included.
- **Help:**
  [`mira_options()`](https://ggmira.ecomplab.com/reference/mira_options.md)
  lists what each component can be set to for a network;
  [`mira_spec()`](https://ggmira.ecomplab.com/reference/mira_spec.md)
  shows what a plot sends to MiRA.
- **Opening:** in the browser or in RStudio’s Viewer pane
  (`print(p, viewer = TRUE)`);
  [`plot_mira()`](https://ggmira.ecomplab.com/reference/plot_mira.md)
  opens a network with MiRA’s defaults.
- **Feedback:**
  [`mira_feedback()`](https://ggmira.ecomplab.com/reference/mira_feedback.md)
  and the documentation’s Feedback buttons open a filled-in GitHub
  issue.
- **MiRA:** bundles [MiRA
  1.2](https://github.com/Ecological-Complexity-Lab/MiRA/releases/tag/v1.2),
  with one later change: in RStudio’s Viewer pane, MiRA’s top bar keeps
  only the lab logo, leaving room for the plot.
