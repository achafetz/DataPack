**   Data Pack
**   COP FY17
**   Aaron Chafetz
**   Purpose: generate output for Excel based IM targeting Data Pack appendix
**   Date: December 10, 2016
**   Updated: 1/25/16


* Note - originally from the Partner Progress report - https://github.com/achafetz/PartnerProgress/blob/master/06_partnerreport_officalnames.do


/* NOTES
	- Data source: FACTS Info [T. Lim], Nov 17, 2016
	- mechanism partner list 2012-2016
*/
********************************************************************************

*import/open data
	capture confirm file "$output\officialnames.dta"
		if _rc{
			preserve
			import excel "$data\FACTSInfo_OfficialNames_2016.11.17.xlsx", firstrow ///
				case(lower) allstring clear
			*clean
				drop operatingunit agency legacyid
				rename mechanismidentifier mechanismid
				rename mechanismname implementingmechanismname
				rename primepartner primepartner
				destring mechanismid, replace
			save "$output\officialnames.dta", replace
			restore
		}
	*end

*merge	
	merge m:1 mechanismid using "$output/officialnames.dta", ///
		update replace nogen keep(1 3 4 5) //keep all but non match from using
