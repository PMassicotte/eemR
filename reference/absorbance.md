# CDOM absorbance data.

Simple absorbance spectra used to test package's functions.

## Usage

``` r
data("absorbance")
```

## Format

A data frame with 711 rows and 4 variables

## Details

- wavelength. Wavelengths used for measurements (190-900 nm.)

- absorbance

## Examples

``` r
data("absorbance")

plot(absorbance$wavelength, absorbance$sample1,
  type = "l",
  xlab = "Wavelengths", ylab = "Absorbance per meter"
)
lines(absorbance$wavelength, absorbance$sample2, col = "blue")
lines(absorbance$wavelength, absorbance$sample3, col = "red")
```
