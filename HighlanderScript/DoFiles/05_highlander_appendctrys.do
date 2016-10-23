**   Highlander Script
**   COP FY16
**   Aaron Chafetz
**   Purpose: create a dataset
**   Date: October 19, 2016
**   Updated: 10/23

/* NOTES
	- Data source: ICPI_Fact_View_Site_IM_20160915 [ICPI Data Store]
*/
********************************************************************************

*append all ou files together for PSNU and site/IM level choices
	cd "$output\"
	foreach t in choice psnu{
		fs "temp_hs_`t'*.dta"
		append using `r(files)', force
		save "$output\hs_`t'_ALL", replace
	}
	*end
	
*append composite file to PSNU by IM Fact View dataset
	use "$fvdata\ICPIFactView_SNUbyIM20160909", clear
	append using "$output\hs_psnu_ALL"
	order hs_agegp hsc highlander, before(fy2015q2)
	save "$fvdata\ICPIFactView_SNUbyIM_Highlander_20160909", replace
