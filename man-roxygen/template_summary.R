#' @return A data frame containing summarized information on EEMs. \describe{
#'   \item{sample}{Character. Sample name of the EEM,} \item{ex_min}{Numerical.
#'   Minimum excitation wavelength} \item{ex_max}{Numerical. Maximum excitation
#'   wavelength} \item{em_min}{Numerical. Minimum emission wavelength}
#'   \item{em_max}{Numerical. Maximum emission wavelength}
#'   \item{is_blank_corrected}{Logical. TRUE if the sample has been blank
#'   corrected.} \item{is_scatter_corrected}{Logical. TRUE if scattering bands
#'   have been removed from the sample.} \item{is_ife_corrected}{Logical. TRUE
#'   if the sample has been corrected for inner-filter effect.}
#'   \item{is_raman_normalized}{Logical. TRUE if the sample has been Raman
#'   normalized.} \item{manufacturer}{Character. The name of the manufacturer.}
#'   }
