
program define taxsimlocal35
version 14.0

local v 35
/*

net from http://www.nber.org/stata
net describe taxsim`v'
net install taxsim`v'

*/
display "begin taxsim`v'.ado on $S_DATE (version `v'.9)"
syntax [,Ssh FTp Curl Http local Replace Secondary Long Interest Wages Mortgage Full Debug]
capture gen  double taxsimid = _n
capture confirm var state 
if _rc > 0  gen state=0

preserve

/* c(tmpdir) only sometimes shows trailing slash*/
local servername `c(username)'
if "$tmpdir" == " "  {
   local tmpdir `c(tmpdir)'/ 
}
else {
   local tmpdir $tmpdir
}
*local tmpdir: subinstr local tmpdir "p/" "p"
if `"`debug'"'=="debug" local tmpdir "./"           
local results  "`tmpdir'results.raw"
local txpydata "`tmpdir'txpydata.raw"
local ftpcmd   "`tmpdir'ftp.txt"
capture rm `txpydata'
capture rm `results' 
capture rm `msg'     
capture rm `ftpcmd'  

di "Intermediate files:"
di "`txpydata' " _n "`results' " _n "`msg' " _n "`ftpcmd'"

gen mtr = 85
if `"`secondary'"' == `"secondary"' { 
   replace mtr = 86
   display "Marginal rate with respect to secondary earner"
} 
if `"`wages'"' == `"wages"' { 
   replace mtr = 11
   display "Marginal rate with respect to overall earnings"
} 
if `"`interest'"' == `"interest"' { 
   replace mtr = 14
   display "Marginal rate with respect to interest income"
} 
if `"`long'"' == `"long"' { 
   replace mtr = 70
   display "Marginal rate with respect to long term gains"
} 

if `"`mortgage'"' == `"mortgage"' { 
   replace mtr = 56
   display "Marginal rate with respect to long term gains"
} 
capture gen idtl=0
if `"`full'"' == `"full"' {
   replace idtl = 2 
   local idtl `idtl'
#delimit ;
     local addvars v10 v11 v12 v13 v14 v15 v16 v17 v18 v19      
                        v20 v21 v22 v23 v24 v25 v26 v27 v28 v29 
                        v30 v31 v32 v33 v34 v35 v36 v37 v38 v39 
                        v40 v41; 
     local addvars v10-v41;
     display "Full Intermediate Calculations Requested";
};
local txpyvars  taxsimid year   state  mstat     page     sage depx dep13      
      dep17     dep18     pwages swages dividends intrec   stcg ltcg otherprop 
      nonprop   pensions  gssi   ui     transfers rentpaid proptax             
      otheritem childcare mortgage idtl mtr pbusinc sbusinc pprofinc 
sprofinc scorp
      sui pui dep6 dep19 age1 age2 age3;
#delimit cr

local tosend `mtr' `idtl' 
local not_found " "
foreach X of local txpyvars {
   capture confirm var `X' 
   if _rc > 0 { 
      di "`X' " _continue
      local not_found  are not found, and default to zero. 
   } 
   else {
      confirm numeric variable `X'
      capture assert `X' != .
      if _rc >0 {
         di as error "`X' has one or more missing values."
         error 416
      }
      local tosend `tosend' `X'
   }
     
}
if _N==0 { 
  display as error "Aborting:  No observations in data set" 
  exit 498 
}  

di "`not_found'"
quietly des
local obs=r(N)
replace idtl=idtl+10 if _n==_N
di "Write `obs' obs to `txpydata'"
outsheet `tosend' using `txpydata', replace comma nolabel
   capture findfile taxsim`v'.exe
   di "`r(fn)'"
   if "$taxsimexe" != "" {
       local taxsimexe $taxsimexe/taxsim`v'.exe
   }
   else {
       local taxsimexe `r(fn)'
   }
   di "`taxsimexe'"
   if "`taxsimexe'"=="" {
     capture findfile taxsim`v'.exe
     di as error "TAXSIM:  `taxsim`v'.exe' not found. See"
     di as error "http://www.nber.org/taxsim/taxsim`v'/taxsim-local.html"
     exit 601
   }    

   if inlist("`c(os)'","MacOSX","Unix") { //edited
          local currdir = c(pwd)
          qui cd ~
          local homedir = c(pwd)
          qui cd "`currdir'"
          local taxsimexe : subinstr local taxsimexe "~" "`homedir'"
          ! chmod ugo+x "`taxsimexe'"
   }


   if "`c(os)'"=="Windows" local taxsimexe : subinstr local taxsimexe "/" "\"    ,all                    
   di  "`taxsimexe' >`results' <`txpydata'"
   if "`debug'"!="debug" set trace on
   shell  "`taxsimexe'"  >`results' <`txpydata'
   if "`debug'"!="debug" set trace off

import delimited using "`results'",clear varnames(1) delimiter(",") 
quietly des
local obs=r(N)
di "`obs' obs received"
if ( `r(N)'==0 ) {
   di as error "No calculations were returned by the tax calculator."
   if `"`http'"' == `"http"' {
      di as error "Possibly Powershell is not available?" 
   }
   else if `"`local'"' == `"local"' { 
      di as error "Is taxsim`v'.exe file in the executable path?"
   }
   else if `"`ftp'"' == `"ftp"' {
      di as error "Is there a firewall problem? See: http://www.nber.org/taxsim/ftp-problems.html" 
   }
   else { 
      di "ssh (default) transport is available in Windows 10 since April 2018. Otherwise try ftp option" 
   }
   exit 
}
if ( `r(N)'-`obs'!=0 ) {
   di as error "`obs' records sent and `r(N)' records received"
   di as error "An error occurred. There should be a report in  
   di as error "this log or in the last few lines of `results'. 
   di as error "Consult the Notes and Support section of the help file at:" 
   di as error "http://www.nber.org/taxsim/stata/ "
   exit _rc
}
capture confirm numeric variable taxsimid 
if _rc!=0 {
   format %-62s taxsimid
   list taxsimid if regexm(taxsimid,":")==1,noobs noheader clean
   exit 
}
*label variable state  "state id"
label variable fiitax "Federal Income Tax"
label variable siitax "State Income Tax"
label variable fica   "OASDI and HI Payroll Tax"
label variable frate  "IIT marginal rate"
label variable srate  "state marginal rate"
label variable ficar  "SS marginal rate" 
if `"`full'"' == `"full"' { 
   label variable v10 "Federal AGI" 
   label variable v11 "UI in AGI" 
   label variable v12 "Social Security in AGI" 
   label variable v13 "Zero Bracket Amount" 
   label variable v14 "Personal Exemptions" 
   label variable v15 "Exemption Phaseout" 
   label variable v16 "Deduction Phaseout" 
   label variable v17 "Deductions allowed" 
   label variable v18 "Federal Taxable Income" 
   label variable v19 "Federal Regular Tax" 
   label variable v20 "Exemption Surtax" 
   label variable v21 "General Tax Credit" 
   label variable v22 "Child Tax Credit (as adjusted)" 
   label variable v23 "Refundable Part of Child Tax Credit" 
   label variable v24 "Child Care Credit" 
   label variable v25 "Earned Income Credit" 
   label variable v26 "Income for the Alternative Minimum Tax" 
   label variable v27 "AMT Liability (addition to regular tax)" 
   label variable v28 "Income Tax before Credits"
   label variable v29 "FICA" 
   label variable v30 "State Household Income" 
   label variable v31 "State Rent Payments" 
   label variable v32 "State AGI" 
   label variable v33 "State Exemption amount" 
   label variable v34 "State Standard Deduction" 
   label variable v35 "State Itemized Deductions" 
   label variable v36 "State Taxable Income" 
   label variable v37 "State Property Tax Credit" 
   label variable v38 "State Child Care Credit" 
   label variable v39 "State EITC "
   label variable v40 "State Total Credits" 
   label variable v41 "State Bracket Rate" 
   label variable v42 "QBI Deduction"
/*   capture label variable v43 "Net Investment Income Tax"
   capture label variable v44 "Medicare Tax on Earned Income" 
*/
   capture label variable v42 "Earned Self-Employment Income for FICA"
   capture label variable v43 "Medicare Tax on Unearned Income"
   capture label variable v44 "Medicare Tax on Earned Income"
   capture label variable v45 "CARES act Recovery Rebates"
} 

save `tmpdir'taxsim_out,replace

if "`replace'" == "replace" {
   restore
   capture drop _merge 
   capture drop `results' 
   capture merge 1:m taxsimid year using `resdir'taxsim_out,update replace
   if _rc != 0 { 
     di "Merge failed " _rc
     tab _merge
   } 
}
else {
   restore
}
capture drop _merge
end
  
