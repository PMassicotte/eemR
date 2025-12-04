# Extract fluorescence peaks

Extract fluorescence peaks

## Usage

``` r
eem_peaks(eem, ex, em, verbose = TRUE)
```

## Arguments

- eem:

  An object of class `eemlist`.

- ex:

  A numeric vector with excitation wavelengths.

- em:

  A numeric vector with emission wavelengths.

- verbose:

  Logical determining if additional messages should be printed.

## Value

An object of class `eemlist`.

A data frame containing excitation and emission peak values. See details
for more information.

## Interpolation

Different excitation and emission wavelengths are often used to measure
EEMs. Hence, it is possible to have mismatchs between measured
wavelengths and wavelengths used to calculate specific metrics. In these
circumstances, EEMs are interpolated using the
[`interp2`](https://rdrr.io/pkg/pracma/man/interp2.html) function from
the `parcma` library. A message warning the user will be prompted if
data interpolation is performed.

## See also

[interp2](https://rdrr.io/pkg/pracma/man/interp2.html)

## Examples

``` r
file <- system.file("extdata/cary/scans_day_1/", "sample1.csv", package = "eemR")
eem <- eem_read(file, import_function = "cary")

eem_peaks(eem, ex = c(250, 350), em = c(300, 400))
#>    sample  ex  em peak_intensity
#> 1 sample1 250 300      0.2318111
#> 2 sample1 350 400      1.7270385
```
