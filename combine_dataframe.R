GHG <- read.csv("ghg_per_year")

drive_path <-"G:/Shared drives/2024 FIRE-SA/DATA/ProcessedResults/"
files <- list.files(path = drive_path, pattern = "\\.csv$", full.names = TRUE)
reductions_frame <- data.frame()

for(i in 1:length(files)){
temp_csv <- read.csv(files[i])
number_reduction <- sum(temp_csv$classification == "reduction")
company_year <- sub(paste0("^", "G:/Shared drives/2024 FIRE-SA/DATA/ProcessedResults/"), "", files[i])
reductions_frame <- rbind(reductions_frame, c(company_year,number_reduction))
}

colnames(reductions_frame) <- c("Company_Year","Reduction_Sentences")

ticker_year <- gsub(".*?([A-Za-z]+_[0-9]+).*", "\\1", reductions_frame$Company_Year)
ticker <- gsub("([^_]+)_[0-9]+", "\\1", ticker_year)
year <- as.numeric(gsub("[A-Za-z]+_([0-9]+)", "\\1", ticker_year))
tickers_years_df <- as.data.frame(cbind(ticker,year))
reductions_df2 <- cbind(reductions_frame, tickers_years_df)
reductions_df2$year <- as.integer(reductions_df2$year)
reductions_df2$year <- paste0("20", reductions_df2$year)

combined_df <- merge(GHG, reductions_df2, by.x = "ticker", by.y = "year", all = TRUE)


