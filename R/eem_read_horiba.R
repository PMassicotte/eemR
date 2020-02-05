# *************************************************************************
# Function reading exported Horiba csv files.
# *************************************************************************
eem_read_horiba <- function(file) {
  data <- read.csv(file,
                   stringsAsFactors = FALSE,
                   check.names = FALSE)

  # There a number of export options available for the Horiba CSVs. I haven't
  # tested them all, but this check should provide some protection if a csv
  # with different options (eg include comments) is exported rather than a csv
  # with only the wavelengths and fluorescence intensities

  if(tolower(names(data)[[1]]) != "wavelength"){
    # Find row and column of fluorescence matrix
    start_coords <-
      which(tolower(as.matrix(data)) == "wavelength", arr.ind = TRUE)[1, ]

    # Read in skipping rows above matrix
    data <-
      read.csv(file,
               skip = start_coords[1],
               stringsAsFactors = FALSE,
               check.names = FALSE)

    # Remove columns before matrix
    data <-
      data[, -c(1:(start_coords[2] - 1))]
  }

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
