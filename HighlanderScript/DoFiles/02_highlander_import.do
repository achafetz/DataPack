**   Highlander Script
**   COP FY16
**   Aaron Chafetz
**   Purpose: import site level Fact View dataset for each OU
**   Date: October 21, 2016
**   Updated: 10/23

/* NOTES
	- Data source: ICPI_Fact_View_Site_IM_20160915 [ICPI Data Store]
*/
********************************************************************************

* import all countries 	
	foreach ou of global ctrylist{
	
*check to see if site level dta file exists
	capture confirm file "$output/temp_orig_site_`ou'.dta"
	*if not file exists, import it
	if _rc{
		di in yellow "`=upper(`ou')': import site level data"
		
		*import
		qui: import delimited ///
			"$fvdata/ALL Site Dataset ${datestamp}/site_im_${datestamp}_`ou'.txt", ///
			clear
			
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
		
		* merge in aggregated Highlander Script age groups & edit type
		qui: merge m:1 age using  "$output\temp_agegpcw.dta", nogen ///
			keep(match master) noreport
		qui: replace hs_type = "Finer" if inlist(indicator, "TX_CURR", "TX_NEW") & ///
			inlist(disaggregate, "Age/Sex Aggregated", "Age/Sex, Aggregated") ///
			& age=="<01"
		qui: replace hs_type = "Total Numerator" if disaggregate=="Total Numerator"
		qui: replace hs_type = "Results" if disaggregate== "Results" 
		
		* create a unique id by type (facility, community, military)
			* demarcated by f_, c_, and m_ at front
			* military doesn't have a unique id so script uses mechanism uid
		qui: tostring type*, replace
		qui: gen fcm_uid = ""
			replace fcm_uid = "f_" + facilityuid if facilityuid!=""
			replace fcm_uid = "c_" + communityuid if facilityuid=="" &  ///
				(typecommunity =="Y" | communityuid!="") & typemilitary!="Y"
			replace fcm_uid = "m_" + mechanismuid if typemilitary=="Y" 
		
		qui: save  "$output/temp_orig_site_`ou'", replace
		clear
	}
	else{
		di in yellow"`ou': site level dta file exists"
	}
	}
	*end
	
