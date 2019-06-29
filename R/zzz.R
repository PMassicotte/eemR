is_between <- function(x, a, b) {
  x >= a & x <= b
}

# Return TRUE if eem is a blank sample

is_blank <- function(eem) {
  blank_names <- paste("nano", "miliq", "milliq", "mq", "blank", sep = "|")

  grepl(blank_names, eem$sample, ignore.case = TRUE)
}
