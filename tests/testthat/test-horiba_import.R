test_that("Standard Horiba EEMs can be imported", {

  file <- system.file("extdata/horiba/horiba_sample.csv", package = "eemR")
  eem <- eem_read(file, import_function = "horiba")

  expect_s3_class(eem, "eemlist")
})


test_that("Non-standard Horiba EEMs can be imported", {

  file <- system.file("extdata/horiba/horiba_non-standard_sample.csv", package = "eemR")
  eem <- eem_read(file, import_function = "horiba")

  expect_s3_class(eem, "eemlist")
})

test_that("Standard & Non-standard Horiba EEMs are identical", {

  standard_file <- system.file("extdata/horiba/horiba_sample.csv", package = "eemR")
  non_standard_file <- system.file("extdata/horiba/horiba_non-standard_sample.csv", package = "eemR")

  standard_eem <- eem_read(standard_file, import_function = "horiba")
  non_standard_eem <- eem_read(non_standard_file, import_function = "horiba")

  # Set names & files equal for tests because they won't be identical
  eem_names(non_standard_eem) <- eem_names(standard_eem)
  non_standard_eem[[1]][["file"]] <- standard_eem[[1]][["file"]]

  expect_identical(non_standard_eem, standard_eem)
})
