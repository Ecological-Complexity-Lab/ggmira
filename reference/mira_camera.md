# Camera: rotate, tilt, zoom and pan the view

Sets how the stack of layers is looked at in MiRA's network view.
Without it, MiRA uses its default angles and fits the network to the
window. Everything can still be changed in MiRA: drag to rotate and
tilt, use the mouse wheel to zoom, Shift+drag to pan.

## Usage

``` r
mira_camera(rotate, tilt, zoom, pan)
```

## Arguments

- rotate:

  Rotation around the vertical axis, in degrees (MiRA's default is 40).

- tilt:

  Tilt toward the viewer, in degrees, between -45 and 45 (MiRA's default
  is 32).

- zoom:

  Zoom relative to MiRA's fitted view (1), between 0.2 and 5.

- pan:

  Move the view by `c(x, y)`, as fractions of the window, each between
  -1 and 1: `c(0.2, 0)` moves the network right by a fifth of the
  window, `c(0, 0.1)` up by a tenth.

## Value

A component, to add to a plot with `+`.

## Details

**Finding the values.** When a plot is opened from R, MiRA shows the
current camera under its zoom buttons, in these units, and updates it as
you move the view. Set the view with the mouse, click MiRA's **R**
button (Copy as R code, next to Save Session), and paste the code, with
its `mira_camera()` call, into your script.

**Limits.** The same call gives the same view only in a browser window
of the same size:

- `zoom` is relative to MiRA's fit, and `pan` to the window, so a larger
  or smaller window (another screen, another computer, a resized or
  full-screen window) shows the same framing at a different size, not
  identical pixels. Use the same window size when a figure must match
  exactly.

- Layers moved one by one (Cmd/Ctrl+drag on a layer) are not part of the
  camera: `mira_camera()` cannot set them (the R button lists them as a
  comment).

- The view also depends on everything else in the plot (layout and
  `seed`, `mira_layer(stack, spacing)`): copy the camera from the plot
  it is meant for.

## See also

[`mira_layer()`](https://ggmira.ecomplab.com/reference/mira_layer.md)
for how the layers are stacked and spaced.

Other components:
[`mira_filter()`](https://ggmira.ecomplab.com/reference/mira_filter.md),
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

# Turn the stack and look at it from lower down
p + mira_camera(rotate = 70, tilt = 15)
#> Not opened: R is not interactive. Print the plot in an R session, or give `browser` to open it from a script.

# Closer, and moved left and up
p + mira_camera(zoom = 1.5, pan = c(-0.1, 0.05))
#> Not opened: R is not interactive. Print the plot in an R session, or give `browser` to open it from a script.
```
