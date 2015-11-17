#' Blank correction
#'
#' @template template_eem
#' @template template_blank
#'
#' @details Scatter bands can often be reduced by subtracting water blank.
#'
#' @references Murphy, K. R., Stedmon, C. a., Graeber, D., & Bro, R. (2013).
#'   Fluorescence spectroscopy and multi-way techniques. PARAFAC. Analytical
#'   Methods, 5(23), 6557. http://doi.org/10.1039/c3ay41160e
#'
#'   \url{http://xlink.rsc.org/?DOI=c3ay41160e}
#'
#' @export
#' @examples
#'
#' ## Example 1
#'
#' # Open the fluorescence eem
#' file <- system.file("extdata/cary/eem/", "sample1.csv", package = "eemR")
#' eem <- eem_read(file)
#'
#' plot(eem)
#'
#' # Open the blank eem
#' file <- system.file("extdata/cary/", "nano.csv", package = "eemR")
#' blank <- eem_read(file)
#'
#' plot(blank)
#'
#' # Remove the blank
#' eem <- eem_remove_blank(eem, blank)
#'
#' plot(eem)
#'
#' ## Example 2
#'
#' # Open the fluorescence eem
#' folder <- system.file("extdata/cary/eem/", package = "eemR")
#' eem <- eem_read(folder)
#'
#' plot(eem, which = 3)
#'
#' # Open the blank eem
#' file <- system.file("extdata/cary/", "nano.csv", package = "eemR")
#' blank <- eem_read(file)
#'
#' plot(blank)
#'
#' # Remove the blank
#' eem <- eem_remove_blank(eem, blank)
#'
#' plot(eem, which = 3)

eem_remove_blank <- function(eem, blank) {

  stopifnot(class(eem) == "eem" | any(lapply(eem, class) == "eem"),
            class(blank) == "eem")

  ## It is a list of eems, then call lapply
  if(any(lapply(eem, class) == "eem")){

    res <- lapply(eem,
                  eem_remove_blank,
                  blank = blank)

    class(res) <- class(eem)
    return(res)
  }

  #---------------------------------------------------------------------
  # Do the blank subtraction.
  #---------------------------------------------------------------------

  x <- eem$x - blank$x

  ## Construct an eem object.
  res <- eem(sample = eem$sample,
             x = x,
             ex = eem$ex,
             em = eem$em)

  attributes(res) <- attributes(eem)
  attr(res, "is_blank_corrected") <- TRUE

  return(res)
}

#' Remove Raman and Rayleigh scattering
#'
#' @template template_eem
#'
#' @param type A string, either "raman" or "rayleigh".
#' @param order A integer number, either 1 (first order) or 2 (second order).
#' @param width Slit width in nm for the cut. Default is 10 nm.
#'
#' @references
#'
#' Lakowicz, J. R. (2006). Principles of Fluorescence Spectroscopy.
#' Boston, MA: Springer US.#'
#'
#' \url{http://doi.org/10.1007/978-0-387-46312-4}
#'
#' Murphy, K. R., Stedmon, C. a., Graeber, D., & Bro, R. (2013).
#' Fluorescence spectroscopy and multi-way techniques. PARAFAC. Analytical
#' Methods, 5(23), 6557. http://doi.org/10.1039/c3ay41160e#'
#'
#'  \url{http://xlink.rsc.org/?DOI=c3ay41160e}
#'
#' @export
#' @examples
#' # Open the fluorescence eem
#' file <- system.file("extdata/cary/eem/", "sample1.csv", package = "eemR")
#' eem <- eem_read(file)
#'
#' plot(eem)
#'
#' # Remove the scattering
#' eem <- eem_remove_scattering(eem = eem, type = "raman", order = 1, width = 10)
#'
#' plot(eem)

eem_remove_scattering <- function(eem, type, order = 1, width = 10){

  stopifnot(class(eem) == "eem" | any(lapply(eem, class) == "eem"),
            all(type %in% c("raman", "rayleigh")),
            is.numeric(order),
            is.numeric(width),
            length(order) == 1,
            length(type) == 1,
            length(width) == 1,
            is_between(order, 1, 2),
            is_between(width, 0, 100))

  ## It is a list of eems, then call lapply
  if(any(lapply(eem, class) == "eem")){

    res <- lapply(eem,
                  eem_remove_scattering,
                  type = type,
                  order = order,
                  width = width)

    class(res) <- class(eem)
    return(res)
  }

  #---------------------------------------------------------------------
  # Remove the scattering.
  #---------------------------------------------------------------------

  x <- eem$x
  em <- eem$em
  ex <- eem$ex

  if(type == "raman"){

    ex <- .find_raman_peaks(eem$ex)

  }

  ind1 <- mapply(function(x)em <= x, order * ex - width)
  ind2 <- mapply(function(x)em <= x, order * ex + width)

  ind3 <- ifelse(ind1 + ind2 == 1, NA, 1)

  x <- x * ind3

  ## Construct an eem object.
  res <- eem(sample = eem$sample,
             x = x,
             ex = eem$ex,
             em = eem$em)

  attributes(res) <- attributes(eem)
  attr(res, "is_scatter_corrected") <- TRUE

  class(res) <- class(eem)

  return(res)
}

.find_raman_peaks <- function(ex){

  # For water, the Raman peak appears at a wavenumber 3600 cm lower than the
  # incident wavenumber. For excitation at 280 nm, the Raman peak from water
  # occurs at 311 nm. Source : Principles of Fluorescence Spectroscopy (2006) -
  # Third Edition.pdf

  ## Convert to wavenumber
  ex_wave_number = 1 / ex * 10000000

  ## For water
  raman_peaks = ex_wave_number - 3600 # I think Stedmon use 3400 TODO

  raman_peaks = 10000000 / raman_peaks

  return(raman_peaks)
}

#' Fluorescence Intensity Calibration Using the Raman Scatter Peak of Water
#'
#' @template template_eem
#' @template template_blank
#'
#' @description Normalize fluorescence intensities to the standard scale of
#'   Raman Units (R.U).
#'
#' @details The normalization procedure consists in dividing all fluorescence
#'   intensities by the area (integral) of the Raman peak. The peak is located
#'   at excitation of 350 nm. (ex = 370) betwen 371 nm. and 428 nm in emission
#'   (371 <= em <= 428).
#'
#' @references
#'
#' Lawaetz, A. J., & Stedmon, C. A. (2009). Fluorescence Intensity Calibration
#' Using the Raman Scatter Peak of Water. Applied Spectroscopy, 63(8), 936-940.
#'
#' \url{http://doi.org/10.1366/000370209788964548}
#'
#' Murphy, K. R., Stedmon, C. a., Graeber, D., & Bro, R. (2013). Fluorescence
#' spectroscopy and multi-way techniques. PARAFAC. Analytical Methods, 5(23),
#' 6557.
#'
#' \url{http://xlink.rsc.org/?DOI=c3ay41160e}
#'
#' @return An object of class \code{eem} containing: \itemize{ \item sample The
#'   file name of the eem. \item x A matrix with fluorescence values. \item em
#'   Emission vector of wavelengths. \item ex Excitation vector of wavelengths.
#'   }
#'
#' @export
#' @examples
#' # Open the fluorescence eem
#' file <- system.file("extdata/cary/eem/", "sample1.csv", package = "eemR")
#' eem <- eem_read(file)
#'
#' plot(eem)
#'
#' # Open the blank eem
#' file <- system.file("extdata/cary/", "nano.csv", package = "eemR")
#' blank <- eem_read(file)
#'
#' # Do the normalisation
#' eem <- eem_raman_normalisation(eem, blank)
#'
#' plot(eem)

eem_raman_normalisation <- function(eem, blank){

  stopifnot(class(eem) == "eem" | any(lapply(eem, class) == "eem"),
            class(blank) == "eem")

  ## It is a list of eems, then call lapply
  if(any(lapply(eem, class) == "eem")){

    res <- lapply(eem,
                  eem_raman_normalisation,
                  blank = blank)

    class(res) <- class(eem)

    return(res)
  }

  #---------------------------------------------------------------------
  # Do the normalisation.
  #---------------------------------------------------------------------
  index_ex <- which(blank$ex == 350)
  index_em <- which(blank$em >= 371 & blank$em <= 428)

  x <- blank$em[index_em]
  y <- blank$x[index_em, index_ex]

  area <- sum(diff(x) * (y[-length(y)] + y[-1]) / 2)

  cat("Raman area:", area, "\n")

  x <- eem$x / area

  ## Construct an eem object.
  res <- eem(sample = eem$sample,
             x = x,
             ex = eem$ex,
             em = eem$em)

  attributes(res) <- attributes(eem)
  attr(res, "is_raman_normalized") <- TRUE

  class(res) <- class(eem)

  return(res)
}

#' Inner-filter effect correction
#'
#' @template template_eem
#'
#' @param pathlength A numeric value indicating the pathlength (in cm) of the
#'   cuvette used for fluorescence measurement. Default is 1 (1cm).
#'
#' @param absorbance A data frame with:
#'
#'   \describe{ \item{wavelength}{A numeric vector containing wavelenghts.}
#'   \item{...}{One or more numeric vectors containing absorbance spectra.}}
#'
#' @details The names of \code{absorbance} variables are expected to match those
#'   of the eems. If the appropriate absorbance spectrum is not found, an
#'   uncorrected eem will be returned and a warning message will be printed.
#'
#' @references Parker, C. a., & Barnes, W. J. (1957). Some experiments with
#'   spectrofluorimeters and filter fluorimeters. The Analyst, 82(978), 606.
#'
#'   \url{http://doi.org/10.1039/an9578200606}
#'
#' @return An object of class \code{eem} containing: \itemize{ \item sample The
#'   file name of the eem. \item x A matrix with fluorescence values. \item em
#'   Emission vector of wavelengths. \item ex Excitation vector of wavelengths.
#'   }
#'
#' @export
#' @examples
#' library(eemR)
#' data("absorbance")

eem_inner_filter_effect <- function(eem, absorbance, pathlength = 1) {

  stopifnot(class(eem) == "eem" | any(lapply(eem, class) == "eem"),

            is.data.frame(absorbance),

            is.numeric(pathlength))


  ## It is a list of eems, then call lapply
  if(any(lapply(eem, class) == "eem")){

    res <- lapply(eem, eem_inner_filter_effect, absorbance = absorbance)

    class(res) <- class(eem)

    return(res)
  }

  #---------------------------------------------------------------------
  # Some checks
  #---------------------------------------------------------------------
  names(absorbance) <- tolower(names(absorbance))

  if(!any(names(absorbance) == "wavelength")){

    stop("'wavelength' variable was not found in the data frame.",
         call. = FALSE)
  }

  wl <- absorbance[, "wavelength"]

  if(!all(is_between(range(eem$em), min(wl), max(wl)))){

    stop("absorbance wavelenghts are not in the range of
         emission wavelengths", call. = FALSE)

  }

  if(!all(is_between(range(eem$ex), min(wl), max(wl)))){

    stop("absorbance wavelenghts are not in the range of
         excitation wavelengths", call. = FALSE)

  }

  spectra <- absorbance[, which(names(absorbance) == eem$sample)]

  ## absorbance spectra not found, we return the uncorected eem
  if(length(spectra) == 0){

    warning("Absorbance spectrum for ", eem$sample, " was not found. Returning uncorrected EEM.",
            call. = FALSE)

    return(eem)
  }

  #---------------------------------------------------------------------
  # Create the ife matrix
  #---------------------------------------------------------------------

  sf <- splinefun(wl, spectra)

  ex <- sf(eem$ex)
  em <- sf(eem$em)

  total_absorbance <- mat.or.vec(nr = length(em), nc = length(ex))

  for(i in 1:length(em)){
    for(j in 1:length(ex)){
      total_absorbance[i, j] <- em[i] + ex[j]
    }
  }

  ife_correction_factor <- 10 ^ (-pathlength / 2 * (total_absorbance))

  cat("Range of IFE correction factors:", range(ife_correction_factor), "\n")

  x <- eem$x / ife_correction_factor

  ## Construct an eem object.
  res <- eem(sample = eem$sample,
             x = x,
             ex = eem$ex,
             em = eem$em)

  attributes(res) <- attributes(eem)
  attr(res, "is_ife_corrected") <- TRUE

  return(res)

}

is_between <- function(x, a, b) {
  x >= a & x <= b
}

