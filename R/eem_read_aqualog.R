# *************************************************************************
# Fonction reading Aqualog dat files.
# *************************************************************************
eem_read_aqualog <- function(file) {
  data <- readLines(file)

  eem <- stringr::str_extract_all(
    data,
    "-?\\d+(?:\\.\\d*)?(?:[eE][+\\-]?\\d+)?"
  )

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
