# 1 read main et loop without indicators --------------------------------------------------------

# Install pacman if not already installed
if (!require("pacman")) install.packages("pacman")
# Load and manage packages with pacman
pacman::p_load(
    pak,
    arsenal,
    dplyr,
    purrr,
    fuzzyjoin
)
# Install specific packages if needed
if (!require("impactR.utils")) pak::pak("gnoblet/impactR.utils")
if (!require("humind")) pak::pak("impact-initiatives-hppu/humind")


dummy_raw_data <- readxl::excel_sheets("inputs/rawr/dummy_raw_data.xlsx") %>%
    map(~ readxl::read_excel(
        path = "inputs/rawr/dummy_raw_data.xlsx",
        sheet = .x,
        guess = 50000
    )) |>
    set_names(readxl::excel_sheets("inputs/rawr/dummy_raw_data.xlsx"))

# Prepare datasets

loop <- left_joints_dup(
    list(
        loop = dummy_raw_data$roster,
        edu_ind = dummy_raw_data$edu_ind,
        health_ind = dummy_raw_data$health_ind,
        nut_ind = dummy_raw_data$nut_ind
    ),
    person_id,
    uuid
)

main <- dummy_raw_data$main

# 2 read main et loop with indicators --------------------------------------------------------

main_to_review <- read.csv("outputs/rawr/main_with_new_names_with_errors.csv")
loop_to_review <- read.csv("outputs/rawr/loop_with_indicators.csv")

# 3 with out - copy paste de humind --------------------------------------------------------


# Add indicators ----------------------------------------------------------

#------ Add to loop
loop_with_indicators <- loop |>
    # Demographics
    add_age_cat("ind_age", breaks = c(-1, 17, 59, 120)) |>
    add_age_18_cat("ind_age") |>
    # Education
    add_loop_edu_ind_age_corrected(main = main, month = 7) |>
    add_loop_edu_access_d() |>
    add_loop_edu_barrier_protection_d() |>
    add_loop_edu_disrupted_d() |>
    # WGQ-SS
    add_loop_wgq_ss() |>
    # Health --- example if wgq_dis_3 exists
    add_loop_healthcare_needed_cat(wgq_dis = "wgq_dis_3")

#------ Add loop to main
main_with_indicators <- main |>
    # Education
    add_loop_edu_ind_schooling_age_d_to_main(loop = loop_with_indicators) |>
    add_loop_edu_access_d_to_main(loop = loop_with_indicators) |>
    add_loop_edu_barrier_protection_d_to_main(loop = loop_with_indicators) |>
    add_loop_edu_disrupted_d_to_main(loop = loop_with_indicators) |>
    # WGQ-SS
    add_loop_wgq_ss_to_main(loop = loop_with_indicators) |>
    # Health
    add_loop_healthcare_needed_cat_to_main(
        loop = loop_with_indicators,
        ind_healthcare_needed_no_wgq_dis = "health_ind_healthcare_needed_no_wgq_dis",
        ind_healthcare_needed_yes_unmet_wgq_dis = "health_ind_healthcare_needed_yes_unmet_wgq_dis",
        ind_healthcare_needed_yes_met_wgq_dis = "health_ind_healthcare_needed_yes_met_wgq_dis"
    )

#------- Clean up food security indicators

# HHS calculation should not contain Don't know or Prefer not to answer
main_with_indicators <- mutate(
    main_with_indicators,
    across(
        c("fsl_hhs_nofoodhh", "fsl_hhs_sleephungry", "fsl_hhs_alldaynight"),
        \(x) case_when(
            x %in% c("dnk", "pnta") ~ NA_character_,
            .default = x
        )
    )
)

# Add to main
main_with_indicators <- main_with_indicators |>
    # Demographics
    add_hoh_final() |>
    add_age_cat(age_col = "resp_age", breaks = c(-1, 17, 59, 120)) |>
    add_age_18_cat(age_col = "resp_age") |>
    add_age_cat(age_col = "hoh_age", breaks = c(-1, 17, 59, 120)) |>
    add_age_18_cat(age_col = "hoh_age") |>
    # Protection
    add_child_sep_cat() |>
    # WASH
    # WASH - Sanitation facility
    add_sanitation_facility_cat() |>
    add_sharing_sanitation_facility_cat() |>
    add_sharing_sanitation_facility_n_ind() |>
    add_sanitation_facility_jmp_cat() |>
    # WASH - Water
    add_drinking_water_source_cat() |>
    add_drinking_water_time_cat() |>
    add_drinking_water_time_threshold_cat() |>
    add_drinking_water_quality_jmp_cat() |>
    # WASH - Hygiene
    add_handwashing_facility_cat() |>
    # SNFI
    add_shelter_type_cat() |>
    add_shelter_issue_cat() |>
    add_fds_cannot_cat() |>
    # HLP
    add_occupancy_cat() |>
    # Food security
    add_lcsi() |>
    add_hhs() |>
    add_fcs(cutoffs = "normal") |>
    add_rcsi() |>
    add_fcm_phase() |>
    add_fclcm_phase() |>
    # Cash & markets
    add_income_source_zero_to_sl() |>
    add_income_source_prop() |>
    add_income_source_rank() |>
    # Expenditure
    add_expenditure_type_zero_freq(
        # Note that in the initial kobo template the utilities column was:
        # cm_expenditure_frequent_utilitues
        # Spelling mistake
        expenditure_freq_types = c(
            "cm_expenditure_frequent_food",
            "cm_expenditure_frequent_rent",
            "cm_expenditure_frequent_water",
            "cm_expenditure_frequent_nfi",
            "cm_expenditure_frequent_utilities",
            "cm_expenditure_frequent_fuel",
            "cm_expenditure_frequent_transportation",
            "cm_expenditure_frequent_communication",
            "cm_expenditure_frequent_other"
        )
    ) |>
    add_expenditure_type_prop_freq(
        # Note that in the initial kobo template the utilities column was:
        # cm_expenditure_frequent_utilitues
        # Spelling mistake
        "cm_expenditure_frequent_food",
        "cm_expenditure_frequent_rent",
        "cm_expenditure_frequent_water",
        "cm_expenditure_frequent_nfi",
        "cm_expenditure_frequent_utilities",
        "cm_expenditure_frequent_fuel",
        "cm_expenditure_frequent_transportation",
        "cm_expenditure_frequent_communication",
        "cm_expenditure_frequent_other"
    ) |>
    add_expenditure_type_freq_rank(
        # Note that in the initial kobo template the utilities column was:
        # cm_expenditure_frequent_utilitues
        # Spelling mistake
        expenditure_freq_types = c(
            "cm_expenditure_frequent_food",
            "cm_expenditure_frequent_rent",
            "cm_expenditure_frequent_water",
            "cm_expenditure_frequent_nfi",
            "cm_expenditure_frequent_utilities",
            "cm_expenditure_frequent_fuel",
            "cm_expenditure_frequent_transportation",
            "cm_expenditure_frequent_communication",
            "cm_expenditure_frequent_other"
        )
    ) |>
    add_expenditure_type_zero_infreq() |>
    add_expenditure_type_prop_infreq() |>
    add_expenditure_type_infreq_rank() |>
    # AAP
    add_received_assistance() |>
    add_access_to_phone_best() |>
    add_access_to_phone_coverage()


# Add composites ---------------------------------------------------------

# Add sectoral composites
main_with_indicators <- main_with_indicators |>
    add_comp_foodsec() |>
    add_comp_snfi() |>
    add_comp_prot() |>
    add_comp_health() |>
    add_comp_wash() |>
    add_comp_edu()

# Add MSNI score and the 4 metrics
main_with_indicators <- main_with_indicators |>
    add_msni()


# 4 arsenal::comparedf // summary::comparedf --------------------------------------------------------


names(main_with_indicators) <- sub("/", ".", names(main_with_indicators))

# Have a look at non shared variables
res <- summary(comparedf(main_with_indicators, main_to_review, int.as.num = TRUE))
res <- res$vars.ns.table # list of non shared variables

# Match non shared variables
vars_ours <- res |>
    filter(version == "x") |>
    select(variable)
vars_theirs <- res |>
    filter(version == "y") |>
    select(variable)

result <- stringdist_full_join(vars_ours, vars_theirs, method = "jw", max_dist = 0.3)
# check how the result looks and adjust max_dist accordingly

write.csv(result |> dplyr::rename(
    our_variable_names = variable.x,
    their_variable_names = variable.y
), "outputs/rawr/non_shared_variables.csv", row.names = FALSE)

# Now go in the csv and match the variables manually by deleting non-coherent rows
# in column "our_variable_names"

# Once modified, load again
non_shared_variables <- read.csv("outputs/rawr/non_shared_variables.csv", header = TRUE) %>% filter(!is.na(our_variable_names))

# Replace names in our dataset
names(main_with_indicators) <- ifelse(
    is.na(non_shared_variables$their_variable_names[match(names(main_with_indicators), non_shared_variables$our_variable_names)]),
    names(main_with_indicators),
    non_shared_variables$their_variable_names[match(names(main_with_indicators), non_shared_variables$our_variable_names)]
)

# Back to comparedf
res <- summary(comparedf(main_with_indicators, main_to_review, int.as.num = TRUE))
res
