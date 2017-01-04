**   Data Pack
**   COP FY17
**   Aaron Chafetz
**   Purpose: generate output for Excel based Data Pack at SNU level
**   Date: November 10, 2016
**   Updated: 1/3/2017

*** SETUP ***
	
*set today's date for saving
	global date: di %tdCCYYNNDD date(c(current_date), "DMY")

*open data
	use "$output/append_temp", clear
	
*keep just key indicator
	keep if (inlist(indicator, "PLHIV", "HTC_TST", "PMTCT_STAT", "TX_CURR", "TX_NEW") ///
		& disaggregate=="Total Numerator") | ///
		(indicator=="HTC_TST" & disaggregate=="Results" & resultstatus=="Positive")
*rename HTC_POS
	replace indicator = "HTC_TST_POS" if indicator=="HTC_TST" & ///
		disaggregate=="Results" & resultstatus=="Positive"
*add APR PLHIV value to Q4
	replace fy2016q4 = fy2016apr if indicator=="PLHIV"
*aggregate to psnu
	collapse (sum) fy2015q3 fy2015q4 fy2016q1 fy2016q2 fy2016q3 fy2016q4, ///
		by(operatingunit psnu psnuuid snuprioritization indicator)
*reshape
	reshape wide fy*, i(operatingunit psnu psnuuid snuprioritization) j(indicator, string)
*sort by PLHIV
	gsort + operatingunit - fy2016q4PLHIV + psnu
	drop *PLHIV
	
*create a space (for PBAC template)
	gen pr_sp = .
	gen pr_sp2 = .
	foreach x in HTC_TST HTC_TST_POS PMTCT_STAT TX_CURR{
		gen `x'_sp1  = .
		gen `x'_sp2  = .
		order `x'_sp1 `x'_sp2, after(fy2016q4`x')
		}
		*end
*reorder
	order operatingunit psnuuid snuprioritization psnu pr_sp pr_sp2
	
*export global list to data pack template
	export excel using "$dpexcel/Global_PSNU_${date}.xlsx", ///
		sheet("Key Ind Trends") firstrow(variables) sheetreplace


