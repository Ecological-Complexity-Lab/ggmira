# ggmira (development version)

* MiRA now ignores self-loops (a node linked to itself within a layer): they
  are not drawn and not counted in degree, strength, density or layer
  similarity. Before, density counted them, so a layer's density could be
  above 1. `mira()`, `plot_mira()` and `plot_multilayer()` warn how many
  self-loops a network has.
* In MiRA's manual, the links to the tutorials and the data format page
  open the MiRA website; before, they led to pages that ggmira does not
  include.
* `inst/MiRA` is now only changed by syncing from MiRA, and a check fails
  if it was edited by hand (see `.github/CONTRIBUTING.md`).

# ggmira 1.0.0 (2026-11-19)

* Fixed browser access on Windows (#36).
* Fixed buttons in the browser (#35).
* Smaller package: only the images used by MiRA's app are bundled (#34).
* Bundled MiRA 1.2; in RStudio's Viewer pane the top bar now shows only the
  lab logo, leaving room for the plot (#33); removed the small-window warning.

# ggmira 0.9.0 (2026-11-15)

The first release. ggmira draws multilayer networks in
[MiRA](https://mira.ecomplab.com/), the browser-based multilayer network
visualizer, with a ggplot2-like syntax: start from a network with `mira()`
and add components with `+`.

* **Elements:** `mira_node()`, `mira_intralayer()`, `mira_interlayer()` and
  `mira_layer()` map colors and sizes to the data's attributes, or set
  constants, shapes and names. Bipartite networks take settings per node
  set.
* **Scales:** `color_scale`, `color_values`, `color_palette`,
  `color_reverse` and `color_limits` in each element (`?mira_scales`).
* **Layout, camera and legends:** `mira_layout()`, `mira_camera()`,
  `mira_legends()`.
* **Filters:** `mira_filter()` draws only some nodes, links or layers.
* **Views:** the plot can open in any of MiRA's views: `mira_mode_grid()`,
  `mira_mode_map()`, `mira_mode_layer()`, `mira_mode_meta()`,
  `mira_mode_dashboard()`, `mira_mode_data()`.
* **Files:** `mira_save()` saves a plot as a PNG, JPG or PDF file, without
  opening a window.
* **Back to R:** MiRA's R button gives the ggmira code for the view on
  screen, changes made in MiRA included.
* **Help:** `mira_options()` lists what each component can be set to for a
  network; `mira_spec()` shows what a plot sends to MiRA.
* **Opening:** in the browser or in RStudio's Viewer pane
  (`print(p, viewer = TRUE)`); `plot_mira()` opens a network with MiRA's
  defaults.
* **Feedback:** `mira_feedback()` and the documentation's Feedback buttons
  open a filled-in GitHub issue.
* **MiRA:** bundles [MiRA 1.2](https://github.com/Ecological-Complexity-Lab/MiRA/releases/tag/v1.2),
  with one later change: in RStudio's Viewer pane, MiRA's top bar keeps only
  the lab logo, leaving room for the plot.
