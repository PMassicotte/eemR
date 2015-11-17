#' Surface plot of eem
#'
#' @param x An object of class \code{eem}.
#' @param ... Extra arguments for \code{image.plot}.
#' @export
#' @examples
#' file <- system.file("extdata/cary/eem/", "sample1.csv", package = "eemR")
#' eem <- eem_read(file)
#'
#' plot(eem)

plot.eem <- function(x, ...){

  jet.colors <- colorRampPalette(c("#00007F",
                                   "blue",
                                   "#007FFF",
                                   "cyan",
                                   "#7FFF7F",
                                   "yellow",
                                   "#FF7F00",
                                   "red",
                                   "#7F0000"))

  fields::image.plot(y = x$em,
             x = x$ex,
             z = t(x$x),
             main = paste(x$sample, "\n", attr(x, "manucafturer"), sep = ""),
             xlab = "Excitation (nm.)",
             ylab = "Emission (nm.)",
             legend.lab = "Fluorescence intensity",
             col = jet.colors(255))
}

#' Surface plot of eem
#'
#' @param x An object of class \code{eemlist}.
#' @param which An integer representing the index of eem to be plotted.
#' @param ... Extra arguments for \code{image.plot}.
#'
#' @export
#' @examples
#' folder <- system.file("extdata/cary/eem/", package = "eemR")
#' eem <- eem_read(folder)
#'
#' plot(eem, which = 2)
plot.eemlist <- function(x, which = 1, ...) {

  stopifnot(which <= length(x))

  plot.eem(x[[which]])

}

#' Display summary of an eem object
#'
#' @param object An object of class \code{eem}.
#' @param ... Extra arguments.
#'
#' @references \url{http://www.sciencedirect.com/science/article/pii/0304420395000623}
#'
#' @export
#' @examples
#' file <- system.file("extdata/cary/eem/", "sample1.csv", package = "eemR")
#' eem <- eem_read(file)
#'
#' summary(eem)

summary.eem <- function(object, ...){

  stopifnot(class(object) == "eem")

  cat("eem object:", dim(object$x)[1],
      "x",  dim(object$x)[2],
      "(", dim(object$x)[1] * dim(object$x)[2], ")", "\n")

  cat("ex: (", range(object$ex), "nm.)", head(object$ex, 3), "...", tail(object$ex, 3), "\n")

  cat("em: (", range(object$em), "nm.)", head(object$em, 3), "...", tail(object$em, 3), "\n")

  cat("is_blank_corrected:", attr(object, "is_blank_corrected"), "\n")

  cat("is_scatter_corrected:", attr(object, "is_scatter_corrected"), "\n")

  cat("is_ife_corrected:", attr(object, "is_ife_corrected"), "\n")

  cat("is_raman_normalized:", attr(object, "is_raman_normalized"), "\n")

  cat("manucafturer:", attr(object, "manucafturer"), "\n")
}


#' Display summary of an eemlist object
#'
#' @param object An object of class \code{eemlist}.
#' @param ... Extra arguments.
#'
#' @export
#' @examples
#' folder <- system.file("extdata/cary/eem/", package = "eemR")
#' eem <- eem_read(folder)
#'
#' summary(eem)
summary.eemlist <- function(object, ...){

  stopifnot(class(object) == "eemlist")

  cat("eemlist object containing:", length(object), "eem\n\n")

  cat("First eem object:\n\n")
  summary.eem(object[[1]])
}


#' Cut emission and/or excitation wavelengths from EEMs
#'
#' @template template_eem
#' @param ex A numeric vector of excitation wavelengths to be removed.
#' @param em A numeric vector of emission wavelengths to be removed.
#'
#' @export
#' @examples
#' # Open the fluorescence eem
#' file <- system.file("extdata/cary/eem/", "sample1.csv", package = "eemR")
#'
#' eem <- eem_read(file)
#' plot(eem)
#'
#' # Cut few excitation wavelengths
#' eem <- eem_cut(eem, ex = c(220, 225, 230, 230))
#' plot(eem)
eem_cut <- function(eem, ex, em){

  stopifnot(class(eem) == "eem" | any(lapply(eem, class) == "eem"))

  ## It is a list of eems, then call lapply
  if(any(lapply(eem, class) == "eem")){

    res <- lapply(eem, eem_cut, ex = ex, em = em)

    class(res) <- class(eem)

    return(res)

  }

  ## Maybe round em and ex wavelengths so it is

  if(!missing(ex)){

    stopifnot(all(ex %in% eem$ex))

    index <- !eem$ex %in% ex

    eem$ex <- eem$ex[index]

    eem$x <- eem$x[, index]

  }

  if(!missing(em)){

    stopifnot(all(em %in% eem$em))

    index <- !eem$em %in% em

    eem$em <- eem$em[index]

    eem$x <- eem$x[index, ]
  }

  return(eem)

}

#' Set Excitation and/or Emission wavelengths
#'
#' This function allows to manully specify either excitation or emission vector
#' of wavelengths in EEMs. This function is mostly used with spectrophotometers
#' such as Shimadzu that do not include excitation wavelengths in fluorescence
#' files.
#'
#' @template template_eem
#' @param ex A numeric vector of excitation wavelengths.
#' @param em A numeric vector of emission wavelengths.
#'
#' @examples
#' folder <- system.file("extdata/shimadzu", package = "eemR")
#'
#' eem <- eem_read(folder)
#' eem <- eem_set_wavelengths(eem, ex = seq(230, 450, by = 5))
#'
#' plot(eem)
#'
#' @export

eem_set_wavelengths <- function(eem, ex, em){

  stopifnot(class(eem) == "eem" | any(lapply(eem, class) == "eem"))

  ## It is a list of eems, then call lapply
  if(any(lapply(eem, class) == "eem")){

    res <- lapply(eem, eem_set_wavelengths, ex = ex, em = em)

    class(res) <- class(eem)

    return(res)

  }

  if(!missing(ex)){

    stopifnot(is.vector(ex),
              is.numeric(ex),
              identical(length(ex), ncol(eem$x)),
              all(ex == cummax(ex))) ## Monotonously increasing

    eem$ex <- ex
  }

  if(!missing(em)){

    stopifnot(is.vector(em),
              is.numeric(em),
              identical(length(em), nrow(eem$x)),
              all(em == cummax(em))) ## Monotonously increasing

    eem$em <- em
  }

  return(eem)

}
