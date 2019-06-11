#' Read excitation-emission fluorescence matrix (eem)
#'
#' @param file File name or folder containing fluorescence file(s).
#' @param recursive logical. Should the listing recurse into directories?
#' @param import_function Either a character or a user-defined function to
#'   import a single eem. If a character, it should be one of "cary", "aqualog",
#'   "shimadzu", "fluoromax4". See vignette () to learn how to create your own
#'   import function.
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
#' @export
#' @examples
#' file <- system.file("extdata/cary/scans_day_1/", package = "eemR")
#' eems <- eem_read(file, recursive = TRUE, import_function = "cary)

eem_read <- function(file, recursive = FALSE, import_function) {
  stopifnot(
    file.exists(file) | file.info(file)$isdir,
    is.logical(recursive),
    is.function(import_function) | is.character(import_function)
  )

  # Use a predefined function of a user-defined function
  f <- eem_import_function_factory(import_function)

  eem_check_import_function(f)

  # *************************************************************************
  # Verify if the user provided a dir or a file.
  # *************************************************************************
  isdir <- file.info(file)$isdir

  if (isdir) {
    file <- list.files(
      file,
      full.names = TRUE,
      recursive = recursive,
      no.. = TRUE,
      include.dirs = FALSE,
      pattern = "*.txt|*.dat|*.csv",
      ignore.case = TRUE
    )

    file <- file[!file.info(file)$isdir]
  }

  # Now read the files
  res <- lapply(file, f)

  # Convert into eems
  res <- lapply(res, eem)

  class(res) <- "eemlist"

  res[unlist(lapply(res, is.null))] <- NULL ## Remove unreadable EEMs

  return(res)
}
