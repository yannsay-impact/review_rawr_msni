rm(list=ls())


# Load packages -----------------------------------------------------------

library(impactR.utils)
# library(impactR.kobo)
# library(impactR.analysis)
library(humind)
library(srvyr)
library(dplyr)
library(tidyr)

library(analysistools)

# Prepare datasets --------------------------------------------------------

loop <- left_joints_dup(list(
  loop = dummy_raw_data$roster,
  edu_ind = dummy_raw_data$edu_ind,
  health_ind = dummy_raw_data$health_ind,
  nut_ind = dummy_raw_data$nut_ind),
  person_id,
  uuid)

main <- dummy_raw_data$main |>
  mutate(weight = 1)

main <- main |> 
  filter(consent == "yes")

loop <- loop |> 
  filter(uuid %in% main$uuid)


# Add indicators ----------------------------------------------------------

#------ Add to loop
loop <- loop |>
  add_age_cat("ind_age") |>
  add_age_18_cat("ind_age") |>
  add_loop_age_dummy("ind_age", 5, 18) |>
  add_edu_access_d("edu_access")

#------- Clean up food security indicators

# Clean hhs
main <- mutate(
  main,
  across(
    c("fsl_hhs_nofoodhh", "fsl_hhs_sleephungry", "fsl_hhs_alldaynight"),
    \(x) case_when(
      x %in% c("dnk", "pnta") ~ NA_character_,
      .default = x
    )
  )
)

# Add to main
main <- main |>
  # Demographics
  add_hoh_final() |>
  add_age_cat("resp_age") |>
  add_age_18_cat("resp_age") |>
  add_age_cat("hoh_age") |>
  add_age_18_cat("hoh_age") |>
  add_loop_age_dummy_to_main(loop, "ind_age_5_18") |>
  # WASH
  add_sanitation_facility_cat() |>
  add_sharing_sanitation_facility_cat() |>
  add_sharing_sanitation_facility_num_ind() |>
  add_drinking_water_source_cat() |>
  add_drinking_water_time_cat() |>
  add_drinking_water_time_threshold_cat() |>
  # SNFI
  add_shelter_type_cat() |>
  add_shelter_issue_cat() |>
  add_fds_cannot_cat() |>
  add_occupancy_cat() |>
  # Food security
  add_lcsi() |>
  add_hhs() |>
  add_fcs(cutoffs = "normal") |>
  add_rcsi() |>
  add_fcm_phase() |>
  # Cash & markets
  add_income_source_zero_to_sl() |>
  add_income_source_prop() |>
  add_income_source_cat() |>
  # AAP
  add_received_assistance()


# Analysis groups ---------------------------------------------------------

# List of grouping variables
group_vars <- list("admin1", "resp_gender", "hoh_gender", "hoh_age_cat")

# Add this list of variables to loop (including weights, and stratum if relevant), joining by uuid
loop <- df_diff(loop, main, uuid) |>
  left_join(
    main |> select(uuid, weight, !!!unlist(group_vars)),
    by = "uuid"
  )


# Prepare design and kobo -------------------------------------------------

# Design main - weighted
design_main_w <- main |>
  as_survey_design(weight = weight)

# Design main - unweighted
design_main_unw <- main |>
  as_survey_design()

# Design loop - weighted
design_loop_w <- loop |>
  as_survey_design(weight = weight)

# Design loop - unweighted
design_loop_unw <- loop |>
  as_survey_design()



# Prepare analysis --------------------------------------------------------

# Bind var_denom when ratio with a ","
loa <- unite(loa, var, var, var_denom, sep = ",", na.rm = TRUE)

# spec analysistools
me_loa <- loa |> 
  rename(analysis_type = analysis,
         analysis_var = var) |> 
  mutate(analysis_var_ratio = case_when(analysis_type == "ratio" ~ analysis_var, 
                                              TRUE ~ NA_character_)) |> 
  separate(analysis_var_ratio,into = c("analysis_var_numerator", "analysis_var_denominator"), sep = ",") |>
  mutate(analysis_type = case_when(analysis_type == "select_one" ~ "prop_select_one",
                                   analysis_type == "select_multiple" ~ "prop_select_multiple", 
                                   TRUE ~ analysis_type)) |> 
  filter(!analysis_var %in% c("hoh_age_cat")) #breaking my code

me_loa <- expand_grid(me_loa, group_var = c(group_vars, NA_character_))

## analysis_var and group_var cannot be similar

filtered_out <- me_loa |> 
  filter(group_var == analysis_var)

me_loa <- me_loa |> 
  filter(group_var != analysis_var | is.na(group_var))

loa_main <- me_loa |> 
  filter(dataset == "main", 
         analysis_var %in% names(main) | analysis_type == "ratio") 
loa_loop <- me_loa |> filter(dataset == "loop", 
                             analysis_var %in% names(loop) | analysis_type == "ratio")
loa_main_unw <- loa_main |> filter(weighted == "no")
loa_loop_unw <- loa_loop |> filter(weighted == "no")
loa_main_w <- loa_main |> filter(weighted == "yes")
loa_loop_w <- loa_loop |> filter(weighted == "yes")





# # Main analysis - weighted
# if (nrow(loa_main_w) > 0) {
#   an_main_w <- create_analysis(
#     design_main_w,
#     loa_main_w,
#     sm_separator =  "/")
# } else {
#   an_main_w <- tibble()
# }
# 
# an_main_w %>% saveRDS("outputs/me/me_an_main_w_no_consent.RDS")
