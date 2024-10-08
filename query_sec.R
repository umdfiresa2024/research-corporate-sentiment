library("httr")

name<-"1804"
api<-"67f15f74f937e7f6376252601326b292d0002f7e51431616c2b3a5384329c981"
url<-paste0("https://api.sec-api.io/mapping/name/", name, "?token=", api)

filename<-paste0("sec_api/", name, ".json")
GET(url,write_disk(filename, overwrite = TRUE))

