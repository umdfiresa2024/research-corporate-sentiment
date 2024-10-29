
library("xml2")
library("httr")
library("XBRL")
library("tidyverse")

options(HTTPUserAgent = "tjones77@terpmail.umd")
info.df <- AnnualReports("GOOG")

symbol<-"CETY"

url <- paste0("http://www.sec.gov/cgi-bin/browse-edgar?action=getcompany&CIK=", 
              symbol, "&type=10-k&dateb=&owner=exclude&count=100")

filings <- xml2::read_html(url)

#extract information of filing name
filing.name <-
  filings %>%
  rvest::html_nodes("#seriesDiv td:nth-child(1)") %>%
  rvest::html_text()

##   Acquire filing date
filing.date <-
  filings %>%
  rvest::html_nodes(".small+ td") %>%
  rvest::html_text()

##   Acquire accession number
accession.no.raw <-
  filings %>%
  rvest::html_nodes(".small") %>%
  rvest::html_text()

accession.no <-
  gsub("^.*Acc-no: ", "", accession.no.raw) %>%
  substr(1, 20)

##   Create dataframe
info.df <- data.frame(filing.name = filing.name, filing.date = filing.date, 
                      accession.no = accession.no)

# Create a directory to store the annual reports
dir_name <- paste0(symbol, "_AnnualReports")
dir.create(dir_name, showWarnings = FALSE)

for (i in 1:length(info.df$filing.name)) {
  
  if(trimws(info.df$filing.name[i]) == "10-K/A") { #skip if it is 10-K/a
    next
  }
  path <- paste0("tr:nth-child(", i + 1 , ") td:nth-child(2) a")
  
  urlToZipPath  <- filings %>%
    rvest::html_node(path) %>%
    rvest::html_attr("href")
  
  converted_string <- sub("\\-index.htm$", ".txt", urlToZipPath)
  
  if(str_sub(converted_string, start = tail(unlist(gregexpr('\\.', converted_string)), n=1)+1) == "html"){
    converted_string = sub("\\-index.html$", ".txt", urlToZipPath)
  }
  
  report_url <- paste0("https://www.sec.gov", converted_string)
  file_name <- str_sub(converted_string, start = tail(unlist(gregexpr('/', converted_string)), n=1)+1)
  dest <- paste0(dir_name,"/",file_name)

expr = {
  download.file(report_url, dest, mode = "wb")
}
}

################################33
head(d)
d<-dir(paste0(symbol,"_AnnualReports"), pattern=".txt")
dir.create(paste0(symbol, '_ScrapedAnnualReports'))



for(i in 1:length(d)){

page_content<-read_html(raw_content_cleaned, as="text", options = c('HUGE','RECOVER'))

paragraphs<-page_content %>%
  rvest::html_nodes("p") %>%
  rvest::html_text()

#####################################
textfile<-str_split(paragraphs,
                           "(?<!\\b(?:Mrs|Mr|Dr|Inc|Ms|Ltd|No|[A-Z])\\.)(?<=\\.|\\?|!)\\s+", 
                           simplify = TRUE) 



# Weird issue occurred where textfile created matrix where the first obs had many variables and columns
# Used paste*() to bind all columns, but paste returns a character so matrix() is used to restore matrix
# textfile is now one matrix that is one column, changed p <- as.data.frame(t(textfile)) as transpose is no longer necessary
textfile <- matrix(paste(textfile))
p<-as.data.frame(textfile)


p2<-p %>%
  mutate(charlength=nchar(V1)) %>%
  mutate(first=substr(V1, 1, 1)) %>%
  filter(str_detect(first, "^[A-Z]")) %>%
  mutate("White spaces" = str_count(V1, " ")) %>%
  mutate("Non-breaking space character" = str_count(V1, "\u00A0"))

p3<-p2 %>%
  filter(`Non-breaking space character`<20)%>%
  filter(`charlength` > 30 & str_ends(V1,"\\."))

filename<-str_split(aapl_href[i], "-",simplify=TRUE)[1,2]

write.csv(p3, paste0(symbol,"_ScrapedAnnualReports/year_", filename, ".csv"))

}

