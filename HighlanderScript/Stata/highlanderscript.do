**   Partner Performance by SNU
**   COP FY16
**   Aaron Chafetz
**   Purpose: Highlander Script
**   Date: October 19, 2016
**   Updated:

/* NOTES
	- Data source: ICPI_Fact_View_Site_IM_20160915 [ICPI Data Store]
*/
********************************************************************************

*create highlander age groups
	cd "C:\Users\achafetz\Documents\ICPI\Data"
	clear
	input str6 (age hs_agegp hs_type) //crosswalk table
		"<01" "<15" "Finer"
		"01-14" "<15" "Finer"
		"<15" "<15" "Coarse"
		"01-04" "<15" "Finer"
		"05-09" "<15" "Finer"
		"05-14" "<15" "Finer"
		"10-14" "<15" "Finer"
		"15+" "15+" "Coarse"
		"15-19" "15+" "Finer"
		"20+" "15+" "Finer"
		"20-24" "15+" "Finer"
		"25-49" "15+" "Finer"
		"50+" "15+" "Finer"
		end
	save temp_cw.dta


* unzip folder containing all site data
	cd "C:\Users\achafetz\Documents\ICPI\Data"
	global folder "ALL Site Dataset 20160915"
	unzipfile "$folder"
	
*convert files from txt to dta for appending and keep only TX_CURR and TX_NEW (total numerator)
	cd "C:\Users\achafetz\Documents\ICPI\Data\ALL Site Dataset 20160915"
	fs 
	foreach ou in `r(files)'{
		di "import/save: `ou'"
		qui: import delimited "`ou'", clear
		*keep just ACT indicator
		qui: replace disaggregate= "Age/Sex Aggregated" if ///
			disaggregate=="Age/Sex, Aggregated" //fix issue with TX_CURR
		qui: keep if (indicator=="HTC_TST" & ///
			inlist(disaggregate, "Age/Sex/Result", "Age/Sex Aggregated/Result", ///
			"Results", "Total Numerator")) | (inlist(indicator, "CARE_NEW", ///
			"TX_NEW", "TX_CURR") & inlist("Age/Sex", "Age/Sex Aggregated", ///
			"Total Numerator"))
		qui: save "`ou'.dta", replace
		}
		*end
*append all ou files together
	clear
	fs *.dta
	di "append files"
	qui: append using `r(files)', force
	
*save all site file
	cd "C:\Users\achafetz\Documents\ICPI\Data"
	local datestamp "20160915"
	save "HIGHLANDER_Site_IM`datestamp'", replace
	
*delete files
	fs *.dta 
	erase `r(files)'
	fs *.txt
	erase `r(files)'
	rmdir "C:\Users\achafetz\Documents\ICPI\Data\ALL Site Dataset 20160915\"
	


	merge m:1 age using "`temp_cw'", nogen keep(match master) //merge in crosswalk table

	
replace hs_type = "Finer" if inlist(indicator, "TX_CURR", "TX_NEW") & disaggregate=="Age/Sex Aggregated" & age=="<01"
replace hs_type = "Total Numerator" if disaggregate=="Total Numerator"
replace hs_type = "Results" if disaggregate== "Results" 


***********

cd "C:\Users\achafetz\Documents\ICPI\Data\ALL Site Dataset 20160915"
import delimited site_im_20160915_southafrica.txt, clear  


replace disaggregate= "Age/Sex Aggregated" if ///
			disaggregate=="Age/Sex, Aggregated" //fix issue with TX_CURR
keep if (indicator=="HTC_TST" & ///
			inlist(disaggregate, "Age/Sex/Result", "Age/Sex Aggregated/Result", ///
			"Results", "Total Numerator")) | ///
	  (indicator=="CARE_NEW" & inlist(disaggregate, "Age/Sex", "Age/Sex Aggregated", ///
			"Total Numerator")) | ///
	  (indicator=="TX_CURR" & inlist(disaggregate,"Age/Sex", "Age/Sex Aggregated", ///
			"Total Numerator"))

merge m:1 age using "C:\Users\achafetz\Documents\ICPI\Data\temp_cw.dta", nogen keep(match master)

replace hs_type = "Finer" if inlist(indicator, "TX_CURR", "TX_NEW") & disaggregate=="Age/Sex Aggregated" & age=="<01"
replace hs_type = "Total Numerator" if disaggregate=="Total Numerator"
replace hs_type = "Results" if disaggregate== "Results" 

gen fcm_uid = ""
	replace fcm_uid = "f_" + facilityuid
	replace fcm_uid = "c_" + communityuid if facilityuid=="" &  typecommunity =="Y"
	replace fcm_uid = "m_" + mechanismuid if typemilitary=="Y"

collapse (sum) fy*, by(operatingunit psnu psnuuid snuprioritization ///
	fcm_uid indicatortype indicator hs_type) 
	*removed fundingagency disaggregate sex resultstatus hs_agegp mechanismid

egen rowtot = rowtotal (fy*)
drop if rowtot==0
drop rowtot
drop fy2016_targets *apr //need to think about how to get this back in


egen id = group(psnuuid fcm_uid indicatortype indicator hs_type)

ds fy*
foreach yr in `r(varlist)'{
	rename `yr' y`yr'
	}
	*end
reshape long y@, i(id) j(pd, string)  
drop id

egen id = group(psnuuid fcm_uid indicatortype indicator pd)
replace hs_type = "TotNum" if hs_type=="Total Numerator"
reshape wide y, i(id) j(hs_type, string)
drop id

ds y*
foreach x in `r(varlist)'{
	rename `x' `=lower("`=subinstr("`x'","y","",.)'")'
	}
	*end

	
	
egen rowtot_htc = rowtotal(coarse-results) if indicator=="HTC_TST"
egen rowtot_oth = rowtotal(coarse finer) if indicator!="HTC_TST"
egen rowtot = rowtotal(rowtot_htc rowtot_oth)
drop if rowtot==0
drop row*
	
gen f_pct = finer/totnum
gen c_pct = coarse/totnum
gen r_pct = results/totnum
gen fc_pct= (finer + coarse)/totnum
	replace f_pct = finer/result if indicator=="HTC_TST" & (r_pct>=.95 | r_pct <=1)
	replace c_pct = coarse/result if indicator=="HTC_TST" & (r_pct>=.95 | r_pct <=1)
	replace fc_pct = (finer + coarse)/result if indicator=="HTC_TST" & (r_pct>=.95 | r_pct <=1)
gen f_prox = abs(1-f_pct)
gen c_prox = abs(1-c_pct)
gen prox_choice = ""
	if f_prox < c_prox {
		replace prox_choice = "finer"
		}
	else if c_prox < f_prox {
		replace prox_choice = "coarse"
		}
	else {
		replace prox_choice = ""
		}
		*end

gen hs_r = ""
	if (f_pct>=.95 | f_pct<=1) replace hs_r = "finer"
	else if (c_pct>=.95 | c_pct<=1) replace hs_r = "coarse"
	else if ((f_pct + c_pct)>=.95 | (f_pct + c_pct)<=1) replace hs_r = "f+c"
	else if ((indicator=="HTC_TST" & (r_pct>=.95 | r_pct <=1) & inlist(result, ., 0)) | ///
		((indicator=="HTC_TST" & (r_pct<=.95 | r_pct >=1) & inlist(totnum, ., 0)) | ///
		((indicator!="HTC_TST" & inlist(totnum, ., 0)) {
		replace hs_r = "no numerator"
		}
		*end
	else replace hs_r = prox_choice 
		
	









foreach v in sex resultstatus hs_agegp{
	replace `v' = "na" if `v'==""
	}
	*end


replace sex = "F" if sex=="Female"
replace sex = "M" if sex=="Male"
replace hs_type="TNum" if hs_type=="Total Numerator"

gen cat = ""
	replace cat = hs_type + "_" + hs_agegp + "_" + sex if inlist(indicator, "CARE_NEW", "TX_NEW", "TX_CURR")
	replace cat = hs_type + "_" + hs_agegp + "_" + sex + "_" + resultstatus if indicator=="HTC_TST"
	replace cat = hs_type if inlist(hs_type, "TNum", "Results")

drop disaggregate sex resultstatus hs_agegp hs_type
egen id = group(pd psnuuid pd psnuuid mechanismid indicator indicatortype fcm_uid)
reshape wide y, i(id) j(cat, string)
