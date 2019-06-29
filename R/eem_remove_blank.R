#' Blank correction
#'
#' @description This function is used to remove blank from eems which can help
#'   to reduce the effect of scatter bands.
#'
#' @template template_eem
#' @template template_blank
#' @template template_details_automatic_blank
#'
#' @details Note that blank correction should be performed before Raman
#'   normalization (\code{eem_raman_normalisation()}). An error will occur
#'   if trying to perform blank correction after Raman normalization.
#'
#' @references Murphy, K. R., Stedmon, C. a., Graeber, D., & Bro, R. (2013).
#'   Fluorescence spectroscopy and multi-way techniques. PARAFAC. Analytical
#'   Methods, 5(23), 6557. http://doi.org/10.1039/c3ay41160e
#'
#'   \url{http://xlink.rsc.org/?DOI=c3ay41160e}
#'
#' @importFrom rlist list.apply list.group list.ungroup
#' @export
#' @examples
#'
#' ## Example 1
#'
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
#' folder <- system.file("extdata/cary/scans_day_1", package = "eemR")
#' eems <- eem_read(folder, import_function = "cary")
#'
#' plot(eems, which = 3)
#'
#' # Open the blank eem
#' file <- system.file("extdata/cary/scans_day_1", "nano.csv", package = "eemR")
#' blank <- eem_read(file, import_function = "cary")
#'
#' plot(blank)
#'
#' # Remove the blank
#' eems <- eem_remove_blank(eems, blank)
#'
#' plot(eems, which = 3)
#'
#' # Automatic correction
#' folder <- system.file("extdata/cary/", package = "eemR")
#'
#' # Look at the folder structure
#' list.files(folder, "*.csv", recursive = TRUE)
#'
#' eems <- eem_read(folder, recursive = TRUE, import_function = "cary")
#' res <- eem_remove_blank(eems)
eem_remove_blank <- function(eem, blank = NA) {
  stopifnot(
    .is_eemlist(eem) | .is_eem(eem),
    .is_eemlist(blank) | is.na(blank)
  )

  is_raman_normalized <- lapply(
    eem,
    function(x) {
      attributes(x)$is_raman_normalized
    }
  )
  is_raman_normalized <- unlist(is_raman_normalized)

  if (any(is_raman_normalized)) {
    stop("Samples have been Raman normalized. Please perform blank removal
         before Raman normalization.", call. = FALSE)
  }

  if (is.na(blank)) {
    t <- list.group(eem, ~location)
    t <- lapply(t, function(x) {
      class(x) <- "eemlist"
      return(x)
    })

    res <- list.apply(t, eem_remove_blank_)
    res <- list.ungroup(res)
    class(res) <- "eemlist"
    return(res)
  } else {
    eem_remove_blank_(eem, blank)
  }
}

eem_remove_blank_ <- function(eem, blank = NA) {
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

    res <- eem_lapply(eem, eem_remove_blank, blank = blank)


    return(res)
  }

  #---------------------------------------------------------------------
  # Do the blank subtraction.
  #---------------------------------------------------------------------

  # Do not correct if it was already done
  if (attributes(eem)$is_blank_corrected) {
    return(eem)
  }

  if (is_blank(eem)) {
    return(eem)
  } # do not modify blank samples

  blank <- unlist(blank, recursive = FALSE)

  x <- eem$x - blank$x

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
  attr(res, "is_blank_corrected") <- TRUE

  return(res)
}
