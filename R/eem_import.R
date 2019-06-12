

eem_import_function_factory <- function(import_function) {
  if (is.function(import_function)) {
    return(import_function)
  }

  switch(import_function,
    "cary" = eem_read_cary,
    "aqualog" = eem_read_aqualog,
    "shimadzu" = eem_read_shimadzu,
    "fluoromax4" = eem_read_fluoromax4,
    # is.function = return(import_function),
    stop("I do not know how to read a file from ", import_function, ". You may want to create your own import function. See vignette browseVignettes('eemR')")
  )
}

#' eem constructor
#'
#' @param data A list containing "file", "x", "em", "ex".
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

eem <- function(data, location = NA) {

  # Use dirname if location if not provided
  if (is.na(location)) {
    location <- dirname(data$file)
  }

  if (!all(c("file", "x", "em", "ex") %in% names(data))) {
    stop("Your custom function should return a named list with four components: file, x, ex, em")
  }

  res <- list(
    sample = file_path_sans_ext(basename(data$file)),
    x = data$x,
    ex = data$ex,
    em = data$em,
    location = location
  )


  class(res) <- "eem"

  attr(res, "is_blank_corrected") <- FALSE
  attr(res, "is_scatter_corrected") <- FALSE
  attr(res, "is_ife_corrected") <- FALSE
  attr(res, "is_raman_normalized") <- FALSE

  return(res)
}

eem_check_import_function <- function(f) {
  arguments <- formals(f)

  if (!all(names(arguments) %in% c("file", "data"))) {
    stop("Your custom function use only two arguments: file, data")
  }

  grepl("eem\\(.*\\)", body(f))
}
