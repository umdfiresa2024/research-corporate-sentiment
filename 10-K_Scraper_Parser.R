library('tidyverse')
library('data.table')
library('rvest')
library('httr')
library('htmltidy')

url <- 
  "https://www.sec.gov/cgi-bin/browse-edgar?action=getcompany&CIK=0000320193&type=10-K&dateb=1990&owner=exclude&count=25"

# Scrape filing page identfier numbers
response <- GET(url,add_headers(
  "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
  "Accept-Language" = "en-US,en;q=0.5",
  "Accept" = "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
  "Accept-Encoding" = "gzip, deflate, br",
  "Referer" = "https://www.sec.gov/",
  "Connection" = "keep-alive",
  "DNT" = "1",  # Do Not Track
  "Upgrade-Insecure-Requests" = "1"))
if (status_code(response) == 200) {
  filings <- 
    read_html(response) %>%
    html_nodes(xpath='//*[@id="seriesDiv"]/table') %>%
    html_table() %>%
    as.data.table() %>%
    janitor::clean_names()
} else {
  print(paste("Failed to retrieve page. Status code:", status_code(doc)))
}

# Drop pre XBRL filings
filings <- filings[str_detect(format, "Interactive")]

# Extract filings identifiers with regex match of digits
pattern <- "\\d{10}\\-\\d{2}\\-\\d{6}"
filings <- filings$description
filings <- 
  stringr::str_extract(filings, pattern)

# Build urls for filings using filing numbers and Edgar's url structure
urls <-
  sapply(filings, function(filing) {
    
    # Rebuild URL to match Edgar format
    url <- 
      paste0(
        "https://www.sec.gov/Archives/edgar/data/320193/",
        paste0(
          str_remove_all(filing, "-"),"/"),
        paste0(
          filing, "-index.htm"),
        sep="")
    
    # Return Url
    url
  })
# Extract hrefs with links to 10-K filings
aapl_href <-
  sapply(urls, function(url) {
    
    # Pattern tomatch
    href <- '//*[@id="formDiv"]/div/table'
    response <- GET(url,add_headers(
      "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
      "Accept-Language" = "en-US,en;q=0.5",
      "Accept" = "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
      "Accept-Encoding" = "gzip, deflate, br",
      "Referer" = "https://www.sec.gov/",
      "Connection" = "keep-alive",
      "DNT" = "1",  # Do Not Track
      "Upgrade-Insecure-Requests" = "1"))
    
    if (status_code(response) == 200) {
      # Table of XBRL Documents
      page <- 
        read_html(response) %>%
        xml_nodes('.tableFile') %>%
        html_table()
    } else {
      print(paste("Failed to retrieve page. Status code:", status_code(doc)))
    }

    # Extract document 
    page <- rbindlist(page)
    document <- 
      page[str_detect(page$Type, "10-K")]$Document
    
    # Take break not to overload Edgar
    Sys.sleep(2)
    
    # Reconstite as href link
    href <- 
      paste0(str_remove(url, "\\d{18}.*$"), 
             str_extract(url, "\\d{18}"),
             "/",
             document)
    href <- href %>%
      str_replace_all('iXBRL', '') %>%
      str_trim()
    
    # Return
    href
    
  })

# Show first 5 hrefs
aapl_href[1:5]

for( i in length(aapl_href)){
  response <- GET(aapl_href[i],add_headers(
    "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
    "Accept-Language" = "en-US,en;q=0.5",
    "Accept" = "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
    "Accept-Encoding" = "gzip, deflate, br",
    "Referer" = "https://www.sec.gov/",
    "Connection" = "keep-alive",
    "DNT" = "1",  # Do Not Track
    "Upgrade-Insecure-Requests" = "1"))
  
  doc <- tidy_html(content(response))
  doc <- read_html(response)
  doc <- tidy_html(response)
  doc <- tidy_html(aapl_href[i])
  
  # Using read_html(response)
  paragraphs<-doc %>%
    rvest::html_nodes("p") %>%
    rvest::html_text()
  
  textfile<-str_split(paragraphs,
                      "(?<!\\b(?:Mrs|Mr|Dr|Inc|Ms|Ltd|No|[A-Z])\\.)(?<=\\.|\\?|!)\\s+", 
                      simplify = TRUE) 
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
}
