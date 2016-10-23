**   Highlander Script
**   COP FY16
**   Aaron Chafetz
**   Purpose: apply Highlander choice by Site/IM/Indicator/IndicatorType/Pediod
**   Date: October 19, 2016
**   Updated: 10/22

/* NOTES
	- Data source: ICPI_Fact_View_Site_IM_20160915 [ICPI Data Store]
*/
********************************************************************************

*reopen original site file 
	use "$output/temp_orig_site_${ctry}", clear

* remove any sites with no data for all quarters 
	egen rowtot = rowtotal (fy*)
	drop if rowtot==0
	drop rowtot

* reshape long so fiscal years are in rows
	*create id for reshape
		gen id = _n
	*rename fiscal years to (1) have common stub and (2) retain their name in reshape 
		drop fy2015apr fy2016_target
		ds fy*
		foreach yr in `r(varlist)'{
			rename `yr' y`yr'
			}
			*end
*reshape
	reshape long y@, i(id) j(pd, string)	
	drop id //needed for reshape	
	
*merge 
	merge m:1 pd psnuuid fcm_uid indicator indicatortype mechanismid ///
		using "$output\temp_hs_choice_${ctry}", nogen

*fill missing
	ds, has(type string)
	foreach v in `r(varlist)'{
		qui: replace `v' = "na" if `v'=="" | `v'=="NULL"
		}
		*end

*remove space in name for reshape
	replace hs_type = "TotNum" if hs_type=="Total Numerator"

*reshape
	egen id = group(pd psnuuid fcm_uid mechanismid indicator indicatortype ///
		primepartner implementingmechanismname disaggregate age sex result ///
		otherdisaggregate status typecommunity)	
	reshape wide y, i(id) j(hs_type, string)
	drop id 
* clean up names, removing y and making lower case
	ds y*
	foreach x in `r(varlist)'{
		rename `x' `=lower("`=subinstr("`x'","y","",.)'")'
		}
		*end
	replace hsc = 99 if hsc==.
		lab def hsc 99 "n/a", modify
*drop blank rows
	egen rowtot = rowtotal (coarse finer results totnum)
	drop if rowtot==0
	drop rowtot

*highlander value
	gen hsval =.
		replace hsval=finer if inlist(hsc, 1,4,6)
		replace hsval=coarse if inlist(hsc, 2,5,7)
		replace hsval=finer + coarse if hsc==3
		replace hsval=results if hsc==8
		replace hsval=totnum if hsc==9

*drop 
	drop coarse-totnum
*reshape
	egen id = group(psnuuid fcm_uid implementingmechanismname mechanismid ///
		primepartner indicator indicatortype disaggregate age sex result ///
		otherdisaggregate status hsc typecommunity)
	reshape wide hsval, i(id) j(pd, string)
	drop id
*remove hsval
	ds hsval*
	foreach x in `r(varlist)'{
		rename `x' `=subinstr("`x'","hsval","",.)'
		}
		*end

*drop blank rows
	egen rowtot = rowtotal (fy*)
	drop if rowtot==0
	drop rowtot
*remove na
	ds, has(type string)
		foreach v in `r(varlist)'{
			qui: replace `v' = "" if `v'=="na"
			}
			*end
*reorder
	drop fcm_uid status
	order fy*, after(hsc)

*add apr figure
	*some countries missing quarters (eg Caribbean)
	foreach i of numlist 2/4{
		capture confirm variable fy2015q`i'
		if _rc qui: gen fy2015q`i'= .
		}
		*end
		order fy2015q2 fy2015q3 fy2015q4, after(hsc)
	egen fy2015apr = rowtotal(fy2015q2 fy2015q3 fy2015q4)
	egen fy2015apr_tx = rowtotal(fy2015q2 fy2015q4) ///
		if indicator=="TX_CURR" & fy2015q3!=.
	replace fy2015apr = fy2015apr_tx if fy2015apr_tx!=.
	drop fy2015apr_tx
	order fy2015apr, after(fy2015q4)

*highlander flag
	gen highlander = "Y"
	order highlander, before(fy2015q2)

*collapse to psnu level
	collapse (sum) fy*, by(ïregion-implementingmechanismname indicator-highlander)
	
*save
	save "$output/tem_hs_psnu_${ctry}", replace
