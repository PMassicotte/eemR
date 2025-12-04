# The names of an eem or eemlist objects

The names of an eem or eemlist objects

## Usage

``` r
eem_names(eem)
```

## Arguments

- eem:

  An object of class `eemlist`.

## Value

An object of class `eemlist`.

A character vector containing the names of the EEMs.

## Examples

``` r
file <- system.file("extdata/cary/", package = "eemR")
eem <- eem_read(file, recursive = TRUE, import_function = "cary")

eem_names(eem)
#> [1] "nano"    "sample1" "sample2" "sample3" "blank"   "s1"     
```
