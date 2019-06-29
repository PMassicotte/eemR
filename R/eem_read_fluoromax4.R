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
