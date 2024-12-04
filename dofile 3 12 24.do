clear
use "D:\Work\Project\call money\final data 03 12 2024.dta"
xi i.day, noomit
foreach var of varlist _Iday_23553- _Iday_23581{
	reg dealrate log_volume if `var'==1
	dfbeta
}

foreach var of varlist _dfbeta_1-_dfbeta_17 {
	egen `var'p5= pctile (`var') if `var'!=., p(5)
	egen `var'p95= pctile (`var')if `var'!=., p(95) 
}
foreach var of varlist _dfbeta_1-_dfbeta_17 {
	gen `var'dm=1 if `var'> `var'p95 & `var'>0 & `var'!=.
replace `var'dm=1 if `var'< `var'p5 & `var'<0 & `var'!=.
replace `var'dm=0 if  `var'dm==. & `var'!=.
}

foreach var of varlist _dfbeta_1-_dfbeta_17 {
	gen `var'dt=`var'dm*log_volume
}

foreach var of varlist _dfbeta_1-_dfbeta_17 {
reg dealrate log_volume `var'dm `var'dt
matrix b`var'=e(b) 
gen beta`var'= b`var'[1,3] if `var'!=.
}
foreach var of varlist _dfbeta_1-_dfbeta_17 {
 reg dealrate log_volume `var'dm `var'dt
matrix pval`var'=r(table) 
gen p`var' = pval`var'[4,3] if `var' != .
}
foreach var of varlist _dfbeta_1-_dfbeta_17 {
    reg dealrate log_volume `var'dm `var'dt
local nobs = e(N) 
gen nobs`var' = `nobs' if `var' != . 
}
foreach var of varlist _dfbeta_1-_dfbeta_17 {
    reg dealrate log_volume `var'dm `var'dt
local adjr2 = e(r2_a) 
gen adjrsq`var' = `adjr2' if `var' != . 
}

foreach var of varlist _dfbeta_1-_dfbeta_17 {
gen `var'depth=1/abs(beta`var')
}
*********************************

foreach var of varlist _dfbeta_1-_dfbeta_17 {
	egen `var'p15= pctile (`var') if `var'!=., p(12)
	egen `var'p85= pctile (`var')if `var'!=., p(95) 
}
foreach var of varlist _dfbeta_1-_dfbeta_17 {
	gen `var'dm85=1 if `var'> `var'p85 & `var'>0 & `var'!=.
replace `var'dm85=1 if `var'< `var'p15 & `var'<0 & `var'!=.
replace `var'dm85=0 if  `var'dm85==. & `var'!=.
}

foreach var of varlist _dfbeta_1-_dfbeta_17 {
	gen `var'dt85=`var'dm85*log_volume
}

foreach var of varlist _dfbeta_1-_dfbeta_17 {
reg dealrate log_volume `var'dm85 `var'dt85
matrix `var'85b=e(b) 
gen beta`var'85= `var'85b[1,3] if `var'!=.
}
foreach var of varlist _dfbeta_1-_dfbeta_17 {
reg dealrate log_volume `var'dm85 `var'dt85
matrix pval`var'85=r(table) 
gen p`var'85 = pval`var'85[4,3] if `var' != .
}



foreach var of varlist _dfbeta_1-_dfbeta_17 {
gen `var'depth85=1/abs(beta`var'85)
}





**************************************
drop if day==day[_n-1]
egen beta= rowmax(beta_dfbeta_1- beta_dfbeta_17)

egen depth_95_5= rowmax(_dfbeta_1depth- _dfbeta_17depth)
egen pval=rowmax(p_dfbeta_1-p_dfbeta_17)
egen obs=rowmax(nobs_dfbeta_1-nobs_dfbeta_17)
egen adj_r=rowmax(adjrsq_dfbeta_1- adjrsq_dfbeta_17)

******************
egen depth_85_15= rowmax(_dfbeta_1depth85- _dfbeta_17depth85)



tsset day
tsline depth_95_5 depth_85_15