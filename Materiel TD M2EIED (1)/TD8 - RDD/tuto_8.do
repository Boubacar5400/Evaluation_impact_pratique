
/*
Analysis of a Regression Discontinuity Design
Did Head Start Reduce Child Mortality?
*/

set more off
clear all

use "C:\Users\DELL\Downloads\Econometric impact Pratice\Materiel TD M2EIED (1)\TD8 - RDD\data_LudwigMiller2007.dta", clear

/* 2. Preliminary statistical and graphical analysis */
***** 2.(a) Variables to generate *****
* id variable
de
gsort - povrate60
capture drop id
gen id=_n
br id povrate60 

*Generate the dummy for the provision of grant-writing assistance 

gen     g = 0 if povrate60 <povrate60[300]
replace g = 1 if povrate60 >=povrate60[300]
replace g = . if povrate60 ==.
tabulate g, miss

*Redefine poverty rate so that the discontinuity is at zero
gen povrate= povrate60-59.1984
**gen povrate = povrate60 - povrate60[300]

***** 2.(b) Histogram for the poverty rate in 1960 *****
histogram povrate, xline(0) frequency xtitle("1960 Poverty rate", /// 
size(vsmall)) title("Distribution of Poverty rate" ) bin(50)


***** 2.(c) bandwidth 16 and 8 *****
gen bandwidth1=(povrate>=-8 & povrate<=8) 
gen bandwidth2=(povrate60>=43.1984 & povrate60<=75.1984) 
tabulate bandwidth1 g
tab bandwidth2 g

***** 2.(d) Check how observable characteristics vary at the cutoff *****
ttest pop60 if bandwidth1==1, by(g) unequal
ttest pct_urban_1960 if bandwidth1==1, by(g) unequal
ttest  pct_black_1960 if bandwidth1==1, by(g) unequal
ttest rate_5964 if bandwidth1==1, by(g) unequal

***** 2.(e) Per-kid county level spending *****
tabstat hsspend_per_kid_68 hsspend_per_kid_72 if bandwidth1 == 1, by(g) ///
stat(mean sd n) columns(stat)
ttest hsspend_per_kid_68 if bandwidth1==1, by(g) unequal
ttest hsspend_per_kid_72 if bandwidth1==1, by(g) unequal


/* 3. Differences of spending at the discontinuity */

***** 3.(a) Generate square, cube of povrate and interaction terms *****

gen povratesq=povrate^2
gen povratecb=povrate^3
gen gpovrate=povrate*g
gen gpovratesq=povratesq*g
gen gpovratecb=povratecb*g

***** 3.(b) Estimation of the three parametric specifications ****
*estimate the flexible linear fit 
reg  hsspend_per_kid_68 povrate g gpovrate if bandwidth2==1
predict linhat

*estimate the flexible quadratic fit 
reg  hsspend_per_kid_68 povrate povratesq g gpovrate gpovratesq if bandwidth2==1
predict sqhat

*estimate the flexible cubic fit instead of the nonparametric estimates 
reg  hsspend_per_kid_68 povrate povratesq povratecb g gpovrate gpovratesq /// 
gpovratecb if bandwidth2==1
predict cbhat

***** 3.(c) grouping the data into five cells on each side of the cutoff *****
*****       for counties with 1960 poverty rates from 40 to 80 percent. *****
capture drop bin
gen bin = floor(povrate/4)*4 + 4/2 + 59.1984
keep if bin>=40 & bin<=80 

***** 3.(d) Mean value and standard error of the mean by categories *****
*****       And confidence interval of 1968 spendings at 95\%       *****
*Install package for command semean
*search semean
*search egenmore
ssc install egenmore, replace
sort bin
by bin: egen bin_mean = mean(hsspend_per_kid_68)
* computes the standard error of the mean (need egenmore: ssc install egenmore, replace)
by bin: egen stderror = semean(hsspend_per_kid_68)
by bin: egen count_n  = count(bin)
* Following commands in the absence of semean function
*by bin: egen sd = sd(hsspend_per_kid_68)
*by bin: gen stderror2 = sd / sqrt(count_n)

*compute the 95% CI
gen upper =bin_mean + 1.96*stderror
gen lower =bin_mean - 1.96*stderror
	
***** 3.(e) Construct graphic *****
*graph for 40-80 poverty rate
keep if povrate60>=40 & povrate60<=80

*generate Figure II
graph twoway (scatter bin_mean bin, msymbol(T) mcolor(black)) /// 
(rcap upper lower bin, lcolor(black)) /// 
(line linhat povrate60 if linhat<800,lcolor(black) lpattern(longdash)) ///
(line sqhat povrate60 if sqhat<800,lcolor(black) lpattern(dash)) /// 
(line cbhat povrate60 if cbhat<800, lcolor(black) lpattern(solid)), ///  
xlabel(40(10)80) xline(59.1984) legend(off) ///
xtitle("1960 Poverty rate", size(vsmall) ) title(`1') 

***** 3.(f) Transofrm commands from 3.(b) to 3.(e) to replicate the figure *****
*****       for any variable ***** 

capture program drop figure
program define figure

		preserve 
		
		local mylabel : variable label `1'

		*estimate the flexible linear fit 

		reg  `1' povrate g gpovrate if bandwidth2==1
		capture drop linhat
		predict linhat

		*estimate the flexible quadratic fit 

		reg  `1' povrate povratesq g gpovrate gpovratesq if bandwidth2==1
		capture drop sqhat
		predict sqhat

		*estimate the flexible cubic fit instead of the nonparametric estimates 

		reg  `1' povrate povratesq povratecb g gpovrate gpovratesq /// 
		gpovratecb if bandwidth2==1
		capture drop cbhat
		predict cbhat

		*grouping the data into five cells on each side of the cutoff 
		*for counties with 1960 poverty rates from 40 to 80 percent.
		capture drop bin
		gen bin = floor(povrate/4)*4 + 4/2 + 59.1984
		keep if bin>=40 & bin<=80 
		
		sort bin
		capture drop bin_mean
		capture drop stderror
		by bin: egen bin_mean = mean(`1')
		by bin: egen stderror = semean(`1')
		*by bin: egen count_n  = count(bin)
		*by bin: egen sd = sd(hsspend_per_kid_68)
		*by bin: gen stderror2 = sd / sqrt(count_n)

		*compute the 95% CI
		capture drop upper
		capture drop lower
		gen upper =bin_mean + 1.96*stderror
		gen lower =bin_mean - 1.96*stderror
		
		*graph for 40-80 poverty rate
		keep if povrate60>=40 & povrate60<=80

		*generate Figure II
		graph twoway (scatter bin_mean bin, msymbol(T) mcolor(black)) /// 
		(rcap upper lower bin, lcolor(black)) /// 
		(line linhat povrate60 if linhat<800,lcolor(black) lpattern(longdash)) ///
		(line sqhat povrate60 if sqhat<800,lcolor(black) lpattern(dash)) /// 
		(line cbhat povrate60 if cbhat<800, lcolor(black) lpattern(solid)), ///  
		xlabel(40(10)80) xline(59.1984) legend(off) ///
		xtitle("1960 Poverty rate", size(vsmall) ) title(`1') nodraw
		
		graph save figure_`1'.gph, replace
		restore
end

figure hsspend_per_kid_68 
graph use "figure_hsspend_per_kid_68.gph"
figure hsspend_per_kid_72
graph use "figure_hsspend_per_kid_72.gph"
graph combine figure_hsspend_per_kid_68.gph figure_hsspend_per_kid_72.gph, ///
col(1) graphregion(margin(l=40 r=40))
figure socspend_per_cap72
graph use "figure_socspend_per_cap72.gph"

erase figure_socspend_per_cap72.gph
erase figure_hsspend_per_kid_68.gph 
erase figure_hsspend_per_kid_72.gph

/* 4. Differences of children mortality at the cutoff */

figure age5_9_sum2 
graph use figure_age5_9_sum2

figure age5_9_injury_rate 
graph use figure_age5_9_injury_rate

figure age25plus_sum2 
graph use figure_age25plus_sum2

figure rate_5964
graph use figure_rate_5964

graph combine figure_age5_9_sum2.gph  figure_age5_9_injury_rate.gph  ///
figure_age25plus_sum2.gph figure_rate_5964.gph, xsize(10) ysize(10)

erase figure_age5_9_sum2.gph  
erase figure_age5_9_injury_rate.gph  
erase figure_age25plus_sum2.gph 
erase figure_rate_5964.gph


/* 5. Implementation of the regression discontinuity estimate */
* For table outputs using word
ssc install outreg, replace

outreg, clear

	*Ages 5-9, Head Start-related causes, 1973-1983
		*Linear fit
		reg  age5_9_sum2 g povrate gpovrate if bandwidth1==1
		outreg, append stats(b se p) starlevels(10 5 1) starloc(1) summstat(N) ///
		summtitle("Number of obs. (counties) with nonzero weight")  ///
		noautosum keep(g) ctitle("", Flexible Linear) ///
		rtitles("Ages 5-9, Head Start-related causes, 1973-1983") nodisplay

	*Ages 5-9, injuries, 1973-1983
		*Linear fit
        reg  age5_9_injury_rate  g povrate gpovrate if bandwidth1==1
		outreg, append stats(b se p) starlevels(10 5 1) starloc(1) summstat(N) ///
		summtitle("Number of obs. (counties) with nonzero weight") ///
		noautosum keep(g) ctitle("", Flexible Linear) ///
		rtitles("Ages 5-9, injuries, 1973-1983") nodisplay

	*Ages 25+, Head Start-related causes, 1973-1983
		*Linear fit
	     reg   age25plus_sum2 g povrate gpovrate if bandwidth1==1
		outreg, append stats(b se p) starlevels(10 5 1) starloc(1) summstat(N) ///
		summtitle("Number of obs. (counties) with nonzero weight") ///
		noautosum  keep(g) ctitle("", Flexible Linear) ///
		rtitles("Ages 25+, Head Start-related causes, 1973-1983")  nodisplay


	*Ages 5-9, Head Start causes, 1959-1964
		*Linear fit
		 reg   rate_5964 g povrate gpovrate if bandwidth1==1
		outreg, append stats(b se p) starlevels(10 5 1) starloc(1) summstat(N) /// 
		summtitle("Number of obs. (counties) with nonzero weight") ///
		keep(g) ctitle("", Flexible Linear) /// 
		rtitles("Ages 5-9, Head Start causes, 1959-1964")   nodisplay

outreg, clear(q5)


/*Question 	6. Improving the average treatment effect with polynomials in the 1960 poverty rate*/

	*Ages 5-9, Head Start-related causes, 1973-1983
		*Quadratic fit
		reg  age5_9_sum2  g povrate povratesq gpovrate gpovratesq if bandwidth2==1
		test povratesq gpovratesq
		outreg, append(q6) starlevels(10 5 1) starloc(1) stats(b se p) /// 
		summstat(N) summtitle("Number of obs. (counties) with nonzero weight") /// 
		noautosum keep(g) ctitle("", Flexible Quadratic) ///  
		rtitles("Ages 5-9, Head Start-related causes, 1973-1983")   nodisplay

	*Ages 5-9, injuries, 1973-1983
		*Quadratic fit
		reg  age5_9_injury_rate  g povrate povratesq gpovrate gpovratesq /// 
		if bandwidth2==1
		test povratesq gpovratesq
		outreg, append(q6) starlevels(10 5 1) starloc(1) stats(b se p) /// 
		summstat(N) summtitle("Number of obs. (counties) with nonzero weight") /// 
		noautosum  keep(g) ctitle("", Flexible Quadratic) /// 
		rtitles("Ages 5-9, injuries, 1973-1983")   nodisplay

	*Ages 25+, Head Start-related causes, 1973-1983
		*Quadratic fit
		reg   age25plus_sum2 g povrate povratesq gpovrate gpovratesq if bandwidth2==1
		test povratesq gpovratesq
		outreg, append(q6) stats(b se p) starloc(1) summstat(N) /// 
		summtitle("Number of obs. (counties) with nonzero weight")  /// 
		noautosum keep(g) ctitle("", Flexible Quadratic) /// 
		rtitles("Ages 25+, Head Start-related causes, 1973-1983")   nodisplay


	*Ages 5-9, Head Start causes, 1959-1964
		*Quadratic fit
		reg  rate_5964 g povrate povratesq gpovrate gpovratesq if bandwidth2==1
		test povratesq gpovratesq
		outreg, append(q6) starlevels(10 5 1) starloc(1) stats(b se p) /// 
		summstat(N) summtitle("Number of obs. (counties) with nonzero weight") /// 
		keep(g) ctitle("", Flexible Quadratic) /// 
		rtitles("Ages 5-9, Head Start causes, 1959-1964")   nodisplay


outreg using q5_final, replay merge(q5) 



***** Using rd command from Nichols, Austin. 2011.  rd 2.0: Revised Stata module 
* for regression discontinuity estimation****
** Install command rd if not installed, then type 'help rd'
**ssc install rd, replace
rd age5_9_sum2 povrate, graph
