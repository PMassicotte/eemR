#' @param verbose Logical determining if additional messages should be printed.
#'
#' @section Interpolation:
#'
#'   Different excitation and emission wavelengths are often used to measure
#'   EEMs. Hence, it is possible to have mismatchs between measured wavelengths
#'   and wavelengths used to calculate specific metrics. In these circumstances,
#'   EEMs are interpolated using the \code{\link{interp2}} function from the
#'   \code{parcma} library. A message warning the user will be prompted if data
#'   interpolation is performed.
#'
#' @seealso \link[pracma]{interp2}
