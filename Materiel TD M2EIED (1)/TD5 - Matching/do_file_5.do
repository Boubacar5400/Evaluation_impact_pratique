
/**************** Advanced Econometrics --- Tutorial 6 ************************/
/****************       OLS and Matching estimators    ************************/

clear all
set more off


use "C:\Users\DELL\Downloads\Econometric impact Pratice\Materiel TD M2EIED (1)\TD5 - Matching\nsw_dw.dta", clear 

/* note: 
* Original samples and description of the data are available on Dehejia's page:
 http://users.nber.org/~rdehejia/nswdata.html

*/
************************ I. calculate means ******************************
* to compute the number of obs later on
gen nb=1

* reproduce MHE T.3.3.2 
tabstat age ed black hisp married nodeg re74 re75 re78, stat(mean semean) by(treat)


************************ II. OLS regression ******************************

**************** A.  OLS with experimental dataset (NSWRE74)**********************


reg re78 treat 

*Specification with extended set of demographic controls*

gen age2 = age*age

reg re78 treat age age2 ed black hisp nodeg 

reg re78 treat re75 

reg re78 treat re75 age age2 ed black hisp nodeg 

reg re78 treat re75 re74 age age2 ed black hisp nodeg


***********************************************************************************
******** B.  OLS with non experimental controls: control group CPS-1 **************

use "C:\Users\DELL\Downloads\Econometric impact Pratice\Materiel TD M2EIED (1)\TD5 - Matching\nsw_dw.dta", clear 
gen exp = 1
append using  "C:\Users\DELL\Downloads\Econometric impact Pratice\Materiel TD M2EIED (1)\TD5 - Matching\cps_controls.dta" 
replace exp = 0 if missing(exp)


***Perform same regressions*****

***********************************************************************************
******** C.  OLS with non experimental controls: control group PSID **************

use "C:\Users\DELL\Downloads\Econometric impact Pratice\Materiel TD M2EIED (1)\TD5 - Matching\nsw_dw.dta", clear 
gen exp = 1
append using  "C:\Users\DELL\Downloads\Econometric impact Pratice\Materiel TD M2EIED (1)\TD5 - Matching\psid_controls.dta" 
replace exp = 0 if missing(exp)

***Perform same regressions*****


*******III. Matching estimators *********************************
*******************

* keep PSID as control group
drop if exp==1 & treat==0
gen age2 = age*age
gen U74=(re74==0)
gen U75=(re75==0)
gen blackU74=U74*black
gen ed2=education^2
gen re742=re74^2
gen re752=re75^2

***** Estimate the propensity score*******************************************
capture drop mypscore 
logit  treat age age2 education ed2 black hisp married re75 re74 re742 re752 blackU74
predict mypscore

histogram mypscore, by(treat, col(1))
psgraph, treated (treat) pscore(mypscore)
drop mypscore 

*** Getting the packages******
***to get the package type in Stata :
*** net search propensity score
*** Then click on the package: (st0026_2) and install it
findit pscore

***or directly: 
ssc install psmatch2, replace 
ssc install nnmatch, replace
***************Using Becker & Ichino procedure**************

pscore treat age age2 education ed2 black hisp married re75 re74 re742 re752, /// 
pscore(mypscore) blockid(myblock) comsup numblo(5) level(0.005) logit detail
* note - testing the balancing property for each block and each covariate

drop mypscore myblock
pscore treat age age2 education ed2 black hisp married re75 re74 re742 re752 ///
 blackU74, pscore(mypscore) blockid(myblock) comsup numblo(5) level(0.005) logit 


******** With non experimental controls: control group CPS-1**************

*Specification with extended set of demographic controls*

 logit treat age age2 education black hisp nodeg married
 capture drop pscore 
 predict pscore, pr
 keep if pscore >.1 & pscore <.9
 
 reg treat age age2 education black hisp nodeg married

 
*Specification with extended set of demographic controls + lagged (1975) earnings*


logit treat re75 age age2 education black hisp nodeg married
capture drop pscore 
predict pscore, pr

 histogram pscore, by(treat, col(1))
 keep if pscore >.1 & pscore <.9
 
 reg re78 treat re75 age age2 education black hisp nodeg married

 
 logit treat re75 re74 age age2 ed2 black hisp nodeg married
 capture drop pscore 
 predict pscore, pr
 histogram pscore, by(treat, col(1))
 keep if pscore >.1 & pscore <.9

reg re78 treat re75 re74 age age2 ed2 black hisp nodeg married
 