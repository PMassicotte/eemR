#' Fluorescence Intensity Calibration Using the Raman Scatter Peak of Water
#'
#' @template template_eem
#' @template template_blank
#' @template template_details_automatic_blank
#'
#' @description Normalize fluorescence intensities to the standard scale of
#'   Raman Units (R.U).
#'
#' @details The normalization procedure consists in dividing all fluorescence
#'   intensities by the area (integral) of the Raman peak. The peak is located
#'   at excitation of 350 nm. (ex = 370) between 371 nm. and 428 nm in emission
#'   (371 <= em <= 428). Note that the data is interpolated to make sure that
#'   fluorescence at em 350 exist.
#'
#' @references
#'
#' Lawaetz, A. J., & Stedmon, C. A. (2009). Fluorescence Intensity Calibration
#' Using the Raman Scatter Peak of Water. Applied Spectroscopy, 63(8), 936-940.
#'
#' \doi{10.1366/000370209788964548}
#'
#' Murphy, K. R., Stedmon, C. a., Graeber, D., & Bro, R. (2013). Fluorescence
#' spectroscopy and multi-way techniques. PARAFAC. Analytical Methods, 5(23),
#' 6557.
#'
#' \url{https://pubs.rsc.org/en/content/articlelanding/2013/ay/c3ay41160e}
#'
#' @return An object of class \code{eem} containing: \itemize{ \item sample The
#'   file name of the eem. \item x A matrix with fluorescence values. \item em
#'   Emission vector of wavelengths. \item ex Excitation vector of wavelengths.
#'   }
#'
#' @export
#' @examples
#' # Open the fluorescence eem
#' file <- system.file("extdata/cary/scans_day_1", "sample1.csv", package = "eemR")
#' eem <- eem_read(file, import_function = "cary")
#'
#' plot(eem)
#'
#' # Open the blank eem
#' file <- system.file("extdata/cary/scans_day_1", "nano.csv", package = "eemR")
#' blank <- eem_read(file, import_function = "cary")
#'
#' # Do the normalisation
#' eem <- eem_raman_normalisation(eem, blank)
#'
#' plot(eem)
eem_raman_normalisation <- function(eem, blank = NA) {
  stopifnot(
    .is_eemlist(eem) | .is_eem(eem),
    .is_eemlist(blank) | is.na(blank)
  )

  if (is.na(blank)) {
    t <- list.group(eem, ~location)
    t <- lapply(t, function(x) {
      class(x) <- "eemlist"
      return(x)
    })

    res <- list.apply(t, eem_raman_normalisation_)
    res <- list.ungroup(res)
    class(res) <- "eemlist"
    return(res)
  } else {
    eem_raman_normalisation_(eem, blank)
  }
}

eem_raman_normalisation_ <- function(eem, blank = NA) {
  stopifnot(
    .is_eemlist(eem) | .is_eem(eem),
    .is_eemlist(blank) | is.na(blank)
  )

  ## It is a list of eems, then call lapply
  if (.is_eemlist(eem)) {
    # if blank is NA then try to split the eemlist into blank and eems
    if (is.na(blank)) {
      blank <- eem_extract_blank(eem)

      if (length(blank) != 1 | length(eem) < 1) {
        stop("Cannot find blank for automatic correction.", call. = FALSE)
      }
    }

    res <- eem_lapply(eem, eem_raman_normalisation_, blank = blank)

    return(res)
  }

  #---------------------------------------------------------------------
  # Do the normalisation.
  #---------------------------------------------------------------------

  # Do not correct if it was already done
  if (attributes(eem)$is_raman_normalized) {
    return(eem)
  }

  # Do not modify blank samples
  if (is_blank(eem)) {
    return(eem)
  }

  blank <- unlist(blank, recursive = FALSE)

  em <- seq(371, 428, by = 2)
  ex <- rep(350, length(em))
  fluo <- pracma::interp2(blank$ex, blank$em, blank$x, ex, em)

  # index_ex <- which(blank$ex == 350)
  # index_em <- which(blank$em >= 371 & blank$em <= 428)
  #
  # x <- blank$em[index_em]
  # y <- blank$x[index_em, index_ex]

  if (any(is.na(em)) | any(is.na(fluo))) {
    stop(
      "NA values found in the blank sample. Maybe you removed scattering too soon?",
      call. = FALSE
    )
  }

  area <- sum(diff(em) * (fluo[-length(fluo)] + fluo[-1]) / 2)

  cat("Raman area:", area, "\n")

  x <- eem$x / area

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
  attr(res, "is_raman_normalized") <- TRUE

  class(res) <- class(eem)

  return(res)
}
