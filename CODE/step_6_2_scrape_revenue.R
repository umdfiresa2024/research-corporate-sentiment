library("httr")
library("readxl")
library("dplyr")
library("stringr")
library("tidyr")

dest.file<-dir("OUTPUT/REPORTS", pattern=".xlsx")

rev_df<-c()

for (i in 121:length(dest.file)) {
  
  print(dest.file[i])
  sheet_names2 <- excel_sheets(paste0("OUTPUT/REPORTS/",dest.file[i]))

  balance_sheet<-sheet_names2[str_detect(tolower(sheet_names2), "balance")]
  
  if (length(balance_sheet)>0) {
  
  for (j in 1:length(balance_sheet)) {
    print(j)
    xxxx<- read_excel(paste0("OUTPUT/REPORTS/",dest.file[i]), balance_sheet[j])
  
    names(xxxx)[1]<-"c1"
    names(xxxx)[2]<-"c2"
    
    assets<-xxxx |>
      mutate(c1=tolower(c1)) |>
      filter(str_detect(c1, "assets")) |>
      mutate(c2=as.numeric(c2)) |>    
      filter(!is.na(c2)) |>
      summarize(assets=max(c2))
  
    equity<-xxxx |>
      mutate(c1=tolower(c1)) |>
      filter(str_detect(c1, "total equity")) |>
      mutate(c2=as.numeric(c2)) |>    
      filter(!is.na(c2)) |>
      summarize(equity=max(c2))

    rev_df <- rbind(rev_df, data.frame(filename = dest.file[i], Assets = assets$assets, Equity=equity$equity))
  }

  }
}

r2<-rev_df |>
  group_by(filename) |>
  summarize(Assets=max(Assets)) |>
  tidyr::separate(filename, into=c("ticker", "X1.13"), sep = "_") |>
  mutate(X1.13=as.numeric(str_remove(X1.13, ".xlsx")))

################################################################################

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

no5<-merge(r2, no4, by=c("ticker", "X1.13")) |>
  filter(Assets>0) |>
  group_by(ticker) |>
  mutate(obs=n())

write.csv(no5, "OUTPUT/step_6_assets.csv", row.names = F)
