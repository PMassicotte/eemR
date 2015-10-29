#' Calculate the fluorescence index (FI)
#'
#' @param eem An object of class \code{eem}
#'
#' @references \url{http://doi.wiley.com/10.4319/lo.2001.46.1.0038}
#'
#' @return A vector containing fluorescence index
#' @export
#' @examples
#' file <- system.file("extdata/eem", "sample1.csv", package = "eemR")
#' eem <- eem_read(file)
#'
#' eem_fluorescence_index(eem)

eem_fluorescence_index <- function(eem){

  stopifnot(class(eem) == "eem" | any(lapply(eem, class) == "eem"))

  ## It is a list of eems, then call lapply
  if(any(lapply(eem, class) == "eem")){

    res <- unlist(lapply(eem, eem_fluorescence_index))

    return(res)
  }

  index_em_370 <- which(eem$ex == 370)
  index_em_450 <- which(eem$em == 450)
  index_em_500 <- which(eem$em == 500)

  fluo_450 <- eem$x[index_em_450, index_em_370]
  fluo_500 <- eem$x[index_em_500, index_em_370]

  fi <- fluo_450 / fluo_500

  return(fi)

}


#' Extrace fluorescence peaks
#'
#' @param eem An object of class \code{eem}
#'
#' @return A data frame containing peaks B, T, A, M and C
#' @export
#' @examples
#' file <- system.file("extdata/eem", "sample1.csv", package = "eemR")
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
  return(data.frame(b = peak_b,
              t = peak_t,
              a = peak_a,
              m = peak_m,
              c = peak_c))

}
