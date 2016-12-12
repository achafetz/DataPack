**   Data Pack
**   COP FY17
**   Aaron Chafetz
**   Purpose: mehcanism list
**   Date: December 10, 2016
**   Updated: 12/11/16

*** SETUP ***

*define date for Fact View Files
	global datestamp "20161115_v2"
	
*set today's date for saving
	global date: di %tdCCYYNNDD date(c(current_date), "DMY")

*import/open data
	use "$fvdata/ICPI_FactView_PSNU_IM_${datestamp}.dta", clear
	
*keep
	gen n = 1
	collapse n, by(operatingunit fundingagency mechanismid implementingmechanismname)
	drop n
	drop if mechanismid<2 //drop dedups
	sort operatingunit mechanismid
*export
	export excel using "$dpexcel/Global_PSNU_${date}.xlsx", ///
		sheet("IM List") firstrow(variables) sheetreplace

