cap log close
log using "IV.log", replace

use "IV.dta", clear

desc

sum 

ttest male, by(got)
ttest age, by(got)
ttest educ2004, by(got)
ttest hadsex12, by(got)
ttest eversex, by(got)
ttest tb, by(got)
ttest land2004, by(got)
ttest hiv2004, by(got)

gen bought100=bought*100
graph bar (mean) bought100, over(got) blabel(bar, format(%7.2g)) ytitle(% d'individus ayant acheté des préservatifs) ylabel(, angle(horizontal)) b1title(A récupéré ses résultats)
graph bar (mean) bought100, over(got) by(hiv2004, note("") b1title("A récupéré ses résultats")) blabel(bar, format(%7.2g)) ytitle(% d'individus ayant acheté des préservatifs) ylabel(, angle(horizontal)) 

reg bought got
/*
probit bought got
mfx
logit bought got
mfx
*/
reg bought got age male educ2004 eversex tb land2004

reg got any age male educ2004 eversex tb land2004
predict got_hat, xb

reg bought got_hat age male educ2004 eversex tb land2004

ivreg2 bought age male educ2004 eversex tb land2004 (got=any)

bys male: ivreg2 bought age educ2004 eversex tb land2004 (got=any)
bys hiv2004 : ivreg2 bought age male educ2004 eversex tb land2004 (got=any)
