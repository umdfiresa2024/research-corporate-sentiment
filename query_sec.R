library("httr")
library("jsonlite")
df<-read.csv("companylist.csv")

comp<-df$x

tickers <- c()
for (i in 3:length(comp)) {
  name<- comp[i]
  api<-"340127a6d808327065204d5164d913f36a7fb564ce3bf98362638b4c3da99d4c"
  url<-paste0("https://api.sec-api.io/mapping/name/", name, "?token=", api)
  
  filename<-"sec_api/file.json"
  GET(url,write_disk(filename, overwrite = TRUE))
  
  data <- fromJSON(paste0("sec_api/",name))
  ticker <- data$ticker[1]
}
tickers
#json_data <- fromJSON(paste(readLines('sec_api/1804.json'), collapse=""))
#raw_json <- fromJSON(file = 1804.json)

# convert json to a spreadsheet

#json_df <- raw_json$cik

#eia_df <- as.data.frame(do.call(rbind,   json_df ))

#eia_df$respondent <- unlist(eia_df$respondent)

#print(eia_df$respondent)



