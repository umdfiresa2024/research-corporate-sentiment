library('tidyverse')
library('data.table')
library('rvest')
library('httr')
library('htmltidy')
url <- paste0("http://www.sec.gov/cgi-bin/browse-edgar?action=getcompany&CIK=AES&type=10-k&dateb=&owner=exclude&count=100")
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
  company_info <- 
    read_html(response) %>%
    html_nodes(xpath='//*[@id="contentDiv"]/div[1]/div[3]/span/a')
    #html_table() %>%
    #as.data.table() %>%
    #janitor::clean_names()
  cik_number <- sub(".*CIK=(\\d{10}).*", "\\1", company_info)
} else {
  print(paste("Failed to retrieve 1st Response page. Status code:", status_code(doc)))
}

### Current xpath finds the companyInfo from which we can find the CIK number to fix the 320193 Issue