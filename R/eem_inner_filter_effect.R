#' Inner-filter effect correction
#'
#' @template template_eem
#'
#' @param pathlength A numeric value indicating the pathlength (in cm) of the
#'   cuvette used for absorbance measurement. Default is 1 (1cm).
#'
#' @param absorbance A data frame with:
#'
#'   \describe{ \item{wavelength}{A numeric vector containing wavelengths.}
#'   \item{...}{One or more numeric vectors containing absorbance spectra.}}
#'
#' @details The inner-filter effect correction procedure is assuming that
#'   fluorescence has been measured in 1 cm cuvette. Hence, absorbance will be
#'   converted per cm. Note that absorbance spectra should be provided (i.e. not
#'   absorption).
#'
#' @section Names matching:
#'
#'   The names of \code{absorbance} variables are expected to match those of the
#'   eems. If the appropriate absorbance spectrum is not found, an uncorrected
#'   eem will be returned and a warning message will be printed.
#'
#' @section Sample dilution:
#'
#'   Kothawala et al. 2013 have shown that a 2-fold dilution was required for
#'   sample presenting total absorbance > 1.5 in a 1 cm cuvette. Accordingly, a
#'   message will warn the user if total absorbance is greater than this
#'   threshold.
#'
#' @references Parker, C. a., & Barnes, W. J. (1957). Some experiments with
#'   spectrofluorometers and filter fluorimeters. The Analyst, 82(978), 606.
#'   \doi{10.1039/an9578200606}
#'
#'   Kothawala, D. N., Murphy, K. R., Stedmon, C. A., Weyhenmeyer, G. A., &
#'   Tranvik, L. J. (2013). Inner filter correction of dissolved organic matter
#'   fluorescence. Limnology and Oceanography: Methods, 11(12), 616-630.
#'   \doi{10.4319/lom.2013.11.616}
#'
#' @return An object of class \code{eem} containing: \itemize{ \item sample The
#'   file name of the eem. \item x A matrix with fluorescence values. \item em
#'   Emission vector of wavelengths. \item ex Excitation vector of wavelengths.
#'   }
#'
#' @examples
#' library(eemR)
#' data("absorbance")
#'
#' folder <- system.file("extdata/cary/scans_day_1", package = "eemR")
#' eems <- eem_read(folder, import_function = "cary")
#' eems <- eem_extract(eems, "nano") # Remove the blank sample
#'
#' # Remove scattering (1st order)
#' eems <- eem_remove_scattering(eems, "rayleigh")
#'
#' eems_corrected <- eem_inner_filter_effect(eems, absorbance = absorbance, pathlength = 1)
#'
#' op <- par(mfrow = c(2, 1))
#' plot(eems, which = 1)
#' plot(eems_corrected, which = 1)
#' par(op)
#' @export
eem_inner_filter_effect <- function(eem, absorbance, pathlength = 1) {
  stopifnot(
    .is_eemlist(eem) | .is_eem(eem),
    is.data.frame(absorbance),
    is.numeric(pathlength)
  )

  ## It is a list of eems, then call lapply
  if (.is_eemlist(eem)) {
    res <- eem_lapply(eem,
      eem_inner_filter_effect_,
      absorbance = absorbance,
      pathlength = pathlength
    )

    return(res)
  }
}

eem_inner_filter_effect_ <- function(eem, absorbance, pathlength = 1) {
  #---------------------------------------------------------------------
  # Some checks
  #---------------------------------------------------------------------

  # names(absorbance) <- tolower(names(absorbance))

  if (!any(names(absorbance) == "wavelength")) {
    stop("'wavelength' variable was not found in the data frame.",
      call. = FALSE
    )
  }

  wl <- absorbance[["wavelength"]]

  if (!all(is_between(range(eem$em), min(wl), max(wl)))) {
    stop("absorbance wavelengths are not in the range of
         emission wavelengths", call. = FALSE)
  }

  if (!all(is_between(range(eem$ex), min(wl), max(wl)))) {
    stop("absorbance wavelengths are not in the range of
         excitation wavelengths", call. = FALSE)
  }

  index <- which(names(absorbance) == eem$sample)

  ## absorbance spectra not found, we return the uncorected eem
  if (length(index) == 0) {
    warning("Absorbance spectrum for ", eem$sample, " was not found. Returning uncorrected EEM.",
      call. = FALSE
    )

    return(eem)
  }

  spectra <- absorbance[[index]]

  #---------------------------------------------------------------------
  # Create the ife matrix
  #---------------------------------------------------------------------

  cat(eem$sample, "\n")

  # Do not correct if it was already done
  if (attributes(eem)$is_ife_corrected) {
    return(eem)
  }

  sf <- stats::splinefun(wl, spectra)

  ex <- sf(eem$ex)
  em <- sf(eem$em)

  # Calculate total absorbance in 1 cm cuvette.
  # This also assume that the fluorescence has been measured in 1 cm cuvette.
  total_absorbance <- sapply(ex, function(x) {
    x + em
  }) / pathlength

  max_abs <- max(total_absorbance)

  if (max_abs > 1.5) {
    cat("Total absorbance is > 1.5 (Atotal = ", max_abs, ")\n",
      "A 2-fold dilution is recommended. See ?eem_inner_filter_effect.\n",
      sep = ""
    )
  }

  ife_correction_factor <- 10^(0.5 * total_absorbance)

  cat(
    "Range of IFE correction factors:",
    round(range(ife_correction_factor), digits = 4), "\n"
  )

  cat(
    "Range of total absorbance (Atotal) :",
    round(range(total_absorbance / pathlength), digits = 4), "\n\n"
  )

  x <- eem$x * ife_correction_factor

  ## Construct an eem object.
  res <- list(
    file = eem$file,
    sample = eem$sample,
    x = x,
    ex = eem$ex,
    em = eem$em
  )

  res <- eem(res)

  attributes(res) <- attributes(eem)
  attr(res, "is_ife_corrected") <- TRUE

  return(res)
}
