library(Gmisc, quietly = TRUE)
library(glue)
library(htmlTable)
library(grid)
library(gridExtra)
library(magrittr)
#install.packages("gridExtra")

grid.newpage()
FLIGHT <- boxGrob("FLIGHT",
        width = 0.1, height = 0.1,
        x = 0.15, y = 0.75)
tickers <- boxGrob("Tickers",
                   width = 0.1, height = 0.1,
                   x = 0.35, y = 0.75)
GHG <- boxGrob("GHG",
               width = 0.1, height = 0.1,
               x = 0.275, y = 0.6)
Ticker <- boxGrob("Ticker",
                  width = 0.1, height = 0.1,
                  x = 0.375, y = 0.6)
Year <- boxGrob("Year",
                width = 0.1, height = 0.1,
                x = 0.475, y = 0.6)
Score <- boxGrob("Score",
                 width = 0.1, height = 0.1,
                 x = 0.575, y = 0.6)
SEC_EDGAR <- boxGrob("SEC \n EDGAR",
                     width = 0.1, height = 0.1,
                     x = 0.275, y = 0.3)
CSVs <- boxGrob("CSVs of \n sentences \n for each \n ticker-year",
                width = 0.15, height = 0.25,
                x = 0.425, y = 0.3)
BERT <- boxGrob("BERT",
                width = 0.1, height = 0.1,
                x = 0.575, y = 0.3)

FLIGHT
tickers
GHG
Ticker
Year
Score
SEC_EDGAR
CSVs
BERT
connectGrob(tickers, SEC_EDGAR)
connectGrob(SEC_EDGAR, CSVs, 'horizontal')
connectGrob(CSVs, BERT, 'horizontal')

