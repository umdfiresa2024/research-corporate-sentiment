
bert<-read.csv("OUTPUT/step_4_bert.csv") |>
  separate(5, into = c("ticker", "year"), sep = "_") |>
  mutate(year=as.numeric(year))

tickers<-read.csv("OUTPUT/step_2_flight_tickers.csv")
year<- 9+seq(2010:2022)
df<-crossing(tickers, year) |>
  rename(ticker=x)

df2<-merge(df, bert, by=c("ticker", "year"), all.x=TRUE) |>
  filter(is.na(sentences))

tickers<-unique(df2$ticker)

write.csv(tickers, "OUTPUT/tickers_to_scrape.csv", row.names = F)
