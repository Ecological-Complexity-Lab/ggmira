# Piece-level checks: no network needed.

test_that("a piece records only the arguments that were given", {
  piece <- mira_node(size = 10)
  expect_s3_class(piece, "mira_piece")
  expect_equal(piece$section, "node")
  expect_equal(piece$fields, list(size = 10))
  expect_equal(mira_layer()$fields, setNames(list(), character()))
})

test_that("each piece writes its own section", {
  expect_equal(mira_layout("circle")$section, "layout")
  expect_equal(mira_intralayer(min_weight = 0)$section, "intralayer")
  expect_equal(mira_interlayer(show = FALSE)$section, "interlayer")
  expect_equal(mira_layer(color = "red")$section, "layer")
})

test_that("colors become #rrggbb", {
  expect_equal(mira_node(color = "red")$fields$color, "#ff0000")
  expect_equal(mira_layer(color = "#A78BFA")$fields$color, "#a78bfa")
  expect_equal(mira_intralayer(color = "grey60")$fields$color, "#999999")
})

test_that("invalid colors are errors; transparency is a warning", {
  expect_error(mira_node(color = "notacolor"), 'mira_node\\(\\): `color` "notacolor" is not a color')
  expect_error(mira_node(color = 2), "must be one color")
  expect_error(mira_node(color = c("red", "blue")), "must be one color")
  expect_error(mira_node(color = NA), "must be one color")
  expect_warning(mira_layer(color = "#ff000080"), "transparency is ignored")
})

test_that("NULL and NA mappings mean MiRA's default (JSON null)", {
  for (value in list(NULL, NA, NA_character_)) {
    fields <- mira_node(color_by = value)$fields
    expect_true("color_by" %in% names(fields))
    expect_null(fields$color_by)
  }
})

test_that("a mapping is one column name", {
  expect_equal(mira_node(size_by = "mass")$fields$size_by, "mass")
  expect_error(mira_node(color_by = 1), "must be one column name")
  expect_error(mira_node(color_by = ""), "must be one column name")
  expect_error(mira_intralayer(color_by = c("a", "b")), "must be one column name")
})

test_that("per-set values become a named list, NA -> NULL", {
  fields <- mira_node(color_by = c(parasite = "module", host = NA),
                      shape = c(parasite = "square", host = "circle"))$fields
  expect_equal(fields$color_by, list(parasite = "module", host = NULL))
  expect_equal(fields$shape, list(parasite = "square", host = "circle"))
  expect_equal(mira_node(size_by = list(host = "mass"))$fields$size_by, list(host = "mass"))
})

test_that("per-set names must be unique and non-empty", {
  expect_error(mira_node(color_by = c(a = "x", a = "y")), "names must be unique")
  expect_error(mira_node(color_by = setNames(c("x", "y"), c("a", ""))), "names must be unique")
  expect_error(mira_node(shape = c(a = "circle", b = NA)), '`shape\\["b"\\]` must be one of')
})

test_that("per-set values are only for node color_by, size_by and shape", {
  expect_error(mira_intralayer(color_by = c(a = "x")), "must be one column name")
  expect_error(mira_layer(color_by = c(a = "x")), "must be one column name")
})

test_that("keywords are only allowed where they mean something", {
  expect_equal(mira_node(color_by = ".set")$fields$color_by, ".set")
  expect_equal(mira_layer(color_by = ".individual")$fields$color_by, ".individual")
  expect_error(mira_node(size_by = ".set"), '".set" is not available here')
  expect_error(mira_node(color_by = c(a = ".set")), '".set" is not available here')
  expect_error(mira_node(color_by = ".individual"), '".individual" is not available here')
  expect_error(mira_layer(color_by = ".set"), '".set" is not available here')
  expect_error(mira_intralayer(color_by = ".individual"), "not available here")
})

test_that("color_by and color together are an error", {
  expect_error(mira_node(color_by = "module", color = "red"),
               "mira_node\\(\\): give `color_by` or `color`, not both")
  expect_error(mira_interlayer(color_by = NA, color = "red"), "not both")
})

test_that("numbers are checked against MiRA's ranges", {
  expect_equal(mira_node(size = 3)$fields$size, 3)
  expect_error(mira_node(size = 2), "`size` must be a number between 3 and 25")
  expect_error(mira_node(size = 26), "between 3 and 25")
  expect_error(mira_node(size = "10"), "between 3 and 25")
  expect_equal(mira_intralayer(min_weight = 1)$fields$min_weight, 1)
  expect_error(mira_intralayer(min_weight = 1.5), "between 0 and 1")
  expect_error(mira_interlayer(min_weight = -0.1), "between 0 and 1")
})

test_that("layout fields are checked", {
  expect_equal(mira_layout("kamada_kawai", seed = 42, nested = TRUE)$fields,
               list(type = "kamada_kawai", seed = 42, nested = TRUE))
  expect_error(mira_layout("spring"), '`type` must be one of "fruchterman"')
  expect_error(mira_layout(seed = 1.5), "`seed` must be a whole number")
  expect_error(mira_layout(seed = NA), "whole number")
  expect_error(mira_layout(nested = "yes"), "`nested` must be TRUE or FALSE")
})

test_that("shape and show are checked", {
  expect_error(mira_node(shape = "triangle"), '`shape` must be one of "circle", "square"')
  expect_error(mira_interlayer(show = NA), "`show` must be TRUE or FALSE")
  expect_equal(mira_interlayer(show = FALSE)$fields$show, FALSE)
})
