install.packages("tidyverse")
library(tidyverse)
data <- read_excel("flightghgdata.xls", 1, range = "B7:M8000")
select_col <- data %>%
  select("GHG QUANTITY (METRIC TONS CO2e)", "PARENT COMPANIES")
new_data <- select_col %>%
  separate("PARENT COMPANIES", into = paste0("PARENT COMPANY ", 1:3), sep = "; ", fill = "right")
data_long <- new_data %>%
  pivot_longer(cols = starts_with("PARENT"),
               names_to = "COMPANY TYPE",  # Name for the column indicating which company it is
               values_to = "PARENT COMPANY")

data_long <- data_long %>%
  mutate(percentage = str_extract(`PARENT COMPANY`, "\\d+(\\.\\d+)?%"))


