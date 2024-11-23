if (!require(bibliometrix)) install.packages("bibliometrix")
library(stringr)
library(ggplot2)
library(tidyverse)
load("bib_updated.RData")

table(dat_updated$PY)
summary(dat_updated$PY)

dat_2023 <- dat_updated %>%
    mutate(PY = if_else(PY == 2024, 2023, PY)) # 2024 should be merged as early access papers
    


test <- biblioAnalysis(dat_2023)
summary(test)

dat_py <- data.frame(PY = factor(na.omit(dat_2023$PY)))
                     
ggplot(data = dat_py, aes(x = PY)) +
    geom_bar(fill = "white", colour = "black") +
    geom_text(stat = 'count', aes(label = ..count..), size = 3, vjust = -0.5) +
    ylab("Number of Publications") +
    xlab("Publication Year") +
    scale_x_discrete(breaks = as.character(c(1990, 1995, 2000, 2005, 2010, 2015, 2020, 2023))) 


