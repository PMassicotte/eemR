# Extract fluorescence peaks

Extract fluorescence peaks

## Usage

``` r
eem_coble_peaks(eem, verbose = TRUE)
```

## Arguments

- eem:

  An object of class `eemlist`.

- verbose:

  Logical determining if additional messages should be printed.

## Value

An object of class `eemlist`.

A data frame containing peaks B, T, A, M and C for each eem. See details
for more information.

## Details

According to Coble (1996), peaks are defined as follow:

Peak B: ex = 275 nm, em = 310 nm

Peak T: ex = 275 nm, em = 340 nm

Peak A: ex = 260 nm, em = 380:460 nm

Peak M: ex = 312 nm, em = 380:420 nm

peak C: ex = 350 nm, em = 420:480 nm

Given that peaks A, M and C are not defined at fix emission wavelength,
the maximum fluorescence value in the region is extracted.

## Interpolation

Different excitation and emission wavelengths are often used to measure
EEMs. Hence, it is possible to have mismatchs between measured
wavelengths and wavelengths used to calculate specific metrics. In these
circumstances, EEMs are interpolated using the
[`interp2`](https://rdrr.io/pkg/pracma/man/interp2.html) function from
the `parcma` library. A message warning the user will be prompted if
data interpolation is performed.

## References

Coble, P. G. (1996). Characterization of marine and terrestrial DOM in
seawater using excitation-emission matrix spectroscopy. Marine
Chemistry, 51(4), 325-346.

[doi:10.1016/0304-4203(95)00062-3](https://doi.org/10.1016/0304-4203%2895%2900062-3)

## See also

[interp2](https://rdrr.io/pkg/pracma/man/interp2.html)

## Examples

``` r
file <- system.file("extdata/cary/scans_day_1/", "sample1.csv", package = "eemR")
eem <- eem_read(file, import_function = "cary")

eem_coble_peaks(eem)
#> Warning: This metric uses either excitation or emission wavelengths that were not present in the data. Data has been interpolated to fit the requested wavelengths.
#>    sample        b        t        a        m        c
#> 1 sample1 1.545298 1.060331 3.731836 2.424096 1.814941
```
