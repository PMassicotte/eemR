#' @importFrom graphics par plot text filled.contour title
#' @importFrom viridis viridis
.plot_eem <- function(x, show_peaks, ...) {
  filled.contour(
    y = x$em,
    x = x$ex,
    z = t(x$x),
    plot.title = title(
      main = paste(x$sample, "\n", attr(x, "manucafturer"), sep = ""),
      xlab = "Excitation (nm.)",
      ylab = "Emission (nm.)"
    ),
    key.title = title("Fluorescence\nintensity"),
    color.palette = viridis::viridis,
    nlevels = 7,
    ...
  )

  if (show_peaks) {
    coble_ex_peak <- list(b = 275, t = 275, a = 260, m = 312, c = 350)
    coble_em_peak <- list(b = 310, t = 340, a = 420, m = 400, c = 450)

    text(coble_ex_peak$b, coble_em_peak$b, "B", font = 2, cex = 1)
    text(coble_ex_peak$t, coble_em_peak$t, "T", font = 2, cex = 1)
    text(coble_ex_peak$a, coble_em_peak$a, "A", font = 2, cex = 1)
    text(coble_ex_peak$m, coble_em_peak$m, "M", font = 2, cex = 1)
    text(coble_ex_peak$c, coble_em_peak$c, "C", font = 2, cex = 1)
  }
}

#' Surface plot of eem
#'
#' @param x An object of class \code{eemlist}.
#' @param which An integer representing the index of eem to be plotted.
#' @param ... Extra arguments for \code{image.plot}.
#' @param show_peaks Boolean indicating if Cobble's peaks should be displayed on
#'   the surface plot. Default is FALSE.
#' @param interactive If \code{TRUE} a Shiny app will start to visualize EEMS.
#'
#' @export
#' @examples
#' folder <- system.file("extdata/cary/scans_day_1/", package = "eemR")
#' eem <- eem_read(folder, import_function = "cary")
#'
#' plot(eem, which = 3)
plot.eemlist <- function(
  x,
  which = 1,
  interactive = FALSE,
  show_peaks = FALSE,
  ...
) {
  stopifnot(which <= length(x))

  if (interactive) {
    .plot_shiny(x)
  } else {
    .plot_eem(x[[which]], show_peaks, ...)
  }
}

eem_as_summary <- function(object) {
  df <- data.frame(
    sample = object$sample,
    ex_min = min(object$ex),
    ex_max = max(object$ex),
    em_min = min(object$em),
    em_max = max(object$em),
    is_blank_corrected = attr(object, "is_blank_corrected"),
    is_scatter_corrected = attr(object, "is_scatter_corrected"),
    is_ife_corrected = attr(object, "is_ife_corrected"),
    is_raman_normalized = attr(object, "is_raman_normalized")
  )

  return(df)
}

#' Display summary of an eemlist object
#'
#' @param x An object of class \code{eemlist}.
#' @param ... Extra arguments.
#' @template template_summary
#'
#' @export
#' @examples
#' folder <- system.file("extdata/cary", package = "eemR")
#' eem <- eem_read(folder, recursive = TRUE, import_function = "cary")
#'
#' print(eem)
print.eemlist <- function(x, ...) {
  stopifnot(inherits(x, "eemlist"))

  df <- lapply(x, eem_as_summary)
  df <- do.call(rbind, df)

  print(df)

  invisible(df)
}

#' Display summary of an eemlist object
#'
#' @param object An object of class \code{eemlist}.
#' @param ... Extra arguments.
#' @template template_summary
#' @export
#' @examples
#' folder <- system.file("extdata/cary", package = "eemR")
#' eem <- eem_read(folder, recursive = TRUE, import_function = "cary")
#'
#' summary(eem)
summary.eemlist <- function(object, ...) {
  stopifnot(inherits(object, "eemlist"))

  df <- lapply(object, eem_as_summary)
  df <- do.call(rbind, df)

  print(df)

  invisible(df)
}


#' Cut emission and/or excitation wavelengths from EEMs
#'
#' @template template_eem
#' @param ex A numeric vector of excitation wavelengths to be removed.
#' @param em A numeric vector of emission wavelengths to be removed.
#' @param exact Logical. If TRUE, only wavelengths matching \code{em} and/or
#'   \code{ex} will be removed. If FALSE, all wavelengths in the range of
#'   \code{em} and/or \code{ex} will be removed.
#' @param fill_with_na Logical. If TRUE, fluorescence values at specified
#'   wavelengths will be replaced with NA. If FALSE, these values will be
#'   removed.
#' @export
#' @examples
#' # Open the fluorescence eem
#' file <- system.file("extdata/cary/scans_day_1/", "sample1.csv", package = "eemR")
#'
#' eem <- eem_read(file, import_function = "cary")
#' plot(eem)
#'
#' # Cut few excitation wavelengths
#' eem <- eem_cut(eem, ex = c(220, 225, 230, 230))
#' plot(eem)
#'
#' eem <- eem_read(file, import_function = "cary")
#' eem <- eem_cut(eem, em = 350:400, fill_with_na = TRUE)
#' plot(eem)
eem_cut <- function(eem, ex, em, exact = TRUE, fill_with_na = FALSE) {
  stopifnot(
    .is_eemlist(eem) | .is_eem(eem)
  )

  ## It is a list of eems, then call lapply
  if (.is_eemlist(eem)) {
    res <-
      lapply(
        eem,
        eem_cut,
        ex = ex,
        em = em,
        exact = exact,
        fill_with_na = fill_with_na
      )

    class(res) <- class(eem)

    return(res)
  }

  ## Maybe round em and ex wavelengths

  if (!missing(ex)) {
    stopifnot(
      is.numeric(ex),
      all(ex >= 0)
    )

    if (exact) {
      index <- which(eem$ex %in% ex)
    } else {
      index <- which(is_between(
        eem$ex,
        min(ex, na.rm = TRUE),
        max(ex, na.rm = TRUE)
      ))
    }

    if (length(index != 0)) {
      if (fill_with_na) {
        # eem$ex[index] <- NA
        eem$x[, index] <- NA
      } else {
        eem$ex <- eem$ex[-index]
        eem$x <- eem$x[, -index]
      }
    }
  }

  if (!missing(em)) {
    stopifnot(
      is.numeric(em),
      all(em >= 0)
    )

    if (exact) {
      index <- which(eem$em %in% em)
    } else {
      index <- which(is_between(
        eem$em,
        min(em, na.rm = TRUE),
        max(em, na.rm = TRUE)
      ))
    }

    if (length(index != 0)) {
      if (fill_with_na) {
        # eem$em[index] <- NA
        eem$x[index, ] <- NA
      } else {
        eem$em <- eem$em[-index]
        eem$x <- eem$x[-index, ]
      }
    }
  }

  return(eem)
}

#' Set Excitation and/or Emission wavelengths
#'
#' This function allows to manually specify either excitation or emission vector
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
#' eem <- eem_read(folder, import_function = "shimadzu")
#' eem <- eem_set_wavelengths(eem, ex = seq(230, 450, by = 5))
#'
#' plot(eem)
#' @export

eem_set_wavelengths <- function(eem, ex, em) {
  stopifnot(.is_eemlist(eem) | .is_eem(eem))

  ## It is a list of eems, then call lapply
  if (.is_eemlist(eem)) {
    res <- lapply(eem, eem_set_wavelengths, ex = ex, em = em)

    class(res) <- class(eem)

    return(res)
  }

  if (!missing(ex)) {
    stopifnot(
      is.vector(ex),
      is.numeric(ex),
      identical(length(ex), ncol(eem$x)),
      all(ex == cummax(ex))
    ) ## Monotonously increasing

    eem$ex <- ex
  }

  if (!missing(em)) {
    stopifnot(
      is.vector(em),
      is.numeric(em),
      identical(length(em), nrow(eem$x)),
      all(em == cummax(em))
    ) ## Monotonously increasing

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
#' @param keep logical. If TRUE, the specified \code{sample} will be returned.
#'   If FALSE, they will be removed.
#'
#' @param ignore_case Logical, should sample name case should be ignored (TRUE)
#'   or not (FALSE). Default is FALSE.
#'
#' @param verbose Logical determining if removed/extracted eems should be
#'   printed on screen.
#'
#' @details \code{sample} argument can be either numeric or character vector. If
#'   it is numeric, samples at specified index will be removed.
#'
#'   If \code{sample} is character, regular expression will be used and all
#'   sample names that have a partial or complete match with the expression will
#'   be removed. See \code{examples} for more details.
#'
#' @examples
#' folder <- system.file("extdata/cary/scans_day_1", package = "eemR")
#' eems <- eem_read(folder, import_function = "cary")
#'
#' eems
#'
#' # Remove first and third samples
#' eem_extract(eems, c(1, 3))
#'
#' # Remove everything except first and third samples
#' eem_extract(eems, c(1, 3), keep = TRUE)
#'
#' # Remove all samples containing "3" in their names.
#' eem_extract(eems, "3")
#'
#' # Remove all samples containing either character "s" or character "2" in their names.
#' eem_extract(eems, c("s", "2"))
#'
#' # Remove all samples containing "blank" or "nano"
#' eem_extract(eems, c("blank", "nano"))
#' @export
eem_extract <- function(
  eem,
  sample,
  keep = FALSE,
  ignore_case = FALSE,
  verbose = TRUE
) {
  stopifnot(inherits(eem, "eemlist"), is.character(sample) | is.numeric(sample))

  sample_names <- unlist(lapply(eem, function(x) {
    x$sample
  }))

  ## Sample number
  if (is.numeric(sample)) {
    stopifnot(all(is_between(sample, 1, length(eem))))

    to_remove <- ifelse(
      rep(keep, length(sample)),
      setdiff(1:length(eem), sample),
      sample
    )

    eem[to_remove] <- NULL

    if (verbose) {
      cat(
        ifelse(keep, "Extracted sample(s):", "Removed sample(s):"),
        sample_names[sample],
        "\n"
      )
    }
  }

  ## Regular expression
  if (is.character(sample)) {
    to_remove <- grepl(
      paste(sample, collapse = "|"),
      sample_names,
      ignore.case = ignore_case
    )

    eem[xor(to_remove, keep)] <- NULL

    if (verbose) {
      if (all(to_remove == FALSE)) {
        cat("Nothing to remove.")
      } else {
        cat(
          ifelse(keep, "Extracted sample(s):", "Removed sample(s):"),
          sample_names[to_remove],
          "\n"
        )
      }
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
#' file <- system.file("extdata/cary/", package = "eemR")
#' eem <- eem_read(file, recursive = TRUE, import_function = "cary")
#'
#' eem_names(eem)
#' @export
eem_names <- function(eem) {
  stopifnot(.is_eemlist(eem) | .is_eem(eem))

  ## It is a list of eems, then call lapply
  if (.is_eemlist(eem)) {
    res <- unlist(lapply(eem, eem_names))

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
#' folder <- system.file("extdata/cary/scans_day_1", package = "eemR")
#' eems <- eem_read(folder, import_function = "cary")
#'
#' eem_names(eems)
#' eem_names(eems) <- c("a", "b", "c", "d")
#' eem_names(eems)
#' @export
`eem_names<-` <- function(x, value) {
  stopifnot(.is_eemlist(x) | .is_eem(x))

  if (.is_eemlist(x)) {
    stopifnot(length(x) == length(value))

    res <- Map(`eem_names<-`, x[], value)

    class(res) <- "eemlist"
    return(res)
  }

  stopifnot(length(value) == 1)

  x$sample <- value

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
#' file <- system.file("extdata/cary/scans_day_1/", "sample1.csv", package = "eemR")
#' eem <- eem_read(file, import_function = "cary")
#'
#' eem <- eem_bind(eem, eem)
eem_bind <- function(...) {
  eem <- c(...)

  list_classes <- unlist(lapply(eem, function(x) {
    class(x)
  }))

  stopifnot(all(list_classes %in% c("eem", "eemlist")))

  eem <- lapply(eem, my_unlist)
  eem <- unlist(eem, recursive = FALSE)

  class(eem) <- "eemlist"

  return(eem)
}

my_unlist <- function(x) {
  if (inherits(x, "eem")) {
    x <- list(x)

    class(x) <- "eemlist"

    return(x)
  } else {
    return(x)
  }
}

.is_eemlist <- function(eem) {
  inherits(eem, "eemlist")
}

.is_eem <- function(eem) {
  inherits(eem, "eem")
}

.plot_shiny <- function(eem) {
  metrics <- dplyr::left_join(
    eem_coble_peaks(eem, verbose = FALSE),
    eem_biological_index(eem, verbose = FALSE),
    by = "sample"
  )

  metrics <- dplyr::left_join(
    metrics,
    eem_fluorescence_index(eem, verbose = FALSE),
    by = "sample"
  )

  metrics <- dplyr::left_join(
    metrics,
    eem_humification_index(eem, verbose = FALSE),
    by = "sample"
  )

  metrics[, -1] <- round(metrics[, -1], digits = 2)

  # nl <- vector(mode = "list", length = length(eem_names(eem)))
  # names(nl) <- eem_names(eem)
  # nl[1:length(nl)] <- 1:length(nl)

  ui <- shiny::fluidPage(
    shiny::titlePanel("EEM interactive visualization"),

    shiny::sidebarLayout(
      shiny::sidebarPanel(
        shiny::checkboxInput("scale", label = "Keep z-axis fixed?", FALSE),
        shiny::hr(),
        shiny::checkboxInput("by", "Combined 2x2 plots", FALSE),
        shiny::hr(),
        shiny::sliderInput(
          "ex_cut",
          "Select excitation range",
          min = min(eem[[1]]$ex),
          max = max(eem[[1]]$ex),
          value = c(min(eem[[1]]$ex), max(eem[[1]]$ex)),
          step = 1
        ),
        shiny::hr(),
        shiny::sliderInput(
          "em_cut",
          "Select emission range",
          min = min(eem[[1]]$em),
          max = max(eem[[1]]$em),
          value = c(min(eem[[1]]$em), max(eem[[1]]$em)),
          step = 1
        )
      ),

      shiny::mainPanel(shiny::plotOutput(
        outputId = "myeem",
        width = "550px",
        height = "550px"
      ))
    ),

    shiny::br(),

    DT::dataTableOutput("eem_list"),

    shiny::br()
  )

  server <- function(input, output) {
    output$myeem <- shiny::renderPlot({
      if (input$scale) {
        zlim <- range(unlist(lapply(eem, function(x) x$x)), na.rm = TRUE)
      } else {
        zlim <- range(eem[[input$eem_list_rows_selected]]$x, na.rm = TRUE)
      }

      if (!is.null(input$eem_list_rows_selected)) {
        n <- ifelse(input$by, 2, 1)

        par(mfrow = c(n, n))

        plot(
          eem,
          which = input$eem_list_rows_selected,
          xlim = c(input$ex_cut[1], input$ex_cut[2]),
          ylim = c(input$em_cut[1], input$em_cut[2]),
          zlim = zlim
        )
      }
    })

    output$eem_list <- DT::renderDataTable(
      metrics,
      server = FALSE,
      selection = "single",
      # selection = list(mode = 'single', target = "row", selected = c(1)),
      options = list(
        autoWidth = TRUE,
        columnDefs = list(list(width = "10px", targets = "_all"))
      )
    )
  }

  shiny::shinyApp(ui, server)
}


#' Extract blank EEM
#'
#' @template template_eem
#' @param average Logical. If TRUE blank EEMs will be averaged
eem_extract_blank <- function(eem, average = TRUE) {
  blank_names <- c("nano", "miliq", "milliq", "mq", "blank")

  blank <- eem_extract(
    eem,
    blank_names,
    keep = TRUE,
    ignore_case = TRUE,
    verbose = FALSE
  )

  # Average all the blank EEMs
  if (average) {
    n <- length(blank)

    message("A total of ", n, " blank EEMs will be averaged.")

    X <- Reduce("+", lapply(blank, function(x) x$x))
    X <- X / n

    blank <- blank[1]
    blank[[1]]$x <- X

    class(blank) <- "eemlist"
  }

  return(blank)
}
