#' Read excitation-emission fluorecence matrix (eem)
#'
#' @param file File name or folder containing fluorescence file(s).
#'
#' @return An object of class \code{eem} containing:
#' \itemize{
#'  \item sample The file name of the eem.
#'  \item x A matrix with fluorescence values.
#'  \item em Emission vector of wavelengths.
#'  \item ex Excitation vector of wavelengths.
#' }
#'
#' @details Note that \code{em} and \code{ex} are rounded before returned.
#'
#' @export
#'
#' @examples
#' fluo <- system.file("extdata/eem", "sample1.csv", package = "eem")
#' ex <- seq(220, 450, by = 5)
#' em <- seq(230, 600, by = 2)
#' eem <- eem_read(fluo, ex, em)

eem_read <- function(file) {

  stopifnot(file.exists(file) | file.info(file)$isdir,
            is.vector(ex),
            is.vector(em),
            is.numeric(ex),
            is.numeric(em))

  #--------------------------------------------
  # Verify if user provided a dir or a file.
  #--------------------------------------------
  isdir <- file.info(file)$isdir

  if(isdir){

    files <- list.files(file, "*.csv", full.names = TRUE)
    res <- lapply(files, eem_read)
    return(res)
  }

  data <- readLines(file)

  data <- stringr::str_split(data, ",")

  expected_col <- unlist(lapply(data, length))[1]

  data[lapply(data, length) != expected_col] <- NULL

  ex <- as.numeric(na.omit(stringr::str_extract(data[[1]], "\\d{3}.\\d{2}")))

  data[1:2] <- NULL ## Remove the first 2 header lines

  data <- matrix(as.numeric(unlist(data)), ncol = expected_col, byrow = TRUE)

  em <- round(data[, 1])

  eem <- data[, seq(2, ncol(data), by = 2)]

  ## Construct an eem object.
  res <- eem(sample = file,
             x = eem,
             ex = ex,
             em = em)

  attr(res, "is_blank_corrected") <- FALSE
  attr(res, "is_scatter_corrected") <- FALSE
  attr(res, "is_ife_corrected") <- FALSE
  attr(res, "is_raman_normalized") <- FALSE

  return(res)
}

#' eem constructor
#'
#' @param sample A string containing the file name of the eem.
#' @param x A matrix with fluorescence values.
#' @inheritParams eem_read
#'
#' @return An object of class \code{eem} containing:
#' \itemize{
#'  \item sample The file name of the eem.
#'  \item x A matrix with fluorescence values.
#'  \item em Emission vector of wavelengths.
#'  \item ex Excitation vector of wavelengths.
#' }
#'
#' @export
#'

eem <- function(sample, x, ex, em){

  eem <- list(sample = basename(sample),
              x = x,
              ex = ex,
              em = em)

  class(eem) <- "eem"

  return(eem)
}
