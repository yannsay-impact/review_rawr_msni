library(tidyverse)
library(srvyr)
library(analysistools)

# Read the dataset with indicators and loa

main <- read.csv("outputs/rawr/main_with_indicators.csv")
loop <- read.csv("outputs/rawr/loop_with_indicators.csv")
loa <- read.csv("inputs/analysistools/msni_analysistools_loa.csv")

# Add the grouping variable and weights to the loop

group_vars <- loa$group_var |> na.omit() |> unique()

loop <- loop |>
  left_join(
    main |> select(uuid, weight, all_of(group_vars)),
    by = "uuid"
  )

# LOA should be divided into 3 analysis: 
# - main dataset with weights,
# - main dataset without weights (admin questions)
# - loop dataset with weights

## Analysis main - weighted
design_main_w <- main |>
  as_survey_design(weight = weight)

loa_main_w <- loa |> 
  filter(dataset == "main",
         weighted == "yes")

if (nrow(loa_main_w) > 0) {
  results_main_weigthed <- create_analysis(
    design_main_w,
    loa_main_w,
    sm_separator =  "/")
} else {
  results_main_weigthed <- tibble()
}

results_main_weigthed %>% 
  saveRDS("outputs/analysistools/results_main_weigthed.RDS")

## Main analysis - unweighted
design_main_unw <- main |>
  as_survey_design()

loa_main_unw <- loa |> 
  filter(dataset == "main",
         weighted == "no")

if (nrow(loa_main_unw) > 0) {
  results_main_unweigthed <- create_analysis(
    design_main_unw,
    loa_main_unw,
    sm_separator =  "/")
} else {
  results_main_unweigthed <- tibble()
}

results_main_unweigthed %>% 
  saveRDS("outputs/analysistools/results_main_unweigthed.RDS")

## Loop analysis - weighted
design_loop_w <- loop |>
  as_survey_design(weight = weight)

loa_loop_w <- loa |> 
  filter(dataset == "loop",
         weighted == "yes")

if (nrow(loa_loop_w) > 0) {
  results_loop_weigthed <- create_analysis(
    design_loop_w,
    loa_loop_w,
    sm_separator =  "/")
} else {
  results_loop_weigthed <- tibble()
}

results_loop_weigthed %>% 
  saveRDS("outputs/analysistools/results_loop_weigthed.RDS")

