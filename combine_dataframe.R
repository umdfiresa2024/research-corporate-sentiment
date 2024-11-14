finalFrame <- read.csv("ghg_per_year")
drive_path <-"G:/Shared drives/2024 FIRE-SA/DATA/ProcessedResults/"
files <- list.files(path = drive_path, pattern = "\\.csv$", full.names = TRUE)
combined_frame <- data.frame()

for(i in 1:length(files)){
temp_csv <- read.csv(files[i])
number_reduction <- sum(temp_csv$classification == "reduction")
company_year <- sub(paste0("^", "G:/Shared drives/2024 FIRE-SA/DATA/ProcessedResults/"), "", files[i])
combined_frame <- rbind(combined_frame, c(company_year,number_reduction))
}

