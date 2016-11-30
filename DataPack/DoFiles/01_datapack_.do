**   Data Pack
**   COP FY17
**   Aaron Chafetz
**   Purpose: generate output for Excel based Data Pack at SNU level
**   Date: 
**   Updated: 11/29/2016

*** SETUP ***

*define date for Fact View Files
	global datestamp "20161115_v2"
	
*set today's date for saving
	global date = subinstr("`c(current_date)'", " ", "", .)
	
*** IMPATT ***

*import/open data
	capture confirm file "$fvdata/ICPI_FactView_NAT_SUBNAT_${datestamp}.dta"
		if !_rc{
			use "$fvdata/ICPI_FactView_NAT_SUBNAT_${datestamp}.dta", clear
		}
		else{
			import delimited "$fvdata/ICPI_FactView_NAT_SUBNAT_${datestamp}.txt", clear
			save "$fvdata/ICPI_FactView_NAT_SUBNAT_${datestamp}.dta", replace
		}
		*end
	

*reshape to get values by fy
	rename value fy //for reshape naming of years
	local vars operatingunituid snu1 psnuuid indicator dataelementuid ///
		numeratordenom indicatortype disaggregate categoryoptioncombouid
	foreach v of local vars {
		replace `v' = "n/a" if `v'==""
		}
	egen id = group(`vars')
	reshape wide fy@, i(id) j(ïfiscalyear)
	drop id
	foreach y in 2015 2016 {
		rename fy`y' fy`y'apr
		gen fy`y'_targets = fy`y'apr if strmatch(dataelementname , "*TARGET*")
		replace fy`y'_targets =. if fy`y'_targets==0
		replace fy`y'apr = . if strmatch(dataelementname , "*TARGET*") 
		}
		*end
*clean 
	foreach v of local vars {
		replace `v' = "" if `v'=="n/a"
		}
	drop techarea dataelementuid dataelementname categoryoptioncombouid fy2015_targets
*save
	save "$output/impatt_temp", replace

*** PSNU by IM ***

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

*apend
	append using "$output/impatt_temp", force

*save
	save "$output/append_temp", replace
	
* generate
	// output from Data Pack Data Needs Excel File
	// updated 11/29
	gen care_curr = fy2016apr if indicator=="CARE_CURR" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen care_curr_T = fy2016_target if indicator=="CARE_CURR" & disaggregate=="Age/Sex" & numeratordenom=="N"
	gen care_curr_f = fy2016apr if indicator=="CARE_CURR" & disaggregate=="Age/Sex" & sex=="Female" & numeratordenom=="N"
	gen care_curr_m = fy2016apr if indicator=="CARE_CURR" & disaggregate=="Age/Sex" & sex=="Male" & numeratordenom=="N"
	gen care_curr_u15 = fy2016apr if indicator=="CARE_CURR" & disaggregate=="Age/Sex" & inlist(age, "<1", "1-4", "5-9","10-14") & numeratordenom=="N"
	gen care_curr_u15_T = fy2016_target if indicator=="CARE_CURR" & disaggregate=="Age/Sex" & inlist(age, "<1", "1-4", "5-9","10-14") & numeratordenom=="N"
	gen care_curr_o15_T = fy2016_target if indicator=="CARE_CURR" & disaggregate=="Age/Sex" & numeratordenom=="N"
	gen care_curr_fy16_T = fy2016_target if indicator=="CARE_CURR" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen care_new = fy2016apr if indicator=="CARE_NEW" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen care_new_T = fy2016_target if indicator=="CARE_NEW" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen care_new_fy16_T = fy2016_target if indicator=="CARE_NEW" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen htc_tst = fy2016apr if indicator=="HTC_TST" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen htc_tst_f_pos = fy2016apr if indicator=="HTC_TST" & disaggregate=="Age/Sex/Result" & sex=="Female" & resultstatus=="Positive" & numeratordenom=="N"
	gen htc_tst_pos = fy2016apr if indicator=="HTC_TST" & disaggregate=="Age/Sex/Result" & resultstatus=="Positive" & numeratordenom=="N"
	gen htc_tst_m_pos = fy2016apr if indicator=="HTC_TST" & disaggregate=="Age/Sex/Result" & sex=="Male" & resultstatus=="Positive" & numeratordenom=="N"
	gen htc_tst_u15 = fy2016apr if indicator=="HTC_TST" & disaggregate=="Age/Sex/Result" & inlist(age, "<1", "1-4", "5-9","10-14") & numeratordenom=="N"
	gen htc_tst_u15_pos = fy2016apr if indicator=="HTC_TST" & disaggregate=="Age/Sex/Result" & resultstatus=="Positive" & numeratordenom=="N"
	gen htc_tst_fy16_T = fy2016_target if indicator=="HTC_TST" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen htc_tst__pos_fy16_T = fy2016_target if indicator=="HTC_TST" & disaggregate=="Total Numerator" & resultstatus=="Positive" & numeratordenom=="N"
	gen htc_tst_T = fy2016_target if indicator=="HTC_TST" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen htc_tst_pos_T = fy2016_target if indicator=="HTC_TST" & disaggregate=="Age/Sex/Result" & resultstatus=="Positive" & numeratordenom=="N"
	gen ovc_acc = fy2016apr if indicator=="OVC_ACC" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen ovc_acc_T = fy2016_target if indicator=="OVC_ACC" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen ovc_serv = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen ovc_serv_T = fy2016_target if indicator=="OVC_SERV" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen plhiv_u15 = fy2016apr if indicator=="PLHIV" & disaggregate=="Age Aggregated/Sex" & age=="<15"
	gen plhiv_o15 = fy2016apr if indicator=="PLHIV" & disaggregate=="Age Aggregated/Sex" & age=="15+"
	gen plhiv_f = fy2016apr if indicator=="PLHIV" & disaggregate=="Age Aggregated/Sex" & sex=="Female"
	gen plhiv_m = fy2016apr if indicator=="PLHIV" & disaggregate=="Age Aggregated/Sex" & sex=="Male"
	gen plhiv = fy2016apr if indicator=="PLHIV" & disaggregate=="Total Numerator"
	gen pop_num = fy2016apr if indicator=="POP_NUM" & disaggregate=="Total Numerator"
	gen pop_num_f = fy2016apr if indicator=="POP_NUM" & disaggregate=="Age Aggregated/Sex" & sex=="Female"
	gen pop_num_m = fy2016apr if indicator=="POP_NUM" & disaggregate=="Age Aggregated/Sex" & sex=="Male"
	gen pmtct_arv_T = fy2016_target if indicator=="PMTCT_ARV" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen pmtct_arv_already = fy2016apr if indicator=="PMTCT_ARV" & disaggregate=="MaternalRegimenType" & otherdisaggregate=="Life-long ART Already" & numeratordenom=="N"
	gen pmtct_arv_curr = fy2016apr if indicator=="PMTCT_ARV" & disaggregate=="MaternalRegimenType"& inlist(otherdisaggregate, "Life-long ART New", "Triple-drug ARV") & numeratordenom=="N"
	gen pmtct_arv_curr_T = fy2016_target if indicator=="PMTCT_ARV" & disaggregate=="MaternalRegimenType"& inlist(otherdisaggregate, "Life-long ART New", "Triple-drug ARV") & numeratordenom=="N"
	gen pmtct_arv_fy16_T = fy2016_target if indicator=="PMTCT_ARV" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen pmtct_eid = fy2016apr if indicator=="PMTCT_EID" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen pmtct_eid_12mo = fy2016apr if indicator=="PMTCT_EID" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen pmtct_eid_12mo_T = fy2016_target if indicator=="PMTCT_EID" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen pmtct_eid_2mo = fy2016apr if indicator=="PMTCT_EID" & disaggregate=="InfantTest" & age=="[months] 02-12" & numeratordenom=="N"
	gen pmtct_eid_pos_2mo = fy2016apr if indicator=="PMTCT_EID_POS_2MO" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen pmtct_eid_pos_12mo = fy2016apr if indicator=="PMTCT_EID_POS_12MO" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen pmtct_fo = fy2016apr if indicator=="PMTCT_FO" & disaggregate=="Outcome" & otherdisaggregate=="HIV-Uninfected: Not Breastfeeding" & numeratordenom=="N"
	gen pmtct_stat_D = fy2016apr if indicator=="PMTCT_STAT" & disaggregate=="Total Numerator" & numeratordenom=="D"
	gen pmtct_stat_D_T = fy2016_target if indicator=="PMTCT_STAT" & disaggregate=="Total Numerator" & numeratordenom=="D"
	gen pmtct_stat = fy2016apr if indicator=="PMTCT_STAT" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen pmtct_stat_T = fy2016_target if indicator=="PMTCT_STAT" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen pmtct_stat_pos = fy2016apr if indicator=="PMTCT_STAT" & disaggregate=="Known/New" & numeratordenom=="N"
	gen pmtct_stat_knownpos = fy2016apr if indicator=="PMTCT_STAT" & disaggregate=="Known/New" & otherdisaggregate=="Known at Entry Positive" & numeratordenom=="N"
	gen pmtct_stat_known_T = fy2016_target if indicator=="PMTCT_STAT" & disaggregate=="Known/New" & numeratordenom=="N"
	gen pmtct_stat_subnat = fy2016apr if indicator=="PMTCT_STAT_SUBNAT" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen prevalence_num = fy2016apr if indicator=="PREVALENCE_NUM" & disaggregate=="NULL"
	gen tb_art_D = fy2016apr if indicator=="TB_ART" & disaggregate=="Total Numerator" & numeratordenom=="D"
	gen tb_art = fy2016apr if indicator=="TB_ART" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen tb_art_T = fy2016_target if indicator=="TB_ART" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen tb_ipt = fy2016apr if indicator=="TB_IPT" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen tb_outcome_D = fy2016apr if indicator=="TB_OUTCOME" & disaggregate=="Total Numerator" & numeratordenom=="D"
	gen tb_screen = fy2016apr if indicator=="TB_SCREEN" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen tb_screen_T = fy2016_target if indicator=="TB_SCREEN" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen tb_stat_D = fy2016apr if indicator=="TB_STAT" & disaggregate=="Total Numerator" & numeratordenom=="D"
	gen tb_stat_D_T = fy2016_target if indicator=="TB_STAT" & disaggregate=="Total Numerator" & numeratordenom=="D"
	gen tb_stat_pos = fy2016apr if indicator=="TB_STAT" & disaggregate=="Result" & resultstatus=="Positive" & numeratordenom=="N"
	gen tb_stat = fy2016apr if indicator=="TB_STAT" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen tb_stat_T = fy2016_target if indicator=="TB_STAT" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen tx_curr = fy2016apr if indicator=="TX_CURR" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen tx_curr_T = fy2016_target if indicator=="TX_CURR" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen tx_curr_f = fy2016apr if indicator=="TX_CURR" & disaggregate=="Age/Sex" & sex=="Female" & numeratordenom=="N"
	gen tx_curr_m = fy2016apr if indicator=="TX_CURR" & disaggregate=="Age/Sex" & sex=="Male" & numeratordenom=="N"
	gen tx_curr_u1 = fy2016apr if indicator=="TX_CURR" & disaggregate=="Age/Sex" & age=="<1" & numeratordenom=="N"
	gen tx_curr_u15 = fy2016apr if indicator=="TX_CURR" & disaggregate=="Age/Sex" & inlist(age, "<1", "1-4", "5-14") & numeratordenom=="N"
	gen tx_curr_u15_T = fy2016_target if indicator=="TX_CURR" & disaggregate=="Age/Sex" & inlist(age, "<1", "1-4", "5-14") & numeratordenom=="N"
	gen tx_curr_1to15_T = fy2016_target if indicator=="TX_CURR" & disaggregate=="Age/Sex" & inlist(age, "1-4", "5-14") & numeratordenom=="N"
	gen tx_curr_o15_T = fy2016_target if indicator=="TX_CURR" & disaggregate=="Age/Sex" & inlist(age, "15-19", "20+") & numeratordenom=="N"
	gen tx_curr_fy16_T = fy2016_target if indicator=="TX_CURR" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen tx_curr_subnat_u15 = fy2016apr if indicator=="TX_CURR_SUBNAT" & disaggregate=="Age/Sex" & age=="<15" & numeratordenom=="N"
	gen tx_curr_subnat = fy2016apr if indicator=="TX_CURR_SUBNAT" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen tx_new = fy2016apr if indicator=="TX_NEW" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen tx_new_T = fy2016_target if indicator=="TX_NEW" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen tx_new_u1 = fy2016apr if indicator=="TX_NEW" & disaggregate=="Age/Sex" & age=="<1" & numeratordenom=="N"
	gen tx_new_u1_T = fy2016_target if indicator=="TX_NEW" & disaggregate=="Age/Sex" & age=="<1" & numeratordenom=="N"
	gen tx_new_fy16_T = fy2016_target if indicator=="TX_NEW" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen tx_new_u15 = fy2016apr if indicator=="TX_NEW" & disaggregate=="Age/Sex" & inlist(age, "<1", "1-4", "5-9","10-14") & numeratordenom=="N"
	gen tx_ret_D = fy2016apr if indicator=="TX_RET" & disaggregate=="Total Numerator" & numeratordenom=="D"
	gen tx_ret = fy2016apr if indicator=="TX_RET" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen tx_ret_u15_D = fy2016apr if indicator=="TX_RET" & disaggregate=="Age/Sex" & inlist(age, "<5", "5-14") & numeratordenom=="D"
	gen tx_ret_u15 = fy2016apr if indicator=="TX_RET" & disaggregate=="Age/Sex" & inlist(age, "<5", "5-14") & numeratordenom=="N"
	gen tx_undetect = fy2016apr if indicator=="TX_UNDETECT" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen tx_undetect_f = fy2016apr if indicator=="TX_UNDETECT" & disaggregate=="Age/Sex" & sex=="Female" & numeratordenom=="N"
	gen tx_undetect_m = fy2016apr if indicator=="TX_UNDETECT" & disaggregate=="Age/Sex" & sex=="Male" & numeratordenom=="N"
	gen tx_undetect_u15 = fy2016apr if indicator=="TX_UNDETECT" & disaggregate=="Age/Sex" & inlist(age, "<1", "1-4", "5-9","10-14") & numeratordenom=="N"
	gen tx_undetect_D = fy2016apr if indicator=="TX_UNDETECT" & disaggregate=="Total Numerator" & numeratordenom=="D"
	gen tx_viral = fy2016apr if indicator=="TX_VIRAL" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen tx_viral_T = fy2016_target if indicator=="TX_VIRAL" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen tx_viral_f = fy2016apr if indicator=="TX_VIRAL" & disaggregate=="Age/Sex" & sex=="Female" & numeratordenom=="N"
	gen tx_viral_m = fy2016apr if indicator=="TX_VIRAL" & disaggregate=="Age/Sex" & sex=="Male" & numeratordenom=="N"
	gen tx_viral_u15 = fy2016apr if indicator=="TX_VIRAL" & disaggregate=="Age/Sex" & inlist(age, "<1", "1-4", "5-9","10-14") & numeratordenom=="N"
	gen vmmc_circ_T = fy2016_target if indicator=="VMMC_CIRC" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen vmmc_circ_rng_T = fy2016_target if indicator=="VMMC_CIRC" & disaggregate=="Age" & inlist(age, "5-19", "20-24", "25-29") & numeratordenom=="N"
	gen vmmc_circ_subnat = fy2016apr if indicator=="VMMC_CIRC_SUBNAT" & disaggregate=="Total Numerator" & numeratordenom=="N"

	gen htc_tst_u15_yield = . // calculated automatically in DP so user can update
	gen pmtct_eid_yield = . // calculated automatically in DP so user can update
	gen pmtct_stat_yield = . // calculated automatically in DP so user can update
	gen tb_stat_yield = . // calculated automatically in DP so user can update
	gen pre_art_yield = . // calculated automatically in DP so user can update
	gen pre_art_u15_yield = . // calculated automatically in DP so user can update
	gen tx_ret_yield = . // calculated automatically in DP so user can update
	gen tx_ret_u15_yield = . // calculated automatically in DP so user can update

	gen ovc_est = . //  spaceholder for users to update manually
	gen vmmc_pop_rng = . //  spaceholder for users to update manually
	gen vmmc_est = . //  spaceholder for users to update manually
	gen vmmc_est_rng = . //  spaceholder for users to update manually

* collapse to just PSNU
	collapse (sum) care_curr-vmmc_est_rng, by(operatingunit psnu psnuuid snuprioritization)
* rename 
	rename psnu snulist
	
*reorder
	order psnuuid snulist
	order htc_tst_u15_yield, after(htc_tst_u15_pos)
	order ovc_est, after(ovc_serv_T)
	order pmtct_eid_yield, after(pmtct_eid_pos_12mo)
	order pmtct_stat_yield, after(pmtct_stat_pos)
	order tb_stat_yield, after(tb_stat_pos)
	order pre_art_yield pre_art_u15_yield, after(tx_curr_fy16_T)
	order tx_ret_yield, after(tx_ret)
	order tx_ret_u15_yield, after(tx_ret_u15)
	order vmmc_pop_rng vmmc_est vmmc_est_rng, after(vmmc_circ_subnat)
	
* rename prioritizations (due to spacing and to match last year)
	replace snuprioritization = "ScaleUp Sat" if snuprioritization=="1 - Scale-Up: Saturation"
	replace snuprioritization = "ScaleUp Agg" if snuprioritization=="2 - Scale-Up: Aggressive"
	replace snuprioritization = "Sustained" if snuprioritization=="4 - Sustained"
	replace snuprioritization = "Ctrl Supported" if snuprioritization=="5 - Centrally Supported"
	replace snuprioritization = "Sustained Com" if snuprioritization=="6 - Sustained: Commodities"
	replace snuprioritization = "NOT DEFINED" if snuprioritization==""

*sort
	gsort + operatingunit - plhiv + snulist
	
****************************
* keep military?
* Issue - SubNat at OU level
****************************

*save 
	save "$output/global_temp", replace

*create OU specific files
	qui:levelsof operatingunit, local(levels)
	foreach ou of local levels {
		preserve
		qui:keep if operatingunit=="`ou'"
		qui: order facilityuid facilityprioritization, before(indicator)
		di in yellow "export dataset: `ou' "
		qui: export delimited using "$dpexcel\`ou'_PSNU_${date}.txt", ///
			nolabel replace dataf
		restore
		}
