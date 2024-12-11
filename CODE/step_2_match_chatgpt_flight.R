library("tidyverse")
library("readxl")
library("stringi")

#clean and filter flight companies
raw_flight<-read.csv("OUTPUT/companylist.csv")

f<-raw_flight |>
  filter(!str_detect(x, "LLC")) |>
  filter(!str_detect(x, "L.L.C.")) |>
  filter(!is.na(x)) |>
  mutate(match_name=toupper(x)) |>
  mutate(match_name=str_remove_all(match_name, "COMPANY")) |>
  mutate(match_name=str_remove_all(match_name, "HOLDINGS")) |>
  mutate(match_name=str_remove_all(match_name, "HOLDING")) |>
  mutate(match_name=str_remove_all(match_name, "INC")) |>
  mutate(match_name=str_remove_all(match_name, "INC")) |>
  mutate(match_name=str_remove_all(match_name, "CORPORATION")) |>
  mutate(match_name=str_remove_all(match_name, "CORP")) |>
  mutate(match_name=str_remove_all(match_name, "LP")) |>
  mutate(match_name=str_remove_all(match_name, "LTD")) |>
  mutate(match_name=str_remove_all(match_name, ", .")) |>
  mutate(match_name=str_remove_all(match_name, "L.P.")) 

chatgpt_output<-read_excel("G:/Shared drives/2024 FIRE-SA/Fall Course/tickers.xlsx")
chatgpt_output2<-read.csv("corporate sentiment - Sheet1.csv", header=FALSE)
names(chatgpt_output2)<-c("company", "ticker")
chatgpt_output3<-read.csv("company final tickers.csv")
names(chatgpt_output3)<-c("company", "ticker")

chat<-rbind(chatgpt_output, chatgpt_output2, chatgpt_output3) |>
  filter(ticker!="N/A") |>
  mutate(match_name=toupper(company)) |>
  filter(!str_detect(match_name, "LLC")) |>
  filter(!str_detect(match_name, "L.L.C.")) |>
  mutate(match_name=str_remove_all(match_name, "COMPANY")) |>
  mutate(match_name=str_remove_all(match_name, "HOLDINGS")) |>
  mutate(match_name=str_remove_all(match_name, "HOLDING")) |>
  mutate(match_name=str_remove_all(match_name, "INC")) |>
  mutate(match_name=str_remove_all(match_name, "INC")) |>
  mutate(match_name=str_remove_all(match_name, "CORPORATION")) |>
  mutate(match_name=str_remove_all(match_name, "CORP")) |>
  mutate(match_name=str_remove_all(match_name, "LP"))|>
  mutate(match_name=str_remove_all(match_name, "LTD")) |>
  mutate(match_name=str_remove_all(match_name, ", .")) |>
  mutate(match_name=str_remove_all(match_name, "L.P.")) 
  
flight.name<-as.data.frame(f$match_name)
names(flight.name)<-"flight.name"
chat.name<-chat$match_name
chat.name <-stri_encode(chat.name, "","UTF-8")

#run match algorithm
flight_output <- c()

for (i in 1:dim(flight.name)[1]) {
  print(i)
  
  distmatrix <- stringdist::stringdistmatrix(flight.name[i,1], 
                                             chat.name[1:2200], 
                                             method = 'lcs', p = 0.1)
  
  best_fit <- apply(distmatrix, 1, which.min)
  similarity <- apply(distmatrix, 1, min)
  output<-as.data.frame(cbind(flight.name[i,1], 
                              chat.name[best_fit], 
                              round(similarity,3)))
  flight_output<-rbind(flight_output, output)
}

write.csv(flight_output, "OUTPUT/step_2_match_flight.csv")

#match companies with tickers

flight_output<-read.csv("OUTPUT/step_2_match_flight.csv")

f2<-flight_output |>
  filter(V3<=1) |>
  rename(chat_match_name=V2) |>
  rename(flight_match_name=V1)

names(chat)<-c("chat_company", "ticker", "chat_match_name")

f3<-merge(f2, chat, by="chat_match_name") |>
  filter(ticker!="None")

names(f)<-c("flight_company", "flight_match_name")

merged <- merge(f, f3, by = "flight_match_name") 

m2<-merged |>
  filter(!str_detect(ticker, "Madrid")) |>
  filter(!str_detect(ticker, "Tokyo")) |>   
  filter(!str_detect(ticker, "Hong Kong")) |>
  filter(!str_detect(ticker, "delisted")) |>
  filter(!str_detect(ticker, "TSE")) |>
  filter(!str_detect(ticker, "Air Liquide SA")) |>
  filter(!str_detect(ticker, "Akzo Nobel NV")) |>
  filter(!str_detect(ticker, "I Squared Capital")) |>
  mutate(ticker=ifelse(str_detect(ticker, "PotashCorp"), "NTR", ticker)) |>
  mutate(ticker=ifelse(str_detect(ticker, "Nutrien"), "NTR", ticker)) |>
  mutate(ticker=ifelse(str_detect(ticker, "General Electric"), "GE", ticker)) |>
  mutate(ticker=ifelse(str_detect(ticker, "Northrop"), "NOC", ticker)) |>
  mutate(ticker=ifelse(str_detect(ticker, "Occidental Petroleum"), "OXY", ticker)) |>
  mutate(ticker=ifelse(str_detect(ticker, "Marathon Petroleum"), "MPC", ticker)) |>
  mutate(ticker=ifelse(str_detect(ticker, "APA Corporation"), "APA", ticker)) |>
  mutate(ticker=ifelse(str_detect(ticker, "Arch Resources"), "ARCH", ticker)) |>
  mutate(ticker=ifelse(str_detect(ticker, "Microchip Technology"), "MCHP", ticker)) |>
  mutate(ticker=ifelse(str_detect(ticker, "Broadcom"), "AVGO", ticker)) |>
  mutate(ticker=ifelse(str_detect(ticker, "PEIX"), " ALTO", ticker)) |>
  mutate(ticker=ifelse(str_detect(ticker, "Pacific Ethanol"), " ALTO", ticker)) |>
  mutate(ticker=ifelse(str_detect(ticker, "Westlake Chemical"), "WLK", ticker)) |>
  mutate(ticker=ifelse(str_detect(ticker, "Waste Management"), "WG", ticker)) |>
  mutate(ticker=ifelse(str_detect(ticker, "BASF"), "BASF", ticker)) |>
  mutate(ticker=ifelse(str_detect(ticker, "BAYRY"), "BAYRY", ticker)) |>
  mutate(ticker=ifelse(str_detect(ticker, "ADI"), "ADI", ticker)) |>
  mutate(ticker=ifelse(str_detect(ticker, "WRK"), "WRK", ticker)) |>
  mutate(ticker=ifelse(str_detect(ticker, "BRK"), "BRK", ticker)) |>
  mutate(ticker=ifelse(str_detect(ticker, "TAP"), "TAP", ticker)) |>
  mutate(ticker=ifelse(str_detect(ticker, "SWN"), "SWN", ticker)) |>
  mutate(ticker=ifelse(str_detect(ticker, "NEM"), "NEM", ticker)) |>
  mutate(ticker=ifelse(str_detect(ticker, "NEE"), "NEE", ticker)) |>
  mutate(ticker=ifelse(str_detect(ticker, "NGG"), "NGG", ticker)) |>
  mutate(ticker=ifelse(str_detect(ticker, "Southern Company"), "SO", ticker)) |>
  mutate(ticker=ifelse(str_detect(ticker, "NSANY"), "NSANY", ticker)) |>
  mutate(ticker=ifelse(str_detect(ticker, "CVX"), "CVX", ticker)) |>
  mutate(ticker=ifelse(str_detect(ticker, "Eversource Energy"), "ES", ticker)) |>
  mutate(ticker=ifelse(str_detect(ticker, "NiSource"), "NI", ticker)) |>
  mutate(ticker=ifelse(str_detect(ticker, "NVS"), "NVS", ticker)) |>
  mutate(ticker=ifelse(str_detect(ticker, "HINDALCO"), "HINDALCO.BO", ticker)) |>
  mutate(ticker=ifelse(str_detect(ticker, "NUE"), "NUE", ticker)) |>
  mutate(ticker=ifelse(str_detect(ticker, "NSC"), "NSC", ticker)) |>
  mutate(ticker=ifelse(str_detect(chat_match_name, "CYPRESS SEMICONDUCTOR "), "IFNNY", ticker)) |>
  mutate(ticker=ifelse(str_detect(chat_match_name, "BIOFUEL ENERGY"), "GPRE", ticker))

#clean companies that merged
#temp<-merged |>
#  filter(str_detect(ticker, "\\("))

#temp<-m2 |>
#  filter(str_detect(ticker, "\\("))

flight_ghg<-read.csv("OUTPUT/step_1_flight_ghg.csv") |>
  rename(flight_company=PARENT.COMPANY)

m3<-merge(m2, flight_ghg, by="flight_company") 

m4<-m3 |>
  group_by(ticker, year) |>
  summarise(GHG=sum(GHG)) |>
  filter(year>=2014 & year<=2022) |>
  group_by(ticker) |>
  mutate(yearcount=n()) |>
  filter(yearcount==9)

#get companies full name (495 companies that matched flight and ticker)
m5<-m3 |>
  mutate(namechar=nchar(chat_company)) |>
  mutate(chat_company=toupper(chat_company)) |>
  group_by(ticker) |>
  mutate(maxchar=max(namechar)) |>
  filter(maxchar==namechar) |>
  group_by(ticker) |>
  mutate(id = row_number()) |>
  filter(id==1) |>
  select(chat_company, ticker, flight_company)

m6<-merge(m4, m5, by="ticker")

write.csv(m6, "OUTPUT/step_2_tickers_ghg.csv", row.names=F)

tick<-unique(m6$ticker)

write.csv(tick, "OUTPUT/step_2_flight_tickers.csv", row.names=F)
