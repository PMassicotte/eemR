#' Surface plot of eem
#'
#' @param x An object of class \code{eemlist}.
#' @param ... Extra arguments for \code{image.plot}.
#' @importFrom grDevices colorRampPalette
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
#' @importFrom utils head tail
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

print.eem <- function(object, ...){
  summary(object)
}

print.eemlist <- function(object, ...){
  summary(object)
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

  stopifnot(.is_eemlist(eem) | .is_eem(eem))

  ## It is a list of eems, then call lapply
  if(.is_eemlist(eem)){

    res <- lapply(eem, eem_cut, ex = ex, em = em)

    class(res) <- class(eem)

    return(res)

  }

  ## Maybe round em and ex wavelengths

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

  stopifnot(.is_eemlist(eem) | .is_eem(eem))

  ## It is a list of eems, then call lapply
  if(.is_eemlist(eem)){

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

#' Extract EEM samples
#'
#' @template template_eem
#'
#' @param sample Either numeric of character vector. See \code{details} for more
#'   information.
#'
#' @param remove logical. Should EEMs removed (TRUE) or extracted (FALSE).
#'
#' @param ignore_case Logical, should sample name case should be ignored (TRUE)
#'   or not (FALSE). Default is FALSE.
#'
#' @details \code{sample} argument can be either numeric or character vector. If
#'   it is numeric, samples at specified index will be removed.
#'
#'   If \code{sample} is character, regular expression will be used and all
#'   sample names that have a partial or complete match with the expression will
#'   be removed. See \code{examples} for more details.
#'
#' @examples
#' folder <- system.file("extdata/cary/eem", package = "eemR")
#' eems <- eem_read(folder)
#'
#' eem_extract(eems, c(1, 3)) ## Removes samples 1 and 3
#' eem_extract(eems, c(1, 3), remove = TRUE) ## extract samples 1 and 3
#'
#' ## Remove all samples containing "3" in their names.
#' eem_extract(eems, "3")
#'
#' ## Remove all samples containing either character "s" or character "2" in their names.
#' eem_extract(eems, c("s", "2"))
#'
#' ## Remove all samples containing "blank" or "nano"
#' eem_extract(eems, c("blank", "nano"))
#'
#' ## Remove all samples starting with "no"
#' eem_extract(eems, "^no")
#'
#' @export
eem_extract <- function(eem, sample, remove = FALSE, ignore_case = FALSE) {

  stopifnot(class(eem) == "eemlist",
            is.character(sample) | is.numeric(sample))

  sample_names <- unlist(lapply(eem, function(x){x$sample}))

  ## Sample number
  if(is.numeric(sample)){

    stopifnot(all(is_between(sample, 1, length(eem))))

    eem[ifelse(remove, -sample, sample)] <- NULL

    cat(ifelse(remove, "Removed sample(s):", "Extracted sample(s):"),
        sample_names[sample], "\n")

  }

  ## Regular expression
  if(is.character(sample)){

    index <- grepl(paste(sample, collapse = "|"),
                   sample_names,
                   ignore.case = ignore_case)

    eem[xor(index, !remove)] <- NULL

    if(all(index == FALSE)){
      cat("Nothing to remove.")
    }
    else{
      cat(ifelse(remove, "Removed sample(s):", "Extracted sample(s):"),
          sample_names[index], "\n")
    }
  }

  return(eem)
}


#' The names of an eem or eemlist objects
#'
#' @template template_eem
#'
#' @return A character vector containing the names of the EEMs.
#'
#' @examples
#' file <- system.file("extdata/cary/eem", "sample1.csv", package = "eemR")
#' eem <- eem_read(file)
#'
#' eem_sample_names(eem)
#'
#' @export
eem_sample_names <- function(eem){

  stopifnot(.is_eemlist(eem) | .is_eem(eem))

  ## It is a list of eems, then call lapply
  if(.is_eemlist(eem)){

    res <- unlist(lapply(eem, eem_sample_names))

    return(res)

  }

  return(eem$sample)
}


#' Set the sample names of an eem or eemlist objects
#'
#' @param x An object of class \code{eem} or \code{eemlist}.
#' @param value A character vector with new sample names. Must be equal
#'   in length to the number of samples in the \code{eem} or \code{eemlist}.
#'
#' @return An \code{eem} or \code{eemlist}.
#'
#' @examples
#' folder <- system.file("extdata/cary/eem", package = "eemR")
#' eems <- eem_read(folder)
#'
#' eem_sample_names(eems)
#' eem_sample_names(eems) <- c("a", "b", "c")
#' eem_sample_names(eems)
#'
#' @export
`eem_sample_names<-` <- function(x, value){


  stopifnot(.is_eemlist(x) | .is_eem(x))

  if(.is_eemlist(x)){

    stopifnot(length(x) == length(value))

    res <- Map(`eem_sample_names<-`, x[], value)

    class(res) <- "eemlist"
    return(res)
  }

  stopifnot(length(value) == 1)

  x$sample = value

  class(x) <- "eem"
  return(x)

}

#' Bind eem or eemlist
#'
#' Function to bind EEMs that have been loaded from different folders or have
#' been processed differently.
#'
#' @param ... One or more object of class \code{eemlist}.
#'
#' @return An object of \code{eemlist}.
#' @export
#'
#' @examples
#' file <- system.file("extdata/cary/eem/", "sample1.csv", package = "eemR")
#' eem <- eem_read(file)
#'
#' eem <- eem_bind(eem, eem)
eem_bind <- function(...){

  eem <- list(...)

  list_classes <- unlist(lapply(eem, function(x) {class(x)}))

  stopifnot(all(list_classes %in% c("eem", "eemlist")))

  eem <- lapply(eem, my_unlist)
  eem <- unlist(eem, recursive = FALSE)

  class(eem) <- "eemlist"

  return(eem)

}

my_unlist <- function(x){

  if(class(x) == "eem"){

    x <- list(x)

    class(x) <- "eemlist"

    return(x)

  }else {

    return(x)

  }
}

.is_eemlist <- function(eem) {
  ifelse(class(eem) == "eemlist", TRUE, FALSE)
}

.is_eem <- function(eem) {
  ifelse(class(eem) == "eem", TRUE, FALSE)
}
