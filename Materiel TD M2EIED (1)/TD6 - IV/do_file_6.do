**************** Advanced Econometrics --- Tutorial 5 ************************/
/****************     Instrumental Variable approach   ************************/

***** AJR refers to Acemoglu, Johnson and Robinson (2001) ******
clear all
set more off
use "C:\Users\DELL\Downloads\Econometric impact Pratice\Materiel TD M2EIED (1)\TD6 - IV\data_AJR_2001.dta", clear 

/* I. Descriptive statistics */
* 1. (a) Quartiles of countries by settler mortality
*generate quartiles
capture drop rank_mort
capture drop count_mort
capture drop ptile_mort
capture drop q_mort
egen rank_mort=rank(extmort4) if baseco == 1, track
egen count_mort=count(extmort4) if baseco == 1
gen ptile_mort=rank_mort/count_mort
gen q_mort=.
replace q_mort=1 if ptile_mort<=.25
replace q_mort=2 if (ptile_mort>.25 & ptile_mort<=.5)
replace q_mort=3 if (ptile_mort>.5 & ptile_mort<=.75)
replace q_mort=4 if ptile_mort>.75 & ptile_mort<.
tab q_mort

* 1. (b) Table of summary statistics
tabstat logpgp95 loghjypl avexpr cons1 cons00a democ00a extmort4, stat(mean sd) col(stat)
tabstat logpgp95 loghjypl avexpr cons1 cons00a democ00a extmort4 if baseco == 1, stat(mean sd) col(stat)
tabstat logpgp95 loghjypl avexpr cons1 cons00a democ00a extmort4 if baseco == 1, by(q_mort) stat(mean sd) col(stat)

/* II. Naive econometric analysis */
* 2. (c) Reproducing table 2
***********************
*---Column 1
***********************
regress logpgp95 avexpr
estimates store OLS1

***********************
*---Column 2
***********************
regress logpgp95 avexpr if baseco==1
estimates store OLS2

***********************
*--Column 3
***********************
regress logpgp95 avexpr lat_abst
estimates store OLS3

***********************
*--Column 4
***********************	
regress logpgp95 avexpr lat_abst africa asia other
estimates store OLS4

***********************
*--Column 5
***********************
regress logpgp95 avexpr lat_abst if baseco==1
estimates store OLS5

***********************
*--Column 6
***********************
regress logpgp95 avexpr lat_abst africa asia other if baseco==1
estimates store OLS6

esttab OLS1 OLS2 OLS3 OLS4 OLS5 OLS6 using "C:\Users\DELL\Downloads\Econometric impact Pratice\Materiel TD M2EIED (1)\TD6 - IV\reg1.tex", label nostar se r2 long replace

* (d) add robust option to every reg command for heteroskedastic standard errors


/* III.  IV approach */
*3. Reproducing Fig.1
twoway (scatter logpgp95 logem4 if baseco == 1)
twoway (scatter logpgp95 logem4 if baseco == 1, msymbol(point) mlabel(shortnam)) (lfit logpgp95  logem4 if baseco == 1), yscale(range(4 11)) xscale(range(2 8))

* 4.(a) Mechanisms under the IV approach
* Model in Equation(4)
reg  avexpr lat_abst cons00a if baseco==1 & extmort4!=.
estimates store Eq4
* Model in Equation (5)
reg cons00a euro1900 lat_abst if baseco==1 & extmort4!=.
estimates store Eq5
* Model in Equation (6)
reg euro1900 lat_abst logem4 if baseco==1 & extmort4!=. 
estimates store Eq6
esttab Eq4 Eq5 Eq6 using "C:\Users\DELL\Downloads\Econometric impact Pratice\Materiel TD M2EIED (1)\TD6 - IV\reg2.tex", label nostar se r2 long replace

* 5.(a) The first stage of the IV approach
reg avexpr logem4 lat_abst if baseco==1 & extmort4!=.
estimates store TWOSLS_1

capture drop predicted_avexpr
predict predicted_avexpr if baseco==1 & extmort4!=., xb
* 5.(b) Second stage
reg logpgp95 predicted_avexpr lat_abst if baseco==1 & extmort4!=.
estimates store TWOSLS_2

* 6. ivreg with STATA built-in command
ivreg logpgp95 lat_abst (avexpr=logem4) if baseco == 1, first
estimates store TWOSLS

/// Note : with the option "first" we say to STATA to display also
/// the first stage regression.

/*  IV. Validity of the approach */

* 7. Exclusion restriction assumption (b)
* Controlling for geographical and climate dimensions
ivreg logpgp95 (avexpr=logem4) temp* humid* if baseco == 1, first
ivreg logpgp95 lat_abst (avexpr=logem4) temp* humid* if baseco == 1, first
ivreg logpgp95 (avexpr=logem4)  steplow deslow stepmid desmid drystep drywint goldm iron silv zinc oilres landlock if baseco == 1, first
ivreg logpgp95 lat_abst (avexpr=logem4)  steplow deslow stepmid desmid drystep  drywint goldm iron silv zinc oilres landlock if baseco == 1, first

* Controlling for diseases (malaria)
ivreg logpgp95 (avexpr=logem4) malfal94, first
ivreg logpgp95 lat_abst (avexpr=logem4) malfal94, first


* 8. outliers
ivreg logpgp95 (avexpr=logem4) if baseco == 1 & rich4!=1, first

* 9. Overidentification
* Panel D of table 8 of the paper
ivreg logpgp95 lat_abst (avexpr=euro1900) logem4
ivreg logpgp95 lat_abst (avexpr=cons00a) logem4
ivreg logpgp95 lat_abst (avexpr=democ00a) logem4
ivreg logpgp95 lat_abst (avexpr=cons1) indtime logem4
ivreg logpgp95 lat_abst (avexpr=democ1) indtime logem4

