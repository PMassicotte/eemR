# Read excitation-emission fluorescence matrix (eem)

Read excitation-emission fluorescence matrix (eem)

## Usage

``` r
eem_read(file, recursive = FALSE, import_function)
```

## Arguments

- file:

  File name or folder containing fluorescence file(s).

- recursive:

  logical. Should the listing recurse into directories?

- import_function:

  Either a character or a user-defined function to import a single eem.
  If a character, it should be one of "cary", "aqualog", "shimadzu",
  "fluoromax4". See `browseVignettes("eemR")` to learn how to create
  your own import function.

## Value

If `file` is a single filename:

An object of class `eem` containing:

- sample The file name of the eem.

- x A matrix with fluorescence values.

- em Emission vector of wavelengths.

- ex Excitation vector of wavelengths.

If `file` is a folder, the function returns an object of class `eemlist`
which is simply a list of `eem`.

## Details

At the moment, Cary Eclipse, Aqualog and Shimadzu EEMs are supported.

`eemR` will automatically try to determine from which spectrofluorometer
the files originate and load the data accordingly. Note that EEMs are
reshaped so X\[1, 1\] represents the fluorescence intensity at
X\[min(ex), min(em)\].

## Examples

``` r
file <- system.file("extdata/cary/scans_day_1/", package = "eemR")
eems <- eem_read(file, recursive = TRUE, import_function = "cary")
```
