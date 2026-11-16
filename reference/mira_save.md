# Save a mira plot as an image file

Draws the plot in MiRA, in a browser that does not open a window, and
saves it with MiRA's own export: the same picture as MiRA's camera
button, with the legends and the "Visualized with MiRA" mark. Works in
scripts and R Markdown, where printing a plot does nothing.

## Usage

``` r
mira_save(
  plot,
  file,
  format = NULL,
  resolution = 2,
  width = 1500,
  height = 900,
  background = "grid",
  legends = TRUE,
  timeout = 60,
  mira_path = NULL
)
```

## Arguments

- plot:

  A `mira_plot`.

- file:

  The file name, such as `"fig1.png"`. Without an extension, `format` is
  added. Its folder must exist, and a file of that name is replaced
  without asking.

- format:

  `"png"`, `"jpg"` (or `"jpeg"`) or `"pdf"`. Without it, the extension
  of `file` decides.

- resolution:

  A whole number from 1 to 4: 1 (screen), 2 (high, the default), 4
  (print). The image is `resolution` times `width` by `height` pixels. A
  PDF page is `width` by `height`, with the picture at this resolution.

- width, height:

  The size of MiRA's window, in pixels: whole numbers from 100 to 8000.
  The plot is fitted to it as in the browser. MiRA is made for windows
  of at least 1024 x 600: smaller ones can cut off legends and panels,
  and in a very small one MiRA may not draw at all (the save then times
  out).

- background:

  `"grid"` (MiRA's grid; the map in map view), `"white"`, or
  `"transparent"` (PNG only). The map view is saved only with `"grid"`;
  the meta-network and the dashboard not with `"transparent"`.

- legends:

  `TRUE` to include the legends (as
  [`mira_legends()`](https://ggmira.ecomplab.com/reference/mira_legends.md)
  sets them) and any open panels of the layer view.

- timeout:

  Seconds to wait for MiRA to draw and save the plot. Large pictures at
  `resolution = 4` can need more than the default.

- mira_path:

  Character. Path to the MiRA web-app directory. If NULL (default), uses
  the copy bundled with the package
  (`system.file("MiRA", package = "ggmira")`).

## Value

The path of the file, invisibly.

## Details

Needs the chromote package and Google Chrome (or Chromium, or Microsoft
Edge; chromote finds it, or set the `CHROMOTE_CHROME` environment
variable to its path). MiRA loads its libraries and map tiles from the
internet, as when a plot opens in the browser.

**What is saved.** Every view except the data view, which is a table (an
error). The dashboard is saved as its whole page, whatever `height` is.
A map is saved as the map with the layers' markers; the networks MiRA
draws over it after a click are not part of the plot. When MiRA could
not use a setting of the plot, R gives MiRA's reason as a warning and
the file is still saved.

**Sizes.** The file holds `resolution` times `width` by `height` pixels,
and the browser has to hold that picture in memory: a very large one
(about 5000 x 4000 at `resolution = 4`) can fail with a browser error.
Reduce `resolution` or the size then. Saving takes a few seconds, and
longer for large pictures (`timeout`).

**The look.** Links are drawn opaque and at least one pixel of the file
wide, so a dense network looks heavier at `resolution = 1` than at 4,
and heavier than on screen. The camera of
[`mira_camera()`](https://ggmira.ecomplab.com/reference/mira_camera.md)
is relative to the window: values copied from MiRA frame the plot the
same way only when `width` and `height` match the browser window they
were set in.

## See also

[`print.mira_plot()`](https://ggmira.ecomplab.com/reference/print.mira_plot.md)
to open the plot in the browser.

## Examples

``` r
if (FALSE) { # \dontrun{
# Needs the chromote package and Chrome; writes files in the working directory
library(emln)
net <- load_emln(17)
p <- mira(net, bipartite = TRUE, setA_type = "bird") +
  mira_node(color_by = "intra_degree_sum")

mira_save(p, "birds.png")
mira_save(p, "birds", format = "pdf", resolution = 4)
mira_save(p, "birds-clear.png", background = "transparent", legends = FALSE)
} # }
```
