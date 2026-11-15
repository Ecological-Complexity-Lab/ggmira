# The view in network mode: the camera and the legends. Neither changes what
# is drawn, only how it is looked at; both can still be changed in MiRA
# (drag to rotate, wheel to zoom, Shift+drag to pan; legends expand,
# minimize and move).

TILT_MAX <- 45       # degrees (MiRA clamps mouse tilting at 0.8 rad)
ZOOM_MIN <- 0.2      # relative to MiRA's fitted view
ZOOM_MAX <- 5
PAN_MAX <- 1         # fraction of the window
LEGEND_NAMES <- c("node_color", "node_size", "node_shape", "intralayer_color", "interlayer_color",
                  "layer_color")
LEGEND_ALL <- "all"
LEGEND_POSITIONS <- c("bottom-right", "top-right", "bottom-left")

#' Camera: rotate, tilt, zoom and pan the view
#'
#' Sets how the stack of layers is looked at in MiRA's network view. Without
#' it, MiRA uses its default angles and fits the network to the window.
#' Everything can still be changed in MiRA: drag to rotate and tilt, use the
#' mouse wheel to zoom, Shift+drag to pan.
#'
#' **Finding the values.** When a plot is opened from R, MiRA shows the
#' current camera under its zoom buttons, in these units, and updates it as
#' you move the view. Set the view with the mouse, click MiRA's **R** button
#' (Copy as R code, next to Save Session), and paste the code, with its
#' `mira_camera()` call, into your script.
#'
#' **Limits.** The same call gives the same view only in a browser window of
#' the same size:
#' - `zoom` is relative to MiRA's fit, and `pan` to the window, so a larger
#'   or smaller window (another screen, another computer, a resized or
#'   full-screen window) shows the same framing at a different size, not
#'   identical pixels. Use the same window size when a figure must match
#'   exactly.
#' - Layers moved one by one (Cmd/Ctrl+drag on a layer) are not part of the
#'   camera: `mira_camera()` cannot set them (the R button lists them as
#'   a comment).
#' - The view also depends on everything else in the plot (layout and
#'   `seed`, `mira_layer(stack, spacing)`): copy the camera from the plot it
#'   is meant for.
#'
#' @param rotate Rotation around the vertical axis, in degrees (MiRA's
#'   default is 40).
#' @param tilt Tilt toward the viewer, in degrees, between -45 and 45
#'   (MiRA's default is 32).
#' @param zoom Zoom relative to MiRA's fitted view (1), between 0.2 and 5.
#' @param pan Move the view by `c(x, y)`, as fractions of the window, each
#'   between -1 and 1: `c(0.2, 0)` moves the network right by a fifth of
#'   the window, `c(0, 0.1)` up by a tenth.
#' @return A component, to add to a plot with `+`.
#' @seealso [mira_layer()] for how the layers are stacked and spaced.
#' @family components
#' @export
#' @examplesIf requireNamespace("emln", quietly = TRUE)
#' library(emln)
#' net <- load_emln(17) # 4 layers; bird and plant nodes
#' p <- mira(net, bipartite = TRUE, setA_type = "bird")
#'
#' # Turn the stack and look at it from lower down
#' p + mira_camera(rotate = 70, tilt = 15)
#'
#' # Closer, and moved left and up
#' p + mira_camera(zoom = 1.5, pan = c(-0.1, 0.05))
mira_camera <- function(rotate, tilt, zoom, pan) {
  .build_piece("camera", "mira_camera", environment(), list(
    rotate = .check_degrees,
    tilt   = .degrees_in(-TILT_MAX, TILT_MAX),
    zoom   = .number_in(ZOOM_MIN, ZOOM_MAX),
    pan    = .check_pan
  ))
}

.check_degrees <- function(value, arg, fn) {
  if (!is.numeric(value) || !.is_scalar(value) || !is.finite(value)) .abort_arg(fn, arg, "must be a number of degrees")
  unname(value)
}

.degrees_in <- function(min, max) {
  function(value, arg, fn) {
    ok <- is.numeric(value) && .is_scalar(value) && is.finite(value)
    if (!ok || value < min || value > max) {
      .abort_arg(fn, arg, sprintf("must be a number of degrees between %s and %s", min, max))
    }
    unname(value)
  }
}

.check_pan <- function(value, arg, fn) {
  ok <- is.numeric(value) && length(value) == 2 && all(is.finite(value)) && all(abs(value) <= PAN_MAX)
  if (!ok) .abort_arg(fn, arg, sprintf("must be c(x, y), each between -%s and %s", PAN_MAX, PAN_MAX))
  as.list(unname(value))
}

#' Legends: which are open, and where
#'
#' A plot opens with every legend minimized (a button "Expand ... Legend").
#' `mira_legends()` opens them: all of them, or the ones named in `show`.
#' A legend appears only when its attribute is mapped (e.g. `node_size`
#' needs `mira_node(size_by = )`). In MiRA, legends can still be expanded,
#' minimized and dragged.
#'
#' These are the legends of network mode, which the grid and the map share.
#' The meta-network and the layer view have their own legends, which start
#' open: there, `position` and `show = FALSE` apply, and legend names in
#' `show` do not. A legend describes the whole network, also when
#' [mira_filter()] draws part of it.
#'
#' A later `mira_legends()` changes only the arguments it gives:
#' `mira_legends(position = "top-right")` moves the legends and leaves an
#' earlier `show` as it was. With no earlier `show` it opens all of them,
#' as `mira_legends()` does.
#'
#' @param show `"all"` (default; `TRUE` is the same), the legends to open
#'   (the others stay minimized): `"node_color"`, `"node_size"`,
#'   `"node_shape"`, `"intralayer_color"`, `"interlayer_color"`,
#'   `"layer_color"`; or `FALSE` to hide the legend panel (MiRA's legend
#'   button shows it again). With per-set colors or sizes, `"node_color"`
#'   and `"node_size"` open both sets' legends.
#' @param position Where the legends are: `"bottom-right"` (MiRA's
#'   default), `"top-right"` or `"bottom-left"`.
#' @return A component, to add to a plot with `+`.
#' @family components
#' @export
#' @examplesIf requireNamespace("emln", quietly = TRUE)
#' library(emln)
#' net <- load_emln(17) # 4 layers; bird and plant nodes
#' p <- mira(net, bipartite = TRUE, setA_type = "bird") +
#'   mira_node(color_by = "verification_level", size_by = "intra_degree_sum") +
#'   mira_layer(color_by = "interaction_type")
#'
#' # Open every legend
#' p + mira_legends()
#'
#' # Open two, at the top right
#' p + mira_legends(show = c("node_color", "layer_color"), position = "top-right")
#'
#' # No legends
#' p + mira_legends(show = FALSE)
mira_legends <- function(show = "all", position) {
  piece <- .build_piece("legend", "mira_legends", environment(), list(
    show     = .check_legend_show,
    position = .choice(LEGEND_POSITIONS)
  ))
  # mira_legends() alone opens all; with arguments, only those are sent, so a
  # later component keeps an earlier `show` (with none, .merge_piece opens all)
  if (length(piece$fields) == 0) piece$fields$show <- LEGEND_ALL
  piece$fields <- piece$fields[intersect(c("show", "position"), names(piece$fields))]
  piece
}

.check_legend_show <- function(value, arg, fn) {
  if (identical(value, TRUE)) return(LEGEND_ALL)
  if (identical(value, FALSE) || identical(value, LEGEND_ALL)) return(value)
  if (!is.character(value) || length(value) == 0 || anyNA(value) || !all(value %in% LEGEND_NAMES)) {
    .abort_arg(fn, arg, sprintf('must be "%s", FALSE, or legend names: %s', LEGEND_ALL,
                                paste0('"', LEGEND_NAMES, '"', collapse = ", ")))
  }
  as.list(unique(unname(value)))
}
