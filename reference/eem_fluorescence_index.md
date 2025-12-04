# Calculate the fluorescence index (FI)

Calculate the fluorescence index (FI)

## Usage

``` r
eem_fluorescence_index(eem, verbose = TRUE)
```

## Arguments

- eem:

  An object of class `eemlist`.

- verbose:

  Logical determining if additional messages should be printed.

## Value

An object of class `eemlist`.

A data frame containing fluorescence index (FI) for each eem.

## Interpolation

Different excitation and emission wavelengths are often used to measure
EEMs. Hence, it is possible to have mismatchs between measured
wavelengths and wavelengths used to calculate specific metrics. In these
circumstances, EEMs are interpolated using the
[`interp2`](https://rdrr.io/pkg/pracma/man/interp2.html) function from
the `parcma` library. A message warning the user will be prompted if
data interpolation is performed.

## References

[doi:10.4319/lo.2001.46.1.0038](https://doi.org/10.4319/lo.2001.46.1.0038)

## See also

[interp2](https://rdrr.io/pkg/pracma/man/interp2.html)

## Examples

``` r
file <- system.file("extdata/cary/scans_day_1/", "sample1.csv", package = "eemR")
eem <- eem_read(file, import_function = "cary")

eem_fluorescence_index(eem)
#>    sample       fi
#> 1 sample1 1.264782
```
