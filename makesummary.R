library("tidyverse")

df<-read.csv("finaldata.csv") |>
  mutate(ticker=as.numeric(as.factor(ticker))) |>
  select(-PARENT.COMPANY)
  

library("modelsummary")

datasummary_skim(df)

####################################3
df<-read.csv("finaldata.csv")

df2<-df |>
  mutate(score=(reduction+netzero)*100/sentences) |>
  mutate(PARENT.COMPANY=ifelse(str_detect(PARENT.COMPANY, "Chevron"), "Chevron", PARENT.COMPANY))

png("Poster Stuff/correlation.png", width=8, height=5, units="in", res=500)

ggplot(df2, aes(x=GHG, y=score, col=PARENT.COMPANY)) + geom_point() + 
  geom_smooth(method="lm", se=FALSE) +
  theme_bw()

dev.off()

summary(m1<-lm(GHG ~ score + as.factor(ticker), data=df2))

library("fixest")
m1<-feols(GHG ~ score:as.factor(ticker) | ticker + year, data=df2)

png("Poster Stuff/coefficients.png", width=8, height=5, units="in", res=500)

modelplot(m1) +
  labs(title="Correlation Between Score and GHG by Company", 
       subtitle="After including year and company fixed effects")

dev.off()

