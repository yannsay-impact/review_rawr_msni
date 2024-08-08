# read results, read dataset
# modify the results key to match correct format
# review analysis with dataset as input.



# 
# library(analysistools)
# library(dplyr)
# library(stringr)
# #review
# analysis <- readRDS("outputs/rawr/an_main_w.RDS")
# 
# analysis_dup <- analysis$analysis_key[duplicated(analysis$analysis_key)]
# # analysis %>% filter(analysis_key %in% analysis_dup) %>% View()
# filtered_out <- analysis %>% 
#   filter(str_detect(analysis_key, "hoh_age_cat"), 
#          duplicated(analysis_key))
# 
# analysis_modif <- analysis %>% 
#   filter(str_detect(analysis_key, "hoh_age_cat", T), 
#          !duplicated(analysis_key)) %>%
#   # correcting for prop_select_*
#   mutate(analysis_key_modif = analysis_key,
#          analysis_key_modif = str_replace(analysis_key_modif, "proportion", "prop_select_one"),
#          analysis_key_modif = if_else(analysis == "select_multiple",
#                                       str_replace(analysis_key_modif, "mean", "prop_select_multiple"),
#                                       analysis_key_modif)) %>% 
#   # correcting for the prop_select_multiple var format
#   mutate(analysis_var_key = str_extract(analysis_key_modif, "(?<=@/@) (.*) (?=@/@)"),
#          analysis_var_key = str_trim(analysis_var_key),
#          new_analysis_var_key = str_remove_all(analysis_var_key, "%/% NA"),
#          new_analysis_var_key = str_replace(new_analysis_var_key, "/", " %/% "),
#          analysis_key_modif_sm = str_replace(analysis_key_modif, analysis_var_key, new_analysis_var_key)) %>%
#   # pick final analysis_key
#   mutate(final_analysis_key = if_else(analysis == "select_multiple",
#                                       analysis_key_modif_sm,
#                                       analysis_key_modif)) %>%
#   select(-all_of(c("analysis_var_key", "new_analysis_var_key", "analysis_key_modif", "analysis_key_modif_sm")))
# 
# analysis_modif$final_analysis_key %>% duplicated() %>% sum()
# 
# me_analysis <- readRDS("outputs/me/me_an_main_w.RDS")
# 
# binded_analysis <- analysis_modif %>% 
#   full_join(select(me_analysis$results_table, 
#                    analysis_key, 
#                    stat,
#                    stat_low,
#                    stat_upp, 
#                    n, 
#                    n_total,
#                    n_w,
#                    n_w_total), by = c("final_analysis_key" = "analysis_key"))
# 
# 
# #
# 
# review_main_analysis <- review_analysis(results_table = binded_analysis, 
#                                         stat_columns_to_review = "stat.x",
#                                         stat_columns_to_compare_with = "stat.y",
#                                         analysis_key_column = "final_analysis_key")
# 
# review_main_analysis$review_table %>%
#   dplyr::group_by(stat) %>%
#   dplyr::summarise(proportion_correct = mean(review_check)*100)
# review_main_analysis$review_table %>%
#   dplyr::group_by(stat, review_comment) %>%
#   dplyr::tally(sort = T)
# review_main_analysis$review_table %>%
#   dplyr::filter(!review_check) %>%
#   dplyr::select(review_check, analysis_type,analysis_var,group_var) %>% 
#   dplyr::distinct()
