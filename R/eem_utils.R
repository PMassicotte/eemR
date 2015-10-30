#' Surface plot of eem
#'
#' @param x An object of class \code{eem}.
#' @param ... Extra arguments for \code{image.plot}.
#' @export
#' @examples
#' file <- system.file("extdata/cary/eem/", "sample1.csv", package = "eemR")
#' eem <- eem_read(file)
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

#' Surface plot of eem
#'
#' @param x An object of class \code{eemlist}.
#' @param which An integer representing the index of eem to be plotted.
#' @param ... Extra arguments for \code{image.plot}.
#'
#' @export
#' @examples
#' folder <- system.file("extdata/cary/eem/", package = "eemR")
#' eem <- eem_read(folder)
#'
#' plot(eem, which = 2)
plot.eemlist <- function(x, which = 1, ...) {

  stopifnot(which <= length(x))

  plot.eem(x[[which]])

}


#' Display summary of an eem object
#'
#' @param object An object of class \code{eem}.
#' @param ... Extra arguments.
#'
#' @references \url{http://www.sciencedirect.com/science/article/pii/0304420395000623}
#'
#' @export
#' @examples
#' file <- system.file("extdata/cary/eem/", "sample1.csv", package = "eemR")
#' eem <- eem_read(file)
#'
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


#' Display summary of an eemlist object
#'
#' @param object An object of class \code{eemlist}.
#' @param ... Extra arguments.
#'
#' @export
#' @examples
#' folder <- system.file("extdata/cary/eem/", package = "eemR")
#' eem <- eem_read(folder)
#'
#' summary(eem)
summary.eemlist <- function(object, ...){

  stopifnot(class(object) == "eemlist")

  cat("eemlist object containing:", length(object), "eem\n\n")

  cat("First eem object:\n\n")
  summary.eem(object[[1]])
}

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

#' Export EEMs to Matlab
#'
#' @param file The .mat file name where to export the structure.
#' @param eem Either an object of class \code{eem} or a list of \code{eem}.
#'
#' @details The function exports EEMs into PARAFAC-ready Matlab \code{.mat} file
#'   usable by the \href{www.models.life.ku.dk/drEEM}{drEEM} toolbox. A
#'   structure named \code{OriginalData} is created and contains:
#'
#'   \describe{
#'    \item{nSample}{The number of eems.}
#'    \item{nEx}{The number of excitation wavelengths.}
#'    \item{nEm}{The number of emission wavelengths.}
#'    \item{Ex}{A vector containing excitation wavelengths.}
#'    \item{Em}{A vector containing emission wavelengths.}
#'    \item{X}{A 3D matrix (nSample X nEx X nEm) containing EEMs.}
#'   }
#'
#' @export
#' @examples
#' file <- system.file("extdata/cary/eem/", "sample1.csv", package = "eemR")
#' eem <- eem_read(file)
#'
#' export_to <- paste(tempfile(), ".mat", sep = "")
#' eem_export_matlab(export_to, eem)

eem_export_matlab <- function(file, eem){

  stopifnot(class(eem) == "eem" | any(lapply(eem, class) == "eem"),
            file.info(dirname(file))$isdir,
            grepl(".mat", basename(file)))


  ## If only one eem is provided...
  if(class(eem) == "eem"){
    eem <- list(eem = eem)
  }

  ## Number of eem
  nSample <- length(eem)

  #---------------------------------------------------------------------
  # Check emission wavelengths
  #---------------------------------------------------------------------
  nEm <- unique(unlist(lapply(eem, function(x) length(x$em))))

  if(length(nEm) != 1){
    stop("Length of emission vectors are not the same across all eem.",
         call. = FALSE)
  }

  Em <- mapply(function(x) x$em, eem)

  if(ncol(unique(Em, MARGIN = 2)) != 1){
    stop("Emission vectors are not the same across all eem.",
         call. = FALSE)
  }

  Em <- Em[, 1] ## Just get the first column

  #---------------------------------------------------------------------
  # Check excitation wavelengths
  #---------------------------------------------------------------------
  nEx <- unique(unlist(lapply(eem, function(x) length(x$ex))))

  if(length(nEx) != 1){
    stop("Length of excitation vectors are not the same across all eem.",
         call. = FALSE)
  }

  Ex <- mapply(function(x) x$ex, eem)

  if(ncol(unique(Ex, MARGIN = 2)) != 1){
    stop("Exctiation vectors are not the same across all eem.",
         call. = FALSE)
  }

  Ex <- Ex[, 1] ## Just get the first column

  #---------------------------------------------------------------------
  # Prepare the 3D X matrix contianing eem sample nSample x nEm x nEx
  #---------------------------------------------------------------------

  ncol = unique(unlist(lapply(eem, function(x) ncol(x$x))))

  if(length(ncol) != 1){
    stop("EEMs do not have all the same number of columns across the dataset.",
         call. = FALSE)
  }

  nrow = unique(unlist(lapply(eem, function(x) nrow(x$x))))

  if(length(nrow) != 1){
    stop("EEMs do not have all the same number of rows across the dataset.",
         call. = FALSE)
  }

  X <- simplify2array(lapply(eem, function(x)x$x))

  X <- array(aperm(X, c(3, 1, 2)), dim = c(nSample, nEm, nEx))

  ## Use PARAFAC "naming" convention
  OriginalData <- list(X = X,
                       nEm = nEm,
                       nEx = nEx,
                       nSample = nSample,
                       Ex = Ex,
                       Em = Em)

  R.matlab::writeMat(file, OriginalData = OriginalData)

  message("Sucesfully exported ", nSample, " EEMs to ", file, ".\n")

}
