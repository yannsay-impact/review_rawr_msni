# spec analysistools
library(tidyverse)
loa <- read.csv("inputs/rawr/loa.csv") |> 
  select(-any_of("X")) |> 
  filter(!duplicated(var))
group_vars <- c("admin1", "hoh_gender", "hoh_age_cat")

me_loa <- loa |> 
  rename(analysis_type = analysis,
         analysis_var = var) |> 
  mutate(analysis_var_ratio = case_when(analysis_type == "ratio" ~ analysis_var, 
                                        TRUE ~ NA_character_)) |> 
  separate(analysis_var_ratio,into = c("analysis_var_numerator", "analysis_var_denominator"), sep = ",") |>
  mutate(analysis_var = case_when(analysis_type == "ratio" ~ NA_character_,
                                  TRUE ~ analysis_var)) |> 
  mutate(analysis_type = case_when(analysis_type == "select_one" ~ "prop_select_one",
                                   analysis_type == "select_multiple" ~ "prop_select_multiple", 
                                   TRUE ~ analysis_type))
group_var = c(group_vars, NA_character_)

me_loa <- expand_grid(me_loa, group_var) 

## analysis_var and group_var cannot be similar



me_loa <- me_loa |> 
  mutate(similar_var = analysis_var == group_var) %>% 
  filter(!similar_var | is.na(similar_var)) %>% 
  select(-similar_var)
readr::write_csv(me_loa, "inputs/analysistools/loa.csv")

