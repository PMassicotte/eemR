% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/eem_utils.R
\name{summary.eemlist}
\alias{summary.eemlist}
\title{Display summary of an eemlist object}
\usage{
\method{summary}{eemlist}(object, ...)
}
\arguments{
\item{object}{An object of class \code{eemlist}.}

\item{...}{Extra arguments.}
}
\value{
A data frame containing summarized information on EEMs. \describe{
  \item{sample}{Character. Sample name of the EEM,} \item{ex_min}{Numerical.
  Minimum excitation wavelength} \item{ex_max}{Numerical. Maximum excitation
  wavelength} \item{em_min}{Numerical. Minimum emission wavelength}
  \item{em_max}{Numerical. Maximum emission wavelength}
  \item{is_blank_corrected}{Logical. TRUE if the sample has been blank
  corrected.} \item{is_scatter_corrected}{Logical. TRUE if scattering bands
  have been removed from the sample.} \item{is_ife_corrected}{Logical. TRUE
  if the sample has been corrected for inner-filter effect.}
  \item{is_raman_normalized}{Logical. TRUE if the sample has been Raman
  normalized.} \item{manufacturer}{Character. The name of the manufacturer.}
  }
}
\description{
Display summary of an eemlist object
}
\examples{
folder <- system.file("extdata/cary", package = "eemR")
eem <- eem_read(folder, recursive = TRUE, import_function = "cary")

summary(eem)
}
