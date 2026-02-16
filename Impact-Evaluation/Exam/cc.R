
install.packages("haven")
install.packages("foreign")
library(haven)
library(foreign)


setwd("C:/Users/Yao Thibaut Kpegli/Desktop/ENS Paris Saclay/Impact-Evaluation/Exam")
DiD <- read_dta("DiD.dta")
View(DiD)

setwd("C:/Users/Yao Thibaut Kpegli/Desktop/ENS Paris Saclay/Impact-Evaluation/Exam")
DiD <- read.dta("DiD.dta")
View(DiD)



