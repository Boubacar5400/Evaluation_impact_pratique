*cap log close
*log using PSM.log, replace


********************************************************************************
****************************Importation de donnée*******************************
********************************************************************************

cd "C:\Users\Yao Thibaut Kpegli\Desktop\ENS Paris Saclay\Impact-Evaluation\PSM"
import excel PSM.xlsx, firstrow clear
*ed


********************************************************************************
*****************Première partie : Statistiques descriptives *******************
********************************************************************************


tab abd
sum
bysort abd: sum

ttest age, by(abd)
reg age abd

ttest C_ach, by(abd)
ttest C_akw, by(abd)
ttest C_ata, by(abd)
ttest C_kma, by(abd)
ttest C_oro, by(abd)
ttest C_pad, by(abd)
ttest C_paj, by(abd)
ttest C_pal, by(abd)

ttest emp_mo, by(abd)
ttest educ, by(abd)
ttest illiterate, by(abd)




********************************************************************************
*******************  Deuxième partie : Score de propension  ********************
********************************************************************************

ta birthyear, gen(b_)

logit abd b_* C_*
predict ps1

reg ps1 abd


tw (kdensity ps1 if abd==1, col(red)) ///
(kdensity ps1  if abd==0, col(blue)) ///
, ytitle(Density) xtitle("Propensity score") graphregion(color(white)) ///
legend(label(1 "Treated") label(2 "Untreated"))


********************************************************************************
*************************  Troisième partie : Matching  ************************
********************************************************************************

psmatch2 abd b_* C_*, logit
pstest

psmatch2 abd b_* C_*, neighbor(3) logit
pstest

psmatch2 abd b_* C_*, kernel logit
pstest



********************************************************************************
*************************  	Quatrième partie : Impact **************************
********************************************************************************

psmatch2 abd b_* C_*, outcome(illiterate educ emp_mo) logit
psmatch2 abd b_* C_*, outcome(illiterate educ emp_mo) neighbor(3) logit
psmatch2 abd b_* C_*, outcome(illiterate educ emp_mo) kernel logit


