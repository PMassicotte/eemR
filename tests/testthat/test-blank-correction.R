context("blank-correction")

test_that("grouped blank correction works", {

  file <- system.file("extdata/cary/scans_day_1/", package = "eemR")
  eems <- eem_read(file)

  eems <- eem_remove_blank(eems)

  mysum <- sum(eem_extract(eems, "sample1", keep = TRUE)[[1]]$x)
  mymean <- mean(eem_extract(eems, "sample1", keep = TRUE)[[1]]$x)

  # These values have been calculated by "hand" in Excel.
  expect_equal(mysum, 14020.78844, tolerance = 0.00001)
  expect_equal(mymean, 1.6038, tolerance = 0.0001)

})


test_that("single blank correction works", {

  file <- system.file("extdata/cary/scans_day_1/sample1.csv", package = "eemR")
  eems <- eem_read(file)

  file <- system.file("extdata/cary/scans_day_1/nano.csv", package = "eemR")
  blank <- eem_read(file)

  eems <- eem_remove_blank(eems, blank)

  mysum <- sum(eem_extract(eems, "sample1", keep = TRUE)[[1]]$x)
  mymean <- mean(eem_extract(eems, "sample1", keep = TRUE)[[1]]$x)

  # These values have been calculated by "hand" in Excel.
  expect_equal(mysum, 14020.78844, tolerance = 0.00001)
  expect_equal(mymean, 1.6038, tolerance = 0.0001)

})
