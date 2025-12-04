# Calculate the fluorescence humification index (HIX)

The fluorescence humification index (HIX), which compares two broad
aromatic dominated fluorescence maxima, is calculated at 254 nm
excitation by dividing the sum of fluorescence intensities between
emission 435 to 480 nm by the the sum of fluorescence intensities
between 300 to 345 nm.

## Usage

``` r
eem_humification_index(eem, scale = FALSE, verbose = TRUE)
```

## Arguments

- eem:

  An object of class `eemlist`.

- scale:

  Logical indicating if HIX should be scaled, default is FALSE. See
  details for more information.

- verbose:

  Logical determining if additional messages should be printed.

## Value

An object of class `eemlist`.

A data frame containing the humification index (HIX) for each eem.

## Interpolation

Different excitation and emission wavelengths are often used to measure
EEMs. Hence, it is possible to have mismatchs between measured
wavelengths and wavelengths used to calculate specific metrics. In these
circumstances, EEMs are interpolated using the
[`interp2`](https://rdrr.io/pkg/pracma/man/interp2.html) function from
the `parcma` library. A message warning the user will be prompted if
data interpolation is performed.

## References

Ohno, T. (2002). Fluorescence Inner-Filtering Correction for Determining
the Humification Index of Dissolved Organic Matter. Environmental
Science & Technology, 36(4), 742-746.

[doi:10.1021/es0155276](https://doi.org/10.1021/es0155276)

## See also

[interp2](https://rdrr.io/pkg/pracma/man/interp2.html)

## Examples

``` r
file <- system.file("extdata/cary/scans_day_1/", package = "eemR")
eem <- eem_read(file, import_function = "cary")

eem_humification_index(eem)
#> Warning: This metric uses either excitation or emission wavelengths that were not present in the data. Data has been interpolated to fit the requested wavelengths.
#> Warning: This metric uses either excitation or emission wavelengths that were not present in the data. Data has been interpolated to fit the requested wavelengths.
#> Warning: This metric uses either excitation or emission wavelengths that were not present in the data. Data has been interpolated to fit the requested wavelengths.
#> Warning: This metric uses either excitation or emission wavelengths that were not present in the data. Data has been interpolated to fit the requested wavelengths.
#>    sample        hix
#> 1    nano  0.5568136
#> 2 sample1  6.3795618
#> 3 sample2  4.2548483
#> 4 sample3 13.0246234
```
