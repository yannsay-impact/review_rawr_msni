rm(list = ls())
source("132-analysis_review.R") |> 
  suppressWarnings()

testthat::test_that("Same results for review 132", {
  
  expected_review_main_analysis <- readRDS("tests/testthat/fixtures/132_review_main_analysis.RDS")
  testthat::expect_equal(review_main_analysis, expected_review_main_analysis)
  
  expected_new_review_main_analysis <- readRDS("tests/testthat/fixtures/132_new_review_main_analysis.RDS")
  testthat::expect_equal(new_review_main_analysis, expected_new_review_main_analysis)
  
  expected_review3_table <- readRDS("tests/testthat/fixtures/132_review3_table.RDS")
  testthat::expect_equal(review3_table, expected_review3_table)
  
})
