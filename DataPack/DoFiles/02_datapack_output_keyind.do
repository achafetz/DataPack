**   Data Pack
**   COP FY17
**   Aaron Chafetz
**   Purpose: generate output for Excel based Data Pack at SNU level
**   Date: November 10, 2016
**   Updated: 12/2/2016

*** SETUP ***

*define date for Fact View Files
	global datestamp "20161115_Q4v1_3"
	
*set today's date for saving
	global date: di %tdCCYYNNDD date(c(current_date), "DMY")


*import/open data
	*capture confirm file "$fvdata/ICPI_FactView_PSNU_IM_${datestamp}.dta"
	capture confirm file "$fvdata/ICPI_FactView_PSNU_${datestamp}.dta"
		if !_rc{
			*use "$fvdata/ICPI_FactView_PSNU_IM_${datestamp}.dta", clear
			use "$fvdata/ICPI_FactView_PSNU_${datestamp}.dta", clear
		}
		else{
			*import delimited "$fvdata/ICPI_FactView_PSNU_IM_${datestamp}.txt", clear
			*save "$fvdata/ICPI_FactView_PSNU_IM_${datestamp}.dta", replace
			import delimited "$fvdata/ICPI_FactView_PSNU_${datestamp}.txt", clear
			save "$fvdata/ICPI_FactView_PSNU_${datestamp}.dta", replace
		}
		*end
		
*clean
	*gen fy2017_targets = 0 //delete after FY17 targets are added into FV dataset
	rename ïregion region
	
*keep just key indicator
	keep if (inlist(indicator, "HTC_TST", "PMTCT_STAT", "TX_CURR", "TX_NEW") ///
		& disaggregate=="Total Numerator") | ///
		(indicator=="HTC_TST" & disaggregate=="Results" & resultstatus=="Positive")
*rename HTC_POS
	replace indicator = "HTC_TST_POS" if indicator=="HTC_TST" & ///
		disaggregate=="Results" & resultstatus=="Positive"
*aggregate to psnu
	collapse (sum) fy2015q3 fy2015q4 fy2016q1 fy2016q2 fy2016q3 fy2016q4, ///
		by(operatingunit psnu psnuuid snuprioritization indicator)
*reshape
	reshape wide fy*, i(operatingunit psnu psnuuid snuprioritization) j(indicator, string)

*drop semi annual indicators
	drop fy2015q3TX_CURR fy2016q1TX_CURR fy2016q3TX_CURR

*create a space
	foreach x in HTC_TST HTC_TST_POS PMTCT_STAT TX_CURR{
		gen `x'_sp1  = .
		gen `x'_sp2  = .
		order `x'_sp1 `x'_sp2, after(fy2016q4`x')
		}
		*end
*reorder
	order psnu, after(snuprioritization)
	
*export global list to data pack template
	export excel using "$dpexcel/Global_PSNU_${date}.xlsx", ///
		sheet("Key Indicators") firstrow(variables) sheetreplace


