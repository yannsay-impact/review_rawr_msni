rm(list = ls())

testthat::test_that("Same results for review 122", {
  source("122-review_without_humind_composition.R") |> 
    suppressWarnings()
  
  expected_res <- readRDS("tests/testthat/fixtures/122_res.rds")
  testthat::expect_equal(res, expected_res)
})