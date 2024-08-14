library(analysistools)
library(dplyr)
library(stringr)
library(srvyr)

# Read results to review, the dataset with indicators
results_to_review <- readRDS("outputs/rawr/an_main.RDS")

main <- read.csv("outputs/rawr/main_with_indicators.csv")
loop <- read.csv("outputs/rawr/loop_with_indicators.csv")

# Checks for duplicated analysis (doubles in loa or label not corrected)
analysis_dup <- results_to_review$analysis_key[duplicated(results_to_review$analysis_key)]
results_to_review %>% filter(analysis_key %in% analysis_dup)

filtered_out <- results_to_review %>%
  filter(duplicated(analysis_key))

# Adds new analysis key following the correct format.
results_to_review <- results_to_review %>%
  filter(!duplicated(analysis_key)) %>%
  # correcting for prop_select_*
  mutate(analysis_key_modif = analysis_key,
         analysis_key_modif = str_replace(analysis_key_modif, "proportion", "prop_select_one"),
         analysis_key_modif = if_else(analysis == "select_multiple",
                                      str_replace(analysis_key_modif, "mean", "prop_select_multiple"),
                                      analysis_key_modif)) %>%
  # correcting for the prop_select_multiple var format
  mutate(analysis_var_key = str_extract(analysis_key_modif, "(?<=@/@) (.*) (?=@/@)"),
         analysis_var_key = str_trim(analysis_var_key),
         new_analysis_var_key = str_remove_all(analysis_var_key, "%/% NA"),
         new_analysis_var_key = str_replace(new_analysis_var_key, "/", " %/% "),
         analysis_key_modif_sm = str_replace(analysis_key_modif, analysis_var_key, new_analysis_var_key)) %>%
  # pick final analysis_key
  mutate(final_analysis_key = if_else(analysis == "select_multiple",
                                      analysis_key_modif_sm,
                                      analysis_key_modif)) %>%
  select(-all_of(c("analysis_var_key", "new_analysis_var_key", "analysis_key_modif", "analysis_key_modif_sm")))

results_to_review$final_analysis_key %>% 
  duplicated() %>% 
  sum()

# Create loa from the results

review_loa <- create_loa_from_results(results_to_review, 
                                      analysis_key_column = "final_analysis_key")

# Create analysis to compare with
design_main_w <- main |>
  as_survey_design(weight = weight)

loa_main<- review_loa |> 
  filter(analysis_var %in% names(main) | analysis_var_numerator %in% names(main))

me_results_main <- create_analysis(design_main_w,
                                   loa_main,
                                   sm_separator =  ".")
binded_analysis <- results_to_review %>%
  full_join(select(me_results_main$results_table %>% filter(!duplicated(analysis_key)),
                   analysis_key,
                   analysis_var, 
                   analysis_var_value,
                   group_var,
                   group_var_value,
                   analysis_type,
                   stat,
                   stat_low,
                   stat_upp,
                   n,
                   n_total,
                   n_w,
                   n_w_total), by = c("final_analysis_key" = "analysis_key"))

# Review the analysis
review_main_analysis <- review_analysis(results_table = binded_analysis,
                                        stat_columns_to_review = "stat.x",
                                        stat_columns_to_compare_with = "stat.y",
                                        analysis_key_column = "final_analysis_key")

review_main_analysis$review_table %>%
  dplyr::group_by(stat) %>%
  dplyr::summarise(proportion_correct = mean(review_check)*100)

review_main_analysis$review_table %>%
  dplyr::group_by(stat, review_comment) %>%
  dplyr::tally(sort = T)

## Different results - likely from ratio
review_main_analysis$results_table %>% 
  filter(review_check_stat.x == FALSE) %>% 
  select(analysis_type, analysis_var, group_var)

review_main_analysis$results_table %>% 
  filter(analysis_type == "ratio", 
         review_check_stat.x == FALSE) %>% 
  group_by(analysis_var, group_var) %>%
  tally() 

review_main_analysis$results_table %>% 
  filter(analysis_type == "ratio", 
         review_check_stat.x == FALSE) %>% 
  select(analysis_var, group_var, group_var_value, stat.x, stat.y)

## Reproducing the analysis manually
shorter_dataset <- me_results_main$dataset %>% 
  select(edu_schooling_age_n,
         edu_disrupted_displaced_n, 
         edu_disrupted_hazards_n,
         edu_disrupted_occupation_n,
         edu_disrupted_teacher_n, 
         weight, admin1, hoh_age_cat, hoh_gender)
shorter_dataset %>% 
  filter(edu_schooling_age_n != 0) %>% 
  mutate(edu_disrupted_teacher_n_w = edu_disrupted_teacher_n*weight, 
         edu_schooling_age_n_w = edu_schooling_age_n * weight)  %>% 
  group_by(admin1) %>%
  summarise(edu_disrupted_teacher_n_w = sum(edu_disrupted_teacher_n_w), 
            edu_schooling_age_n_w= sum(edu_schooling_age_n_w)) %>% 
  mutate(ratio =edu_disrupted_teacher_n_w/ edu_schooling_age_n_w )

## New analysis with a filter_denominator_0 set to FALSE
new_ratio_loa <- me_results_main$loa |>  
  filter(analysis_var_numerator %in% c("edu_disrupted_displaced_n",
                                       "edu_disrupted_hazards_n",
                                       "edu_disrupted_occupation_n",
                                       "edu_disrupted_teacher_n")) |> 
  mutate(filter_denominator_0 = FALSE)

design_main_w <- me_results_main$dataset |>
  as_survey_design(weight = weight)

new_results <- create_analysis(design_main_w,loa = new_ratio_loa)

new_binded_analysis <- results_to_review %>%
  right_join(select(new_results$results_table,
                    analysis_key,
                    analysis_var, 
                    analysis_var_value,
                    group_var,
                    group_var_value,
                    analysis_type,
                    stat,
                    stat_low,
                    stat_upp,
                    n,
                    n_total,
                    n_w,
                    n_w_total), by = c("final_analysis_key" = "analysis_key"))


new_review_main_analysis <- review_analysis(results_table = new_binded_analysis,
                                            stat_columns_to_review = "stat.x",
                                            stat_columns_to_compare_with = "stat.y",
                                            analysis_key_column = "final_analysis_key")
new_review_main_analysis$review_table %>%
  dplyr::group_by(stat) %>%
  dplyr::summarise(proportion_correct = mean(review_check)*100)

## Other possible review problem weighted and un-weighted results are mixed together.
## I am using the weighted analysis from 131-analysis_with_analyistools.R
review_only_weigthed_analysis <- readRDS("outputs/analysistools/results_main_weigthed.RDS")
# 
review3_binded_analysis <- results_to_review |> 
  full_join(select(review_only_weigthed_analysis$results_table,
                   analysis_key,
                   analysis_var,
                   analysis_var_value,
                   group_var,
                   group_var_value,
                   analysis_type,
                   stat,
                   stat_low,
                   stat_upp,
                   n,
                   n_total,
                   n_w,
                   n_w_total), by = c("final_analysis_key" = "analysis_key"))


review3_table <- review_analysis(results_table = review3_binded_analysis,
                                        stat_columns_to_review = "stat.x",
                                        stat_columns_to_compare_with = "stat.y",
                                        analysis_key_column = "final_analysis_key")

review3_table$results_table %>% 
  filter(review_comment_stat.x == "Missing in stat.y") %>% 
  group_by(var) %>%
  tally()
review3_table$results_table %>% 
  filter(var == "resp_age_cat") %>% 
  group_by(weighted) %>% 
  tally()
#missing in .y because it is no-weighted.


