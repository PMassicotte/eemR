# Set the sample names of an eem or eemlist objects

Set the sample names of an eem or eemlist objects

## Usage

``` r
eem_names(x) <- value
```

## Arguments

- x:

  An object of class `eem` or `eemlist`.

- value:

  A character vector with new sample names. Must be equal in length to
  the number of samples in the `eem` or `eemlist`.

## Value

An `eem` or `eemlist`.

## Examples

``` r
folder <- system.file("extdata/cary/scans_day_1", package = "eemR")
eems <- eem_read(folder, import_function = "cary")

eem_names(eems)
#> [1] "nano"    "sample1" "sample2" "sample3"
eem_names(eems) <- c("a", "b", "c", "d")
eem_names(eems)
#> [1] "a" "b" "c" "d"
```
