# Screenshots of MiRA for Getting started and the help pages: the whole
# page, as in the browser (headless Chrome via chromote; nothing opens).
#
# Run from the ggmira folder:   Rscript dev/screenshots.R
# Only some images:             Rscript dev/screenshots.R step-1-plot mira_mode_meta
#
# Writes vignettes/articles/figures/*.png and man/figures/*.jpg. Not made
# here: man/figures/README-rstudio.png (a real RStudio window, taken by hand)
# and vignettes/articles/figures/beta-feedback.png (the site's feedback form).
suppressMessages({library(emln); devtools::load_all(".", quiet = TRUE)})
ART <- "vignettes/articles/figures"
MAN <- "man/figures"
only <- commandArgs(TRUE)

pause <- function(seconds) { end <- Sys.time() + seconds; while (Sys.time() < end) later::run_now(0.05) }
js <- function(b, code) .wait_for(b$Runtime$evaluate(code, awaitPromise = TRUE, returnByValue = TRUE, wait_ = FALSE),
                                  Sys.time() + 30, "shot")$result$value

shot <- function(name, p, dir = ART, width = 1100, height = 707, wait = 5, before = NULL, format = "png") {
  if (length(only) && !name %in% only) return(invisible())
  app <- .mira_app(p$network_json, .view_json(p), .resolve_mira_path(NULL))
  server <- .start_server(app, 8795)
  on.exit(httpuv::stopServer(server$handle))
  b <- chromote::ChromoteSession$new(width = width, height = height)
  on.exit(b$close(), add = TRUE)
  .wait_for(b$Page$navigate(sprintf("http://localhost:%d/?autoload=true", server$port), wait_ = FALSE),
            Sys.time() + 30, "shot")
  pause(wait)
  if (!is.null(before)) { js(b, before); pause(1.5) }
  shot <- .wait_for(b$Page$captureScreenshot(format = format, quality = if (format == "jpeg") 90, wait_ = FALSE),
                    Sys.time() + 30, "shot")
  file <- file.path(dir, paste0(name, if (format == "png") ".png" else ".jpg"))
  writeBin(jsonlite::base64_dec(shot$data), file)
  cat("wrote", file, "\n")
}

net <- suppressMessages(load_emln(17))
p1 <- suppressMessages(mira(net, bipartite = TRUE, setA_type = "bird"))
p2 <- p1 + mira_layout("kamada_kawai", seed = 42)
p3 <- p2 + mira_node(color_by = "verification_level", color_values = c(genus = "red", species = "#1f77b4"),
                     size_by = "intra_degree_sum", size = 8)
p4 <- p3 + mira_intralayer(color_by = "type", min_weight = 0.01) +
  mira_interlayer(color = "grey40", curvature = 0.8, min_weight = 0.5,
                  pairs = list(c("layer_1", "layer_2"), c("layer_3", "layer_4")))
p5 <- p4 + mira_layer(color_by = "layer_name", color_values = c(layer_1 = "orange", layer_3 = "#9467bd"),
                      labels = TRUE, label_size = 18, stack = "vertical", spacing = 250)
p <- p5
shot("step-1-plot", p1)
shot("step-2-layout", p2)
shot("step-3-nodes", p3)
shot("step-4-links", p4)
shot("step-5-layers", p5)
shot("step-6-filter", p + mira_filter(nodes = type == "plant" | node_name %in% c("Geospiza_fuliginosa", "Geospiza_fortis")))
shot("step-6-filter-layers", p + mira_filter(layers = latitude > -0.6))
shot("step-7-view", p + mira_legends(show = c("node_color", "layer_color"), position = "top-right") +
       mira_camera(rotate = 60, tilt = 25) + mira_node(highlight = "Geospiza_fortis"))
shot("step-8-grid", p + mira_mode_grid(columns = 2))
shot("step-8-meta", p + mira_mode_meta(aggregation = "weights", color_by = "participation"), wait = 7)
shot("step-8-meta-layers", p + mira_mode_meta(layers = latitude > -0.6), wait = 7)
if (!length(only) || "step-9-save" %in% only) {
  mira_save(p, file.path(ART, "step-9-save.png"), width = 1200, height = 750, resolution = 1)
  cat("wrote step-9-save\n")
}
p10 <- p1 + mira_layout("kamada_kawai", seed = 42) +
  mira_node(color_by = "intra_degree_sum", size = 8, color_palette = "magma", color_reverse = TRUE) +
  mira_intralayer(color_by = "type", color_palette = "Okabe-Ito") +
  mira_layer(labels = TRUE) + mira_camera(rotate = 50, tilt = 20) +
  mira_legends(show = c("node_color", "intralayer_color"))
shot("step-10-button", p10, width = 1200, height = 750,
     before = "{const b = document.getElementById('copyRCodeBtn'); b.style.outline = '3px solid #e11d48'; b.style.outlineOffset = '3px'; b.style.borderRadius = '6px';}")
shot("step-10-copy", p10, width = 1200, height = 750, before = "document.getElementById('copyRCodeBtn').click()")

pS <- mira(net, bipartite = TRUE, setA_type = "bird", directed = TRUE) +
  mira_layout("kamada_kawai", seed = 3) +
  mira_node(color_by = c(bird = "intra_in_strength", plant = "verification_level"),
            color_values = list(plant = c(species = "#1f77b4", genus = "#ff7f0e")),
            size_by = c(bird = "intra_in_degree", plant = NA), perspective = FALSE) +
  mira_intralayer(color_by = "type", color_values = c(pollination = "#d62728"), arrow_size = 0.5) +
  mira_interlayer(show = TRUE, color_by = "type", color_values = c(interlayer = "black"), curvature = 0.2) +
  mira_layer(color_by = "interaction_type", color_scale = "categorical",
             color_values = c("seed-dispersal" = "#17becf"), labels = TRUE, stack = "horizontal", spacing = 450)
shot("scales", pS)
shot("scale-continuous", p1 + mira_node(color_by = "intra_degree_sum", color_scale = "continuous"))
shot("scale-categorical", p1 + mira_node(color_by = "intra_degree_sum", color_scale = "categorical"))
shot("scale-palettes", p1 + mira_layout("bipartite", seed = 42) +
       mira_node(color_by = "intra_degree_sum", color_palette = "magma", color_reverse = TRUE, color_limits = c(0, 30)) +
       mira_intralayer(color_by = "type", color_palette = "Okabe-Ito") +
       mira_legends(show = c("node_color", "intralayer_color")))
shot("constant", p1 + mira_node(color = "steelblue", shape = "circle") + mira_intralayer(color = "grey60") +
       mira_interlayer(show = TRUE, color = "red") + mira_layer(color = "#e5e7eb"))

# The README's plot, and the help pages of the views
pR <- p1 + mira_layout("bipartite", seed = 42, nested = TRUE) +
  mira_node(color_by = "verification_level", color_values = c(genus = "red", species = "#1f77b4"),
            size_by = "intra_degree_sum", size = 8, shape = c(bird = "square", plant = "circle")) +
  mira_intralayer(color_by = "type", min_weight = 0.01) +
  mira_layer(color_by = "layer_name", labels = TRUE) +
  mira_legends(show = c("node_color", "intralayer_color"))
shot("README-network", pR, dir = MAN, width = 1100, height = 668, format = "jpeg")
for (v in list(list("mira_mode_grid", mira_mode_grid()), list("mira_mode_map", mira_mode_map()),
               list("mira_mode_layer", mira_mode_layer()), list("mira_mode_dashboard", mira_mode_dashboard()),
               list("mira_mode_data", mira_mode_data()), list("mira_mode_meta", mira_mode_meta()))) {
  shot(v[[1]], pR + v[[2]], dir = MAN, width = 1100, height = 668, format = "jpeg", wait = 7)
}
