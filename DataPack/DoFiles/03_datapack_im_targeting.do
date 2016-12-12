**   Data Pack
**   COP FY17
**   Aaron Chafetz
**   Purpose: generate output for Excel based IM targeting Data Pack appendix
**   Date: December 10, 2016
**   Updated: 12/11

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
		rename `v' im_`v'
		}
	*end
	
levelsof operatingunit, local(levels)
	foreach ou of local levels{
	preserve
	keep if operatingunit == "`ou'"
	collapse (sum) im_*, by(operatingunit psnu psnuuid indicatortype mechanismid)

	*reshape long
		reshape long im_, i(operatingunit psnu psnuuid indicatortype mechanismid) j(indicator, string)
	*concatenate type & mech id
		sort indicatortype mechanismid psnu
		gen mechandtype = indicatortype + "_" +  mechanismid
			drop indicatortype mechanismid
	*reshape wide
		reshape wide im_, i(operatingunit psnu psnuuid indicator) j(mechandtype, string)
	*recode 0's as missing
	ds im_*
	recode `r(varlist)' (0=.)
	
	*totals for DSD and TA
		egen tot = rowtotal(im_*)

	*create IM by snu distribution	
		ds im_*
		foreach im in `r(varlist)'{
			replace `im' = round(`im'/tot,.001)
		}
		*end
	*save
		save "$output/temp_collapse_`ou'.dta", replace
	
	restore
	}
	*end
clear
*append all together
	cd "$output/"
	fs temp_collapse*.dta
	append using `r(files)'
	cd "$projectpath"

*cleanup 	
	drop tot
	sort indicator psnu
	order operatingunit psnuuid psnu indicator
	replace indicator = upper(indicator)
	replace indicator = "TX_CURR 1-15" if indicator == "TX_CURR_1TO15"
	replace indicator = "TX_CURR 15+" if indicator == "TX_CURR_O15"
	rename psnu snulist_D

*export
	*create dataset for each OU
	levelsof operatingunit, local(levels)
	foreach ou of local levels{
		preserve
		di "`ou'"
		qui: keep if operatingunit=="`ou'"
		local sht "`ou'" & "_IMD"
		qui: export excel using "$dpexcel/Global_PSNU_${date}.xlsx", ///
			sheet(sht) firstrow(variables) sheetreplace
		restore
	}
	*end

/*
       IM_1_DSD | IM_2_DSD | .... | IM_1_TA | IM_2_DSD
------|---------|----------|------|---------|----------
PSNU 1
PSNU 2
......
*/
