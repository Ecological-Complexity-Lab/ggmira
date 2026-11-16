# mira_save(): argument checks, the /api/save endpoint, and (with Chrome
# and the internet) a real save.

save_net <- function() {
  structure(list(
    nodes = data.frame(node_id = 1:4, node_name = c("p1", "p2", "h1", "h2"),
                       node_type = c("parasite", "parasite", "host", "host")),
    layers = data.frame(layer_id = 1:2, layer_name = c("L1", "L2")),
    extended = data.frame(layer_from = c("L1", "L2"), node_from = c("p1", "p1"),
                          layer_to = c("L1", "L2"), node_to = c("h1", "h2"), weight = c(1, 1)),
    state_nodes = data.frame(layer_id = c(1, 1, 2, 2), node_id = c(1, 3, 1, 4),
                             layer_name = c("L1", "L1", "L2", "L2"),
                             node_name = c("p1", "h1", "p1", "h2"))
  ), class = "multilayer")
}
save_plot <- function() suppressMessages(mira(save_net(), bipartite = TRUE, setA_type = "parasite"))

test_that("the format comes from the extension, or `format` adds one", {
  expect_equal(.save_target("a.png", NULL, "f"), list(file = "a.png", format = "png"))
  expect_equal(.save_target("a.JPEG", NULL, "f"), list(file = "a.JPEG", format = "jpg"))
  expect_equal(.save_target("dir/a.pdf", NULL, "f"), list(file = "dir/a.pdf", format = "pdf"))
  expect_equal(.save_target("a", "PDF", "f"), list(file = "a.pdf", format = "pdf"))
  expect_equal(.save_target("a.jpg", "jpeg", "f"), list(file = "a.jpg", format = "jpg"))
  expect_error(.save_target("a.png", "pdf", "f"), '`format` is "pdf" but `file` ends in ".png"')
  expect_error(.save_target("a.svg", NULL, "f"), 'must end in ".png", ".jpg" or ".pdf"')
  expect_error(.save_target("a", NULL, "f"), "or give `format`")
  expect_error(.save_target("a", "svg", "f"), '`format` must be "png", "jpg" or "pdf"')
  expect_error(.save_target(c("a.png", "b.png"), NULL, "f"), "`file` must be a file name")
})

test_that("arguments are checked before Chrome starts", {
  p <- save_plot()
  expect_error(mira_save(save_net(), "a.png"), "`plot` must be a mira plot")
  expect_error(mira_save(p, "a.png", resolution = 3.5), "`resolution` must be a whole number from 1 to 4")
  expect_error(mira_save(p, "a.png", resolution = 8), "from 1 to 4")
  expect_error(mira_save(p, "a.png", width = 50), "`width` must be a whole number from 100 to 8000")
  expect_error(mira_save(p, "a.png", height = "tall"), "`height` must be")
  expect_error(mira_save(p, "a.png", timeout = 0), "`timeout` must be a number from 1 to Inf")
  expect_error(mira_save(p, "a.png", background = "black"), '`background` must be one of "grid", "white", "transparent"')
  expect_error(mira_save(p, "a.png", legends = NA), "`legends` must be TRUE or FALSE")
})

test_that("views and backgrounds MiRA cannot save are errors", {
  p <- save_plot()
  expect_error(mira_save(p + mira_mode_data(), "a.png"), "the data view is a table")
  expect_error(mira_save(p, "a.jpg", background = "transparent"), '"transparent" needs a PNG file')
  expect_error(mira_save(p, "a.pdf", background = "transparent"), '"transparent" needs a PNG file')
  expect_error(mira_save(p + mira_mode_meta(), "a.png", background = "transparent"),
               "not available in the meta-network view")
  expect_error(mira_save(p + mira_mode_dashboard(), "a.png", background = "transparent"),
               "not available in the dashboard view")
})

test_that("the map view is saved only on its map", {
  expect_error(.check_save_view("map", "png", "white", "mira_save"),
               '`background` "white" is not available in the map view')
  expect_error(.check_save_view("map", "png", "transparent", "mira_save"), "not available in the map view")
  expect_no_error(.check_save_view("map", "png", "grid", "mira_save"))
  expect_no_error(.check_save_view(NULL, "png", "white", "mira_save"))
})

test_that("the export is given the time left, not chromote's ten seconds", {
  expect_equal(.seconds_left(Sys.time() + 120), 120, tolerance = 0.05)
  expect_equal(.seconds_left(Sys.time() - 5), 1)
})

test_that("the save endpoint takes the posted image only when asked for", {
  mira_dir <- file.path(tempfile("ggmira-save-"), "MiRA")
  dir.create(mira_dir, recursive = TRUE)
  writeLines("<html>MiRA</html>", file.path(mira_dir, "index.html"))
  image <- as.raw(c(0x89, 0x50, 0x4e, 0x47))
  post <- list(PATH_INFO = "/api/save", REQUEST_METHOD = "POST",
               rook.input = list(read = function() image))

  received <- NULL
  app <- .mira_app("{}", NULL, normalizePath(mira_dir), on_save = function(body) received <<- body)
  expect_equal(app$call(post)$status, 200L)
  expect_equal(received, image)
  # a GET is not a save
  received <- NULL
  app$call(list(PATH_INFO = "/api/save", REQUEST_METHOD = "GET"))
  expect_null(received)
  # print() serves no save endpoint
  plain <- .mira_app("{}", NULL, normalizePath(mira_dir))
  expect_equal(plain$call(post)$status, 404L)
})

test_that("mira_save() writes the image MiRA draws", {
  skip_on_cran()
  skip_if_not_installed("chromote")
  skip_if(is.null(chromote::find_chrome()), "Chrome not found")
  skip_if_offline() # MiRA loads its libraries from the internet

  dir <- tempfile("ggmira-saved-")
  dir.create(dir)
  p <- save_plot() + mira_node(color_by = "node_type")

  png_file <- mira_save(p, file.path(dir, "plot.png"), width = 400, height = 300)
  bytes <- readBin(png_file, "raw", 24)
  expect_equal(bytes[1:4], as.raw(c(0x89, 0x50, 0x4e, 0x47)))
  # IHDR width and height: resolution 2 times the window
  expect_equal(sum(as.integer(bytes[17:20]) * 256^(3:0)), 800)
  expect_equal(sum(as.integer(bytes[21:24]) * 256^(3:0)), 600)

  pdf_file <- mira_save(p, file.path(dir, "plot"), format = "pdf", width = 400, height = 300)
  expect_equal(basename(pdf_file), "plot.pdf")
  expect_equal(rawToChar(readBin(pdf_file, "raw", 4)), "%PDF")

  # MiRA's warnings about the spec become R warnings
  warned <- suppressWarnings(save_plot() + mira_layer(color_by = "no_such")) # R warns too
  expect_warning(mira_save(warned, file.path(dir, "warned.png"), width = 400, height = 300),
                 "MiRA: layer.color_by")
})
