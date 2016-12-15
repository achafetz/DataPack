**   Data Pack
**   COP FY17
**   Aaron Chafetz
**   Purpose: generate output for Excel based IM targeting Data Pack appendix
**   Date: December 10, 2016
**   Updated: 


* Note - originally from the Partner Progress report - https://github.com/achafetz/PartnerProgress/blob/master/06_partnerreport_officalnames.do


/* NOTES
	- Data source: FACTS Info [T. Lim], Nov 17, 2016
	- mechanism partner list 2012-2016
*/
********************************************************************************

*import/open data
	capture confirm file "$output\FACTInfo_OfficialNames_2016.11.17.dta"
		if !_rc{
			use "$output\FACTInfo_OfficialNames_2016.11.17.dta", clear
		}
		else{
			import excel "$data\FACTSInfo_OfficialNames_2016.11.17.xlsx", firstrow ///
				case(lower) allstring clear
			save "$output\FACTInfo_OfficialNames_2016.11.17.dta", replace
		}
	*end

*clean
	drop operatingunit agency legacyid
	rename mechanismidentifier mechanismid
	rename mechanismname implementingmechanismname
	rename primepartner primepartner
	
	
*save 
	save "$output\officialnames.dta", replace
