#' Read excitation-emission fluorescence matrix (eem)
#'
#' @param file File name or folder containing fluorescence file(s).
#' @param recursive logical. Should the listing recurse into directories?
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
#' @details At the moment, Cary Eclipse, Aqualog and Shimadzu EEMs are
#'   supported.
#'
#'   \code{eemR} will automatically try to determine from which
#'   spectrofluorometer the files originate and load the data accordingly. Note
#'   that EEMs are reshaped so X[1, 1] represents the fluorescence intensity at
#'   X[min(ex), min(em)].
#'
#' @importFrom stats na.omit
#' @importFrom readr read_lines
#' @export
#' @examples
#' file <- system.file("extdata/cary/scans_day_1/", package = "eemR")
#' eems <- eem_read(file, recursive = TRUE)

eem_read <- function(file, recursive = FALSE) {

  stopifnot(file.exists(file) | file.info(file)$isdir,
            is.logical(recursive))

  f <- function(file) {

    # *************************************************************************
    # Read the file and try to figure from which spectrofluo it belongs.
    # *************************************************************************

    data <- read_lines(file)

    if(is_cary_eclipse(data)){
      return(eem_read_cary(data, file))
    }

    if(is_aqualog(data)){
      return(eem_read_aqualog(data, file))
    }

    if(is_shimadzu(data)){
      return(eem_read_shimadzu(data, file))
    }

    if(is_fluoromax4(data)){
      return(eem_read_fluoromax4(data, file))
    } else {
      return(eem_read_generic(file)) # If nothing else works, try read generic.
    }

    message("I do not know how to read *** ", basename(file), " ***\n")
  }

  # *************************************************************************
  # Verify if user provided a dir or a file.
  # *************************************************************************
  isdir <- file.info(file)$isdir

  if(isdir){

    file <- list.files(file,
                        full.names = TRUE,
                        recursive = recursive,
                        no.. = TRUE,
                        include.dirs = FALSE,
                        pattern = "*.txt|*.dat|*.csv",
                        ignore.case = TRUE)

    file <- file[!file.info(file)$isdir]

  }

  res <- lapply(file, f)

  class(res) <- "eemlist"

  res[unlist(lapply(res, is.null))] <- NULL ## Remove unreadable EEMs

  return(res)

}

#' eem constructor
#'
#' @param file A string containing the file name of the eem.
#' @param x A matrix with fluorescence values.
#' @param ex Vector of excitation wavelengths.
#' @param em Vector of emission wavelengths.
#' @param location Location of the eem file.
#'
#' @importFrom tools file_path_sans_ext
#'
#' @return An object of class \code{eem} containing:
#' \itemize{
#'  \item sample The file name of the eem.
#'  \item x A matrix with fluorescence values.
#'  \item em Emission vector of wavelengths.
#'  \item ex Excitation vector of wavelengths.
#' }

eem <- function(file, x, ex, em, location = NA){

  # Use dirname if location if not provided
  if (is.na(location)) {
    location <- dirname(file)
  }


  eem <- list(sample = file_path_sans_ext(basename(file)),
              x = x,
              ex = ex,
              em = em,
              location =  location)

  class(eem) <- "eem"

  return(eem)
}


is_cary_eclipse <- function(x) {
  any(grepl("EX_", x, ignore.case = TRUE)) ## Need to be more robust
}

is_aqualog <- function(x) {
  any(grepl("Normalized by|^Sample - Blank|^Wavelength", x))
}

is_shimadzu <- function(x){

  x <- stringr::str_split(x, "\t")

  # a bit weak, but works for now
  all(unlist(lapply(x, length)) %in% 2)
}

is_fluoromax4 <- function(x) {
  any(grepl("F1", x))
}


# *************************************************************************
# Function reading Shimadzu .TXT files.
# *************************************************************************
eem_read_shimadzu <- function(data, file){

  data <- stringr::str_split(data, "\t")

  data <- lapply(data, as.numeric)

  data <- do.call(rbind, data)

  min_em <- min(data[, 1])
  max_em <- max(data[, 1])

  interval <- data[2, 1] - data[1, 1]

  em <- seq(min_em, max_em, by = interval)

  data <- data[, 2]

  eem <- matrix(data, nrow = length(em), byrow = FALSE)

  ## Construct an eem object.
  res <- eem(file = file,
             x = eem,
             ex = NA,
             em = em)

  attr(res, "is_blank_corrected") <- FALSE
  attr(res, "is_scatter_corrected") <- FALSE
  attr(res, "is_ife_corrected") <- FALSE
  attr(res, "is_raman_normalized") <- FALSE
  attr(res, "manufacturer") <- "Shimadzu"

  message("Shimadzu files do not contain excitation wavelengths.")
  message("Please provide them using the eem_set_wavelengths() function.")

  return(res)

}

# *************************************************************************
# Function reading Cary Eclipse csv files.
# *************************************************************************
eem_read_cary <- function(data, file){

  min_col <- 15 # Do not expect fluorescence data when there is less than 15 cols.

  data <- stringr::str_split(data, ",")
  data[unlist(lapply(data, length)) < min_col] <- NULL

  ## Find the probable number of columns
  n_col <- unlist(lapply(data, length))
  expected_col <- as.numeric(names(sort(-table(n_col)))[1])

  data[lapply(data, length) != expected_col] <- NULL

  ex <- as.numeric(na.omit(stringr::str_match(data[[1]], stringr::regex("Ex_(\\d+\\.?\\d*)", ignore_case = TRUE))[, 2]))

  data[1:2] <- NULL ## Remove the first 2 header lines

  data <- matrix(as.numeric(unlist(data, use.names = FALSE)),
                 ncol = expected_col, byrow = TRUE)

  data <- data[,which(colMeans(is.na(data)) < 1)] ## remove na columns

  eem <- data[, !data[1, ] %in% ex] ## Remove duplicated columns

  em <- data[, 1]

  ## Construct an eem object.
  res <- eem(file = file,
             x = eem,
             ex = ex,
             em = em)

  attr(res, "is_blank_corrected") <- FALSE
  attr(res, "is_scatter_corrected") <- FALSE
  attr(res, "is_ife_corrected") <- FALSE
  attr(res, "is_raman_normalized") <- FALSE
  attr(res, "manufacturer") <- "Cary Eclipse"

  return(res)
}

# *************************************************************************
# Fonction reading Aqualog dat files.
# *************************************************************************
eem_read_aqualog <- function(data, file){

  eem <- stringr::str_extract_all(data, "-?\\d+(?:\\.\\d*)?(?:[eE][+\\-]?\\d+)?")

  ex <- sort(as.numeric(eem[[1]]))

  n_col <- lapply(eem, length)
  n_col <- unlist(n_col)
  expected_col <- as.numeric(names(sort(-table(n_col)))[1])

  eem[n_col != expected_col] <- NULL
  eem <- lapply(eem, as.numeric)
  eem <- do.call(rbind, eem)

  em <- eem[, 1]
  eem <- eem[, -1]
  eem <- as.matrix(eem[, ncol(eem): 1])

  ## Construct an eem object.
  res <- eem(file = file,
             x = eem,
             ex = ex,
             em = em)

  attr(res, "is_blank_corrected") <- FALSE
  attr(res, "is_scatter_corrected") <- FALSE
  attr(res, "is_ife_corrected") <- FALSE
  attr(res, "is_raman_normalized") <- FALSE
  attr(res, "manufacturer") <- "Aqualog"

  return(res)
}

# *************************************************************************
# Fonction reading Fluoromax-4 dat files.
# *************************************************************************
eem_read_fluoromax4 <- function(data, file) {

  data <- stringr::str_split(data, "\t")

  ## Find the probable number of columns
  n_col <- unlist(lapply(data, length))
  expected_col <- as.numeric(names(sort(-table(n_col)))[1])
  data[lapply(data, length) != expected_col] <- NULL

  data <- suppressWarnings(matrix(as.numeric(unlist(data, use.names = FALSE)), ncol = expected_col, byrow = TRUE))

  ex <- as.vector(na.omit(data[1, ]))
  em <- as.vector(na.omit(data[, 1]))
  eem <- data[2:nrow(data), 2:ncol(data)]

  res <- eem(file = file,
             x = eem,
             ex = ex,
             em = em)

  attr(res, "is_blank_corrected") <- FALSE
  attr(res, "is_scatter_corrected") <- FALSE
  attr(res, "is_ife_corrected") <- FALSE
  attr(res, "is_raman_normalized") <- FALSE
  attr(res, "manufacturer") <- "fluoromax4"

  return(res)

}

# ****************************************************************************
# Try to read a generic file. Need better verification.
# ****************************************************************************
eem_read_generic <- function(file) {

  dat <- readr::read_lines(file)
  dat <- stringr::str_split(dat, "\t|,")

  n_col <- unlist(lapply(dat, length))
  expected_col <- as.numeric(names(sort(-table(n_col)))[1])
  dat[lapply(dat, length) != expected_col] <- NULL

  dat <- simplify2array(dat)

  M <- apply(dat, 1, as.numeric)

  wl1 <- as.vector(na.omit(M[1, ]))
  wl2 <- as.vector(na.omit(M[, 1]))

  M <- M[-1, ]
  M <- M[, -1]

  if (max(wl1) > max(wl2)) {
    ex <- wl2
    em <- wl1
  } else {
    ex <- wl1
    em <- wl2
  }

  # monotonically increasing vectors?
  stopifnot(all(ex == cummax(ex)) & all(em == cummax(em)))

  res <- eem(file = file,
             x = M,
             ex = ex,
             em = em)

  attr(res, "is_blank_corrected") <- FALSE
  attr(res, "is_scatter_corrected") <- FALSE
  attr(res, "is_ife_corrected") <- FALSE
  attr(res, "is_raman_normalized") <- FALSE
  attr(res, "manufacturer") <- "Unknown"

  return(res)

}
