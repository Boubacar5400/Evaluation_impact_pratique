cap log close
log using DID.log, replace

use "DID.dta", clear

desc
sum age1994
tab sex
sum primary
tab treat, sum(age)
tab treat, sum(sex)
tab treat, sum(primary)
ttest age, by(treat)
ttest sex, by(treat)
ttest primary, by(treat)

codebook cluster
preserve
collapse (mean)  sex1994 age1994 primary electric pipwater distcapital treat, by(cluster)
ttest electric, by(treat)
ttest pipwater, by(treat)
ttest distcapital, by(treat)
ttest sex1994, by(treat)
ttest age1994, by(treat)
ttest primary, by(treat)
restore

reg primary treat if ycohort==1
reg primary treat sex1994 age1994 electric pipwater distcapital if ycohort==1
reg primary treat if ocohort==1
reg primary treat sex1994 age1994 electric pipwater distcapital if ocohort==1

tab ycohort treat, sum(primary)
sum primary if ycohort==1 & treat==1
sum primary if ycohort==1 & treat==0
sum primary if ycohort==0 & treat==1
sum primary if ycohort==0 & treat==0

reg primary treat ycohort ycohortxtreat
reg primary treat ycohort ycohortxtreat sex1994 age1994 electric pipwater distcapital

log close
