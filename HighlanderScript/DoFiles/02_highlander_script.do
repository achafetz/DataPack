**   Highlander Script
**   COP FY16
**   Aaron Chafetz
**   Purpose: develop a model of the Highlander Script
**   Date: October 19, 2016
**   Updated: 10/21

/* NOTES
	- Data source: ICPI_Fact_View_Site_IM_20160915 [ICPI Data Store]
*/
********************************************************************************

*loop over all countries
	*angola asiaregional botswana burma burundi cambodia
	local ctrylist     ///
		cameroon caribbeanregion centralamerica centralasia civ ///
		dominicanrepublic drc ethiopia ghana guyana haiti india indonesia ///
		kenya lesotho malawi mozambique namibia nigeria png rwanda ///
		southafrica southsudan swaziland tanzania uganda ukraine ////
		vietnam zambia zimbabwe
	foreach ou of local ctrylist{
		di "`=upper(`ou')'" in yellow
	
* import data
	use  "$output/temp_orig_site_`ou'", replace //run 02_highlander_convert first
	* only HTC_TST, TX_NEW, and TX_CURR

* merge in aggregated Highlander Script age groups & edit type
	merge m:1 age using  "$output\temp_agegpcw.dta", nogen keep(match master)
	replace hs_type = "Finer" if inlist(indicator, "TX_CURR", "TX_NEW") & ///
		inlist(disaggregate, "Age/Sex Aggregated", "Age/Sex, Aggregated") ///
		& age=="<01"
	replace hs_type = "Total Numerator" if disaggregate=="Total Numerator"
	replace hs_type = "Results" if disaggregate== "Results" 
	
* create a unique id by type (facility, community, military)
	* demarcated by f, c, and m at front
	* military doesn't have a unique id so script uses mechanism uid
	tostring type*, replace
	gen fcm_uid = ""
		replace fcm_uid = "f_" + facilityuid
		replace fcm_uid = "c_" + communityuid if facilityuid=="" &  ///
			typecommunity =="Y"
		replace fcm_uid = "m_" + mechanismuid if typemilitary=="Y" 

* collapse so one observation per site (removed fundingagency)
	collapse (sum) fy*, by(operatingunit psnu psnuuid snuprioritization ///
		fcm_uid indicatortype indicator hs_type mechanismid) 

*drop dedups (apply decision at after with merge)
	drop if inlist(mechanismid, 0, 1)
	
* remove any sites with no data for all quarters 
	drop fy2016_targets *apr
		/*want to just look at quarterly data; apr should be recalculatedneed 
			need to think about if targets should/shouldn't be determined by 
			results selection*/
	egen rowtot = rowtotal (fy*)
	drop if rowtot==0
	drop rowtot

* reshape long so fiscal years are in rows
	*rename fiscal years to (1) have common stub and (2) retain their name in reshape 
		ds fy*
		foreach yr in `r(varlist)'{
			rename `yr' y`yr'
			}
			*end
	*reshape
		reshape long y@, i(psnuuid fcm_uid mechanismid indicatortype ///
			indicator hs_type) j(pd, string)	

*reshape wide, adding Highlander types as columns for doing analysis
	*remove space in name for reshape
		replace hs_type = "TotNum" if hs_type=="Total Numerator"

	* reshape
		reshape wide y, i(psnuuid fcm_uid mechanismid indicatortype ///
			indicator pd) j(hs_type, string)
	* clean up names, removing y and making lower case
		ds y*
		foreach x in `r(varlist)'{
			rename `x' `=lower("`=subinstr("`x'","y","",.)'")'
			}
			*end

*drop if no data in row	(different for HTC because using result)
	egen rowtot = rowtotal(coarse-totnum)
	drop if rowtot==0
	drop row*

/*
            Highlander numerator
	|--------|----------------------------------------|
	| Option | Numerator                              |
	|--------|----------------------------------------|
	| 1      | Total Numerator used                   |
	| 2      | Result used (HTC) - complete           |
	| 3      | Result used (HTC) - no total numerator |
	| 4      | Total Numerator used (HTC)             |
	| 5      | No Total Numerator                     |
	|--------|----------------------------------------|
*/
* deterime which numerator to use
	gen r_pct = results/totnum //determine completeness
	gen hs_num_desc=.
		lab var hs_num_desc "Type of Numerator for Highlander Script"
		lab def hs_num_desc 1 "Total Numerator used" 2 "Result used (HTC)" ///
			3 "Result used (HTC) - no total numerator" ///
			4 "Total Numerator used (HTC)" 5 "No Total Numerator"
		lab val hs_num_desc hs_num_desc
		replace hs_num_desc = 1 if !inlist(totnum,0,.) & indicator!="HTC_TST" 
		replace hs_num_desc = 2 if !inlist(result,0,.) & indicator=="HTC_TST" ///
			& (r_pct>=.95 & r_pct<=1)
		replace hs_num_desc = 3 if inlist(totnum,0,.) & indicator=="HTC_TST"  ///
			& !inlist(result,0,.)
		replace hs_num_desc = 4 if !inlist(totnum,0,.) & indicator=="HTC_TST" ///
			& (r_pct<.95 | r_pct>1)
		replace hs_num_desc = 5 if inlist(totnum,0,.) & hs_num_desc==.

* create numerator based on description
	gen hs_num = totnum if inlist(hs_num_desc, 1, 4)
		replace hs_num = result if inlist(hs_num_desc, 2, 3)
		lab var hs_num "Highlander Numerator"
		
* create Highlander indicators used for making selection	
	gen f_pct = finer/hs_num
	gen c_pct = coarse/hs_num
	gen fc_pct= (finer + coarse)/hs_num
	gen f_prox = abs(1-f_pct)
	gen c_prox = abs(1-c_pct)
	
/*
		Highlander Script Result
	|-------|------------------------------|
	| Order | Highlander Result            |
	|-------|------------------------------|
	| 1     | Fine (complete)              |
	| 2     | Coarse (complete)            |
	| 3     | Fine + Coarse (complete)     |
	| 4     | Fine (incomplete)            |
	| 5     | Coarse (incomplete)          |
	| 6     | Fine (max, no num)           |
	| 7     | Coarse (max, no num)         |
	| 8     | Result (no fine or coarse)   |
	| 9     | Total Numerator (no disaggs) |
	|-------|------------------------------|
*/
*determine highlander script choice by above ordering
	gen hsc = .
		lab var hsc "Highlander Disagg Choice"
		lab def hsc 1 "Fine (complete)" 2 "Coarse (complete)" ///
			3 "Fine + Coarse (complete)" 4 "Fine (incomplete)" ///
			5 "Coarse (incomplete)" 6 "Fine (max, no num)" ///
			7 "Coarse (max, no num)" 8 "Result (no fine/coarse)" ///
			9 "Total Num (no disaggs)"
		lab val hsc hsc
		replace hsc = 1 if (f_pct>=.95 & f_pct<=1)
		replace hsc = 2 if (c_pct>=.95 & c_pct<=1) & hsc==.
		replace hsc = 3 if (fc_pct>=.95 & fc_pct<=1) & hsc==.
		replace hsc = 4 if f_prox <= c_prox & !inlist(f_prox,0,.) & !inlist(finer,0,.) & hsc==.
		replace hsc = 5 if (c_prox < f_prox) & !inlist(c_prox,0,.) & !inlist(coarse,0,.) & hsc==.
		replace hsc = 6 if ((finer >= coarse) & !inlist(finer,0,.) | (!inlist(finer,0,.) & inlist(coarse,0,.))) & hsc==.
		replace hsc = 7 if ((coarse > finer) & !inlist(coarse,0,.) | (!inlist(coarse,0,.) & inlist(finer,0,.))) & hsc==.
		replace hsc = 8 if !inlist(result,0,.) & hsc==.
		replace hsc = 9 if !inlist(totnum,0,.) & hsc==.

*keep only variables pertinent to site information for merge
	drop coarse-totnum r_pct hs_num-c_prox hs_num_desc

*sort for merging
	sort psnuuid fcm_uid indicator indicatortype 

*save for merging
	save "temp_hs_choice_`ou'", replace

*******************************************************************************

*reopen original site file 
	use "$output/temp_orig_site_`ou'", clear

* merge in aggregated Highlander Script age groups & edit type
	merge m:1 age using  "$output\temp_agegpcw.dta", nogen keep(match master)
	replace hs_type = "Finer" if inlist(indicator, "TX_CURR", "TX_NEW") & ///
		inlist(disaggregate, "Age/Sex Aggregated", "Age/Sex, Aggregated") ///
		& age=="<01"
	replace hs_type = "Total Numerator" if disaggregate=="Total Numerator"
	replace hs_type = "Results" if disaggregate== "Results" 
	
* create a unique id by type (facility, community, military)
	* demarcated by f, c, and m at front
	* military doesn't have a unique id so script uses mechanism uid
	tostring type*, replace
	gen fcm_uid = ""
		replace fcm_uid = "f_" + facilityuid
		replace fcm_uid = "c_" + communityuid if facilityuid=="" &  ///
			typecommunity =="Y"
		replace fcm_uid = "m_" + mechanismuid if typemilitary=="Y" 

* remove any sites with no data for all quarters 
	egen rowtot = rowtotal (fy*)
	drop if rowtot==0
	drop rowtot

* reshape long so fiscal years are in rows
	*create id for reshape
		gen id = _n
	*rename fiscal years to (1) have common stub and (2) retain their name in reshape 
		drop fy2015apr
		ds fy*
		foreach yr in `r(varlist)'{
			rename `yr' y`yr'
			}
			*end
	*reshape
		reshape long y@, i(id) j(pd, string)	
		drop id //needed for reshape	

*******************************************************************************
		
	*merge 
		merge m:1 pd psnuuid fcm_uid indicator indicatortype mechanismid ///
			using "temp_hs_choice_`ou'", nogen
	
	*fill missing
		ds, not(type int long float byte)
		foreach v in `r(varlist)'{
			replace `v' = "na" if `v'==""
			}
			*end

	*remove space in name for reshape
		replace hs_type = "TotNum" if hs_type=="Total Numerator"

	*reshape
		egen id = group(pd psnuuid fcm_uid mechanismid indicator indicatortype ///
			implementingmechanismname disaggregate age sex result ///
			otherdisaggregate)	
		reshape wide y, i(id) j(hs_type, string)
		drop id 
	* clean up names, removing y and making lower case
		ds y*
		foreach x in `r(varlist)'{
			rename `x' `=lower("`=subinstr("`x'","y","",.)'")'
			}
			*end
		replace hsc = 99 if hsc==.
			lab def hsc 99 "n/a", modify
	*drop blank rows
		egen rowtot = rowtotal (coarse finer results totnum)
		drop if rowtot==0
		drop rowtot
	
	*highlander value
		gen hsval =.
			replace hsval=finer if inlist(hsc, 1,4,6)
			replace hsval=coarse if inlist(hsc, 2,5,7)
			replace hsval=finer + coarse if hsc==3
			replace hsval=results if hsc==8
			replace hsval=totnum if hsc==9
	
	*drop 
		drop coarse-totnum
	*reshape
		egen id = group(psnuuid fcm_uid mechanismid indicator indicatortype ///
			disaggregate age sex result otherdisaggregate hsc)
		reshape wide hsval, i(id) j(pd, string)
		drop id
	*remove hsval
		ds hsval*
		foreach x in `r(varlist)'{
			rename `x' `=subinstr("`x'","hsval","",.)'
			}
			*end
	
	*drop blank rows
		egen rowtot = rowtotal (fy*)
		drop if rowtot==0
		drop rowtot
	*remove na
		ds, not(type int long float byte)
			foreach v in `r(varlist)'{
				replace `v' = "" if `v'=="na"
				}
				*end
	*reorder
		drop fcm_uid status
		order fy*, after(hsc)
	
	*add apr figure
		egen fy2015apr = rowtotal(fy2015q2 fy2015q3 fy2015q4)
		egen fy2015apr_tx = rowtotal(fy2015q2 fy2015q4) ///
			if indicator=="TX_CURR" & fy2015q3!=.
		replace fy2015apr = fy2015apr_tx if fy2015apr_tx!=.
		drop fy2015apr_tx
		order fy2015apr, after(fy2015q4)
	
	*highlander flag
		gen highlander = "Y"
		order highlander, before(fy2015q2)
	
	*collapse to psnu level
		collapse (sum) fy*, by(ïregion-implementingmechanismname indicator-highlander)
		
	*save
		save "$output/hs_psnu_`ou'", replace
		di "Save: `ou'" in yellow
	}
	*end
