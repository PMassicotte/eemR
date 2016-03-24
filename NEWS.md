# eemR 0.1.3 (unreleased)

- `eem_remove_blank()` can now try to implicitly remove a blank eem from a `eemlist` object. If blank is omited, the function will try to extract the blank from the `eemlist` object. This is done by looking for sample names containing one of these complete or partial strings (ignoring case):
      - nano
      - miliq
      - milliq
      - mq
      - blank
      
- `eem_extract()` has now an argument `verbose` (default = FALSE) that determine if the names of removed or extraced eems should be printed on screen.

- Implemented the generic `print()` method which calls `summary()`.

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
