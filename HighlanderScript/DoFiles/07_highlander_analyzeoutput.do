**   Highlander Script
**   COP FY17
**   Aaron Chafetz
**   Purpose: summary output tables
**   Date: October 24, 2016
**   Updated: 

/* NOTES
	- Data source: ICPI_Fact_View_Site_IM_20160915 [ICPI Data Store]
*/
********************************************************************************


* Raw number of Sites by IMs and Indicator Type

	*open data
		use "$output/hs_choice_ALL", clear
		rename hsc hs_choice

	*frequency of each Highlander Script selection
		tab operatingunit hs_choice, row
		bysort indicatortype: tab operatingunit hs_choice, row

	* Are there sites with different Highlander selections?
		
		tab hs_choice, gen(hs_)
		qui: collapse (max) hs_1-hs_9, by(operatingunit psnuuid fcm_uid indicatortype indicator pd psnu snuprioritization)
		qui: egen hs_choice_count = rowtotal(hs_1-hs_9)
		tab hs_choice_count
		tab operatingunit hs_choice_count, row
	

	*export
	*set today's date for saving
		global date = subinstr("`c(current_date)'", " ", "", .)
		use "$output/hs_choice_ALL", clear
		export delimited using "$excel\HS_Choice_${date}", ///
				nolabel replace dataf
		use "$output/hs_psnu_ALL", clear
		export delimited using "$excel\HS_Values_PSNU_Agg_${date}", ///
				nolabel replace dataf
		