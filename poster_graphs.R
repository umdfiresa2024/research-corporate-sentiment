library('tidyverse')
finaldata <- read.csv('finaldata.csv')
finaldata <- finaldata %>%
  filter(!(is.na(PARENT.COMPANY)))
finaldata$reduction_netzero <- finaldata$reduction + finaldata$netzero
class(finaldata$year)

ggplot(finaldata, aes(x = factor(year), y = reduction_netzero, col = ticker)) +
  geom_point()

ggplot(finaldata, aes(x = factor(year), y = GHG, col = ticker))+
  geom_point()

ggplot(finaldata, aes(x = GHG, y = reduction_netzero, col = ticker))+
  geom_point()

