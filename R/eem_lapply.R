eem_lapply <- function(list, fun, ...) {

  res <- lapply(list, fun, ...)
  class(res) <- "eemlist"

  return(res)
}
