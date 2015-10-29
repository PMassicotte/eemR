#' Surface plot of eem
#'
#' @param x An object of class \code{eem}
#' @param ... Extra arguments for \code{image.plot}
#' @export
#'
#' @examples
#' fluo <- system.file("extdata/eem", "sample1.csv", package = "eemR")
#' eem <- eem_read(fluo)
#'
#' plot(eem)

plot.eem <- function(x, ...){

  fields::image.plot(y = x$em,
             x = x$ex,
             z = t(x$x),
             main = x$sample,
             xlab = "Excitation (nm.)",
             ylab = "Emission (nm.)")
}


#' Display summary of an eem object
#'
#' @param object An object of class \code{eem}
#' @param ... Extra arguments
#'
#' @references \url{http://linkinghub.elsevier.com/retrieve/pii/0304420395000623}
#'
#' @export
#'
#' @examples
#' fluo <- system.file("extdata/eem", "sample1.csv", package = "eemR")
#' eem <- eem_read(fluo)
#' summary(eem)

summary.eem <- function(object, ...){

  stopifnot(class(object) == "eem")

  cat("eem object:", dim(object$x)[1],
      "x",  dim(object$x)[2],
      "(", dim(object$x)[1] * dim(object$x)[2], ")", "\n")

  cat("ex: (", range(object$ex), "nm.)", head(object$ex, 3), "...", tail(object$ex, 3), "\n")

  cat("em: (", range(object$em), "nm.)", head(object$em, 3), "...", tail(object$em, 3), "\n")

  cat("is_blank_corrected:", attr(object, "is_blank_corrected"), "\n")

  cat("is_scatter_corrected:", attr(object, "is_scatter_corrected"), "\n")

  cat("is_ife_corrected:", attr(object, "is_ife_corrected"), "\n")

  cat("is_raman_normalized:", attr(object, "is_raman_normalized"), "\n")
}


#' Blank correction
#'
#' @template template_eem
#' @template template_blank
#'
#' @export
#'
#' @examples
#'
#' # Open the fluorescence eem
#' file <- system.file("extdata/eem", "sample1.csv", package = "eemR")
#' eem <- eem_read(file)
#'
#' plot(eem)
#'
#' # Open the blank eem
#' file <- system.file("extdata", "nano.csv", package = "eemR")
#' blank <- eem_read(file)
#'
#' plot(blank)
#'
#' # Remove the blank
#' eem <- eem_remove_blank(eem, blank)
#'
#' plot(eem)
eem_remove_blank <- function(eem, blank) {

  stopifnot(class(eem) == "eem" | any(lapply(eem, class) == "eem"),
            class(blank) == "eem")

  ## It is a list of eems, then call lapply
  if(any(lapply(eem, class) == "eem")){

    res <- lapply(eem,
                  eem_remove_blank,
                  blank = blank)

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
#' @param type A string, either "raman" or "rayleigh"
#' @param order A integer number, either 1 (first order) or 2 (second order)
#' @param width Slit width in nm for the cut
#'
#' @export
#'
#' @examples
#' # Open the fluorescence eem
#' file <- system.file("extdata/eem", "sample1.csv", package = "eemR")
#' eem <- eem_read(file)
#'
#' plot(eem)
#'
#' # Remove the scattering
#' eem <- eem_remove_scattering(eem = eem, type = "raman", order = 1, width = 10)
#'
#' plot(eem)

eem_remove_scattering <- function(eem, type, order = 1, width){

  stopifnot(class(eem) == "eem" | any(lapply(eem, class) == "eem"),
            type %in% c("raman", "rayleigh"),
            is.numeric(order),
            is.numeric(width))

  ## It is a list of eems, then call lapply
  if(any(lapply(eem, class) == "eem")){

    res <- lapply(eem,
                  eem_remove_scattering,
                  type = type,
                  order = order,
                  width = width)

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

#' Title
#'
#' @template template_eem
#' @template template_blank
#'
#' @return An object of class \code{eem} containing:
#' \itemize{
#'  \item sample The file name of the eem.
#'  \item x A matrix with fluorescence values.
#'  \item em Emission vector of wavelengths.
#'  \item ex Excitation vector of wavelengths.
#' }
#' @export
#'
#' @examples
#' # Open the fluorescence eem
#' file <- system.file("extdata/eem", "sample1.csv", package = "eemR")
#' eem <- eem_read(file)
#'
#' plot(eem)
#'
#' # Open the blank eem
#' file <- system.file("extdata", "nano.csv", package = "eemR")
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

  return(res)
}

eem_export_matlab <- function(eem){

}
