*cap log close
*log using RDD.log, replace

cd "C:\Users\Yao Thibaut Kpegli\Desktop\ENS Paris Saclay\Impact Evaluation\MOOC\Chap 5_RDD\Pratique"
use RDD.dta, clear

desc

sum

_pctile score, per(85)
return list

gen 	merite=0
replace merite=1 if score>=152

tab merite

ttest momsecondary, by(merite)
ttest dadsecondary, by(merite)
ttest running, by(merite)
ttest distance, by(merite)

reg highestgrade score


gen 	score_10=1 if score<110
replace score_10=2 if score>=110 & score<120
replace score_10=3 if score>=120 & score<130
replace score_10=4 if score>=130 & score<140
replace score_10=5 if score>=140 & score<150
replace score_10=6 if score>=150 & score<160
replace score_10=7 if score>=160 & score<170
label de score_10l 1 "100-109" 2 "110-119" 3 "120-129" 4 "130-139" 5 "140-149" 6 "150-159" 7 "160-169"
label values score_10 score_10l

gen winner100=winner*100

graph bar (mean) winner100, over(score_10) ytitle(Received award (%)) ylabel(#10, angle(horizontal))
tab score_10 winner, row nofreq

graph bar (mean) winner100, over(highestgrade) ytitle(Received award (%)) ylabel(#10, angle(horizontal))
tab highestgrade winner, row nofreq

gen 	interval1=0
replace interval1=1 if score>142 & score<162

ttest momsecondary if interval1==1, by(merite)
ttest dadsecondary if interval1==1, by(merite)
ttest running if interval1==1, by(merite)
ttest distance if interval1==1, by(merite)

gen 	interval2=0
replace interval2=1 if score>132 & score<170

ttest momsecondary if interval2==1, by(merite)
ttest dadsecondary if interval2==1, by(merite)
ttest running if interval2==1, by(merite)
ttest distance if interval2==1, by(merite)

reg highestgrade winner

gen 	score_dist=score-152

reg highestgrade winner score_dist
reg highestgrade winner score_dist c.score_dist#c.score_dist
reg highestgrade winner score_dist c.score_dist#c.score_dist c.score_dist#c.score_dist#c.score_dist

reg winner score_dist c.score_dist#c.score_dist merite
predict b_winner, xb
reg highestgrade b_winner score_dist c.score_dist#c.score_dist
ivreg2 highestgrade score_dist c.score_dist#c.score_dist (winner=merite)
,
reg highestgrade winner if interval1==1
reg highestgrade winner score_dist if interval1==1
reg highestgrade winner score_dist c.score_dist#c.score_dist if interval1==1
