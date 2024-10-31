library("tidyverse")
library("readxl")

raw_flight<-read.csv("companylist.csv")
  

chatgpt_output<-read_excel("G:/Shared drives/2024 FIRE-SA/Fall Course/tickers.xlsx")
chatgpt_output2<-read.csv("corporate sentiment - Sheet1.csv", header=FALSE)
names(chatgpt_output2)<-c("company", "ticker")
chatgpt_output3<-read.csv("company final tickers.csv")
names(chatgpt_output3)<-c("company", "ticker")

chat<-rbind(chatgpt_output, chatgpt_output2, chatgpt_output3) |>
  filter(ticker!="N/A")

library("stringi")

flight.name<-as.data.frame(raw_flight$x)
names(flight.name)<-"flight.name"
chat.name<-chat$company
chat.name <-stri_encode(chat.name, "","UTF-8")

#flight=sp500
#chat=nyse
flight_output <- c()
#for(i in 2:dim(flight.name)[1]) {
for (i in 2:100) {
  print(i)
  
  distmatrix <- stringdist::stringdistmatrix(flight.name[i,1], 
                                             chat.name[1:2578], 
                                             method = 'lcs', p = 0.1)
  
  best_fit <- apply(distmatrix, 1, which.min)
  similarity <- apply(distmatrix, 1, min)
  output<-as.data.frame(cbind(flight.name[i,1], 
                              chat.name[best_fit], 
                              round(similarity,3)))
  flight_output<-rbind(flight_output, output)
}


df<-read.csv("cleanedflight.csv")
#merge flight.name to df
merged <- merge(flight.name, df, by.x = "chat.name", by.y = "PARENT.COMPANY")
grouped_merge <- merged %>% 
  group_by(ticker, year) %>%
  summarize(GHG=sum(GHG))

#group_by(ticker, year) %>%
#summarize(GHG=sum(GHG))
