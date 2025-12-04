# Extract EEM samples

Extract EEM samples

## Usage

``` r
eem_extract(eem, sample, keep = FALSE, ignore_case = FALSE, verbose = TRUE)
```

## Arguments

- eem:

  An object of class `eemlist`.

- sample:

  Either numeric of character vector. See `details` for more
  information.

- keep:

  logical. If TRUE, the specified `sample` will be returned. If FALSE,
  they will be removed.

- ignore_case:

  Logical, should sample name case should be ignored (TRUE) or not
  (FALSE). Default is FALSE.

- verbose:

  Logical determining if removed/extracted eems should be printed on
  screen.

## Value

An object of class `eemlist`.

## Details

`sample` argument can be either numeric or character vector. If it is
numeric, samples at specified index will be removed.

If `sample` is character, regular expression will be used and all sample
names that have a partial or complete match with the expression will be
removed. See `examples` for more details.

## Examples

``` r
folder <- system.file("extdata/cary/scans_day_1", package = "eemR")
eems <- eem_read(folder, import_function = "cary")

eems
#>    sample ex_min ex_max em_min em_max is_blank_corrected is_scatter_corrected
#> 1    nano    220    450    230    600              FALSE                FALSE
#> 2 sample1    220    450    230    600              FALSE                FALSE
#> 3 sample2    220    450    230    600              FALSE                FALSE
#> 4 sample3    220    450    230    600              FALSE                FALSE
#>   is_ife_corrected is_raman_normalized
#> 1            FALSE               FALSE
#> 2            FALSE               FALSE
#> 3            FALSE               FALSE
#> 4            FALSE               FALSE

# Remove first and third samples
eem_extract(eems, c(1, 3))
#> Removed sample(s): nano sample2 
#>    sample ex_min ex_max em_min em_max is_blank_corrected is_scatter_corrected
#> 1 sample1    220    450    230    600              FALSE                FALSE
#> 2 sample3    220    450    230    600              FALSE                FALSE
#>   is_ife_corrected is_raman_normalized
#> 1            FALSE               FALSE
#> 2            FALSE               FALSE

# Remove everything except first and third samples
eem_extract(eems, c(1, 3), keep = TRUE)
#> Extracted sample(s): nano sample2 
#>    sample ex_min ex_max em_min em_max is_blank_corrected is_scatter_corrected
#> 1    nano    220    450    230    600              FALSE                FALSE
#> 2 sample2    220    450    230    600              FALSE                FALSE
#>   is_ife_corrected is_raman_normalized
#> 1            FALSE               FALSE
#> 2            FALSE               FALSE

# Remove all samples containing "3" in their names.
eem_extract(eems, "3")
#> Removed sample(s): sample3 
#>    sample ex_min ex_max em_min em_max is_blank_corrected is_scatter_corrected
#> 1    nano    220    450    230    600              FALSE                FALSE
#> 2 sample1    220    450    230    600              FALSE                FALSE
#> 3 sample2    220    450    230    600              FALSE                FALSE
#>   is_ife_corrected is_raman_normalized
#> 1            FALSE               FALSE
#> 2            FALSE               FALSE
#> 3            FALSE               FALSE

# Remove all samples containing either character "s" or character "2" in their names.
eem_extract(eems, c("s", "2"))
#> Removed sample(s): sample1 sample2 sample3 
#>   sample ex_min ex_max em_min em_max is_blank_corrected is_scatter_corrected
#> 1   nano    220    450    230    600              FALSE                FALSE
#>   is_ife_corrected is_raman_normalized
#> 1            FALSE               FALSE

# Remove all samples containing "blank" or "nano"
eem_extract(eems, c("blank", "nano"))
#> Removed sample(s): nano 
#>    sample ex_min ex_max em_min em_max is_blank_corrected is_scatter_corrected
#> 1 sample1    220    450    230    600              FALSE                FALSE
#> 2 sample2    220    450    230    600              FALSE                FALSE
#> 3 sample3    220    450    230    600              FALSE                FALSE
#>   is_ife_corrected is_raman_normalized
#> 1            FALSE               FALSE
#> 2            FALSE               FALSE
#> 3            FALSE               FALSE
```
