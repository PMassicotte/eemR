#' @export
runExample <- function() {
  appDir <- system.file("shiny-examples", "myapp", package = "eemR")
  if (appDir == "") {
    stop("Could not find example directory. Try re-installing `eemR`.", call. = FALSE)
  }

  shiny::runApp(appDir, display.mode = "normal")
}
