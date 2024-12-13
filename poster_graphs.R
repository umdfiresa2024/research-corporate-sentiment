library('tidyverse')

finaldata <- read.csv('finaldata.csv')
finaldata <- finaldata %>%
  filter(!(is.na(PARENT.COMPANY)))
finaldata$reduction_netzero <- finaldata$reduction + finaldata$netzero
class(finaldata$year)

ggplot(finaldata, aes(x = factor(year), y = reduction_netzero, col = ticker, group = ticker)) +
  geom_point()+
  geom_line()

ggplot(finaldata, aes(x = factor(year), y = GHG, col = ticker, group = ticker))+
  geom_point()+
  geom_line()

ggplot(finaldata, aes(x = GHG, y = reduction_netzero, col = ticker, group = ticker))+
  geom_point()+
  geom_line()

