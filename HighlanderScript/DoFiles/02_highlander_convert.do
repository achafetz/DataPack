**   Highlander Script
**   COP FY16
**   Aaron Chafetz
**   Purpose: import site level Fact View dataset for each OU
**   Date: October 21, 2016
**   Updated:

/* NOTES
	- Data source: ICPI_Fact_View_Site_IM_20160915 [ICPI Data Store]
*/
********************************************************************************

* all countries
	local ctrylist angola asiaregional botswana burma burundi cambodia ///
		cameroon caribbeanregion centralamerica centralasia civ ///
		dominicanrepublic drc ethiopia ghana guyana haiti india indonesia ///
		kenya lesotho malawi mozambique namibia nigeria png rwanda ///
		southafrica southsudan swaziland tanzania uganda ukraine ////
		vietnam zambia zimbabwe

* import all countries 		
	foreach ou of local ctrylist{
		di in yellow "Import: `ou'" 
		qui: import delimited ///
			"$fvdata/ALL Site Dataset 20160915/site_im_20160915_`ou'.txt", clear
		*keep only HTC_TST, TX_NEW, and TX_CURR
		qui: keep if (indicator=="HTC_TST" & ///
			inlist(disaggregate, "Age/Sex/Result", ///
				"Age/Sex Aggregated/Result", "Results", "Total Numerator")) | ///
			///(indicator=="CARE_NEW" & inlist(disaggregate, "Age/Sex", ///
				///"Age/Sex Aggregated", "Total Numerator")) | ///
			(indicator=="TX_CURR" & inlist(disaggregate,"Age/Sex", ///
				"Age/Sex Aggregated", "Age/Sex, Aggregated", "Total Numerator")) | ///
			(indicator=="TX_NEW" & inlist(disaggregate, "Age/Sex", ///
				"Age/Sex Aggregated", "Total Numerator"))
		qui: save  "$output/temp_orig_site_`ou'", replace
	}
