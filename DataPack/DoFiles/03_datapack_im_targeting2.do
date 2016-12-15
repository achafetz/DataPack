**   Data Pack
**   COP FY17
**   Aaron Chafetz
**   Purpose: generate output for Excel based IM targeting Data Pack appendix
**   Date: December 10, 2016
**   Updated: 12/13

*** SETUP ***

*define date for Fact View Files
	global datestamp "20161115_v2"
	
*set today's date for saving
	global date: di %tdCCYYNNDD date(c(current_date), "DMY")

*import/open data
	capture confirm file "$fvdata/ICPI_FactView_PSNU_IM_${datestamp}.dta"
		if !_rc{
			use "$fvdata/ICPI_FactView_PSNU_IM_${datestamp}.dta", clear
		}
		else{
			import delimited "$fvdata/ICPI_FactView_PSNU_IM_${datestamp}.txt", clear
			save "$fvdata/ICPI_FactView_PSNU_IM_${datestamp}.dta", replace
		}
		*end


*clean
	rename ïregion region
	replace psnu = "[no associated SNU]" if psnu==""

* gen vars for distro tabs (see 01_datapack_outputs)
	*HTC_TST
		gen htc_tst = fy2016apr if indicator=="HTC_TST" & disaggregate=="Total Numerator" & numeratordenom=="N"
	*HTC_TST [CBTC]
		gen htc_tst_cbtc = fy2016apr if indicator=="HTC_TST" & disaggregate=="ServiceDeliveryPoint/Result" & inlist(otherdisaggregate, "Home-based", "Mobile") & numeratordenom=="N"
	*HTC_TST [PITC]
		gen htc_tst_pitc = fy2016apr if indicator=="HTC_TST" & disaggregate=="ServiceDeliveryPoint/Result" & inlist(otherdisaggregate, "Inpatient","HIV Care and Treatment Clinic", "Outpatient Department", "Other Service Delivery Point") & numeratordenom=="N"
	*HTC_TST [VCT]
		gen htc_tst_vct = fy2016apr if indicator=="HTC_TST" & disaggregate=="ServiceDeliveryPoint/Result" & inlist(otherdisaggregate, "Voluntary Counseling & Testing standalone", "Voluntary Counseling & Testing co-located") & numeratordenom=="N"
	*KP_MAT
		gen kp_mat = fy2016apr if indicator=="KP_MAT" & disaggregate=="Total Numerator" & numeratordenom=="N"
	*KP_PREV_FSW
		gen kp_prev_fsw = fy2016apr if indicator=="KP_PREV" & disaggregate=="KeyPop" & otherdisaggregate=="FSW" & numeratordenom=="N"
	*KP_PREV_MSMTG
		gen kp_prev_msmtg = fy2016apr if indicator=="KP_PREV" & disaggregate=="KeyPop" & otherdisaggregate=="MSM/TG" & numeratordenom=="N"
	*KP_PREV_PWID
		gen kp_prev_pwid = fy2016apr if indicator=="KP_PREV" & disaggregate=="KeyPop"& inlist(otherdisaggregate, "Female PWID", "Male PWID") & numeratordenom=="N"
	*OVC_SERV
		gen ovc_serv = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Total Numerator" & numeratordenom=="N"
	*PMTCT_ARV
		gen pmtct_arv = fy2016apr if indicator=="PMTCT_ARV" & disaggregate=="Total Numerator" & numeratordenom=="N"
	*PMTCT_EID
		gen pmtct_eid = fy2016apr if indicator=="PMTCT_EID" & disaggregate=="Total Numerator" & numeratordenom=="N"
	*PMTCT_STAT
		gen pmtct_stat = fy2016apr if indicator=="PMTCT_STAT" & disaggregate=="Total Numerator" & numeratordenom=="N"
	*PMTCT_STAT_POS
		gen pmtct_stat_pos = fy2016apr if indicator=="PMTCT_STAT" & disaggregate=="Known/New" & numeratordenom=="N"
	*PP_PREV
		gen pp_prev = fy2016apr if indicator=="PP_PREV" & disaggregate=="Total Numerator" & numeratordenom=="N"
	*TX_CURR 1-14 (FY16T)
		gen tx_curr_1to15_fy16T = fy2016_targets if indicator=="TX_CURR" & disaggregate=="Age/Sex" & inlist(age, "01-04", "05-14") & numeratordenom=="N"
	*TX_CURR 15+ (FY16T)
		gen tx_curr_o15_fy16T = fy2016_targets if indicator=="TX_CURR" & disaggregate=="Age/Sex" & inlist(age, "15-19", "20+") & numeratordenom=="N"
	*TX_CURR 1-14
		gen tx_curr_1to15 = fy2016apr if indicator=="TX_CURR" & disaggregate=="Age/Sex" & inlist(age, "01-04", "05-14") & numeratordenom=="N"
	*TX_CURR 15+
		gen tx_curr_o15 = fy2016apr if indicator=="TX_CURR" & disaggregate=="Age/Sex" & inlist(age, "15-19", "20+") & numeratordenom=="N"
	*VMMC_CIRC
		gen vmmc_circ = fy2016apr if indicator=="VMMC_CIRC" & disaggregate=="Total Numerator" & numeratordenom=="N"

* aggregate up to PSNU level
	drop fy*
	tostring mechanismid, replace
		replace mechanismid = "00000" if mechanismid=="0"
		replace mechanismid = "00001" if mechanismid=="1"
	ds *, not(type string)
	foreach v in `r(varlist)'{
		rename `v' val_`v'
		}
	*end

*collapse
	collapse (sum) val_*, by(operatingunit psnu psnuuid indicatortype mechanismid)
*reshape long
	reshape long val_, i(operatingunit psnu psnuuid indicatortype mechanismid) j(indicator, string)
*drop missing
	drop if val_==0
*sort
	sort operatingunit indicatortype mechanismid psnu
*distro
	egen total = total(val_), by(operatingunit psnuuid indicator)
	gen distro = val_/ total
		drop total
*clean up
	order operatingunit psnuuid psnu mechanismid indicator indicatortype
	replace indicator = upper(indicator)
	replace indicator = "TX_CURR 1-15" if indicator == "TX_CURR_1TO15"
	replace indicator = "TX_CURR 15+" if indicator == "TX_CURR_O15"
	replace indicator = "TX_CURR 1-15 T" if indicator == "TX_CURR_1TO15_FY16T"
	replace indicator = "TX_CURR 15+ T" if indicator == "TX_CURR_O15_FY16T"

*export
	export excel using "$dpexcel/Global_PSNU_${date}.xlsx", ///
		sheet("IM Results") firstrow(variables) sheetreplace
