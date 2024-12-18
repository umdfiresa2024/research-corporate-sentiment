# Do changes in environmental corporate sentiment correlate with changes in GHG levels?
FIRE Sustainability Analytics - Joshua Hildebrand, Sohum Desai, Abhinav
Akenapalli
2024-12-09

# 1. Introduction

Understanding the impact of environmental corporate sentiment on changes
in greenhouse gas emissions emphasizes the importance of environmental
communication. By connecting how publicly traded companies communicate
their environmental sentiment with changes in their operation’s
greenhouse gas emissions, policymakers can better understand the impact
of regulation that requires ecological reporting. This connection
presents an opportunity to encourage companies to reduce their
greenhouse gas emissions and show society their corporate environmental
sentiment in their annual 10-K reports. This type of communication will
become more important as countries factor pollution output into the
costs of production to clean domestic manufacturing. It will also
further our knowledge on differentiating honest environmental sentiment
that is acted upon as reflected by their pollution levels compared to
“cheap talk” (Bingler et al., 2024). Through our data, we hold companies
more accountable for their communications of their environmental
impacts. By examining greenhouse gas emissions reported to the EPA’s
FLIGHT database, we can narrow our focus to directly connecting a
company’s sentiment of their pollution to the actual emissions they
generate. We can focus on this sentiment through closely examining the
10-K reports of these companies in order to detect their environmental
sentiment compared to their actual greenhouse gas emission output.

Our research boils down to three main parts. We had three main data
sources which starts with the EPA Flight data to rack the greenhouse gas
emissions from large facilities. Then, we have the SEC EDGAR 10-k
reports which captures the communications made by these companies, and
ClimateBERT which is utilized to classify environmental sentiment
present in these communications. We started with 11,000 companies from
the FLIGHT data which was then narrowed down to 100 publicly traded
companies that had 13 years worth of emissions data and 10-k filing
statements. Lastly, using ClimateBERT’s net-zero/reduction model we were
able to classify these sentences and compare this with the greenhouse
gas emission data we have.

# 2. Literature Review

- Presently, much work has been done on discerning genuine climate
  commitments and ‘cheap talk’. Current research concludes that firms
  with poor environmental action tend to communicate more environmental
  goals to “distract from poor performance” (Preuss & Max, 2023). This
  study focused on firms that were a part of the S&P 500 betwen 2010
  and 2020. The reasoning behind this is that firms part of The S&P 500
  were more likely to issue sociopolitical statements and are more
  likely to have political action committee (PAC) contributions compared
  to smaller firms (Preuss & Max, 2023). This means that policies that
  intend to generate environmental commitments need to require clarity
  from companies if they want genuine environmental communications from
  companies.

- Identifying specific and genuine environmental communications has been
  done through ClimateBERT’s environmental claims detection model. Given
  Preuss & Max’s large data set of annual reports, shareholder
  preposals, and press releases, they decided to not manually verify if
  each statement contained a keyword, but instead they focused on
  generating n-grams which were 2-4 words in length. From here the study
  generated measures of sociopolitical claims per topic. Both of these
  measurements were based on the frequency of these n-grams within the
  sample data. The first measure was the number of times any n-gram
  appeared in the corporate filings data they collected and the second
  measure docs counted the number of documents per year that included
  two distinct environmental related n-grams. These measurements were
  the foundation to the conclusions and claims of the study. To clarify, the last couple sentences are talking about
  how Preuss & Max broke down their data to detect sentiment from annual reports, shareholder proposals,
and press releases. These can then be inputted into the ClimateBERT model for detection and further analysis. 

- Our research uses the zero-emissions BERT large language model created
  by (Bingler et al. 2024), to detect sentences with planned GHG
  reduction sentiments and combine the output with GHG emissions to
  evaluate if a company’s pollution reflects their sentiment. The
  zero-emissions BERT large language model is a fine-tuned ClimateBERT
  language model with a classification head for detecting sentences that
  are either related to emission net zero or reduction targets. There
  are multiple studies that have utilized the climateBERT large language
  model, specifically a study completed by Bingler, relating Task Force
  on Climate-Related Financial Disclosures (TCFD) recommendations with
  the impact on disclosures of TCFD-supporting companies. This study is
  similar to ours, and utilized climateBERT to analyze the disclosures
  of TCFD-supporting firms. The model found “that the firms’ TCFD
  support is mostly just talk and that these firms cherry-pick to report
  primarily non-material climate risk information” (Bingler et
  al. 2022).

- Our research scans corporate communications from companies for
  sentences containing emissions information and changes in their
  corresponding pollution measured by the government. By examining these
  two variables we will see if companies support their environmental
  claims through changes in their emission levels.

# 3 Data

## 3.1 FLIGHT

The EPA FLIGHT data set shows our outcome variable which is the
greenhouse gas (GHG) emissions for large facilities. Using this data
set, the environmental impact of each company can be quantified. In
order to match these companies, to 10-K reports, the company list from
FLIGHT is fed into Chat GPT. The intuition is simple: companies that can
be associated with a stock ticker will be in the SEC EDGAR database. For
this reason, 11,000 companies were fed into CHAT GPT to determine if
each company had a ticker. The output was each company’s name and a
stock ticker or N/A if a ticker was not found. Chat GPT found 2578
companies with a ticker. Using a string distance library, the Chat GPT
output was merged with FLIGHT data to link GHG emissions with these
tickers. The string distance library was used to narrow down companies
that were repeats or companies that were not even in FLIGHT that Chat
GPT may have unintentionally added. Next, the number of years for each
company was examined. To keep data uniform and allow for the most
specific data, it was determined that only companies with 13 years of
data will be used in our data. The final result is 100 companies that
will be referenced in SEC EDGAR. Relating the GHG emissions from these
companies from the past 13 years to corporate sentiment from SEC EDGAR
10-K reports, a score can be determined for each company.

The below code shows the process of merging the tickers from ChatGPT to
the company names gathered from the EPA FLIGHT database. This begins with
loading the csv files containing the tickers found through ChatGPT. This
code ensures that all data points are strings in order to use string
distance matching.
``` r
chat<-rbind(chatgpt_output, chatgpt_output2, chatgpt_output3) |>
  filter(ticker!="N/A")
library("stringi")
flight.name<-as.data.frame(raw_flight$x)
names(flight.name)<-"flight.name"
chat.name<-chat$company
chat.name <-stri_encode(chat.name, "","UTF-8")
```
The below code snippet utilizes string distance matching to properly
merge the company names to tickers. We do this because some of the 
company names given by ChatGPT corresponding to the tickers do not
directly match the EPA FLIGHT company names.
``` r
flight_output <- c()
for (i in 7033:dim(flight.name)[1]) {
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
```
The data was then filtered to strings that were exact matches (V3 == 0).
This data was then merged with the EPA FLIGHT database to get the matched
output dataframe.
``` r
install.packages("plyr")
library("plyr")
df<-read.csv("match_flight1.csv")
f<-as.data.frame(rbind.fill(df, flight_output)) |>
  filter(V3==0) |>
  dplyr::select(V1, V2)
names(f)<-c("flight", "company")
merged <- merge(f, chat, by = "company")
tick<-unique(merged$ticker)
write.csv(tick, "flight_tickers.csv", row.names=F)
grouped_merge <- merged %>% 
  group_by(ticker, year) %>%
  summarize(GHG=sum(GHG))
```

## 3.2 SEC EDGAR

10-K documents summarize a company’s financial performance and other
important information including their environmental and emissions
activity. By scraping the SEC EDGAR database, 10-K reports were
collected for our geographic unit, each company, for a frequency of each
year for the past 13 years and then parsed by sentence to create a data
collection of spreadsheets containing each sentence from each 10-K.
After gathering companies from the FLIGHT database, we filtered the
companies to only consider ones that are publicly traded. This ensures
that they will be in the SEC EDGAR database since this database only has
companies that are publicly traded. This task produced one spreadsheet
of sentences for the past 13 years for each of the 100 FLIGHT companies
yielding 1,300 spreadsheets.

``` r
library('tidyverse')
library('data.table')
library('rvest')
library('httr')

symbol_table <- as.data.frame(read.csv('unique_tickers_only.csv'))
symbol<-read.csv('flight_tickers.csv', header = TRUE) |>
  filter(!str_detect(x,"N/A")) |> 
  filter(!str_detect(x, " ")) |>
  filter(!str_detect(x,"\\."))


try_scrape_parse <- function(i){
  tryCatch({
    
url <- paste0("http://www.sec.gov/cgi-bin/browse-edgar?action=getcompany&CIK=", 
              symbol$x[i], "&type=10-k&dateb=&owner=exclude&count=100")

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
if (status_code(response) == 200) {
  filings <- 
    read_html(response) %>%
    html_nodes(xpath='//*[@id="seriesDiv"]/table') %>%
    html_table() %>%
    as.data.table() %>%
    janitor::clean_names()
} else {
  print(paste("Failed to retrieve 1st Response page. Status code:", status_code(doc)))
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
        "https://www.sec.gov/Archives/edgar/data/",cik_number,"/",
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
      print(paste("Failed to retrieve 2nd Response page. Status code:", status_code(response)))
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

aapl_href <- lapply(aapl_href, function(x) {
  result <- x[str_detect(x, "htm$")]
  if (length(result) == 0) character(0) else result
})

# Show first 5 hrefs
#aapl_href[1:5]
#dir.create('AAPL_Scraped_Parsed')

for( j in 1:length(aapl_href)){
  response <- GET(as.character(aapl_href[j]),add_headers(
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
    doc <- read_html(response)
    
  } else {
    print(paste("Failed to retrieve Response3 page. Status code:", status_code(response)))
  }

  
  # Using read_html(response)
  paragraphs<-doc %>%
    rvest::html_nodes("p, div") %>%
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
    filter(`charlength` > 30 & str_ends(V1,"\\.")) %>%
    select(V1)
  
  filename <- unlist(str_split(names(aapl_href[j]), "-"))[2]
  write.csv(p3, 
            paste0("G:/Shared drives/2024 FIRE-SA/DATA/Companies_Scraped(2)/", 
                       symbol$x[i], "_", filename, ".csv"))
}
},
  error = function(e){
    message(paste0("An error occurred at ", i," ", symbol$x[i]))
    print(e)
  },
  warning = function(w){
    message(paste0("A warning occurred at ", i, " ", symbol$x[i]))
    print(w)
    return(NA)
  })
}
for (i in 2:nrow(symbol)) {
  try_scrape_parse(i)
}
try_scrape_parse(1)
```

## 3.3 BERT

ClimateBERT is a large language model that is utilized to determine
whether the current sentence or phrase is a claim regarding
environmental sentiment or not. This model was developed from
DistilRoBERTa model, after some further training on both climate related
research papers and corporate/general news as well as company reports
(ChatClimate - About, n.d.). From here we decided to utilize the net
zero reduction model. This model is a fine tuned version of the
climateBERT model, and is able to classify if statements are either
related to emission net zero or reduction targets (ChatClimate - About,
n.d.). Thus, this model is an improved version of both the DistilRoBERT
model as well as the original climateBERT model. 

Basically the way we
use this model, is we input a csv file of fragmented or whole sentences
into this net zero reduction model and one by one the model will return
a classification along with a confidence score which is our dependent
variable. Thus, once the entire csv has been ran through the model a new
csv with classifications and confidence scores has been produced. 

Now, we are able to draw conclusions and make claims regarding companies
communications regarding net zero reduction and their actual greenhouse
gas emissions. After the whole csv has been processed we can compare the
sentences classified as reduction and compare that to the total number
of sentences. This will then provide a ratio which we can compare with
any company along with their greenhouse gas emissions. The most crucial
part of this is that the ratio we calculate represent the fraction of
sentences with net-zero commitments. 

An example sentence which was
identified as net-zero is: “After reconsidering the arguments for the
2018 final rule and finding them lacking, FHWA proposed to require State
DOTs and MPOs that have NHS mileage within their State geographic
boundaries and metropolitan planning area boundaries, respectively, to
establish declining targets for reducing CO2 emissions generated by
on-road mobile sources, that align with the Administration’s target of
net-zero emissions, economy-wide, by 2050, accordance with the national
policy established under section 1 of E.O. 13990, “Protecting Public
Health and the Environment and Restoring Science to Tackle the Climate
Crisis”, section 201 of E.O. 14008, “Tackling the Climate Crisis at Home
and Abroad”, and at the Leaders Summit on Climate.” The model
successfully parsed through this sentence was trained to identify this
as a sentence regarding net zero emissions.

```
# Process each text entry
        for text in df['V1'].tolist():
            try:
                result = pipe_env(text)
                sentiment.append(result)
                classifications.append(result[0]['label'])
            except Exception as e:
                print(f"Error processing text in {path}: {str(e)}")
                classifications.append("error")
                sentiment.append(None)

        # Create results DataFrame
        df_results = pd.DataFrame({
            'text': df['V1'].tolist(),
            'classification': classifications
        })

```
This code is where pass in each broken down statement into the ClimateBERT model. The model will then 
complete its classification and append the result to the given statement. Should there be any error in classification, 
the model will append error instead to indicate something went wrong in classification. Then, the results dataframe
will be created storing all of the sentences along with their classifications. 

To summarize: 
- The outcome variable is GHG emissions
- The dependent variable is Corporate Sentiment score
- The frequency is year and geographical unit is each company

# 4. Summary

## 4.1 Data Cleansing Chart

![Data Cleansing
Chart](Poster%20Stuff/Copy%20of%20Data%20Cleansing%20Chart%20Corporate%20Sentiment%20(2).png)

Only publicly traded companies are required to report 10-K statements.
Thus, we parsed through each company in our EPA FLIGHT company list to
generate tickers only for that companies were publicly traded and
therefore have reported 10-K statements. From here we were able to then
scrape the SEC EDGAR collect data and create a csv file containing the
broken down 10-K statement’s sentences for each ticker-year. These csv
files were then process through the BERT net zero reduction model to
identify emission reduction sentences. Lastly we generate scores by
computing ratio of reduction sentences to total sentences in the 10-K
report and connected them to the quantity of GHG emissions for each year
as reported on EPA FLIGHT database.

## 4.2 Plot

![GHG per year plot](GHG_year.png) This plot shows the GHG per year for
each of the 15 companies.

![Reduction plot](reduction_GHG.png) This plot shows the number of
reductions according to each GHG value for each of the 15 companies.

![Correlation plot](Poster%20Stuff/correlation.png) This plot shows the
relationship between corporate sentiment and GHG emissions for each
company.

## 4.3 Empirical Analysis and Linear Regression

### Empirical Analysis

Our research examined the relationship between environmental corporate
sentiment and greenhouse gas emissions utilizing the following model.
Note, this is a simiplified version of what our research looked like to
give a glimpse into how we achieved our results.

    Sentiment_Score(i,t) = (Reduction_Sentences(i,t) + NetZero_Sentences(i,t)) / Total_Sentences(i,t)
    where:
    i = company identifier
    t = year (2010-2022)
    Reduction_Sentences = sentences classified as containing emission reduction commitments
    NetZero_Sentences = sentences classified as containing net-zero targets

To analyze the relationship between sentiment and emissions, we
estimate:

    Sentiment_Score(i,t) = β₀ + β₁GHG_Emissions(i,t) + γᵢ + δₜ + ε(i,t)
    where:
    β₀ = intercept term
    β₁ = coefficient measuring the relationship between GHG emissions and sentiment
    γᵢ = company fixed effects
    δₜ = year fixed effects
    ε(i,t) = error term

The sentiment score for each company-year observation is calculated as
the ratio of sentences classified by ClimateBERT as either emission
reduction or net-zero commitments to total sentences in the 10-K report.
GHG emissions are measured in metric tons of CO2 equivalent as reported
to EPA FLIGHT.

### Linear Regression Summary

``` r
library('tidyverse')
library('fixest')
df<-read.csv("finaldata.csv")

df2<-df |>
  mutate(score=(reduction+netzero)*100/sentences) |>
  mutate(PARENT.COMPANY=ifelse(str_detect(PARENT.COMPANY, "Chevron"), "Chevron", PARENT.COMPANY))
m1<-feols(GHG ~ score:as.factor(ticker) | ticker + year, data=df2)
summary(m1)
```

    OLS estimation, Dep. Var.: GHG
    Observations: 195
    Fixed-effects: ticker: 15,  year: 13
    Standard-errors: Clustered (ticker) 
                                 Estimate Std. Error   t value   Pr(>|t|)    
    score:as.factor(ticker)ABT 11015617.0    7032441  1.566400 1.3957e-01    
    score:as.factor(ticker)ADI  1006307.8   11561987  0.087036 9.3188e-01    
    score:as.factor(ticker)ADM  -575054.5    1242152 -0.462950 6.5051e-01    
    score:as.factor(ticker)APD  5063034.2    1816499  2.787248 1.4541e-02 *  
    score:as.factor(ticker)ATI -6625038.8    6270115 -1.056606 3.0858e-01    
    score:as.factor(ticker)BMY -6547807.0    5844456 -1.120345 2.8142e-01    
    score:as.factor(ticker)CAG -5801834.4   15110025 -0.383973 7.0677e-01    
    score:as.factor(ticker)CAT -6523751.3   12836426 -0.508222 6.1921e-01    
    score:as.factor(ticker)CE   2977058.6    4321171  0.688947 5.0212e-01    
    score:as.factor(ticker)CF  18430294.5    2608069  7.066643 5.6242e-06 ***
    score:as.factor(ticker)CLF 61671107.3    1819253 33.899132 7.7067e-15 ***
    score:as.factor(ticker)CNP  4577781.3    1659530  2.758481 1.5387e-02 *  
    score:as.factor(ticker)COP -8357158.9    1719811 -4.859349 2.5280e-04 ***
    score:as.factor(ticker)CVX -6210008.3    2206426 -2.814510 1.3781e-02 *  
    score:as.factor(ticker)ED    -50255.1    1035133 -0.048549 9.6196e-01    
    ---
    Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    RMSE: 2,913,161.3     Adj. R2: 0.713618
                        Within R2: 0.369347

![Coefficient plot](Poster%20Stuff/coefficients.png) This graph shows
95% confidence intervals for the correlation between corporate sentiment
and GHG emissions for each company.

# 5. Discussion

## 5.1 Findings

After completing all of the research above, we actually found that there
is a pattern regarding corporate sentiment and actual changes in GHG
levels. We found that companies with higher GHG emissions consistently
produce more environmental reduction/net-zero commitments or statements
in their sentiment. This correlation suggests that companies who produce
more GHG emissions, attempt to make up for it or mask it via
environmental communication.

## 5.2 Quantitative Analysis

From the data we collected and processed there are various metrics that
show us this correlation between corporate sentiment and greenhouse gas
emissions. From the graphs produced, we can see that firms with
emissions that exceed 20 million GHG units, generally also have nearly
2-3 times more statements regarding reduction/net-zero commitments. It
is also important to recognize that even with communication increasing
through the years, the emissions remained pretty stable signaling that
there is no action behind these commitments. Lastly, when
reduction/net-zero statements are increasing, we also see higher
emission in these times.

## 5.3 Mechanisms

There are various mechanisms that drive this correlation between
corporate sentiment and GHG emissions detailed below. 1. Implementation
Timeline - It takes time for changes to be reflected once they are
announced. For example, if a given plan is announced it may take an
entire year for the change to be reflected in the data. 2. Mergers and
Acquisitions - When companies merge or are acquired by others, there can
be an effect in the emission measurement. Relocation also plays a factor
in emissions measurements whether it could be an increase, decrease, or
loss of data.

## 5.4 Literature Context

Our findings are very similar and correlate with existing research.
Bingler et al.(2022) found that firms with poor environmental
performance tend to communicate more reduction/net-zero commitments to
“distract from poor performance.” Our study further validates this
phenomenon across a longer time frame with emissions data.

# 6. Future Plans

Our future plans for this project are vast, but some ways that we can
proceed have been detailed below.

1.  Industry Specific Research
    - Moving forward we could analyze sector specific patterns, and see
      if different sectors have different correlations between GHG and
      corporate sentiment
2.  Increased Timeframe and Firms
    - This data processing handling requires a lot of computing power,
      so with some more powerful computing resources we may be able to
      expand our research across many more firms and years, ultimately
      making our findings more reliable.
3.  Policy Influence
    - Another way to move forward includes researching more about policy
      changes and how they effect corporate sentiment. How effective are
      current disclosure policies? Do changes in these policies also
      change corporate sentiment?

# 7. References

- Bingler, J., Kraus, M., Leippold, M., & Webersinke, N. (2022). How
  cheap talk in climate disclosures relates to climate initiatives,
  corporate emissions, and reputation risk. Swiss Finance Institute
  Research Paper, (22-01)

- Preuss, S., & Max, M. M. (2023). Do firms put their money where their
  mouth is? Sociopolitical claims and corporate political activity.
  Accounting, Organizations and Society, 101510

- ChatClimate - About. (n.d.). Frigg.eco.
  <https://www.chatclimate.ai/climatebert>

- Bingler, J., Kraus, M., Leippold, M., & Webersinke, N. (2022). Cheap
  talk and cherry-picking: What ClimateBert has to say on corporate
  climate risk disclosures. Sciencedirect Research Paper, (22-01)
