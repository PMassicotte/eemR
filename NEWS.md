# eemR 0.1.2 (unreleased)

- Reading EEMs should be ~ 50% faster.

- New function `eem_sample_names()` implemented.
    - `eem_sample_names(eem)` returns a vector containing the sample names of all EEMs.
    - `eem_sample_names(eem) <- c(...)` sets the sample names of all EEMs.

- `eem_extract()` has now an argument `ignore_case` (#10) to specify if the regular expression search should ignore sample name case (TRUE) or not (FALSE).

- Various improvement in documentation.

# eemR 0.1.1

- Fixing minimal R version to run the package (R >= 3.2.1)

# eemR 0.1.0

- First version of eemR
