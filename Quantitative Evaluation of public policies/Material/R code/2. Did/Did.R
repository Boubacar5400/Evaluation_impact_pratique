rm(list=ls())

# Import data
library(foreign)
eitc = read.dta("eitc.dta")   # After you set the correct directory

# data description
summary(eitc)

# Conditional distributions
summary(eitc[eitc$children == 0, ])
summary(eitc[eitc$children == 1, ])
summary(eitc[eitc$children >= 1, ])
summary(eitc[eitc$children >= 1 & eitc$year == 1994, ])

# Dummy variables (before/after and control/treated) 
eitc$post93 = as.numeric(eitc$year >= 1994) # EITC came into effect in 1994
eitc$anykids = as.numeric(eitc$children >= 1) # EITC only affects women with at least one child. The control group therefore consists of all women with at least one child

# Graph shwoing the evolution of the control and treatment groups
minfo = aggregate(eitc$work, list(eitc$year,eitc$anykids == 1), mean) # We take the mean of wirk by year, conditionnaly to anykids
names(minfo) = c("YR","Treatment","LFPR")
minfo$Group[1:6] = "Single women, no children"
minfo$Group[7:12] = "Single women, children"
minfo
require(ggplot2)    
qplot(YR, LFPR, data=minfo, geom=c("point","line"), colour=Group,
      xlab="Year", ylab="Labor Force Participation Rate")

# Difference in difference model with robust inference
library(sandwich)
library(lmtest)
reg1 = lm(work ~ anykids*post93, data = eitc)
summary(reg1)
coeftest(reg1, vcovHC(reg1))

reg2 = lm(work ~ anykids*post93 + 
            unearn + children + nonwhite +
          + age + I(age^2) + ed + I(ed^2), data = eitc)
summary(reg2)
coeftest(reg2, vcovHC(reg2))
library(effects)
plot(effect(c("age"),reg2, vcov.=sandwich, xlab="Age",ylab="LFPR", type= "response",main=NULL))
plot(effect(c("ed"),reg2, vcov.=sandwich, xlab="Age",ylab="LFPR", type= "response",main=NULL))


# Placebo model
eitc.sub = eitc[eitc$year <= 1993,]
eitc.sub$post91 = as.numeric(eitc.sub$year >= 1992)
reg3 <- lm(work ~ post91*anykids, data = eitc.sub)
summary(reg3)
coeftest(reg3, vcovHC(reg3))
