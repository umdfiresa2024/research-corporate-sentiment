# Load required packages
library(tidyverse)
library(readxl)

# Define the years and create an empty list to hold the data
years <- c("2010", "2011", "2012", "2013", "2014", "2015", "2016", "2017", "2018", "2019", "2020", "2021", "2022")  # Adjust to your actual sheet names
data_list <- list()

# Read each sheet and append to the list
for (year in years) {
  sheet_data <- read_excel("flightghgdata.xls", sheet = year, range = "B7:M8000") %>%
    mutate(year = year)  # Add a year column
  data_list[[year]] <- sheet_data
}

# Combine all data frames into one
combined_data <- bind_rows(data_list)

# Select relevant columns
select_col <- combined_data %>%
  select("GHG QUANTITY (METRIC TONS CO2e)", "PARENT COMPANIES", "year")

# Separate parent companies into multiple columns
new_data <- select_col %>%
  separate("PARENT COMPANIES", into = paste0("PARENT COMPANY ", 1:3), sep = "; ", fill = "right")

# Reshape data to long format
data_long <- new_data %>%
  pivot_longer(cols = starts_with("PARENT"),
               names_to = "COMPANY TYPE",
               values_to = "PARENT COMPANY")

# Extract percentages from the PARENT COMPANY column
data_long <- data_long %>%
  mutate(percentage = str_extract(`PARENT COMPANY`, "\\d+(\\.\\d+)?%")) 

# Convert percentage to numeric
data_long <- data_long %>%
  mutate(numeric_percentage = as.numeric(gsub("%", "", percentage)) / 100)

# Ensure GHG quantity is numeric
data_long <- data_long %>%
  mutate(`GHG QUANTITY (METRIC TONS CO2e)` = as.numeric(`GHG QUANTITY (METRIC TONS CO2e)`))

# Adjust GHG emissions, keeping original values if numeric_percentage is NA
data_long <- data_long %>%
  mutate(adjusted_ghg = ifelse(is.na(numeric_percentage), 
                               `GHG QUANTITY (METRIC TONS CO2e)`, 
                               `GHG QUANTITY (METRIC TONS CO2e)` * numeric_percentage))

# Group by parent company and year, then summarize the GHG emissions
data_summary <- data_long %>%
  group_by(`PARENT COMPANY`, year) %>% 
  summarize(GHG = sum(adjusted_ghg, na.rm = TRUE), .groups = 'drop') 

# View the summarized result
print(data_summary)
