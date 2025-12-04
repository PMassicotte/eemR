# Calculate the biological fluorescence index (BIX)

The biological fluorescence index (BIX) is calculated by dividing the
fluorescence at excitation 310 nm and emission at 380 nm (ex = 310, em =
380) by that at excitation 310 nm and emission at 430 nm (ex = 310, em =
430).

## Usage

``` r
eem_biological_index(eem, verbose = TRUE)
```

## Arguments

- eem:

  An object of class `eemlist`.

- verbose:

  Logical determining if additional messages should be printed.

## Value

An object of class `eemlist`.

A data frame containing the biological index (BIX) for each eem.

## Interpolation

Different excitation and emission wavelengths are often used to measure
EEMs. Hence, it is possible to have mismatchs between measured
wavelengths and wavelengths used to calculate specific metrics. In these
circumstances, EEMs are interpolated using the
[`interp2`](https://rdrr.io/pkg/pracma/man/interp2.html) function from
the `parcma` library. A message warning the user will be prompted if
data interpolation is performed.

## References

Huguet, A., Vacher, L., Relexans, S., Saubusse, S., Froidefond, J. M., &
Parlanti, E. (2009). Properties of fluorescent dissolved organic matter
in the Gironde Estuary. Organic Geochemistry, 40(6), 706-719.

[doi:10.1016/j.orggeochem.2009.03.002](https://doi.org/10.1016/j.orggeochem.2009.03.002)

## See also

[interp2](https://rdrr.io/pkg/pracma/man/interp2.html)

## Examples

``` r
file <- system.file("extdata/cary/scans_day_1/", package = "eemR")
eem <- eem_read(file, import_function = "cary")

eem_biological_index(eem)
#>    sample       bix
#> 1    nano 2.6812045
#> 2 sample1 0.7062640
#> 3 sample2 0.8535423
#> 4 sample3 0.4867927
```
