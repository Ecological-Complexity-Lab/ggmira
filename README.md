# ggmira <img src="man/figures/logo.png" align="right" height="138" alt="ggmira logo" />

<!-- badges: start -->
[![Lifecycle: beta](man/figures/lifecycle-beta.svg)](#lifecycle)
<!-- badges: end -->

## Overview

ggmira is an R interface to [MiRA](https://mira.ecomplab.com/), the
browser-based multilayer network visualizer. Its syntax follows ggplot2:
start from a base plot with `mira()` and add components with `+` to control
the nodes, links, layers and more. Using MiRA as the engine makes the plot
both reproducible, because it is described in code, and interactive, because it opens in MiRA, where you can keep exploring and adjusting it.  It also enables using the seven visualization models of MIRA as well as a suite of other features such as node highlighting.

ggmira works with the multilayer objects of the
[emln](https://emln.ecomplab.com/) package, and includes its own copy of
MiRA, so plots open without an internet connection.


## Installation

ggmira is not on CRAN yet. Install the development version from GitHub:

```r
install.packages("emln")
# install.packages("remotes")
remotes::install_github("Ecological-Complexity-Lab/ggmira")
```

## Usage

```r
library(emln)
library(ggmira)

net <- load_emln(17) # 4 layers; birds and plants

mira(net, bipartite = TRUE, setA_type = "bird") +
  mira_layout("bipartite", seed = 42, nested = TRUE) +
  mira_node(color_by = "verification_level",
            color_values = c(genus = "red", species = "#1f77b4"),
            size_by = "intra_degree_sum", size = 8,
            shape = c(bird = "square", plant = "circle")) +
  mira_intralayer(color_by = "type", min_weight = 0.01) +
  mira_layer(color_by = "layer_name", labels = TRUE) +
  mira_legends(show = c("node_color", "intralayer_color"))
```

<img src="man/figures/README-network.jpg" width="100%" alt="The plot in MiRA: four stacked layers, birds as squares and plants as circles, links colored by interaction type" />

`plot_mira(net)` opens a network with MiRA's defaults. *Get started* builds
a plot step by step; the reference lists every component.

## Lifecycle

ggmira is in beta (version 0.1): it works and is being tested, and its
interface may still change. Beta testers: please start with
[Beta testing](https://github.com/Ecological-Complexity-Lab/ggmira/blob/main/vignettes/articles/beta-testing.Rmd).

## Getting help

Report problems and suggestions at
<https://github.com/Ecological-Complexity-Lab/ggmira/issues>, with the code
you ran and a screenshot of MiRA. Problems in MiRA itself go to
<https://github.com/Ecological-Complexity-Lab/MiRA/issues>.
