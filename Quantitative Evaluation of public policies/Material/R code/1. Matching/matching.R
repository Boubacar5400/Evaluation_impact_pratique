# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# In this tutorial we analyze the effect of going to Catholic school, as opposed to public school, on
# student achievement. Because students who attend Catholic school on average are different from
# students who attend public school, we will use propensity score matching to get more credible
# causal estimates of Catholic schooling.
# US data
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

# Remove all objects from memory
rm(list=ls())

# The following packages must be installed
library(MatchIt) 
library(dplyr) 
library(ggplot2)
library(gridExtra) 

# Read the data (set your wd first)
ecls <- read.csv("ecls.csv")

### Preliminary analysis on unmatched data

# Mean difference on the outcome variable

summary(ecls[ecls$catholic == 0, ])
summary(ecls[ecls$catholic == 1, ])
with(ecls, t.test(c5r2mtsc_std ~ catholic))

# Mean differences on the matching variables

ecls_cov <- c('race_white', 'p5hmage', 'w3income', 'p5numpla', 'w3momed_hsb')
lapply(ecls_cov, function(v) { t.test(ecls[, v] ~ ecls[, 'catholic'])})


### Estimation of the propensity score 
# Estimation of a logit model 
ecls$w3income_1k = ecls$w3income/1000
m_ps <- glm(catholic ~ race_white + w3income_1k + p5hmage + p5numpla + w3momed_hsb,
            family = binomial(), data = ecls)
summary(m_ps)

# Computation of the propensity score
prs_df <- data.frame(pr_score = predict(m_ps, type = "response"),catholic = m_ps$model$catholic)
head(prs_df)

# Common support region 
labs <- paste("Actual school type attended:", c("Catholic", "Public"))
prs_df$catholic = ifelse(prs_df$catholic == 1, labs[1], labs[2])
ggplot(prs_df, aes(x = pr_score)) + geom_histogram(color = "white") + facet_wrap(~catholic) + xlab("Probability of going to Catholic school") + theme_bw()

### Matching algorithm

# we remove missing values as MatchIt does not allow for missing values

summary(ecls[,ecls_cov])
ecls_nomiss <- ecls %>%
  select(c5r2mtsc_std, catholic, one_of(ecls_cov)) %>%
  na.omit()
summary(ecls_nomiss[,ecls_cov])

# Matching

mod_match <- matchit(catholic ~ race_white + w3income + p5hmage + p5numpla + w3momed_hsb,
                     method = "nearest", data = ecls_nomiss)

# Information on how successful the maching was

summary(mod_match)
plot(mod_match)

# Create a dataframe with only the matched observations

dta_m <- match.data(mod_match)
dim(dta_m)

### Covariate balance

# Visual inspection

fn_bal <- function(dta, variable) {
  dta$variable <- dta[, variable]
  if (variable == 'w3income') dta$variable <- dta$variable / 10^3 
  dta$catholic <- as.factor(dta$catholic)
  support <- c(min(dta$variable), max(dta$variable))
  ggplot(dta, aes(x = distance, y = variable, color = catholic)) +
    geom_point(alpha = 0.2, size = 1.3) +
    geom_smooth(method = "loess", se = F) +
    xlab("Propensity score") +
    ylab(variable) +
    theme_bw() +
    ylim(support)
}

grid.arrange(
  fn_bal(dta_m, "w3income"),
  fn_bal(dta_m, "p5numpla") + theme(legend.position = "none"),
  fn_bal(dta_m, "p5hmage"),
  fn_bal(dta_m, "w3momed_hsb") + theme(legend.position = "none"),
  fn_bal(dta_m, "race_white"),
  nrow = 3, widths = c(1, 0.8)
)

# Mean differences

dta_m %>%
  group_by(catholic) %>%
  select(one_of(ecls_cov)) %>%
  summarise_all(funs(mean))

lapply(ecls_cov, function(v) { t.test(dta_m[, v] ~ dta_m$catholic)})

### Estimation of treatment effects  

with(dta_m, t.test(c5r2mtsc_std ~ catholic))
lm_treat1 <- lm(c5r2mtsc_std ~ catholic, data = dta_m)
summary(lm_treat1)
lm_treat2 <- lm(c5r2mtsc_std ~ catholic + race_white + p5hmage +
                  I(w3income / 10^3) + p5numpla + w3momed_hsb, data = dta_m)
summary(lm_treat2)

