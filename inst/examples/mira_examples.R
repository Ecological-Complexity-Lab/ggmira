# ggmira examples: every argument of every component, on one network.
#
# emln network 17: 4 layers (pollination and seed dispersal on two islands),
# two node sets (bird, plant), interlayer links between layers 1-2 and 3-4.
# Run the examples one at a time; each opens in the browser.
# When done: httpuv::stopAllServers()

# Install:   remotes::install_github("Ecological-Complexity-Lab/ggmira")
# Help:      ?ggmira (the functions by group), ?mira_node, ?mira_scales, ...
# Site:      from a checkout of the repository (it is not published yet)
#            pkgdown::build_site("~/GitHub/ecomplab/ggmira", examples = FALSE)
#            pkgdown::preview_site("~/GitHub/ecomplab/ggmira")



library(emln)
library(ggmira)

net <- load_emln(17)

# What each component can be set to for this network: columns, computed
# attributes, scale types and values
mira_options(net, bipartite = TRUE, setA_type = "bird")

# ---- 1. Display: layout, labels, layers, interlayer pairs -------------------

p1 <- mira(net, bipartite = TRUE, setA_type = "bird") +
  # reproducible bipartite layout, nodes sorted by degree
  mira_layout("bipartite", seed = 42, nested = TRUE) +
  mira_node(
    color_by = "verification_level",
    # two levels with manual colors; "family" keeps the palette color
    color_values = c(genus = "red", species = "#1f77b4"),
    # node size by degree (computed by MiRA), base size 8
    size_by = "intra_degree_sum", size = 8,
    # birds as squares, plants as circles
    shape = c(bird = "square", plant = "circle"),
    # node names; nodes drawn in the layers' 3D perspective
    labels = TRUE, label_size = 10, perspective = TRUE
  ) +
  mira_intralayer(
    color_by = "type",
    color_values = c(pollination = "#d62728", "seed-dispersal" = "#2ca02c"),
    # hide links with weight below 0.01
    min_weight = 0.01
  ) +
  # pairs: only links between layers 1-2 and 3-4 (and turns interlayer links on)
  mira_interlayer(
    color = "grey40", min_weight = 0.5, curvature = 0.8,
    pairs = list(c("layer_1", "layer_2"), c("layer_3", "layer_4"))
  ) +
  # one color per layer: two set by hand, the others keep MiRA's colors
  mira_layer(
    color_by = "layer_name",
    color_values = c(layer_1 = "orange", layer_3 = "#9467bd"),
    # layer names, node set names, layers stacked top to bottom
    labels = TRUE, label_size = 18, set_labels = TRUE,
    stack = "vertical", spacing = 250
  )
print(p1)

# ---- 1b. Filter: all plants and two finches; strong links only ------------

p1b <- p1 +
  mira_filter(
    nodes = type == "plant" | node_name %in% c("Geospiza_fuliginosa", "Geospiza_fortis"),
    links = weight > 0.05
  )
print(p1b)

# ---- 1c. Camera, legends, highlight -------------------------------------------
# Camera values: set the view with the mouse in MiRA, then "Copy for R" (under
# the zoom buttons). Zoom and pan are relative to the window: the view matches
# exactly only in a window of the same size. Layers dragged one by one are not
# included.

p1c <- p1 +
  mira_camera(rotate = 60, tilt = 25, zoom = 1.2, pan = c(0, 0.05)) +
  mira_legends(show = c("node_color", "layer_color"), position = "top-right") +
  mira_node(highlight = "Geospiza_fortis")
print(p1c)

# ---- 1d. Views (MiRA's modes) --------------------------------------------------
# One view per plot: a second mira_mode_*() of another view replaces the first,
# with a warning. mira_camera() works in network mode only, mira_filter() in
# network, grid and map modes only (R warns otherwise).

print(p1b + mira_mode_grid())     # the filter of 1b, in the grid

print(p1 + mira_mode_grid(columns = 2))

p1d <- p1 +
  mira_node(highlight = "Geospiza_fortis") +
  mira_mode_meta(aggregation = "weights", layout = "bipartite", color_by = "uniform",
                 size_by = "participation", size = 1.5, min_weight = 0.1, nested = FALSE,
                 labels = TRUE, label_size = 14)
print(p1d)

# One color per node set (color replaces color_by)
print(p1 + mira_mode_meta(color = c(bird = "orange", plant = "darkgreen")))

# Node shapes follow mira_node(shape = ) (p1: birds squares, plants circles),
# with a shape legend
print(p1 + mira_mode_meta(layout = "circular"))

# Dim the nodes and links of layers: select the others, by name or by a
# condition on net$layers
print(p1 + mira_mode_meta(layers = c("layer_3", "layer_4")))
print(p1 + mira_mode_meta(layers = !layer_name %in% c("layer_1", "layer_2")))
print(p1 + mira_mode_meta(layers = latitude > -0.6))

print(p1 + mira_mode_map())       # the layers have latitude and longitude
print(p1 + mira_mode_layer())
print(p1 + mira_mode_dashboard())
print(p1 + mira_mode_data())

# Any view with MiRA's defaults and no components
plot_mira(net, bipartite = TRUE, setA_type = "bird", mode = "meta")

# ---- 2. Color scales ---------------------------------------------------------

# directed = TRUE: in/out degrees and arrowheads
p2 <- mira(net, bipartite = TRUE, setA_type = "bird", directed = TRUE) +
  mira_layout("kamada_kawai", seed = 3) +
  mira_node(
    # links run plant -> bird, so birds have in-degrees, plants out-degrees
    color_by = c(bird = "intra_in_strength", plant = "verification_level"),
    # birds: no manual colors; in-strength is numeric, so a gradient
    # plants: categorical, two levels with manual colors
    color_values = list(plant = c(species = "#1f77b4", genus = "#ff7f0e")),
    # birds sized by in-degree; plants keep the default size
    size_by = c(bird = "intra_in_degree", plant = NA),
    # flat nodes
    perspective = FALSE
  ) +
  # links colored by "type" both here and in mira_interlayer(): one shared
  # scale; the two components name different values, so their colors merge
  mira_intralayer(
    color_by = "type", color_values = c(pollination = "#d62728"),
    arrow_size = 0.5
  ) +
  mira_interlayer(
    show = TRUE, color_by = "type", color_values = c(interlayer = "black"),
    curvature = 0.2
  ) +
  # layers by interaction type; one value with a manual color
  mira_layer(
    color_by = "interaction_type", color_scale = "categorical",
    color_values = c("seed-dispersal" = "#17becf"),
    labels = TRUE, stack = "horizontal", spacing = 450
  )
print(p2)

# ---- 3. Scale type: the same numeric attribute two ways ------------------------

# MiRA's default for a numeric attribute with many values: a gradient
p3a <- mira(net, bipartite = TRUE, setA_type = "bird") +
  mira_node(color_by = "intra_degree_sum", color_scale = "continuous")
print(p3a)

# categorical: one color per degree value
p3b <- mira(net, bipartite = TRUE, setA_type = "bird") +
  mira_node(color_by = "intra_degree_sum", color_scale = "categorical")
print(p3b)

# ---- 4. Constant colors --------------------------------------------------------

p4 <- mira(net, bipartite = TRUE, setA_type = "bird") +
  mira_node(color = "steelblue", shape = "circle") +
  mira_intralayer(color = "grey60") +
  mira_interlayer(show = TRUE, color = "red") +
  mira_layer(color = "#e5e7eb")
print(p4)
