*cap log close
*log using PSM.log, replace

cd "C:\Users\Yao Thibaut Kpegli\Desktop\ENS Paris Saclay\Impact Evaluation\MOOC\Chap 3_PSM\Pratique"
use "psm.dta", clear




describe
tab abd
sum
bysort abd: sum

ttest age, by(abd)
ttest emp_mo, by(abd)
ttest educ, by(abd)
ttest illiterate, by(abd)
ttest C_ach, by(abd)
ttest C_akw, by(abd)
ttest C_ata, by(abd)
ttest C_kma, by(abd)
ttest C_oro, by(abd)
ttest C_pad, by(abd)
ttest C_paj, by(abd)
ttest C_pal, by(abd)

gen birthyear=2005-age


export excel PSM.xlsx , replace firstrow(var)


gen location=1* C_ach+2* C_akw+3* C_ata+4* C_kma+5* C_oro+6* C_pad+7* C_paj+8* C_pal

xi: logit abd i.birthyear i.location
predict ps1

sum ps1 if abd==1
sum ps1 if abd==0

tw kdensity ps1 if abd==1, col(red) fi(inten0)|| kdensity ps1  if abd==0, col(blue) fi(inten0)

xi: psmatch2 abd i.birthyear i.location, logit
pstest
;
xi: psmatch2 abd i.birthyear i.location, neighbor(3) logit
pstest

xi: psmatch2 abd i.birthyear i.location, kernel logit
pstest

xi: psmatch2 abd i.birthyear i.location, outcome(illiterate educ emp_mo) logit
xi: psmatch2 abd i.birthyear i.location, outcome(illiterate educ emp_mo) neighbor(3) logit
xi: psmatch2 abd i.birthyear i.location, outcome(illiterate educ emp_mo) kernel logit

;
