library("dplyr")
library("stringr")
library("tidyr")

ghg<-read.csv("OUTPUT/step_2_tickers_ghg.csv") |>
  mutate(year=year-2000) |>
  select(-yearcount)

ghg_comp<-unique(ghg$ticker) #there are 188 SEC companies that reported 13 years of emissions

bert<-read.csv("OUTPUT/step_4_bert.csv") |>
  separate(filename, into=c("ticker", "year", "tail"), sep="_") |>
  select(-tail) |>
  mutate(year=as.numeric(year))

bert_comp<-unique(bert$ticker) #there are 18 companies that we were able to scrape 10-K data for 13 years

assets<-read.csv("OUTPUT/step_6_assets.csv") |>
  select(ticker, Assets, year)

df<-merge(ghg, bert, by=c("year", "ticker"))

