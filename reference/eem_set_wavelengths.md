# Set Excitation and/or Emission wavelengths

This function allows to manually specify either excitation or emission
vector of wavelengths in EEMs. This function is mostly used with
spectrophotometers such as Shimadzu that do not include excitation
wavelengths in fluorescence files.

## Usage

``` r
eem_set_wavelengths(eem, ex, em)
```

## Arguments

- eem:

  An object of class `eemlist`.

- ex:

  A numeric vector of excitation wavelengths.

- em:

  A numeric vector of emission wavelengths.

## Value

An object of class `eemlist`.

## Examples

``` r
folder <- system.file("extdata/shimadzu", package = "eemR")

eem <- eem_read(folder, import_function = "shimadzu")
eem <- eem_set_wavelengths(eem, ex = seq(230, 450, by = 5))

plot(eem)
```
