library("httr")
library("jsonlite")
library("tidyverse")

df<-read.csv("companylist.csv") %>%
  mutate(x=str_remove(x, "LLC")) %>%
  mutate(x=str_remove(x, "Inc.")) %>%
  mutate(x=str_remove(x, "Inc")) %>%
  mutate(x=str_remove(x, "INC")) %>%
  mutate(x=str_remove(x, "LTD")) %>%
  mutate(x=trimws(x, "both"))

comp<-df$x


get_sec <- function(i) {
  tryCatch(
    #try to do this
    {
      name<- comp[i]
      api<-"340127a6d808327065204d5164d913f36a7fb564ce3bf98362638b4c3da99d4c"
      url<-paste0("https://api.sec-api.io/mapping/name/", name, "?token=", api)
      
      filename<-"sec_api/file.json"
      GET(url,write_disk(filename, overwrite = TRUE))
      
      data <- fromJSON("sec_api/file.json", simplifyVector = TRUE)
      
      eia_json_df <- raw_json$response$data
      data2<-data %>%
        filter(ticker!="")
      
      ticker <- data2$ticker[1]
    
      },
    #if an error occurs, tell me the error
    error=function(e) {
      message('An Error Occurred')
      print(e)
    },
    #if a warning occurs, tell me the warning
    warning=function(w) {
      message('A Warning Occurred')
      print(w)
      return(NA)
    }
  )
}



tickers <- c()
#for (i in 2:length(comp)) {
for (i in 2:5) {
  print(i)
  ticker <- get_sec(i)
  tickers<-rbind(tickers, ticker)
}
  
  
  
  
  
  
  
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



