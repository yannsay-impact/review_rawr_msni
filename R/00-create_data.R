
# Loading example data
# pak::pak("impact-initiatives-hppu/humind.data")
library(humind.data)
data(dummy_raw_data, package = "humind.data")

humind.data::dummy_raw_data |> writexl::write_xlsx("inputs/rawr/dummy_raw_data.xlsx")

humind.data::loa |> write.csv("inputs/rawr/loa.csv")
humind.data::survey_updated |> write.csv("inputs/rawr/survey_updated.csv")
humind.data::choices_updated |> write.csv("inputs/rawr/choices_updated.csv")
