**   Highlander Script
**   COP FY16
**   Aaron Chafetz
**   Purpose: create a dataset
**   Date: October 19, 2016
**   Updated: 10/20

/* NOTES
	- Data source: ICPI_Fact_View_Site_IM_20160915 [ICPI Data Store]
*/
********************************************************************************


*set date of frozen instance - needs to be changed w/ updated data
	global datestamp "20161010"
	
* unzip folder containing all site data
	unzipfile "$fvdata\ALL Site Dataset ${datestamp}"
	
*convert files from txt to dta for appending and keep only TX_CURR and TX_NEW (total numerator)
	cd "$fvdata\ALL Site Dataset ${datestamp}"
	fs 
	foreach ou in `r(files)'{
		di "import/save: `ou'"
		qui: import delimited "`ou'", clear
		*keep just ACT indicator
		qui: replace disaggregate= "Age/Sex Aggregated" if ///
			disaggregate=="Age/Sex, Aggregated" //fix issue with TX_CURR
		qui: keep if (indicator=="HTC_TST" & ///
			inlist(disaggregate, "Age/Sex/Result", "Age/Sex Aggregated/Result", ///
			"Results", "Total Numerator")) | (inlist(indicator, "CARE_NEW", ///
			"TX_NEW", "TX_CURR") & inlist("Age/Sex", "Age/Sex Aggregated", ///
			"Total Numerator"))
		qui: save "`ou'.dta", replace
		}
		*end
*append all ou files together
	clear
	fs *.dta
	di "append files"
	qui: append using `r(files)', force
	
*save all site file
	save "$data\HIGHLANDER_Site_IM${datestamp}", replace
	
*delete files (to save space)
	fs *.dta 
	erase `r(files)'
	fs *.txt
	erase `r(files)'
	rmdir "C:\Users\achafetz\Documents\ICPI\Data\ALL Site Dataset 20160915\"
	
