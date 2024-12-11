library("tidyverse")

path<-"G:/Shared drives/2024 FIRE-SA/DATA/ProcessedCSV/FIRE298/"
folders<-dir(path)

df<-read.csv("OUTPUT/step_4_bert.csv")

bertall<-c()
for (f in 12:13) {
  print(f)
  file_list<-dir(paste0(path, folders[f]))
  
  bert<-c()
  
  for (i in 1:length(file_list)) {
    print(paste0(path,folders[f], "/", file_list[i]))
  df <-read.csv(paste0(path,folders[f], "/", file_list[i])) |>
    mutate(sentences=1) |>
    mutate(reduction=ifelse(classification=="reduction",1,0)) |>
    mutate(netzero=ifelse(classification=="net-zero",1,0)) |>
    mutate(error=ifelse(classification=="error",1,0)) |>
    summarize(sentences=sum(sentences), reduction=sum(reduction),
              netzero=sum(netzero), error=sum(error)) |>
    mutate(filename=file_list[i])
  
  bert<-rbind(bert, df)
  }
  
  bertall<-rbind(bertall, bert)
}

bert2<-rbind(df, bertall)
write.csv(bert2, "OUTPUT/step_4_bert2.csv", row.names=F)
write.csv(bertall, "OUTPUT/step_4_bert.csv", row.names=F)
