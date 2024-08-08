library(tidyverse)
library(srvyr)
library(analysistools)
main <- read.csv("outputs/rawr/main_with_indicators.csv")
loop <- read.csv("outputs/rawr/loop_with_indicators.csv")
loa <- read.csv("inputs/analysistools/loa.csv")
# Analysis groups ---------------------------------------------------------

# List of grouping variables
group_vars <- list("admin1", "hoh_gender", "hoh_age_cat")

# Add this list of variables to loop (including weights, and stratum if relevant), joining by uuid
loop <- loop |>
  left_join(
    main |> select(uuid, weight, !!!unlist(group_vars)),
    by = "uuid"
  )


# Prepare design and kobo -------------------------------------------------

# Design main - weighted
design_main_w <- main |>
  as_survey_design(weight = weight)
# Design loop - weighted
design_loop_w <- loop |>
  as_survey_design(weight = weight)



# Prepare analysis --------------------------------------------------------

loa <- loa |> 
  filter(dataset == "main", 
         analysis_var %in% names(main) | analysis_type == "ratio") 
loa_loop <- loa |> filter(dataset == "loop", 
                             analysis_var %in% names(loop) | analysis_type == "ratio")
loa_main_unw <- loa |> filter(weighted == "no")
loa_loop_unw <- loa_loop |> filter(weighted == "no")
loa_main_w <- loa |> filter(weighted == "yes")
loa_loop_w <- loa_loop |> filter(weighted == "yes")





# Main analysis - weighted
if (nrow(loa_main_w) > 0) {
  an_main_w <- create_analysis(
    design_main_w,
    loa_main_w,
    sm_separator =  "/")
} else {
  an_main_w <- tibble()
}

an_main_w %>% saveRDS("outputs/me/me_an_main.RDS")
