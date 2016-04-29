# eemR 0.1.3

- Interactive plot using a simple shiny app. Using `plot(eems, interactive = TRUE)` will lunch a shiny app that allows to interactively browse EEMs contained in `eems`.

- A vignette has been added to the package whic can be viewed using `vignette(topic = "introduction", package = "eemR")`.

- An error will occur if one try to do raman normalization on a blank where scattering bands have been removed.

- `eem_sample_names()` has been replaced by `eem_names()`.

- Reading Aqualog files is now ~20% faster (#26).

- `plot()` gains an argument `show_peaks = TRUE/FALSE` which can be used to display most common fluorescence peaks used in the literature. 

- `eem_remove_blank()` and `eem_raman_normalisation()` can now try to implicitly use a blank eem from a `eemlist` object (#20). If blank is omitted (`blank = NA`), the functions will try to extract the blank from the `eemlist` object. This is done by looking for sample names containing one of these complete or partial strings (ignoring case):
      - "nano"
      - "miliq"
      - "milliq"
      - "mq"
      - "blank"

Consider the following example where there are two folders that could represent scans performed on two different days `scans_day_1` and `scans_day_2`. In each folder there are three samples and one blank files. In that context, `eem_remove_blank()` will use the blank `nano.csv` from `sample1.csv`, `sample2.csv` and `sample3.csv`. The same strategy will be used for files in folder `scans_day_2` but with blank named `blank.csv`.

```
inst/extdata/cary/
├── scans_day_1
│   ├── nano.csv
│   ├── sample1.csv
│   ├── sample2.csv
│   └── sample3.csv
└── scans_day_2
    ├── blank.csv
    └── s1.csv
```

- `eem_extract()` has now an argument `verbose` (default = FALSE) that determine if the names of removed or extracted eems should be printed on screen.

- Implemented the generic `print()` method which calls `summary()`.

- Added tests to the packages to verify metrics.

- Now better estimate the number of columns to read in Cary Eclipse files (#27). This also makes reading much faster.

# eemR 0.1.2

- Sample names are now exported when using the `eem_export_matlab()` function.

- New function `eem_bind()` implemented to merge objects of class `eem` and `eemlist`.

- Reading EEMs should be ~ 50% faster.

- New function `eem_sample_names()` implemented.
    - `eem_sample_names(eem)` returns a vector containing the sample names of all EEMs.
    - `eem_sample_names(eem) <- c(...)` sets the sample names of all EEMs.

- `eem_extract()` has now an argument `ignore_case` (#10) to specify if the regular expression search should ignore sample name case (TRUE) or not (FALSE).

- Sample names (i.e. file names) are now verified with `make.names()` (#15).

- Various improvements in documentation.

# eemR 0.1.1

- Fixing minimal R version to run the package (R >= 3.2.1)

# eemR 0.1.0

- First version of eemR
