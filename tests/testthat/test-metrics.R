context("metrics")

file <- system.file("extdata/cary/scans_day_1/sample1.csv", package = "eemR")
eems <- eem_read(file)

test_that("Cobble's peaks", {

  metrics <- eem_coble_peaks(eems, verbose = FALSE)

  b <- 1.5452981
  t <- 1.060331225
  a <- 3.731835842 # approximative value since some wl do not exist
  m <- 2.443755269 # approximative value since some wl do not exist
  c <- 1.815422177 # approximative value since some wl do not exist

  expect_equal(b, metrics$b)
  expect_equal(t, metrics$t)
  expect_equal(a, metrics$a)
  expect_equal(m, metrics$m, tolerance = 0.01)
  expect_equal(c, metrics$c, tolerance = 0.001)

})
