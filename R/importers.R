# *************************************************************************
# Function reading Shimadzu .TXT files.
# *************************************************************************
eem_read_shimadzu <- function(file) {
  data <- readLines(file)

  data <- stringr::str_split(data, "\t")

  data <- lapply(data, as.numeric)

  data <- do.call(rbind, data)

  min_em <- min(data[, 1])
  max_em <- max(data[, 1])

  interval <- data[2, 1] - data[1, 1]

  em <- seq(min_em, max_em, by = interval)

  data <- data[, 2]

  eem <- matrix(data, nrow = length(em), byrow = FALSE)

  l <- list(
    file = file,
    x = eem,
    em = em,
    ex = NA
  )

  return(l)
}

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

# *************************************************************************
# Fonction reading Aqualog dat files.
# *************************************************************************
eem_read_aqualog <- function(file) {
  data <- readLines(file)

  eem <- stringr::str_extract_all(data, "-?\\d+(?:\\.\\d*)?(?:[eE][+\\-]?\\d+)?")

  ex <- sort(as.numeric(eem[[1]]))

  n_col <- lapply(eem, length)
  n_col <- unlist(n_col)
  expected_col <- as.numeric(names(sort(-table(n_col)))[1])

  eem[n_col != expected_col] <- NULL
  eem <- lapply(eem, as.numeric)
  eem <- do.call(rbind, eem)

  em <- eem[, 1]
  eem <- eem[, -1]
  eem <- as.matrix(eem[, ncol(eem):1])

  l <- list(
    file = file,
    x = eem,
    em = em,
    ex = ex
  )

  return(l)
}

# *************************************************************************
# Fonction reading Fluoromax-4 dat files.
# *************************************************************************
eem_read_fluoromax4 <- function(file) {
  data <- readLines(file)

  data <- stringr::str_split(data, "\t")

  ## Find the probable number of columns
  n_col <- unlist(lapply(data, length))
  expected_col <- as.numeric(names(sort(-table(n_col)))[1])
  data[lapply(data, length) != expected_col] <- NULL

  data <- suppressWarnings(matrix(as.numeric(unlist(data, use.names = FALSE)), ncol = expected_col, byrow = TRUE))

  ex <- as.vector(na.omit(data[1, ]))
  em <- as.vector(na.omit(data[, 1]))
  eem <- data[2:nrow(data), 2:ncol(data)]

  l <- list(
    file = file,
    x = eem,
    em = em,
    ex = ex
  )

  return(l)
}
