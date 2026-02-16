cap log close
log using RCT.log, replace

use "RCT.dta", clear

des

sum
*tab1 got Ti any male educ2004 hadsex12 eversex tb land2004 hiv2004, m
ttest age, by(any)
ttest male, by(any)
ttest educ2004, by(any)
ttest hadsex12, by(any)
ttest eversex, by(any)
ttest tb, by(any)
ttest land2004, by(any)
ttest hiv2004, by(any)

tab any, sum(got)
graph bar (mean) got, over(any) blabel(bar, format(%7.2g)) ytitle(% d'individus ayant récupéré ses résultats) ylabel(, angle(horizontal))
tab Ti, sum(got)
graph bar (mean) got, over(Ti) blabel(bar, format(%7.2g)) ytitle(% d'individus ayant récupéré ses résultats) ylabel(, angle(horizontal))

reg got any
/*
probit got any
mfx
logit got any
mfx
*/
reg got any age male i.educ2004
/*qui probit got any age male educ2004
mfx
qui logit got any age male educ2004
mfx
*/

reg got Ti age male i.educ2004
reg got i.Ti age male i.educ2004

test 50.Ti=100.Ti
test 100.Ti=200.Ti
test 200.Ti=300.Ti

reg got i.any i.male any#male age educ2004
reg got i.any i.educ2004 any#i.educ2004 i.male age 
