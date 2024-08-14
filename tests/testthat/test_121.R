# integration 121
rm(list = ls())
testthat::test_that("Same results for review 121", {
  source("121-review_with_humind_composition.R") |> 
    suppressWarnings()
  
  expected_to_display <- readRDS("tests/testthat/fixtures/121_to_display.rds")
  testthat::expect_equal(to_display, expected_to_display)
})


