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
  select("GHG QUANTITY (METRIC TONS CO2e)", "PARENT COMPANIES", "year", 
         "GHGRP ID", "LATITUDE", "LONGITUDE")

# Separate parent companies into multiple columns
new_data <- select_col %>%
  separate("PARENT COMPANIES", into = paste0("PARENT COMPANY ", 1:3), sep = "; ", fill = "right")

# Reshape data to long format
data_long <- new_data %>%
  pivot_longer(cols = starts_with("PARENT"),
               names_to = "COMPANY TYPE",
               values_to = "PARENT COMPANY")

# Extract percentages from the PARENT COMPANY column
data_long2 <- data_long %>%
  mutate(percentage = str_extract(`PARENT COMPANY`, "\\d+(\\.\\d+)?%"),
         `PARENT COMPANY` = str_remove(`PARENT COMPANY`, "\\s*\\(\\d+(\\.\\d+)?%\\)")) %>%
  mutate(numeric_percentage = as.numeric(gsub("%", "", percentage)) / 100) %>%
  mutate(`GHG QUANTITY (METRIC TONS CO2e)` = as.numeric(`GHG QUANTITY (METRIC TONS CO2e)`))

# Adjust GHG emissions, keeping original values if numeric_percentage is NA
data_long3 <- data_long2 %>%
  mutate(adjusted_ghg = ifelse(is.na(numeric_percentage), 
                               `GHG QUANTITY (METRIC TONS CO2e)`, 
                               `GHG QUANTITY (METRIC TONS CO2e)` * numeric_percentage))

################################################################################

#match company with sentiment score

df20<-data_long3 |>
  filter(year==2020) |>
  filter(!is.na(`PARENT COMPANY`)) |>
  rename(flight_company=`PARENT COMPANY`)

|>
  filter(!str_detect(`PARENT COMPANY`, "LLC")) |>
  filter(!str_detect(`PARENT COMPANY`, "L.L.C.")) |>
  filter(!is.na(`PARENT COMPANY`)) |>
  mutate(match_name=toupper(`PARENT COMPANY`)) |>
  mutate(match_name=str_remove_all(match_name, "COMPANY")) |>
  mutate(match_name=str_remove_all(match_name, "HOLDINGS")) |>
  mutate(match_name=str_remove_all(match_name, "HOLDING")) |>
  mutate(match_name=str_remove_all(match_name, "INC")) |>
  mutate(match_name=str_remove_all(match_name, "INC")) |>
  mutate(match_name=str_remove_all(match_name, "CORPORATION")) |>
  mutate(match_name=str_remove_all(match_name, "CORP")) |>
  mutate(match_name=str_remove_all(match_name, "LP")) |>
  mutate(match_name=str_remove_all(match_name, "LTD")) |>
  mutate(match_name=str_remove_all(match_name, ", .")) |>
  mutate(match_name=str_remove_all(match_name, "L.P.")) 

tickers<-read.csv("OUTPUT/step_2_tickers_ghg.csv") |>
  filter(year==2020)

df21<-merge(df20, tickers, by=c("flight_company")) |>
  select(LATITUDE, LONGITUDE, ticker)

bert<-read.csv("OUTPUT/step_4_bert.csv") |>
  separate(5, into = c("ticker", "year"), sep = "_") |>
  mutate(year=as.numeric(year)) |>
  filter(year==20) |>
  mutate(share=(reduction + netzero)/(sentences-error)) |>
  select(ticker, share)

df22<-merge(df21, bert, by="ticker") |>
  group_by(LATITUDE, LONGITUDE) |>
  summarize(share=mean(share))

library("terra")
library("tidycensus")
library("readxl")
fac<-vect(df22, geom=c("LONGITUDE", "LATITUDE"), crs="+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs ")

count<-vect("CENSUS/tl_2020_us_county")

count$STATEFP<-as.numeric(count$STATEFP)

count2<-subset(count, count$STATEFP<57)

count3<-subset(count2, count2$STATEFP!=2 & count2$STATEFP!=15)

plot(count3)

dem<-read_excel("CENSUS/est20all.xls", skip=3) |>
  rename(STATEFP=`State FIPS Code`, COUNTYFP=`County FIPS Code`, Poverty_Pct=`Poverty Percent, All Ages`) |>
  mutate(STATEFP=as.numeric(STATEFP), Poverty_Pct=as.numeric(Poverty_Pct)) |>
  select(STATEFP, COUNTYFP, Poverty_Pct)

cd<-merge(count3, dem, by=c("STATEFP", "COUNTYFP"))

facp<-project(fac, crs(count3))

fac_buff<-terra::buffer(facp, width = 5000)

plot(fac_buff)

png("CENSUS/map.png", 
    res=500, width=6, height=5, units="in")

plot(cd, "Poverty_Pct", breaks=c(0,10, 20, 30, 40, 50), 
     main="Facility Location and County-Level %Poverty",
     legend.args = list(text = '%Poverty'))
     
points(facp, "share", col="#FDE725FF")

add_legend()

dev.off()

###calculate poverty###############
count4<-buffer(count3, width = 0)

int<-extract(count4, facp)

facdf<-as.data.frame(fac_buff)

df<-cbind(int, facdf)

df2<-merge(df, dem, by=c("STATEFP", "COUNTYFP"))

png("CENSUS/plot.png", 
    res=500, width=8, height=5, units="in")

ggplot(data=df2, aes(y=share*100, x=Poverty_Pct)) + geom_point(size=4, col="#73D055FF") + 
  theme_bw() + 
  ggtitle("Corporate Sentiment and Demographics Near Facilities") + 
  ylab("Percentage of Reduction and Net-Zero Sentences in 2020") + 
  xlab("Percentage of People Living Under the Poverty Line") +
  theme(plot.title = element_text(size = 20, face="bold"))

dev.off()