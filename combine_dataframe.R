# Read in GHG dataframe
GHG <- read.csv("ghg_per_year")

#Create list of BERT CSVs from google drive
drive_path <-"G:/Shared drives/2024 FIRE-SA/DATA/ProcessedResults/"
files <- list.files(path = drive_path, pattern = "\\.csv$", full.names = TRUE)
reductions_df <- data.frame()

# Loop through list of BERT CSVs and rowbind them by company_year and reductions in reductions_df
for(i in 1:length(files)){
temp_csv <- read.csv(files[i])
number_reduction <- sum(temp_csv$classification == "reduction")
company_year <- sub(paste0("^", "G:/Shared drives/2024 FIRE-SA/DATA/ProcessedResults/"), "", files[i])
reductions_df <- rbind(reductions_df, c(company_year,number_reduction))
}

colnames(reductions_df) <- c("Company_Year","Reduction_Sentences")

#Split reductions into tickers, years, and reductions
ticker_year <- gsub(".*?([A-Za-z]+_[0-9]+).*", "\\1", reductions_df$Company_Year)
ticker <- gsub("([^_]+)_[0-9]+", "\\1", ticker_year)
year <- as.numeric(gsub("[A-Za-z]+_([0-9]+)", "\\1", ticker_year))
tickers_years_df <- as.data.frame(cbind(ticker,year))
reductions_df2 <- cbind(reductions_df, tickers_years_df)
reductions_df2$year <- as.integer(reductions_df2$year)
reductions_df2$year <- paste0("20", reductions_df2$year)

#write.csv(reductions_df2, "reductions_df2.csv")

# Merge GHG and reductions_df2 by ticker and year
# Not functioning yet
red <- read.csv("reductions_df2.csv")
combined_df <- merge(GHG, red, by = c("ticker", "year"), all = TRUE)


