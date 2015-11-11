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

  fields::image.plot(y = x$em,
             x = x$ex,
             z = t(x$x),
             main = paste(x$sample, "\n", attr(x, "manucafturer"), sep = ""),
             xlab = "Excitation (nm.)",
             ylab = "Emission (nm.)")
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

