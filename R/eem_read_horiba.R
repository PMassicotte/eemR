# *************************************************************************
# Function reading exported Horiba csv files.
# *************************************************************************
eem_read_horiba <- function(file) {
  data <- read.csv(file,
                   stringsAsFactors = FALSE,
                   check.names = FALSE)

  em <- data[["Wavelength"]]
  ex <- as.numeric(names(data)[-1])

  x <- as.matrix(data[,-c(1)])
  colnames(x) <- NULL

  # Excitation wavelengths decrease so ex and x have to be reversed
  ex <- rev(ex)
  x <- x[, ncol(x):1]

  l <- list(file = file,
            em = em,
            ex = ex,
            x = x)

  return(l)
}
