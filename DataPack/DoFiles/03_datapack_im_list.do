**   Data Pack
**   COP FY17
**   Aaron Chafetz
**   Purpose: mehcanism list
**   Date: December 10, 2016
**   Updated: 1/9/16

*** SETUP ***

*define date for Fact View Files
	global datestamp "20161230_v2_2"

*set today's date for saving
	global date: di %tdCCYYNNDD date(c(current_date), "DMY")

*import/open data
	use "$fvdata/ICPI_FactView_PSNU_IM_${datestamp}.dta", clear

*update all partner and mech to offical names (based on FACTS Info)
	capture confirm file "$output/officialnames.dta"
	if _rc{
		preserve
		run "$dofiles/05_datapack_officialnames"
		restore
		}
		*end
	merge m:1 mechanismid using "$output/officialnames.dta", ///
		update replace nogen keep(1 3 4 5) //keep all but non match from using

*keep
	gen n = 1
	collapse n, by(operatingunit fundingagency mechanismid implementingmechanismname)
	drop n
	drop if mechanismid<2 //drop dedups 00000 and 00001
	sort operatingunit mechanismid
*export
	export excel using "$dpexcel/Global_PSNU_${date}.xlsx", ///
		sheet("IM PBAC Targets") firstrow(variables) sheetreplace
