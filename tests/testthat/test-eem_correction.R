test_that("Correction functions do not change the sample names of the eems", {

  folder <- system.file("extdata/cary/scans_day_1", package = "eemR")
  eems <- eem_read(folder, import_function = "cary")

  new_names <- c("nano", "sample_a", "sample_b", "sample_c")
  eem_names(eems) <- new_names

  expect_equal(eem_names(eems), new_names)

  # Check if correction functions do not change the names of the eems
  eems <- eem_remove_scattering(eems, "rayleigh")
  expect_equal(eem_names(eems), new_names)

  eems <- eem_remove_blank(eems)
  expect_equal(eem_names(eems), new_names)

  eems <- eem_raman_normalisation(eems)
  expect_equal(eem_names(eems), new_names)

  data("absorbance")
  names(absorbance) <- c("wavelength", "sample_a", "sample_b", "sample_c")
  suppressWarnings(eems <- eem_inner_filter_effect(eems, absorbance = absorbance, pathlength = 1))
  expect_equal(eem_names(eems), new_names)

})
