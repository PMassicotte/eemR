test_that("EEMs can be exported into Matlab .mat file", {

  file <- system.file("extdata/cary/", package = "eemR")
  eem <- eem_read(file, recursive = TRUE, import_function = "cary")
  export_to <- paste(tempfile(), ".mat", sep = "")

  expect_invisible(eem_export_matlab(export_to, eem))
  expect_true(file.exists(export_to))


})
