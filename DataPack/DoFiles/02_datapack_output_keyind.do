**   Data Pack
**   COP FY17
**   Aaron Chafetz
**   Purpose: generate output for Excel based Data Pack at SNU level
**   Date: November 10, 2016
**   Updated: 1/10/2017

*** SETUP ***
	
*set today's date for saving
	global date: di %tdCCYYNNDD date(c(current_date), "DMY")

*open data
	use "$output/append_temp", clear
	
*keep just key indicator
	keep if (inlist(indicator, "PLHIV", "HTC_TST", "PMTCT_ARV", "TB_ART", "TX_CURR", ///
		"TX_NEW", "VMMC_CIRC") & disaggregate=="Total Numerator") | ///
		(indicator=="HTC_TST" & inlist(disaggregate, "Results", ///
		"Age/Sex Aggregated/Result") & resultstatus=="Positive") | ///
		(indicator=="PMTCT_ART" & disaggregate=="MaternalRegimenType2017")
*rename HTC_POS
	replace indicator = "HTC_TST_POS" if indicator=="HTC_TST" & ///
		inlist(disaggregate, "Results","Age/Sex Aggregated/Result") ///
		& resultstatus=="Positive"
*fix MER 1.0 -> 2.0 errors for FY17 targets
	replace fy2017_targets=. if ///
		(indicator == "HTC_TST_POS" & disaggregate=="Results") | ///
		(indicator == "PMTCT_ARV")
	replace indicator="PMTCT_ARV" if indicator=="PMTCT_ART"
*add APR PLHIV value to Q4
	replace fy2016q4 = fy2016apr if indicator=="PLHIV"
*aggregate to psnu
	collapse (sum) fy2015apr fy2016apr fy2017_targets, ///
		by(operatingunit psnu psnuuid snuprioritization indicator)
*reshape
	reshape wide fy*, i(operatingunit psnu psnuuid snuprioritization) j(indicator, string)
*sort by PLHIV
	gsort + operatingunit - fy2016aprPLHIV + psnu
	drop *PLHIV
	
*create a space (for PBAC template)
	gen pr_sp = .
	gen pr_sp2 = .
	foreach x in HTC_TST HTC_TST_POS PMTCT_ARV TB_ART TX_CURR TX_NEW {
		gen `x'_sp1 = .
		gen `x'_sp2 = .
		gen `x'_sp3 = .
		order `x'_sp1 `x'_sp2 `x'_sp3, after(fy2017_targets`x')
		}
		*end
*reorder
	order operatingunit psnuuid snuprioritization psnu pr_sp pr_sp2
	
*export global list to data pack template
	export excel using "$dpexcel/Global_PSNU_${date}.xlsx", ///
		sheet("Key Ind Trends") firstrow(variables) sheetreplace


