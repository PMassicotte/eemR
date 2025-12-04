# Export EEMs to Matlab

Export EEMs to Matlab

## Usage

``` r
eem_export_matlab(file, ...)
```

## Arguments

- file:

  The .mat file name where to export the structure.

- ...:

  One or more object of class `eemlist`.

## Value

A structure named `OriginalData` is created and contains:

- nSample:

  The number of eems.

- nEx:

  The number of excitation wavelengths.

- nEm:

  The number of emission wavelengths.

- Ex:

  A vector containing excitation wavelengths.

- Em:

  A vector containing emission wavelengths.

- X:

  A 3D matrix (nSample X nEx X nEm) containing EEMs.

`sample_name` The list of sample names (i.e. file names) of the imported
EEMs.

## Details

The function exports EEMs into PARAFAC-ready Matlab `.mat` file usable
by the [drEEM](https://dreem.openfluor.org/) toolbox.

## Known bug in export

`eemR` uses `R.Matlab` to export the the fluorescence data into a
matfile. However, there is currently a bug in the latter package that
require the user to reshape the exported data once in Matlab. This can
be done using the following command:
`load('OriginalData.mat'); OriginalData.X = reshape(OriginalData.X, OriginalData.nSample, OriginalData.nEm, OriginalData.nEx)`

## Examples

``` r
file <- system.file("extdata/cary/", package = "eemR")
eem <- eem_read(file, recursive = TRUE, import_function = "cary")

export_to <- paste(tempfile(), ".mat", sep = "")
eem_export_matlab(export_to, eem)
#> Successfully exported 6 EEMs to /tmp/RtmpPlyexV/file195e53145248.mat.
```
