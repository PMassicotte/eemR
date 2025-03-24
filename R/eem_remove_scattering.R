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
#' \doi{10.1007/978-0-387-46312-4}
#'
#' Murphy, K. R., Stedmon, C. a., Graeber, D., & Bro, R. (2013).
#' Fluorescence spectroscopy and multi-way techniques. PARAFAC. Analytical
#' Methods, 5(23), 6557. https://doi.org/10.1039/c3ay41160e#'
#'
#'  \url{https://pubs.rsc.org/en/content/articlelanding/2013/AY/c3ay41160e}
#'
#' @export
#' @examples
#' # Open the fluorescence eem
#' file <- system.file("extdata/cary/scans_day_1", "sample1.csv", package = "eemR")
#' eem <- eem_read(file, import_function = "cary")
#'
#' plot(eem)
#'
#' # Remove the scattering
#' eem <- eem_remove_scattering(eem = eem, type = "raman", order = 1, width = 10)
#' eem <- eem_remove_scattering(eem = eem, type = "rayleigh", order = 1, width = 10)
#'
#' plot(eem)
eem_remove_scattering <-
  function(eem, type, order = 1, width = 10) {
    stopifnot(
      .is_eemlist(eem) | .is_eem(eem),
      all(type %in% c("raman", "rayleigh")),
      is.numeric(order),
      is.numeric(width),
      length(order) == 1,
      length(type) == 1,
      length(width) == 1,
      is_between(order, 1, 2),
      is_between(width, 0, 100)
    )

    ## It is a list of eems, then call lapply
    if (.is_eemlist(eem)) {
      res <- eem_lapply(
        eem,
        eem_remove_scattering_,
        type = type,
        order = order,
        width = width
      )

      return(res)
    }

    #---------------------------------------------------------------------
    # Remove the scattering.
    #---------------------------------------------------------------------
  }

eem_remove_scattering_ <-
  function(eem, type, order = 1, width = 10) {
    x <- eem$x
    em <- eem$em
    ex <- eem$ex

    if (type == "raman") {
      ex <- .find_raman_peaks(eem$ex)
    }

    ind1 <- mapply(function(x) em <= x, order * ex - width)
    ind2 <- mapply(function(x) em <= x, order * ex + width)

    ind3 <- ifelse(ind1 + ind2 == 1, NA, 1)

    x <- x * ind3

    ## Construct an eem object.
    res <- eem
    res$x <- x

    attributes(res) <- attributes(eem)
    attr(res, "is_scatter_corrected") <- TRUE

    class(res) <- class(eem)

    return(res)
  }


.find_raman_peaks <- function(ex) {
  # For water, the Raman peak appears at a wavenumber 3600 cm lower than the
  # incident wavenumber. For excitation at 280 nm, the Raman peak from water
  # occurs at 311 nm. Source : Principles of Fluorescence Spectroscopy (2006) -
  # Third Edition.pdf

  ## Convert wavenumber from nm to cm
  ex_wave_number <- 1 / ex

  ## For water. 3600 nm = 0.00036 cm
  raman_peaks <- ex_wave_number - 0.00036 # I think Stedmon use 3400 TODO

  ## Bring back to nm
  raman_peaks <- 1 / raman_peaks

  # raman_peaks <- -(ex / (0.00036 * ex - 1))

  return(raman_peaks)
}
