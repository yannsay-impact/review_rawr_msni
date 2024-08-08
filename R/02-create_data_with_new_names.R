remaned_vector <- c(
  health_score = "comp_health_score",
  prot_score = "comp_prot_score",
  dimension_prot_child_sep_cat = "comp_prot_child_sep_cat",
  dimension_prot_score_concern = "comp_prot_score_concern",
  edu_score = "comp_edu_score",
  dimension_edu_score_disrupted = "comp_edu_score_disrupted",
  dimension_edu_score_attendance = "comp_edu_score_attendance",
  foodsec_score = "comp_foodsec_score",
  dimension_wash_score_water_quantity = "comp_wash_score_water_quantity",
  dimension_wash_score_water_quality = "comp_wash_score_water_quality",
  dimension_wash_score_sanitation = "comp_wash_score_sanitation",
  dimension_wash_score_hygiene = "comp_wash_score_hygiene",
  snfi_score = "comp_snfi_score",
  dimension_snfi_score_shelter_type_cat = "comp_snfi_score_shelter_type_cat",
  dimension_snfi_score_shelter_issue_cat = "comp_snfi_score_shelter_issue_cat",
  dimension_snfi_score_occupancy_cat = "comp_snfi_score_occupancy_cat",
  dimension_snfi_score_fds_cannot_cat = "comp_snfi_score_fds_cannot_cat",
  health_in_need = "comp_health_in_need",
  prot_in_need = "comp_prot_in_need",
  edu_in_need = "comp_edu_in_need",
  foodsec_in_need = "comp_foodsec_in_need",
  wash_in_need = "comp_wash_in_need",
  snfi_in_need = "comp_snfi_in_need",
  health_in_acute_need = "comp_health_in_acute_need",
  prot_in_acute_need = "comp_prot_in_acute_need",
  edu_in_acute_need = "comp_edu_in_acute_need",
  foodsec_in_acute_need = "comp_foodsec_in_acute_need",
  wash_in_acute_need = "comp_wash_in_acute_need",
  snfi_in_acute_need = "comp_snfi_in_acute_need",
  msni_score = "msni_score",
  msni_in_need = "msni_in_need",
  msni_in_acute_need = "msni_in_acute_need",
  count_sectors_in_need = "sector_in_need_n",
  sector_needs_profile = "sector_needs_profile")

main_with_indicators <- read.csv("outputs/rawr/main_with_indicators.csv")
main_with_indicators %>% 
  rename(all_of(remaned_vector)) %>%
  write.csv("outputs/rawr/main_with_new_names.csv")

main_with_errors <- read.csv("outputs/rawr/main_with_errors.csv")
main_with_errors %>% 
  rename(all_of(remaned_vector)) %>%
  write.csv("outputs/rawr/main_with_new_names_with_errors.csv")
