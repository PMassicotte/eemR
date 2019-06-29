#' eem constructor
#'
#' @param data A list containing "file", "x", "em", "ex".
#'
#' @importFrom tools file_path_sans_ext
#'
#' @return An object of class \code{eem} containing:
#' \itemize{
#'  \item sample The sample name of the eem.
#'  \item file The filename of the eem.
#'  \item location Directory of the eem.
#'  \item x A matrix with fluorescence values.
#'  \item em Emission vector of wavelengths.
#'  \item ex Excitation vector of wavelengths.
#' }

eem <- function(data) {
  if (!all(c("file", "x", "em", "ex") %in% names(data))) {
    stop("Your custom function should return a named list with four components: file, x, ex, em")
  }

  res <- list(
    file = data$file,
    sample = ifelse(
      is.null(data$sample),
      file_path_sans_ext(basename(data$file)),
      data$sample
    ),
    x = data$x,
    ex = data$ex,
    em = data$em,
    location = dirname(data$file)
  )

  class(res) <- "eem"

  attr(res, "is_blank_corrected") <- FALSE
  attr(res, "is_scatter_corrected") <- FALSE
  attr(res, "is_ife_corrected") <- FALSE
  attr(res, "is_raman_normalized") <- FALSE

  return(res)
}
