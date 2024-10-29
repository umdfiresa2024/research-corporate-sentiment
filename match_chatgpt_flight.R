library("tidyverse")
library("readxl")

raw_flight<-read.csv("companylist.csv")

chatgpt_output<-read_excel("G:/Shared drives/2024 FIRE-SA/Fall Course/tickers.xlsx")
chatgpt_output2<-read.csv("corporate sentiment - Sheet1.csv", header=FALSE)
names(chatgpt_output2)<-c("company", "ticker")
chatgpt_output3<-read.csv("company final tickers.csv")
names(chatgpt_output3)<-c("company", "ticker")

chat<-rbind(chatgpt_output, chatgpt_output2, chatgpt_output3)

flight.name = data.frame(raw_flight$x)
names(flight.name)<-"flight.name"
chat.name = data.frame(chat$company)
names(chat.name)<-"chat.name"

#flight=sp500
#chat=nyse
flight.name$chat.name <- "" # Creating an empty column

#for(i in 2:dim(flight.name)[1]) {
for (i in 2:600) {
  print(i)
  x <- agrep(flight.name$flight.name[i], chat.name$chat.name,
             ignore.case=TRUE, value=TRUE,
             max.distance = 0.05, useBytes = TRUE)
  x <- paste0(x,"")
  flight.name$chat.name[i] <- x
}

df<-read.csv("cleanedflight.csv")
#merge flight.name to df

#group_by(ticker, year) %>%
#summarize(GHG=sum(GHG))
