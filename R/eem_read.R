#' Read excitation-emission fluorecence matrix (eem)
#'
#' @param file File name or folder containing fluorescence file(s).
#'
#' @return If \code{file} is a single filename:
#'
#'   An object of class \code{eem} containing: \itemize{ \item sample The file
#'   name of the eem. \item x A matrix with fluorescence values. \item em
#'   Emission vector of wavelengths. \item ex Excitation vector of wavelengths.
#'   }
#'
#'   If \code{file} is a folder, the function returns an object of class
#'   \code{eemlist} which is simply a list of \code{eem}.
#'
#' @details At the moment,
#'   \href{https://www.agilent.com/en-us/products/fluorescence/fluorescence-systems/cary-eclipse-fluorescence-spectrophotometer}{Cary
#'    Eclipse} and
#'   \href{http://www.horiba.com/us/en/scientific/products/fluorescence-spectroscopy/}{Aqualog}
#'    EEMs are supported.
#'
#'   \code{eemR} will automatically try to determine from which
#'   spectrofluorometer the files originate and load the data accordingly. Note
#'   that EEMs are reshaped so X[1, 1] represents the fluoresence intensity at
#'   X[min(ex), min(em)].
#'
#' @export
#' @examples
#' file <- system.file("extdata/cary/eem/", "sample1.csv", package = "eemR")
#' eem <- eem_read(file)

eem_read <- function(file) {

  stopifnot(file.exists(file) | file.info(file)$isdir)

  #--------------------------------------------
  # Verify if user provided a dir or a file.
  #--------------------------------------------
  isdir <- file.info(file)$isdir

  if(isdir){

    files <- list.files(file, full.names = TRUE)
    res <- lapply(files, eem_read)

    class(res) <- "eemlist"

    return(res)
  }

  #---------------------------------------------------------------------
  # Read the file and try to figure from which spectrofluo it belongs.
  #---------------------------------------------------------------------
  data <- readLines(file)

  if(is_cary_eclipse(data)){
    return(.eem_read_cary(data, file))
  }

  if(is_aqualog(data)){
    .eem_read_aqualog(data, file)
  }


}

#' eem constructor
#'
#' @param sample A string containing the file name of the eem.
#' @param x A matrix with fluorescence values.
#' @param ex Vector of excitation wavelengths.
#' @param em Vector of emission wavelengths.
#'
#' @return An object of class \code{eem} containing:
#' \itemize{
#'  \item sample The file name of the eem.
#'  \item x A matrix with fluorescence values.
#'  \item em Emission vector of wavelengths.
#'  \item ex Excitation vector of wavelengths.
#' }

eem <- function(sample, x, ex, em){

  eem <- list(sample = strsplit(basename(sample), "\\.")[[1]][1],
              x = x,
              ex = ex,
              em = em)

  class(eem) <- "eem"

  return(eem)
}


is_cary_eclipse <- function(x) {
  any(grepl("Instrument\\s+(Cary Eclipse)", x)) ## Need to be more robust
}

is_aqualog <- function(x) {
  any(grepl("Normalized by", x)) ## Need to be more robust
}


.eem_read_cary <- function(data, file){

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
  attr(res, "manucafturer") <- "Cary Eclipse"

  return(res)
}

.eem_read_aqualog <- function(data, file){

  data <- stringr::str_split(data, "\t")

  ex <- rev(as.numeric(na.omit(stringr::str_extract(data[[1]], "\\d+"))))

  data[1:3] <- NULL ## Remove the first 3 header lines

  data <- lapply(data, as.numeric)

  eem <- do.call(rbind, data)

  em <- eem[, 1]

  eem <- eem[, 2:ncol(eem)]

  eem <- eem[, c(ncol(eem):1)]

  ## Construct an eem object.
  res <- eem(sample = file,
             x = eem,
             ex = ex,
             em = em)

  attr(res, "is_blank_corrected") <- FALSE
  attr(res, "is_scatter_corrected") <- FALSE
  attr(res, "is_ife_corrected") <- FALSE
  attr(res, "is_raman_normalized") <- FALSE
  attr(res, "manucafturer") <- "Aqualog"

  return(res)
}
