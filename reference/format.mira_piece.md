# Show a component as the call that would make it

Colors are shown as the `"#rrggbb"` sent to MiRA, `NULL` mappings
(MiRA's default) as `NA`, and one color per layer as
`color_by = "layer_name"`.

## Usage

``` r
# S3 method for class 'mira_piece'
format(x, ...)

# S3 method for class 'mira_piece'
print(x, ...)
```

## Arguments

- x:

  A component (class `mira_piece`).

- ...:

  Not used.

## Value

[`format()`](https://rdrr.io/r/base/format.html): one string.
[`print()`](https://rdrr.io/r/base/print.html): `x`, invisibly.

## Examples

``` r
mira_node(color_by = c(pollinator = "module", plant = NA), size = 8)
#> mira_node(color_by = c(pollinator = "module", plant = NA), size = 8)
```
