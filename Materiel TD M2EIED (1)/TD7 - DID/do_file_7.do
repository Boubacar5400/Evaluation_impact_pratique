clear all
set more off

***** Change working directory and import data *********************************
use "C:\Users\DELL\Downloads\Econometric impact Pratice\Materiel TD M2EIED (1)\TD7 - DID\CardKrueger_session8.dta",clear

***** 3.(c) Descriptive stats of observable caracteristics**********************
tabstat chain co_owned wage_st inctime firstinc meals open hrsopen psoda pfry /*
*/pentree if t==0, by(state) stat(mean sd)
tabstat chain co_owned wage_st2 inctime2 firstin2 meals2 open2r hrsopen2 /*
*/psoda2 pfry2 pentree2 if t==1, by(state) stat(mean sd) 
********************************************************************************

***** 3.(d) We need to create the fte and starting_wage variables **************
gen fte=empft+emppt*0.5+nmgrs if t==0
replace fte=empft2+emppt2*0.5+nmgrs2 if t==1

gen starting_wage=wage_st if t==0
replace starting_wage=wage_st2 if t==1

***** 3.(e) Check that the policy has indeed been implemented ******************
gen wnj0=wage_st if state==1 & t==0 /* NJ, before the law*/

gen wnj1=wage_st2 if state==1 & t==1 /* NJ, after the law */
gen wpa0=wage_st if state==0 & t==0 /* PA, before the law */
gen wpa1=wage_st2 if state==0 & t==1 /* PA, after the law */

* One can look at the evolution of wages graphically ****

histogram wpa0, bin(50) percent fcolor(black) legend(label /*
*/(1 "Pennsylvania before")) addplot(histogram  wpa1, bin(50) /*
*/percent legend(label (2 "Pennsylvania after")))
histogram wnj0, bin(50) percent fcolor(black) legend(label /*
*/(1 "New Jersey before")) addplot(histogram wnj1, bin(50) /*
*/percent legend(label (2 "New Jersey after")))

*** Nothing ha changed in PA, contrary to NJ

* One can estimate the change in mean wage *****
 ttest starting_wage if state==0, by(t) unequal
 ttest starting_wage if state==1, by(t) unequal
 
* One can look at the evolution of the proportion of wages >5.05  ***** 
bysort state t : su starting_wage, d

gen sum_min=(starting_wage>=5.05 & starting_wage!=.)
bysort state t : ta sum_min

***** 4. Variation in full-time employment in NJ *******************************
*****Calculate mean fte in NJ (state=1) by time (feb92=0, nov92=1)******

bysort state t: su fte
ttest fte if state==1, by(t) unequal

*In order to get standard errors 
*(note: std error of mean: st. dev / square root of nb of obs.)*
