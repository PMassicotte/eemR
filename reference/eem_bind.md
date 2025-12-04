# Bind eem or eemlist

Function to bind EEMs that have been loaded from different folders or
have been processed differently.

## Usage

``` r
eem_bind(...)
```

## Arguments

- ...:

  One or more object of class `eemlist`.

## Value

An object of `eemlist`.

## Examples

``` r
file <- system.file("extdata/cary/scans_day_1/", "sample1.csv", package = "eemR")
eem <- eem_read(file, import_function = "cary")

eem <- eem_bind(eem, eem)
```
