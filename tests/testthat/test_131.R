rm(list = ls())
source("131-analysis_with_analysistools.R") |> 
  suppressWarnings()
testthat::test_that("Same results for analysis 131", {
  expected_results_main_weighted <- readRDS("tests/testthat/fixtures/131_results_main_weigthed.RDS")
  testthat::expect_equal(results_main_weigthed, expected_results_main_weighted)
  
  expected_results_loop_weighted <- readRDS("tests/testthat/fixtures/131_results_loop_weigthed.RDS")
  testthat::expect_equal(results_loop_weigthed, expected_results_loop_weighted)
  
  expected_results_main_unweighted <- readRDS("tests/testthat/fixtures/131_results_main_unweigthed.RDS")
  testthat::expect_equal(results_main_unweigthed, expected_results_main_unweighted)
  
})
