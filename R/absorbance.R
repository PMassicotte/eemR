#' CDOM absorbance data.
#'
#' Simple absorbance spectra used to test package's functions.
#'
#' \itemize{
#'   \item wavelength.  Wavelengths used for measurements (190-900 nm.)
#'   \item absorbance
#' }
#'
#' @import ggplot2
#' @importFrom tidyr gather
#'
#' @docType data
#' @keywords datasets
#' @name absorbance
#' @usage data(absorbance)
#' @format A data frame with 711 rows and 4s variables
#' @examples
#' library(ggplot2)
#' library(tidyr)
#' data("absorbance")
#'
#' absorbance <- gather(absorbance, sample, absorbance, -wavelength)
#'
#' ggplot(absorbance, aes(x = wavelength, y = absorbance, group = sample)) +
#'  geom_line(aes(color = sample), size = 0.1)
NULL
