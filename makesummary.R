library("tidyverse")

df<-read.csv("finaldata.csv") |>
  mutate(ticker=as.numeric(as.factor(ticker))) |>
  select(-PARENT.COMPANY)
  

library("modelsummary")

datasummary_skim(df)

png("summary.png", res=500)

datasummary(year + GHG + sentences + reduction + netzero + error ~ Mean + SD + Min + Max, fmt=0, data=df)

dev.off()