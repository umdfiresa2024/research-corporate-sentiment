# Do changes in environmental corporate sentiment lead to changes in GHG levels?

**Author:** FIRE Sustainability Analytics  
**Date:** Fall 2024  
**Editor:** Visual

---

# 1. Introduction

Understanding the impact of environmental corporate sentiment on changes in greenhouse gas emissions emphasizes the importance of environmental communication. By connecting how companies communicate their environmental sentiment with changes in their operation’s greenhouse gas emissions, policymakers can better understand the impact of regulation that requires ecological communication. This connection presents an opportunity to encourage companies to reduce their greenhouse gas emissions and show society their corporate environmental sentiment. This type of communication will become more important as countries look factor pollution output into the costs of production to clean domestic manufacturing. It will also further our knowledge on differentiating honest environmental sentiment that is acted upon as reflected by their pollution levels compared to “cheap talk” (Bingler et al., 2024). Through our data, we hold companies more accountable for their communications of their environmental impacts. By examining greenhouse gas emissions we can narrow our focus to directly connecting a company's sentiment of their pollution to the actual emissions they generate.

# 2. Literature Review

-   Presently, much work has been done on discerning genuine climate commitments and ‘cheap talk’. Current research concludes that firms with poor environmental action tend to communicate more environmental goals to “distract from poor performance” (Preuss & Max, 2023). This study focused on firms that were a part of the S&P500 during the time of the sample space. The reasoning behind this is that firms part of the S&P 500 were more likely to issue sociopolitical statements and are more likely to have PAC contributions compared to smaller firms (Preuss & Max, 2023). This means that policies that intend to generate environmental commitments need to require clarity from companies if they want genuine environmental communications from companies. Identifying specific and genuine environmental communications has been done through ClimateBERT’s environmental claims detection model. Given their large dataset, they decided to not manually verify if each statement contained a keyword, but instead they focused on generating n-grams which were 2-4 words in length. From here the study generated measures of sociopolitical claims per topic. Both of these measurements were based on the frequency of these n-grams within the sample data. The first measure was the number of times any n-gram appeared in the corporate filings data they collected and the second measure docs counted the number of documents per year that included two distinct environmental related n-grams. These measurements were the foundation to the conclusions and claims of the study. 

-   Our research uses the zero-emissions BERT large language model created by (Bingler et al. 2024), to detect sentences with planned GHG reduction sentiments and combine the output with GHG emissions to evaluate if a company’s pollution reflects their sentiment. The zero-emissions BERT large language model is a fine-tuned ClimateBERT language model with a classification head for detecting sentences that are either related to emission net zero or reduction targets. There are multiple studies that have utilized the climateBERT large language model, specifically a study completed by Bingler, relating TCFD recommendations with the impact on disclosures of TCFD-supporting companies. This study is similar to ours, and utilized climateBERT to analyze the disclosures of TCFD-supporting firms. The model found "that the firms' TCFD support is mostly just talk and that these firms cherry-pick to report primarily non-material climate risk information" (Bingler et al. 2022).

-   Our research scans corporate communications from companies for sentences containing emissions information and changes in their corresponding pollution measured by the government. By examining these two variables we will see if companies support their environmental claims through changes in their emission levels.

# 3 Data

## 3.1 FLIGHT

The EPA FLIGHT data set shows the greenhouse gas (GHG) emissions for large facilities. Using this data set, the environmental impact of each company can be quantified. In order to match these companies, to 10-K reports, the company list from FLIGHT is fed into Chat GPT. The intuition is simple: companies that can be associated with a stock ticker will be in the SEC EDGAR database. For this reason, 11, 000 companies were fed into CHAT GPT to determine if each company had a ticker. The output was each company's name and a stock ticker or N/A if a ticker was not found. Chat GPT found 2578 companies with a ticker. Using a string distance library, the Chat GPT output was merged with FLIGHT data to link GHG emissions with these tickers. The string distance library was used to narrow down companies that were repeats or companies that were not even in FLIGHT that Chat GPT may have unintentionally added. Next, the number of years for each company was examined. To keep data uniform and allow for the most specific data, it was determined that only companies with 13 years of data will be used in our data. The final result is 100 companies that will be referenced in SEC EDGAR. Relating the GHG emissions from these companies from the past 13 years to corporate sentiment from SEC EDGAR 10-K reports, a score can be determined for each company. 

## 3.2 SEC EDGAR

10-K documents summarize a company's financial performance and other important information including their environmental and emissions activity. By scraping the SEC EDGAR database, 10-K reports were collected for each company and then parsed by sentence to create a data collection of spreadsheets containing each sentence from each 10-K.

## 3.3 BERT

ClimateBERT is a large language model that is utilized to determine whether the current sentence or phrase is a claim regarding environmental sentiment or not. This model was developed from DistilRoBERTa model, after some further training on both climate related research papers and corporate/general news as well as company reports. From here we decided to utilize the net zero reduction model. This model is a fine tuned version of the climateBERT model, and is able to classify if statements are either related to emission net zero or reduction targets. Thus, this model is an improved version of both the DistilRoBERT model as well as the original climateBERT model. Basically the way we use this model, is we input a csv file of fragmented or whole sentences into this net zero reduction model and one by one the model will return a classification along with a confidence score. Thus, once the entire csv has been ran through the model a new csv with classifications and confidence scores has been produced. Now, we are able to draw conclusions and make claims regarding companies communications regarding net zero reduction and their actual greenhouse gas emissions.

# 4. Summary

## 4.1 Data Cleansing Chart
In this research project much of our time was spent cleaning and parsing through our data to make sure we could correctly pass it into the net zero reduction model. Since we were scraping the SEC EDGAR database to collect 10-k reports for each company and ultimately create a csv file with these statements broken down, we had to make sure that each company we analyzed was public. The reason for this is that only publicly traded companies are required to report these 10k statements. Thus, we parsed through each company in our comapny list to determine which of these companies were publicly traded and therefore have reported 10k statements. From here we were able to then collect data and create a csv file containing the broken down 10k statement. Once we have our final results for this week we will create a chart to document this process, this is just a description of what we had to do. 

## 4.2 Plot
We will create a plot once our results have completed and we have extracted all of the data we need. We cannot draw any conclusions yet as we are still feeding the text into the net zero reduction model. Once this is complete, and we can match company names with their ticker, we will be able to generate a plot and make conclusions about it. 

## 4.3 Discussion
Once again, we are still finishing up processing our results. As these results come finish and we are able to create our plot then we will be able to have a proper discussion regarding our research. We will be able to draw some conclusions as well as make some claims. 

# 5. References

-   Bingler, J., Kraus, M., Leippold, M., & Webersinke, N. (2022). How cheap talk in climate disclosures relates to climate initiatives, corporate emissions, and reputation risk. Swiss Finance Institute Research Paper, (22-01)

-   Preuss, S., & Max, M. M. (2023). Do firms put their money where their mouth is? Sociopolitical claims and corporate political activity. Accounting, Organizations and Society, 101510

-   ClimateBERT Climate . ChatClimate. (n.d.). https://www.chatclimate.ai/climatebert

-   Bingler, J., Kraus, M., Leippold, M., & Webersinke, N. (2022). Cheap talk and cherry-picking: What ClimateBert has to say on corporate climate risk disclosures. Sciencedirect Research Paper, (22-01)

