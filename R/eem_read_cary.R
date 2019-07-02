# *************************************************************************
# Function reading Cary Eclipse csv files.
# *************************************************************************
eem_read_cary <- function(file) {
  data <- readLines(file)

  min_col <- 15 # Do not expect fluorescence data when there is less than 15 cols.

  data <- stringr::str_split(data, ",")
  data[unlist(lapply(data, length)) < min_col] <- NULL

  ## Find the probable number of columns
  n_col <- unlist(lapply(data, length))
  expected_col <- as.numeric(names(sort(-table(n_col)))[1])

  data[lapply(data, length) != expected_col] <- NULL

  ex <- as.numeric(na.omit(stringr::str_match(data[[1]], stringr::regex("Ex_(\\d+\\.?\\d*)", ignore_case = TRUE))[, 2]))

  data[1:2] <- NULL ## Remove the first 2 header lines

  data <- matrix(as.numeric(unlist(data, use.names = FALSE)),
                 ncol = expected_col, byrow = TRUE
  )

  data <- data[, which(colMeans(is.na(data)) < 1)] ## remove na columns

  eem <- data[, !data[1, ] %in% ex] ## Remove duplicated columns

  em <- data[, 1]

  l <- list(
    file = file,
    x = eem,
    em = em,
    ex = ex
  )

  return(l)
}
