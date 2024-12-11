library("dplyr")
library("stringr")
library("tidyr")

path<-"G:/Shared drives/2024 FIRE-SA/DATA/new_scrape/"

oldtic<-as.data.frame(dir(path)) |>
  tidyr::separate(1, into = c("ticker", "year"), sep = "_") |>
  mutate(year=as.numeric(stringr::str_remove(year, ".csv"))) |>
  filter(year<=22) |>
  group_by(ticker) |>
  mutate(obs=n()) |>
  filter(obs==13)

old_ticker<-unique(oldtic$ticker) 

files<-as.data.frame(dir(path)) |>
  tidyr::separate(1, into = c("ticker", "year"), sep = "_") |>
  mutate(year=as.numeric(stringr::str_remove(year, ".csv"))) |>
  filter(year>=14 & year<=22) |>
  group_by(ticker) |>
  mutate(obs=n()) |>
  filter(obs==9)

ticker<-unique(files$ticker)

list<-setdiff(ticker, old_ticker)
ticker<-list
year<-13+seq(1:9)

df<-tidyr::crossing(ticker, year) |>
  mutate(filename=paste0(ticker, "_", year, ".csv"))


for (i in 1:nrow(df)) {
  print(i)
  f<-read.csv(paste0(path, df$filename[i]))
  write.csv(f, paste0("G:/Shared drives/2024 FIRE-SA/DATA/new_scrape_input_4/",df$filename[i]))
}
#############################################################################

for (i in 212:227) {
  print(i)
  f<-read.csv(paste0(path, df2$filename[i]))
  write.csv(f, paste0("G:/Shared drives/2024 FIRE-SA/DATA/new_scrape_input_3/",df2$filename[i]))
}
