#' Calculate the fluorescence index (FI)
#'
#' @param eem An object of class \code{eem}
#'
#' @references \url{http://doi.wiley.com/10.4319/lo.2001.46.1.0038}
#'
#' @return A data frame containing fluorescence index (FI) for each eem.
#' @export
#' @examples
#' file <- system.file("extdata/cary/eem/", "sample1.csv", package = "eemR")
#' eem <- eem_read(file)
#'
#' eem_fluorescence_index(eem)

eem_fluorescence_index <- function(eem){

  stopifnot(class(eem) == "eem" | any(lapply(eem, class) == "eem"))

  ## It is a list of eems, then call lapply
  if(any(lapply(eem, class) == "eem")){

    res <- lapply(eem, eem_fluorescence_index)
    res <- dplyr::bind_rows(res)

    return(res)
  }

  index_em_370 <- which(eem$ex == 370)
  index_em_450 <- which(eem$em == 450)
  index_em_500 <- which(eem$em == 500)

  fluo_450 <- eem$x[index_em_450, index_em_370]
  fluo_500 <- eem$x[index_em_500, index_em_370]

  fi <- fluo_450 / fluo_500

  return(data.frame(sample = eem$sample, fi = fi))

}


#' Extrace fluorescence peaks
#'
#' @param eem An object of class \code{eem}
#'
#' @return A data frame containing peaks B, T, A, M and C for each eem.
#' @export
#' @examples
#' file <- system.file("extdata/cary/eem/", "sample1.csv", package = "eemR")
#' eem <- eem_read(file)
#'
#' eem_coble_peaks(eem)
eem_coble_peaks <- function(eem){

  stopifnot(class(eem) == "eem" | any(lapply(eem, class) == "eem"))

  ## It is a list of eems, then call lapply
  if(any(lapply(eem, class) == "eem")){

    res <- lapply(eem, eem_coble_peaks)
    res <- dplyr::bind_rows(res)

    return(res)
  }

  coble_ex_peak <- c(b = 275, t = 275, a = 260, m = 312, c = 350)

  if(!all(coble_ex_peak %in% eem$ex)){
    warning("Some Coble excitation wavelengths were not found.
            Closest excitation wavelenghts will be used instead.",
            call. = FALSE)
  }

  #--------------------------------------------
  # Excitation peaks
  #--------------------------------------------
  index_ex_peak_b <- which.min(abs(eem$ex - 275))
  index_ex_peak_t <- which.min(abs(eem$ex - 275))
  index_ex_peak_a <- which.min(abs(eem$ex - 260))
  index_ex_peak_m <- which.min(abs(eem$ex - 312))
  index_ex_peak_c <- which.min(abs(eem$ex - 350))

  #--------------------------------------------
  # Emission peaks
  #--------------------------------------------
  index_em_peak_b <- which.min(abs(eem$em - 310))
  index_em_peak_t <- which.min(abs(eem$em - 340))
  index_em_peak_a <- which(eem$em >= 380 & eem$em <= 460)
  index_em_peak_m <- which(eem$em >= 380 & eem$em <= 420)
  index_em_peak_c <- which(eem$em >= 420 & eem$em <= 480)

  #--------------------------------------------
  # Get peak values
  #--------------------------------------------
  peak_b <- max(eem$x[index_em_peak_b, index_ex_peak_b])
  peak_t <- max(eem$x[index_em_peak_t, index_ex_peak_t])
  peak_a <- max(eem$x[index_em_peak_a, index_ex_peak_a], na.rm = TRUE)
  peak_m <- max(eem$x[index_em_peak_m, index_ex_peak_m], na.rm = TRUE)
  peak_c <- max(eem$x[index_em_peak_c, index_ex_peak_c], na.rm = TRUE)

  #--------------------------------------------
  # Return the data
  #--------------------------------------------
  return(data.frame(sample = eem$sample,
                    b = peak_b,
                    t = peak_t,
                    a = peak_a,
                    m = peak_m,
                    c = peak_c))

}


#' Calculate the fluorescence humification index (HIX)
#'
#' @param eem An object of class \code{eem} or \code{eemlist}.
#' @param scale Logical indicating if HIX should be scaled, default is FALSE.
#'   See details for more information.
#'
#' @description The fluorescence humification index (HIX), which compares two
#'   broad aromatic dominated fluorescence maxima, is calculated at 255 nm
#'   excitation by dividing the integrated emission from 435 to 480 nm by the
#'   integrated emission from 300 to 346 nm.
#'
#' @references Ohno, T. (2002). Fluorescence Inner-Filtering Correction for
#'   Determining the Humification Index of Dissolved Organic Matter.
#'   Environmental Science & Technology, 36(4), 742–746.
#'
#'   \url{http://doi.org/10.1021/es0155276}
#'
#' @return A data frame containing the humification index (HIX) for each eem.
#' @export
#' @examples
#' file <- system.file("extdata/cary/eem/", package = "eemR")
#' eem <- eem_read(file)
#'
#' eem_humification_index(eem)
#'
eem_humification_index <- function(eem, scale = FALSE) {

  stopifnot(class(eem) == "eem" | any(lapply(eem, class) == "eem"),
            is.logical(scale))

  ## It is a list of eems, then call lapply
  if(any(lapply(eem, class) == "eem")){

    res <- lapply(eem, eem_humification_index)
    res <- dplyr::bind_rows(res)

    return(res)
  }

  #---------------------------------------------------------------------
  # Get the data and calculate the humification index (HIX)
  #---------------------------------------------------------------------
  index_ex <- which(eem$ex == 254)
  index_em_435_480 <- which(eem$em >= 435 & eem$em <= 480)
  index_em_300_345 <- which(eem$em >= 300 & eem$em <= 345)

  sum_em_435_480 <- sum(eem$x[index_em_435_480, index_ex])
  sum_em_300_345 <- sum(eem$x[index_em_300_345, index_ex])

  if(scale){
    hix <- sum_em_435_480 / (sum_em_300_345 + sum_em_435_480)
  }else{
    hix <- sum_em_435_480 / sum_em_300_345
  }

  return(data.frame(sample = eem$sample, hix = hix))
}

#' Calculate the biological fluorescence index (BIX)
#'
#' @param eem An object of class \code{eem} or \code{eemlist}.
#'
#' @description The biological fluorescence index (BIX) is calculated by
#'   dividing the fluorescence at excitation 310 nm and emission at 380 nm (ex =
#'   310, em = 430) by that at excitation 310 nm and emission at 430 nm (ex =
#'   310, em = 380).
#'
#' @references Huguet, A., Vacher, L., Relexans, S., Saubusse, S., Froidefond,
#'   J. M., & Parlanti, E. (2009). Properties of fluorescent dissolved organic
#'   matter in the Gironde Estuary. Organic Geochemistry, 40(6), 706-719.
#'
#'   \url{http://doi.org/10.1016/j.orggeochem.2009.03.002}
#'
#' @return A data frame containing the biological index (BIX) for each eem.
#' @export
#' @examples
#' file <- system.file("extdata/cary/eem/", package = "eemR")
#' eem <- eem_read(file)
#'
#' eem_biological_index(eem)
#'
eem_biological_index <- function(eem) {

  stopifnot(class(eem) == "eem" | any(lapply(eem, class) == "eem"))

  ## It is a list of eems, then call lapply
  if(any(lapply(eem, class) == "eem")){

    res <- lapply(eem, eem_biological_index)
    res <- dplyr::bind_rows(res)

    return(res)
  }

  #---------------------------------------------------------------------
  # Get the data and calculate the biological index (BIX)
  #---------------------------------------------------------------------
  index_ex <- which(eem$ex == 310)
  index_em1 <- which(eem$em == 380)
  index_em2 <- which(eem$em == 430)

  bix <- eem$x[index_em1, index_ex] / eem$x[index_em2, index_ex]

  return(data.frame(sample = eem$sample, bix = bix))
}
