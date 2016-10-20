/*******************************************************************************

** ACT TOOL DATA SUBSET **

	Purpose: Collapse full frozen data set to just observations needed for the 
		ACT Tool used in country POARTS
	Date: May 24, 2016
	Updated: 10/18/2016
	Aaron Chafetz
	USAID/ICPI 
	
*******************************************************************************/

*set directories
	global source "C:\Users\achafetz\Documents\ICPI\Data"
	global save  "C:\Users\achafetz\Documents\ICPI\Peds"
*set date of frozen instance - needs to be changed w/ updated data
	local datestamp "20161010"
*import frozen instance for ACT Monitoring Tool
	capture confirm file "$source\ICPIFactView_SNUbyIM`datestamp'.dta"
		if !_rc{
			di "Use Existing Dataset"
			use "$source\ICPIFactView_SNUbyIM`datestamp'.dta", clear
		}
		else{
			di "Import Dataset"
			import delimited "$source\ICPI_Fact_View_PSNU_IM_`datestamp'.txt", clear
			save "$source\ICPIFactView_SNUbyIM`datestamp'.dta", replace
		}
	*end

*remove unnessary observations and indicators
	drop if numeratordenom =="D" //only need numerators
	keep operatingunit operatingunituid countryname psnu psnuuid ///
		snuprioritization indicator disaggregate ///
		age resultstatus otherdisaggregate ///
		fy2015apr fy2016* //adjust periods as necessary (keeping previous FY, current FY targets and quarterly data)
*remove rows with zero data in results and targets
	recode fy2015apr fy2016* (0=.)
	egen resultsum = rowmiss(fy2015apr fy2016*)
	ds fy2015 fy2016*
	global count: word count `r(varlist)' 
	drop if resultsum == $count
	drop resultsum
*keep only specific indicator disaggregates
	keep if /// HTC_TST CARE_NEW TX_NEW TX_CURR TX_RET TX_UNDETECT TX_VIRAL
		(inlist(indicator, "HTC_TST",  "CARE_NEW", "TX_NEW", "TX_CURR", "TX_RET", "TX_UNDETECT", "TX_VIRAL") & ///
		inlist(disaggregate, "Age/Sex/Result", "Age/Sex Aggregated/Result", "Age/Sex", "Age/Sex Aggregated", "Age/Sex, Aggregated")) ///
		| /// PMTCT_EID (<1 for HTC)
		(inlist(indicator, "PMTCT_EID", "PMTCT_EID_POS_2MO", "PMTCT_EID_POS_12MO") & ///
		disaggregate=="Total Numerator") ///
		| /// PMTCT_STAT
		(indicator=="PMTCT_STAT" & disaggregate=="Known/New") ///
		| /// Total numerators for completeness checks
		(inlist(indicator, "HTC_TST", "CARE_NEW", "TX_NEW", "TX_CURR") & ///
		disaggregate=="Total Numerator")
*identify ACT countries
	gen act = .
	replace act = 1 if ///
	inlist(operatingunit, "Cameroon", "Democratic Republic of the Congo", "Kenya", "Lesotho", "Malawi", "Mozambique", "Tanzania", "Zambia", "Zimbabwe")
	order act, after(countryname)
*export	
	local date = subinstr("`c(current_date)'", " ", "", .)
	export delimited using "$save\ACTMonitoringTooldata_`date'.txt", ///
			nolabel replace dataf
	
bob		
********************************************************************************
********************************************************************************
********************************************************************************

/* ACT Data Validation Check **
	Purpose: Validate data by age disaggs from raw data compared to formula pulls
		in the ACT Tool */
		
*open
	use "$save\frozen_20160513.dta", clear
*select country to compare and remove ' from country names
	*keep if operatingunit=="Malawi"
	replace operatingunit="Cote dIvoire" if operatingunit=="Cote d'Ivoire"
*order age disaggs for display
	gen disagg=.
		replace disagg = 1 if age=="<15" | (inlist(age, "<01", "01-14") & inlist(indicator, "TX_NEW", "TX_CURR") &  inlist(disaggregate, "Age/Sex Aggregated", "Age/Sex, Aggregated"))
		replace disagg = 3 if (age=="<01" & !inlist(disaggregate, "Age/Sex Aggregated", "Age/Sex, Aggregated")) |(inlist(indicator, "PMTCT_EID", "PMTCT_EID_POS_12MO") & disaggregate=="Total Numerator" & disaggregate=="Total Numerator")
			recode disagg (3=.) if indicator=="HTC_TST"
		replace disagg = 4 if age=="01-04"
		replace disagg = 5 if age=="<05"
		replace disagg = 6 if inlist(age, "05-09", "10-14", "05-14")
		replace disagg = 7 if age=="15-19"
		replace disagg = 8 if otherdisaggregate=="Known at Entry"
		replace disagg = 9 if otherdisaggregate=="Newly Identified"
		lab def disagg 1 "Gross Total(<15)" 2 "Finer Total (<15)" 3 "<01" ///
			4 "01-04" 5 "<05" 6 "05-14" 7 "15-19" 8 "Known at Entry" ///
			9 "Newly Identified"
		lab val disagg disagg
*replace HTC_TST <1 with PMTCT_EID Total Numerator and validate
	clonevar ind = indicator
	clonevar dis = disaggregate
		replace ind = "HTC_TST" if indicator=="PMTCT_EID" & disaggregate=="Total Numerator"
		replace dis = "Age/Sex/Result" if indicator=="PMTCT_EID" & disaggregate=="Total Numerator"
	table disagg if indicator=="PMTCT_EID" & disaggregate=="Total Numerator", ///
			c(sum fy2016q1 sum fy2016q2 sum fy2016_targets sum fy2015apr) format(%12.0fc) cellwidth(17)
	table disagg if ind=="HTC_TST" & dis=="Age/Sex/Result" & disagg==3, ///
			c(sum fy2016q1 sum fy2016q2 sum fy2016_targets sum fy2015apr) format(%12.0fc) cellwidth(17)
*rename disaggregates for ease of looping over variables		
	replace dis = "Age/Sex" if inlist(ind, "HTC_TST", "PMTCT_STAT") & inlist(dis, "Age/Sex/Result", "Known/New")
	replace dis = "Age/Sex Aggregated" if ind =="HTC_TST" & dis=="Age/Sex Aggregated/Result"

*loop over OUs and indicators to check ACT age disagg tables
	local vars HTC_TST HTC_TST_POS CARE_NEW TX_NEW TX_CURR PMTCT_STAT
	local settings "c(sum fy2016q1 sum fy2016q2 sum fy2016_targets sum fy2015apr) format(%12.0fc) cellwidth(17)"
	levelsof(operatingunit), local(ou)
	qui: log using "$save/valcheck.txt", text replace
	foreach ctry of local ou{
		preserve
		qui: keep if operatingunit=="`ctry'"
		*add break for each OU
		di _newline _newline "*************************************************************************************" _newline _newline ///
			"*** `=upper("`ctry'")' ***" _newline _newline "*************************************************************************************" _newline _newline
		foreach ind of local vars{
			di "`ind'"
			if "`ind'" =="HTC_TST_POS" {
				qui: replace ind = "HTC_TST" if indicator=="PMTCT_EID_POS_12MO" & disaggregate=="Total Numerator"
				qui: replace dis = "Age/Sex" if indicator=="PMTCT_EID_POS_12MO" & disaggregate=="Total Numerator"
				qui: replace resultstatus= "Positive" if indicator=="PMTCT_EID_POS_12MO" & disaggregate=="Total Numerator"
				table disagg if ind=="HTC_TST" & resultstatus=="Positive" & inlist(dis, "Age/Sex", "Age/Sex Aggregated"), `settings'
				}
			else {
				capture noisily: table disagg if ind=="`ind'" & inlist(dis, "Age/Sex", "Age/Sex Aggregated", "Age/Sex, Aggregated"), `settings'
				*id no observations, continue to next indicator
					if _rc==2000{
						continue
						}
				}
			}
		qui: restore
		}
		qui: log close
			*end

			
********************************************************************************

*open
	use "$save\frozen_20160513.dta", clear
*remove unnessary observations and indicators
	drop if numeratordenom =="D" //only need numerators
	keep operatingunit operatingunituid countryname psnu psnuuid ///
		snuprioritization indicator disaggregate ///
		age resultstatus otherdisaggregate ///
		fy2015apr fy2016_targets fy2016q1 fy2016q2 //adjust periods as necessary (keeping previous FY, current FY targets and quarterly data)
*keep only specific indicator disaggregates
	keep if /// HTC_TST CARE_NEW TX_NEW TX_CURR TX_RET TX_UNDETECT TX_VIRAL
		(inlist(indicator, "HTC_TST",  "CARE_NEW", "TX_NEW", "TX_CURR", "TX_RET", "TX_UNDETECT", "TX_VIRAL") & ///
		inlist(disaggregate, "Age/Sex/Result", "Age/Sex Aggregated/Result", "Age/Sex", "Age/Sex Aggregated", "Age/Sex, Aggregated")) ///
		| /// PMTCT_EID (<1 for HTC)
		(inlist(indicator, "PMTCT_EID", "PMTCT_EID_POS_12MO") & ///
		disaggregate=="Total Numerator") ///
		| /// PMTCT_STAT
		(indicator=="PMTCT_STAT" & disaggregate=="Known/New")
*order age disaggs for display
	gen disagg=.
		replace disagg = 1 if age=="<15" | (inlist(age, "<01", "01-14") & inlist(indicator, "TX_NEW", "TX_CURR") &  inlist(disaggregate, "Age/Sex Aggregated", "Age/Sex, Aggregated"))
		replace disagg = 3 if (age=="<01" & !inlist(disaggregate, "Age/Sex Aggregated", "Age/Sex, Aggregated")) |(inlist(indicator, "PMTCT_EID", "PMTCT_EID_POS_12MO") & disaggregate=="Total Numerator" & disaggregate=="Total Numerator")
			recode disagg (3=.) if indicator=="HTC_TST"
		replace disagg = 4 if age=="01-04"
		replace disagg = 5 if age=="<05"
		replace disagg = 6 if inlist(age, "05-09", "10-14", "05-14")
		replace disagg = 7 if age=="15-19"
		replace disagg = 8 if otherdisaggregate=="Known at Entry"
		replace disagg = 9 if otherdisaggregate=="Newly Identified"
		lab def disagg 1 "Gross Total(<15)" 2 "Finer Total (<15)" 3 "<01" ///
			4 "01-04" 5 "<05" 6 "05-14" 7 "15-19" 8 "Known at Entry" ///
			9 "Newly Identified"
		lab val disagg disagg
		drop if disagg==.
*replace HTC_TST <1 with PMTCT_EID Total Numerator and validate
	clonevar ind = indicator
	clonevar dis = disaggregate
		replace ind = "HTC_TST" if indicator=="PMTCT_EID" & disaggregate=="Total Numerator"
		replace dis = "Age/Sex/Result" if indicator=="PMTCT_EID" & disaggregate=="Total Numerator"
	table disagg if indicator=="PMTCT_EID" & disaggregate=="Total Numerator", ///
			c(sum fy2016q1 sum fy2016q2 sum fy2016_targets sum fy2015apr) format(%12.0fc) cellwidth(17)
	table disagg if ind=="HTC_TST" & dis=="Age/Sex/Result" & disagg==3, ///
			c(sum fy2016q1 sum fy2016q2 sum fy2016_targets sum fy2015apr) format(%12.0fc) cellwidth(17)
*rename disaggregates for ease of looping over variables		
	replace dis = "Age/Sex" if inlist(ind, "HTC_TST", "PMTCT_STAT") & inlist(dis, "Age/Sex/Result", "Known/New")
	replace dis = "Age/Sex Aggregated" if ind =="HTC_TST" & dis=="Age/Sex Aggregated/Result"

*create HTC_TST_POS indicator
	expand 2 if ind == "HTC_TST" & resultstatus=="Positive", gen(new)
		replace ind = "HTC_TST_POS" if new==1
		drop new
	*expand 2 if indicator=="PMTCT_EID_POS_12MO" & disaggregate=="Total Numerator", gen(new)
	replace ind = "HTC_TST_POS" if indicator=="PMTCT_EID_POS_12MO" ///
			& disaggregate=="Total Numerator"
		*drop new
*collapse to sum up results/targets by ou, ind and disagg
	collapse (sum) fy2016q1 fy2016q2 fy2016_targets fy2015apr, by(operatingunit ind disagg)
*order indicators
	gen ind2 = .
		replace ind2 = 1 if ind=="HTC_TST"
		replace ind2 = 2 if ind=="HTC_TST_POS"
		replace ind2 = 3 if ind=="CARE_NEW"
		replace ind2 = 4 if ind=="TX_NEW"
		replace ind2 = 5 if ind=="TX_CURR"
		replace ind2 = 6 if ind=="TX_RET"
		replace ind2 = 7 if ind=="TX_VIRAL"
		replace ind2 = 8 if ind=="TX_UNDETECT"
		replace ind2 = 9 if ind=="PMTCT_STAT"
		lab def ind 1 "HTC_TST" 2 "HTC_TST_POS" 3 "CARE_NEW" 4 "TX_NEW" ///
			5 "TX_CURR" 6 "TX_RET" 7 "TX_VIRAL" 8 "TX_UNDETECT" 9 "PMTCT_STAT"
		lab val ind2 ind
		drop ind
		rename ind2 ind
		order ind, before(disagg)
		sort operatingunit ind disagg
*create a finer age disagg total
	gen indchng = .
		replace indchng = 1 if ind!=ind[_n-1]
	expand 2 if indchng==1, gen(new)
		drop indchng
		replace disagg = 2 if new==1
		sort operatingunit ind disagg
		foreach q of varlist fy* {
			replace `q' = . if disagg==2
			egen finertotal_`q' = total(`q') if !inlist(disagg, 1,7), by(operatingunit ind)
			replace `q' = finertotal_`q' if new==1
			drop finertotal_`q'
			}
			*end
		drop new
*add quarter totals
	egen tot_ytd = rowtotal(fy2016q*)
		order tot_ytd, before(fy2016_targets)
	format fy* tot_ytd %13.0fc
	

	
	
	
	
	
	
