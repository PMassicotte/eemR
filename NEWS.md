# eemR 0.1.2

- Reading EEMs should be ~ 50% faster.

- Generic function `names()` implemented.
    - `names(eem)` returns a vector containing the sample names of all EEMs.
    - `names(eem) <- c(...)` sets the sample names of all EEMs.

- `eem_extract()` has now an argument `ignore_case` (#10) to specify if the regular expression search should ignore sample name case (TRUE) or not (FALSE).

- Various improvement in documentation.

# eemR 0.1.1

- Fixing minimal R version to run the package (R >= 3.2.1)

# eemR 0.1.0

- First version of eemR
