# ggmira examples: every argument of every piece, on one network.
#
# emln network 17: 4 layers (pollination and seed dispersal on two islands),
# two node sets (bird, plant), interlayer links between layers 1-2 and 3-4.
# Run the examples one at a time; each opens in the browser.
# When done: httpuv::stopAllServers()

remotes::install_github("Ecological-Complexity-Lab/ggmira")
library(emln)
library(ggmira)

net <- load_emln(17)

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

# ---- 2. Color scales ---------------------------------------------------------

# directed = TRUE: in/out degrees and arrowheads
p2 <- mira(net, bipartite = TRUE, setA_type = "bird", directed = TRUE) +
  mira_layout("kamada_kawai", seed = 3) +
  mira_node(
    color_by = c(bird = "verification_level", plant = "intra_in_degree"),
    # birds: categorical, two levels with manual colors
    # plants: no manual colors; in-degree is numeric, so a gradient
    color_values = list(bird = c(species = "#1f77b4", genus = "#ff7f0e")),
    # birds sized by out-degree; plants keep the default size
    size_by = c(bird = "intra_out_degree", plant = NA),
    # flat nodes
    perspective = FALSE
  ) +
  # links colored by "type" both here and in mira_interlayer(): one shared
  # scale; the two pieces name different values, so their colors merge
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

# ---- What a plot sends to MiRA ---------------------------------------------------

mira_spec(p2) # as an R list
cat(mira_spec(p2, json = TRUE)) # as JSON
mira_node(color_by = "module", color_values = c("1" = "red")) # a piece prints as its call
