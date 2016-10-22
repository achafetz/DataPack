**   Highlander Script
**   COP FY16
**   Aaron Chafetz
**   Purpose: create a dataset
**   Date: October 19, 2016
**   Updated: 10/22

/* NOTES
	- Data source: ICPI_Fact_View_Site_IM_20160915 [ICPI Data Store]
*/
********************************************************************************

*append all ou files together for PSNU
	cd "$output\"
	fs "hs_psnu*.dta"
	append using `r(files)', force
	save "$output\hs_psnu_ALL", replace
	
	cd bob
	
*append composite file to PSNU by IM Fact View dataset
	use
