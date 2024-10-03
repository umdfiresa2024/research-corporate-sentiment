df<-read_file("national_highway_system.txt", )

textfile<-str_split(df,
                    "(?<!\\b(?:Mrs|Mr|Dr|Inc|Ms|Ltd|No|[A-Z])\\.)(?<=\\.|\\?|!)\\s+", 
                    simplify = TRUE)
p<-as.data.frame(t(textfile))

p2<-p %>%
  mutate(charlength=nchar(V1)) %>%
  mutate(first=substr(V1, 1, 1)) %>%
  filter(str_detect(first, "^[A-Z]")) %>%
  filter(charlength>30)

t<-p2$V1

write.csv(t, "sample_netzero.csv", row.names=F)
