library("dplyr")
library("stringr")
library("tidyr")

ghg<-read.csv("OUTPUT/step_2_tickers_ghg.csv") |>
  mutate(year=year-2000) |>
  select(-yearcount)

ghg_comp<-unique(ghg$ticker) #there are 188 SEC companies that reported 13 years of emissions

bert<-read.csv("OUTPUT/step_4_bert2.csv") |>
  separate(filename, into=c("ticker", "year", "tail"), sep="_") |>
  select(-tail) |>
  mutate(year=as.numeric(year))

bert_comp<-unique(bert$ticker) #there are 18 companies that we were able to scrape 10-K data for 13 years

assets<-read.csv("OUTPUT/step_6_assets.csv") |>
  select(ticker, Assets, year)

df<-merge(ghg, bert, by=c("year", "ticker")) |>
  mutate(share=(reduction + netzero)*100/(sentences-error)) 

comp<-df |>
  group_by(ticker) |>
  tally() |>
  filter(n>=9)

df2<-merge(df, comp, by="ticker") |>
  mutate(GHGmil=GHG/1000000) |>
  mutate(ticker=as.factor(ticker)) |>
  arrange(ticker, year) |>
  group_by(ticker) |>
  mutate(lagshare=lag(share)) |>
  mutate(laglagshare=lag(lagshare))

sent<-sum(df2$sentences)

install.packages("viridis") 
library("viridis")  

png("OUTPUT/line_by_tick.png", width=5, height=5, units="in", res=500)
ggplot(df2, aes(x=share, y=GHG, col=ticker)) + geom_point(size=2) + geom_line(size=2) + theme_bw() +
  scale_color_viridis(discrete = TRUE) +
  xlab("Share of Sentences") + 
  ylab("GHG Emissions") +
  theme(legend.position="none") + 
  ggtitle("Correlation by Company")
dev.off()


df3<-df2 |>
  group_by(year) |>
  mutate(year=year+2000) |>
  summarize(GHG=mean(GHG), share=mean(share))

png("OUTPUT/line.png", width=5, height=5, units="in", res=500)
ggplot(df3) + 
  geom_line(aes(y=GHG, x=year, col="GHG"), size=2) + 
  geom_line(aes(y = share * 100000000, x=year, col="ShareSentences"), size=2) +
  scale_color_manual(values=c("#39568CFF", "#73D055FF")) +
  theme_bw()   +    # Secondary y-axis: Share scaled
  scale_y_continuous(
    name = "GHG Emissions (in tons of CO2e)",   # Primary y-axis label
    sec.axis = sec_axis(~ . / 100000000, name = "Share of Reduction and Net-Zero Sentences (%)") # Secondary y-axis label with scaling
  ) +
  ggtitle("Averages Across Time")
dev.off()

library('fixest')

m1<-feols(GHGmil ~ share, data=df2)
summary(m1)

m2<-feols(GHGmil ~ share | year, data=df2)
summary(m2)

m3<-feols(GHGmil ~ share | ticker + year, data=df2)
summary(m3)

m4<-feols(GHGmil ~ share:ticker | ticker + year, data=df2)
summary(m4)


m5<-feols(GHGmil ~ share + lagshare + laglagshare| ticker + year, data=df2)
summary(m5)



etable(m1, m2, m3, m5,
       se = "cluster",
       cluster = "ticker",
       keep = c("share"),
       se.below = TRUE,
       digits = 2,
       replace=TRUE,
       title="Regression Results",
       fitstat=c('n', 'ar2'),
       digits.stats = 2,
       signif.code=c("***"=0.01, "**"=0.05, "*"=0.10),
       file="OUTPUT/reg.tex")

library(modelsummary)

b <- list(geom_vline(xintercept = 0, color = '#73D055FF'),
          annotate("rect", alpha = .1,
                   xmin = -.5, xmax = .5, 
                   ymin = -Inf, ymax = Inf))

png("OUTPUT/whisker.png", width=5, height=10, units="in", res=500)
modelplot(m4, background = b)
dev.off()
