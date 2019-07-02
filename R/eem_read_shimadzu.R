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
