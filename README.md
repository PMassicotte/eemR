<!-- README.md is generated from README.Rmd. Please edit that file -->
[![Travis-CI Build Status](https://travis-ci.org/PMassicotte/eemR.svg?branch=master)](https://travis-ci.org/PMassicotte/eemR)

EEM (excitation-emission fluorescence matrix)
=============================================

The **eem** package implements various functions used calculate metrics from excitation-emission matrix (EEM) as well as to preform pre-processing corrections before PARAFAC analysis (Bro 1997; C. A. Stedmon and Markager 2005; Murphy et al. 2013). All functions from this package start with the `eem_` prefix.

``` r
library(eem)
ls("package:eem")
#> [1] "eem_coble_peaks"         "eem_fluorescence_index" 
#> [3] "eem_raman_normalisation" "eem_read"               
#> [5] "eem_remove_blank"        "eem_remove_scattering"
```

Please note this is a very alpha version of the package.

Reading EEMs
============

At the moment, only EEM csv files produced by Cary Eclipse are supported. EEM can be read using the `eem_read()` function.

``` r
library(eem)

file <- system.file("extdata/eem", "sample1.csv", package = "eem")
eem <- eem_read(file)

plot(eem)
```

![](README-unnamed-chunk-3-1.png)

Implemented metrics
===================

The current implemented metrics are:

1.  The fluorescence index (FI) developped by McKnight et al. (2001)
2.  The Coble fluorescence peaks proposed by Coble (1996)

``` r
library(eem)

file <- system.file("extdata/eem", "sample1.csv", package = "eem")
eem <- eem_read(file)

eem_fluorescence_index(eem)
#> [1] 1.264782

eem_coble_peaks(eem)
#> Warning: Some Coble excitation wavelengths were not found.
#>             Closest excitation wavelenghts will be used instead.
#>          b        t        a        m        c
#> 1 1.545298 1.060331 3.731836 2.459364 1.815422
```

PARAFAC pre-processing
======================

Three types of correction are currently supported:

1.  `eem_remove_blank()` which subtract a water blank from the eem.
2.  `eem_remove_scattering()` which remove both *Raman* and *Rayleigh* scattering.
3.  `eem_raman_normalisation()` which normalise EEM fluoresence intensities.
4.  `eem_inner_filter()` which correct (Ohno 2002) **TODO**

Removing Raman and Rayleigh scattering
--------------------------------------

The `eem_remove_scattering()` function removes both Raman and Rayleigh scattering from EEMs.

``` r

file <- system.file("extdata/eem", "sample1.csv", package = "eem")
eem <- eem_read(file)

res <- eem_remove_scattering(eem = eem, type = "raman", order = 1, width = 10)
res <- eem_remove_scattering(eem = res, type = "rayleigh", order = 1, width = 10)

plot(eem)
plot(res)
```

<img src="README-unnamed-chunk-5-1.png" title="" alt="" width="300cm" height="250cm" /><img src="README-unnamed-chunk-5-2.png" title="" alt="" width="300cm" height="250cm" />

Blank removal
-------------

The `eem_remove_blank()` function subtract blank (miliq) water from eem.

``` r

file <- system.file("extdata", "nano.csv", package = "eem")

blank <- eem_read(file)

res <- eem_remove_blank(res, blank)

plot(res)
```

<img src="README-unnamed-chunk-6-1.png" title="" alt="" width="300cm" height="250cm" />

Raman normalization
-------------------

The `eem_raman_normalisation()` function implement a simple calibration method for fluorescence intensity using only the integrated area of a water Raman peak. More details can be found in Lawaetz and Stedmon (2009).

``` r

res <- eem_raman_normalisation(res, blank)
#> Raman area: 9.514551

plot(res)
```

<img src="README-unnamed-chunk-7-1.png" title="" alt="" width="300cm" height="250cm" />

References
==========

Bro, Rasmus. 1997. “PARAFAC. Tutorial and applications.” *Chemometrics and Intelligent Laboratory Systems* 38 (2): 149–71. [doi:10.1016/S0169-7439(97)00032-4](http://doi.org/10.1016/S0169-7439(97)00032-4).

Coble, Paula G. 1996. “Characterization of marine and terrestrial DOM in seawater using excitation-emission matrix spectroscopy.” *Marine Chemistry* 51 (4): 325–46. [doi:10.1016/0304-4203(95)00062-3](http://doi.org/10.1016/0304-4203(95)00062-3).

Lawaetz, A J, and C A Stedmon. 2009. “Fluorescence Intensity Calibration Using the Raman Scatter Peak of Water.” *Applied Spectroscopy* 63 (8): 936–40. [doi:10.1366/000370209788964548](http://doi.org/10.1366/000370209788964548).

McKnight, Diane M., Elizabeth W. Boyer, Paul K. Westerhoff, Peter T. Doran, Thomas Kulbe, and Dale T. Andersen. 2001. “Spectrofluorometric characterization of dissolved organic matter for indication of precursor organic material and aromaticity.” *Limnology and Oceanography* 46 (1). American Society of Limnology; Oceanography: 38–48. [doi:10.4319/lo.2001.46.1.0038](http://doi.org/10.4319/lo.2001.46.1.0038).

Murphy, Kathleen R., Colin a. Stedmon, Daniel Graeber, and Rasmus Bro. 2013. “Fluorescence spectroscopy and multi-way techniques. PARAFAC.” *Analytical Methods* 5 (23): 6557. [doi:10.1039/c3ay41160e](http://doi.org/10.1039/c3ay41160e).

Ohno, Tsutomu. 2002. “Fluorescence Inner-Filtering Correction for Determining the Humification Index of Dissolved Organic Matter.” *Environmental Science & Technology* 36 (4): 742–46. [doi:10.1021/es0155276](http://doi.org/10.1021/es0155276).

Stedmon, Colin A, and Stiig Markager. 2005. “Resolving the variability in dissolved organic matter fluorescence in a temperate estuary and its catchment using PARAFAC analysis.” *Limnology and Oceanography* 50 (2): 686–97. [doi:10.4319/lo.2005.50.2.0686](http://doi.org/10.4319/lo.2005.50.2.0686).
