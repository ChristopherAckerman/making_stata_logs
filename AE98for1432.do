// Edited 04-16-20 from code for Extrapolating 2013

clear all
set more off
capture log close
log using AE98for1432.log, replace
use m_d_806.dta, clear

***************************
******** recodes **********
***************************

gen ageq2nd1=real(ageq2nd)
gen ageq3rd1=real(ageq3rd)

gen multi2nd = (ageq2nd1 == ageq3rd1)

gen educm = gradem - 3
replace educm = gradem - 2 if fingradm == 2 | fingradm == 1
replace educm = max(0,educm)

gen blackm= ( racem==2)
gen hispm= ( racem==12)
gen whitem= ( racem==1)
gen othracem = 1 - blackm - hispm - whitem

gen boy1st = (sexk==0)
gen boy2nd = (sex2nd==0)
gen boys2 = (sexk==0 & sex2nd==0)
gen girls2 =(sexk==1 & sex2nd==1)
gen samesex =(boys2==1 | girls2==1)

gen morekids = 1 if kidcount>2
replace morekids = 0 if kidcount<=2

gen illegit=0
gen yom = .
replace qtrmar = qtrmar - 1 
replace yom = yobm + agemar if (qtrbthm <= qtrmar) 
replace yom = yobm + agemar + 1 if (qtrbthm>qtrmar) 
gen dom_q = yom + (qtrmar/4) 
gen dolb_q = yobk + ((qtrbkid)/4) 
replace illegit = 1 if ((dom_q - dolb_q)>0	) 

gen yobd=79 - aged
replace yobd = 80 - aged if qtrbthd==0

gen agem1 = agem*1
gen aged1 = aged*1
gen ageqm = 4*(80 - yobm)-qtrbthm-1
gen ageqd = 4*(80 - yobd) - qtrbthd
gen agefstd = int((ageqd - ageqk)/4)
gen agefstm = int((ageqm - ageqk)/4)
gen msample = 0
replace msample = 1 if ((aged!=.) & (timesmar==1) & (marital==0) & (illegit==0) & (agefstd >=15) & (agefstm >= 15) & !mi(agefstd))

gen weeksm1 = weeksm*1
gen weeksd1 = weeksd*1
gen workedm = 0
replace workedm = 1 if weeksm>0
gen workedd = 0
replace workedd = 1 if weeksd>0
gen hourswd = hoursd*1
gen hourswm = hoursm*1

*All women sample:
keep if ((agem1>=21 & agem1<=35) & (kidcount>=2) & (ageq2nd1>4) & (agefstm>=15) & (asex==0) & (aage==0) & (aqtrbrth==0) & (asex2nd==0) & (aage2nd==0))
  /*& (agefstd>=15 | agefstd==.)*/
  
*keep if (msample==1)
  
sum agem1 kidcount ageq2nd1 agefstm weeksm1 workedm morekids agem1 boy1st boy2nd blackm hispm othracem multi2nd samesex msample

*OLS:
reg weeksm1 morekids agem1 agefstm boy1st boy2nd blackm hispm othracem, r
reg workedm morekids agem1 agefstm boy1st boy2nd blackm hispm othracem, r

*first stage and reduced form: twins
reg morekids multi2nd, r
reg weeksm1 multi2nd, r
reg workedm multi2nd, r
*Wald for twins
ivregress 2sls weeksm1 (morekids = multi2nd)
 
*first stage and reduced form: samesex
reg morekids samesex, r
reg weeksm1 samesex, r
reg workedm samesex, r
*Wald for samesex
ivregress 2sls weeksm1 (morekids = samesex)

*check for balance
reg agefstm multi2nd agem1 boy1st boy2nd blackm hispm othracem, r
reg educm multi2nd agem1 agefstm boy1st boy2nd blackm hispm othracem, r
reg agefstm samesex agem1 boy1st boy2nd blackm hispm othracem, r
reg educm samesex agem1 agefstm boy1st boy2nd blackm hispm othracem, r

*2sls (twins, w/covs)
ivregress 2sls weeksm1 (morekids = multi2nd) agem1 agefstm boy1st boy2nd blackm hispm othracem, r
ivregress 2sls workedm (morekids = multi2nd) agem1 agefstm boy1st boy2nd blackm hispm othracem, r

*2sls (samesex, w/covs)
ivregress 2sls weeksm1 (morekids = samesex) agem1 agefstm boy1st boy2nd blackm hispm othracem, r
ivregress 2sls workedm (morekids = samesex) agem1 agefstm boy1st boy2nd blackm hispm othracem, r

*2sls (overid, w/covs)
ivregress 2sls weeksm1 (morekids = multi2nd samesex) agem1 agefstm boy1st boy2nd blackm hispm othracem, r
ivregress 2sls workedm (morekids = multi2nd samesex) agem1 agefstm boy1st boy2nd blackm hispm othracem, r

*manual 2SLS
reg morekids multi2nd samesex agem1 agefstm boy1st boy2nd blackm hispm othracem
predict more_hat if e(sample)
reg weeksm1 more_hat agem1 agefstm boy1st boy2nd blackm hispm othracem, r
reg workedm more_hat agem1 agefstm boy1st boy2nd blackm hispm othracem, r

log close
