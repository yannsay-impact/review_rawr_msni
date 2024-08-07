
# Loading example data
# pak::pak("impact-initiatives-hppu/humind.data")
library(humind.data)
data(dummy_raw_data, package = "humind.data")

humind.data::dummy_raw_data |> writexl::write_xlsx("inputs/rawr/dummy_raw_data.xlsx")
# from <- system.file("../data-raw/REACH_2024_MSNA-kobo-tool_draft_v11.xlsx", package = "humind.data")
# fs::file_copy(from, "inputs/rawr/", overwrite = FALSE)
humind.data::loa |> write.csv("inputs/rawr/loa.csv")
humind.data::survey_updated |> write.csv("inputs/rawr/survey_updated.csv")
humind.data::choices_updated |> write.csv("inputs/rawr/choices_updated.csv")
