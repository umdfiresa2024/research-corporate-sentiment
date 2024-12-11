#library("tidyverse")
library("httr")
library("readxl")
library("rJava")
library("XLConnect")

no<-read.csv("access_no.csv")

path<-"G:/Shared drives/2024 FIRE-SA/DATA/new_scrape/"

files<-as.data.frame(dir(path)) |>
  tidyr::separate(1, into = c("ticker", "year"), sep = "_") |>
  mutate(year=as.numeric(stringr::str_remove(year, ".csv"))) |>
  filter(year<=22) |>
  group_by(ticker) |>
  mutate(obs=n()) |>
  filter(obs==13)

ticker<-unique(files$ticker) 
freq<-data.frame(1:13)
df<-crossing(data.frame(ticker), freq)

no2<-cbind(no, df) 

no3<-no2 |>
  tidyr::separate(1, into = c("c1", "year", "c3", sep="-")) |>
  mutate(year=as.numeric(year)) |>
  select(year)

no4<-cbind(no2, no3) |>
  filter(year>13 & year<=22)

rev_df<-c()

for (i in 1:168) {
  print(i)
accession.no.raw <- no4$accession_numbers[i]
accession.no <- gsub("-", "" , accession.no.raw)

CIK <- no4$cik_numbers[i]
CIK <- as.numeric(CIK)

inst.url <- paste0("https://www.sec.gov/Archives/edgar/data/", CIK, "/", 
                   accession.no, "/Financial_Report.xlsx")
dest.file<-paste0("OUTPUT/REPORTS/", no4$ticker[i], "_", no4$X1.13[i], ".xlsx")

downfail <- 0

tryCatch(
  expr = {
    # Try to download the file
    download.file(inst.url, dest.file, mode = "wb", 
                  headers = c(`User-Agent` = "Thanicha Ruangmas/1.0 (ruangmas@umd.edu)"))
    
  },
  error = function(e) {
    message('Caught an error!')
    print(e)
    downfail <<- 1  # Flag the download as failed
  },
  warning = function(w) {
    file_size <- file.info(dest.file)$size
    if (file_size == 0) {
      file.remove(dest.file)  # Remove the empty file if download failed
    }
    message("Warning occurred during download.")
    downfail <<- 1  # Flag the download as failed
  },
  finally = {
    message('FILE DOWNLOAD COMPLETE\n')
  }
)

# If download was successful (downfail == 0), read the sheet names from the .xls file
if(downfail == 0) {
  # Read the sheet names using readxl package for .xls files
  sheet_names2 <- excel_sheets(dest.file)
  print(sheet_names2)  # Optional: print the sheet names to verify
} else {
  message("Download failed or empty file.")
  # Optional: Retry download if necessary
  inst.url <- paste0("https://www.sec.gov/Archives/edgar/data/", CIK, "/", 
                     accession.no, "/Financial_Report.xls")
  dest.file <- paste0("OUTPUT/REPORTS/", no4$ticker[i], "_", no4$X1.13[i], ".xls")
  
  # Retry downloading the file
  download.file(inst.url, dest.file, mode = "wb", 
                headers = c(`User-Agent` = "Thanicha Ruangmas/1.0 (ruangmas@umd.edu)"))
  
  # Now, use readxl to load the .xls file
  wb <- XLConnect::loadWorkbook(dest.file)
  sheet_names <- XLConnect::getSheets(wb)
}

####################work with spreadsheet########################################

patterns <- c("Consolidated Statements Of Oper", "Consolidated Statement Of Opera",
              "Consolidated Statement of Incom", "CONSOLIDATED STATEMENTS OF INCO",
              "Consolidated Statements of Inco",
              "Consolidated_Statements_Of_Oper", "Consolidated_Statement_Of_Opera","Consolidated_Statement_of_Incom", "CONSOLIDATED_STATEMENTS_OF_INCO")

pagecounter <- 1
boltest <- FALSE

sheet_names2 <- excel_sheets(dest.file)
for (sheet2 in sheet_names2) {
  if(any(str_detect(tolower(sheet2), "balance"))){
    boltest <- TRUE
    break
  }
  pagecounter <- pagecounter + 1
}
if(boltest){ 
  
  dfexecl <- data.frame()
  if(downfail == 0) {
    xxxx<- read_excel(dest.file, sheet_names2[pagecounter])
  } else {
    print("dffailed")
    xxxx <- readWorksheet(workbook, sheet_names2[pagecounter], 3)
    
  }
  dfexecl <- bind_rows(dfexecl, xxxx)
  
  names(dfexecl)[1]<-"c1"
  names(dfexecl)[2]<-"c2"
  
  rev<-dfexecl |>
    mutate(c1=tolower(c1)) |>
    filter(str_detect(c1, "revenue")) |>
    filter(!is.na(c2))
  
  first_net_sales <- max(as.numeric(rev$c2))
  
  first_net_sales <- first_net_sales *1000000
} else {
  print("excel page not found")
  first_net_sales <-0
}

rev_df <- rbind(rev_df, data.frame(`REPORTING YEAR` = no4$year[i], `Revenue` = first_net_sales,
                                   `PARENT COMPANIES`= no4$ticker[i]))
}


