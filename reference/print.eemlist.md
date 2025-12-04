# Display summary of an eemlist object

Display summary of an eemlist object

## Usage

``` r
# S3 method for class 'eemlist'
print(x, ...)
```

## Arguments

- x:

  An object of class `eemlist`.

- ...:

  Extra arguments.

## Value

A data frame containing summarized information on EEMs.

- sample:

  Character. Sample name of the EEM,

- ex_min:

  Numerical. Minimum excitation wavelength

- ex_max:

  Numerical. Maximum excitation wavelength

- em_min:

  Numerical. Minimum emission wavelength

- em_max:

  Numerical. Maximum emission wavelength

- is_blank_corrected:

  Logical. TRUE if the sample has been blank corrected.

- is_scatter_corrected:

  Logical. TRUE if scattering bands have been removed from the sample.

- is_ife_corrected:

  Logical. TRUE if the sample has been corrected for inner-filter
  effect.

- is_raman_normalized:

  Logical. TRUE if the sample has been Raman normalized.

- manufacturer:

  Character. The name of the manufacturer.

## Examples

``` r
folder <- system.file("extdata/cary", package = "eemR")
eem <- eem_read(folder, recursive = TRUE, import_function = "cary")

print(eem)
#>    sample ex_min ex_max em_min em_max is_blank_corrected is_scatter_corrected
#> 1    nano    220    450    230    600              FALSE                FALSE
#> 2 sample1    220    450    230    600              FALSE                FALSE
#> 3 sample2    220    450    230    600              FALSE                FALSE
#> 4 sample3    220    450    230    600              FALSE                FALSE
#> 5   blank    220    450    230    600              FALSE                FALSE
#> 6      s1    220    450    230    600              FALSE                FALSE
#>   is_ife_corrected is_raman_normalized
#> 1            FALSE               FALSE
#> 2            FALSE               FALSE
#> 3            FALSE               FALSE
#> 4            FALSE               FALSE
#> 5            FALSE               FALSE
#> 6            FALSE               FALSE
```
