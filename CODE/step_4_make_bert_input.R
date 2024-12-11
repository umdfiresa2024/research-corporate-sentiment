library("dplyr")
library("stringr")
library("tidyr")

path<-"G:/Shared drives/2024 FIRE-SA/DATA/new_scrape/"

files<-as.data.frame(dir(path)) |>
  tidyr::separate(1, into = c("ticker", "year"), sep = "_") |>
  mutate(year=as.numeric(stringr::str_remove(year, ".csv"))) |>
  filter(year<=22) |>
  group_by(ticker) |>
  mutate(obs=n()) |>
  filter(obs==13)

ticker<-unique(files$ticker) 
year<-9+seq(10:22)

df<-tidyr::crossing(ticker, year) |>
  mutate(filename=paste0(ticker, "_", year, ".csv"))

#check which ones have been fed into bert
bert<-read.csv("OUTPUT/step_4_bert.csv")|>
  tidyr::separate(5, into = c("ticker", "year"), sep = "_") |>
  mutate(year=as.numeric(year))

df2<-merge(df, bert, by=c("ticker", "year"), all.x=TRUE) 

temp<-unique(df2)

df2<-merge(df, bert, by=c("ticker", "year"), all.x=TRUE) |>
  filter(is.na(sentences))

for (i in 1:227) {
  print(i)
  f<-read.csv(paste0(path, df2$filename[i]))
  write.csv(f, paste0("G:/Shared drives/2024 FIRE-SA/DATA/new_scrape_input/",df2$filename[i]))
}
#############################################################################

for (i in 212:227) {
  print(i)
  f<-read.csv(paste0(path, df2$filename[i]))
  write.csv(f, paste0("G:/Shared drives/2024 FIRE-SA/DATA/new_scrape_input_3/",df2$filename[i]))
}
