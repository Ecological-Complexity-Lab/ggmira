# ggmira 0.9.0

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
