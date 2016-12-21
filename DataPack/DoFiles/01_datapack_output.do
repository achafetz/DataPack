**   Data Pack
**   COP FY17
**   Aaron Chafetz
**   Purpose: generate output for Excel based Data Pack at SNU level
**   Date: November 10, 2016
**   Updated: 12/20/2016

*** SETUP ***

*define date for Fact View Files
	global datestamp "20161115_Q4v1_4"
	
*set today's date for saving
	global date: di %tdCCYYNNDD date(c(current_date), "DMY")
	
*** IMPATT ***

*import/open data
	*replace ${datestamp} for current version until new FW uploaded
	capture confirm file "$fvdata/ICPI_FactView_NAT_SUBNAT_${datestamp}.dta"
		if !_rc{
			use "$fvdata/ICPI_FactView_NAT_SUBNAT_${datestamp}.dta", clear
		}
		else{
			import delimited "$fvdata/ICPI_FactView_NAT_SUBNAT_${datestamp}.txt", clear
			save "$fvdata/ICPI_FactView_NAT_SUBNAT_${datestamp}.dta", replace
		}
		*end
*clean
	rename ïregion region	
	ds fy*
	*remove NULLS so data can be destringed
	foreach pd in `r(varlist)'{
		replace `pd' = "." if `pd' == "NULL"
		destring `pd', replace
	}
	*end
	
*rename variables to match
	rename fy2015q4 fy2015apr
	rename fy2016q4 fy2016apr	
	
/*
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
*/


*save
	save "$output/impatt_temp", replace

*** PSNU by IM ***

*import/open data
	*capture confirm file "$fvdata/ICPI_FactView_PSNU_IM_${datestamp}.dta"
	capture confirm file "$fvdata/ICPI_FactView_PSNU_${datestamp}.dta"
		if !_rc{
			*use "$fvdata/ICPI_FactView_PSNU_IM_${datestamp}.dta", clear
			use "$fvdata/ICPI_FactView_PSNU_${datestamp}.dta", clear
		}
		else{
			*import delimited "$fvdata/ICPI_FactView_PSNU_IM_${datestamp}.txt", clear
			*save "$fvdata/ICPI_FactView_PSNU_IM_${datestamp}.dta", replace
			import delimited "$fvdata/ICPI_FactView_PSNU_${datestamp}.txt", clear
			save "$fvdata/ICPI_FactView_PSNU_${datestamp}.dta", replace
		}
		*end
		
*clean
	*gen fy2017_targets = 0 //delete after FY17 targets are added into FV dataset
	rename ïregion region
	
*apend
	append using "$output/impatt_temp", force

*adjust prioritizations
	rename fy17snuprioritization snuprioritization
	drop fy16snuprioritization
	
********************************************************************************	
*keep just pilot countries --> remove after piloting
	keep if inlist(operatingunit, "Nigeria", "Mozambique", "Tanzania", "Zambia")
********************************************************************************
	
*save
	save "$output/append_temp", replace
	
* generate
	// output generated in Data Pack template (POPsubset sheet)
	// updated 12/12
	gen care_curr = fy2016apr if indicator=="CARE_CURR" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen care_curr_T = fy2017_targets if indicator=="CARE_CURR" & disaggregate=="Age/Sex" & numeratordenom=="N"
	gen care_curr_f = fy2016apr if indicator=="CARE_CURR" & disaggregate=="Age/Sex" & sex=="Female" & numeratordenom=="N"
	gen care_curr_m = fy2016apr if indicator=="CARE_CURR" & disaggregate=="Age/Sex" & sex=="Male" & numeratordenom=="N"
	gen care_curr_u15 = fy2016apr if indicator=="CARE_CURR" & disaggregate=="Age/Sex" & inlist(age, "<01", "01-04", "05-09","10-14") & numeratordenom=="N"
	gen care_curr_u15_T = fy2017_targets if indicator=="CARE_CURR" & disaggregate=="Age/Sex" & inlist(age, "<01", "01-04", "05-09","10-14") & numeratordenom=="N"
	gen care_curr_o15_T = fy2017_targets if indicator=="CARE_CURR" & disaggregate=="Age/Sex" & numeratordenom=="N"
	gen care_curr_fy16_T = fy2016_targets if indicator=="CARE_CURR" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen care_new = fy2016apr if indicator=="CARE_NEW" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen care_new_T = fy2017_targets if indicator=="CARE_NEW" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen care_new_fy16_T = fy2016_targets if indicator=="CARE_NEW" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen htc_tst = fy2016apr if indicator=="HTC_TST" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen htc_tst_f_pos = fy2016apr if indicator=="HTC_TST" & disaggregate=="Age/Sex/Result" & sex=="Female" & resultstatus=="Positive" & numeratordenom=="N"
	gen htc_tst_pos = fy2016apr if indicator=="HTC_TST" & disaggregate=="Age/Sex/Result" & resultstatus=="Positive" & numeratordenom=="N"
	gen htc_tst_m_pos = fy2016apr if indicator=="HTC_TST" & disaggregate=="Age/Sex/Result" & sex=="Male" & resultstatus=="Positive" & numeratordenom=="N"
	gen htc_tst_u15 = fy2016apr if indicator=="HTC_TST" & disaggregate=="Age/Sex/Result" & inlist(age, "<01", "01-04", "05-09","10-14") & numeratordenom=="N"
	gen htc_tst_u15_pos = fy2016apr if indicator=="HTC_TST" & disaggregate=="Age/Sex/Result" & inlist(age, "<01", "01-04", "05-09","10-14") & resultstatus=="Positive" & numeratordenom=="N"
	gen htc_tst_u15_yield = 0
	gen htc_tst_fy16_T = fy2016_targets if indicator=="HTC_TST" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen htc_tst_pos_fy16_T = fy2016_targets if indicator=="HTC_TST" & disaggregate=="Total Numerator" & resultstatus=="Positive" & numeratordenom=="N"
	gen htc_tst_T = fy2017_targets if indicator=="HTC_TST" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen htc_tst_pos_T = fy2017_targets if indicator=="HTC_TST" & disaggregate=="Age/Sex/Result" & resultstatus=="Positive" & numeratordenom=="N"
	gen htc_tst_spd_inpatient_neg = fy2016apr if indicator=="HTC_TST" & disaggregate=="ServiceDeliveryPoint/Result" & resultstatus=="Negative" & otherdisaggregate=="Inpatient" & numeratordenom=="N"
	gen htc_tst_spd_oth_neg = fy2016apr if indicator=="HTC_TST" & disaggregate=="ServiceDeliveryPoint/Result" & resultstatus=="Negative"& inlist(otherdisaggregate, "HIV Care and Treatment Clinic", "Outpatient Department", "Other Service Delivery Point") & numeratordenom=="N"
	gen htc_tst_spd_home_neg = fy2016apr if indicator=="HTC_TST" & disaggregate=="ServiceDeliveryPoint/Result" & resultstatus=="Negative" & otherdisaggregate=="Home-based" & numeratordenom=="N"
	gen htc_tst_spd_mobile_neg = fy2016apr if indicator=="HTC_TST" & disaggregate=="ServiceDeliveryPoint/Result" & resultstatus=="Negative" & otherdisaggregate=="Mobile" & numeratordenom=="N"
	gen htc_tst_spd_vtcalone_neg = fy2016apr if indicator=="HTC_TST" & disaggregate=="ServiceDeliveryPoint/Result" & resultstatus=="Negative" & otherdisaggregate=="Voluntary Counseling & Testing standalone" & numeratordenom=="N"
	gen htc_tst_spd_vtccoloc_neg = fy2016apr if indicator=="HTC_TST" & disaggregate=="ServiceDeliveryPoint/Result" & resultstatus=="Negative" & otherdisaggregate=="Voluntary Counseling & Testing co-located" & numeratordenom=="N"
	gen htc_tst_spd_inpatient_pos = fy2016apr if indicator=="HTC_TST" & disaggregate=="ServiceDeliveryPoint/Result" & resultstatus=="Positive" & otherdisaggregate=="Inpatient" & numeratordenom=="N"
	gen htc_tst_spd_oth_pos = fy2016apr if indicator=="HTC_TST" & disaggregate=="ServiceDeliveryPoint/Result" & resultstatus=="Positive"& inlist(otherdisaggregate, "HIV Care and Treatment Clinic", "Outpatient Department", "Other Service Delivery Point") & numeratordenom=="N"
	gen htc_tst_spd_home_pos = fy2016apr if indicator=="HTC_TST" & disaggregate=="ServiceDeliveryPoint/Result" & resultstatus=="Positive" & otherdisaggregate=="Home-based" & numeratordenom=="N"
	gen htc_tst_spd_mobile_pos = fy2016apr if indicator=="HTC_TST" & disaggregate=="ServiceDeliveryPoint/Result" & resultstatus=="Positive" & otherdisaggregate=="Mobile" & numeratordenom=="N"
	gen htc_tst_spd_vtcalone_pos = fy2016apr if indicator=="HTC_TST" & disaggregate=="ServiceDeliveryPoint/Result" & resultstatus=="Positive" & otherdisaggregate=="Voluntary Counseling & Testing standalone" & numeratordenom=="N"
	gen htc_tst_spd_vtccoloc_pos = fy2016apr if indicator=="HTC_TST" & disaggregate=="ServiceDeliveryPoint/Result" & resultstatus=="Positive" & otherdisaggregate=="Voluntary Counseling & Testing co-located" & numeratordenom=="N"
	gen htc_tst_spd_tot_pos = 0
	gen kp_prev_fsw = fy2016apr if indicator=="KP_PREV" & disaggregate=="KeyPop" & otherdisaggregate=="FSW" & numeratordenom=="N"
	gen kp_prev_fsw_T = fy2017_targets if indicator=="KP_PREV" & disaggregate=="KeyPop" & otherdisaggregate=="FSW" & numeratordenom=="N"
	gen kp_prev_msmtg = fy2016apr if indicator=="KP_PREV" & disaggregate=="KeyPop" & otherdisaggregate=="MSM/TG" & numeratordenom=="N"
	gen kp_prev_msmtg_T = fy2017_targets if indicator=="KP_PREV" & disaggregate=="KeyPop" & otherdisaggregate=="MSM/TG" & numeratordenom=="N"
	gen kp_prev_pwid = fy2016apr if indicator=="KP_PREV" & disaggregate=="KeyPop"& inlist(otherdisaggregate, "Female PWID", "Male PWID") & numeratordenom=="N"
	gen kp_prev_pwid_T = fy2017_targets if indicator=="KP_PREV" & disaggregate=="KeyPop"& inlist(otherdisaggregate, "Female PWID", "Male PWID") & numeratordenom=="N"
	gen kp_mat = fy2016apr if indicator=="KP_MAT" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen kp_mat_T = fy2017_targets if indicator=="KP_MAT" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen ovc_acc = fy2016apr if indicator=="OVC_ACC" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen ovc_acc_T = fy2017_targets if indicator=="OVC_ACC" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen ovc_serv = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen ovc_serv_T = fy2017_targets if indicator=="OVC_SERV" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen plhiv_u15 = fy2016apr if indicator=="PLHIV" & disaggregate=="Age Aggregated/Sex" & age=="<15"
	gen plhiv_o15 = fy2016apr if indicator=="PLHIV" & disaggregate=="Age Aggregated/Sex" & age=="15+"
	gen plhiv_f = fy2016apr if indicator=="PLHIV" & disaggregate=="Age Aggregated/Sex" & sex=="Female"
	gen plhiv_m = fy2016apr if indicator=="PLHIV" & disaggregate=="Age Aggregated/Sex" & sex=="Male"
	gen plhiv = fy2016apr if indicator=="PLHIV" & disaggregate=="Total Numerator"
	gen pop_num = fy2016apr if indicator=="POP_NUM" & disaggregate=="Total Numerator"
	gen pop_num_f = fy2016apr if indicator=="POP_NUM" & disaggregate=="Age Aggregated/Sex" & sex=="Female"
	gen pop_num_m = fy2016apr if indicator=="POP_NUM" & disaggregate=="Age Aggregated/Sex" & sex=="Male"
	gen pmtct_arv_T = fy2017_targets if indicator=="PMTCT_ARV" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen pmtct_arv_already = fy2016apr if indicator=="PMTCT_ARV" & disaggregate=="MaternalRegimenType" & otherdisaggregate=="Life-long ART Already" & numeratordenom=="N"
	gen pmtct_arv_curr = fy2016apr if indicator=="PMTCT_ARV" & disaggregate=="MaternalRegimenType"& inlist(otherdisaggregate, "Life-long ART New", "Triple-drug ARV") & numeratordenom=="N"
	gen pmtct_arv_curr_T = fy2017_targets if indicator=="PMTCT_ARV" & disaggregate=="MaternalRegimenType"& inlist(otherdisaggregate, "Life-long ART New", "Triple-drug ARV") & numeratordenom=="N"
	gen pmtct_arv_fy16_T = fy2016_targets if indicator=="PMTCT_ARV" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen pmtct_eid = fy2016apr if indicator=="PMTCT_EID" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen pmtct_eid_12mo = fy2016apr if indicator=="PMTCT_EID" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen pmtct_eid_12mo_T = fy2017_targets if indicator=="PMTCT_EID" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen pmtct_eid_2mo = fy2016apr if indicator=="PMTCT_EID" & disaggregate=="InfantTest" & age=="[months] 02-12" & numeratordenom=="N"
	gen pmtct_eid_pos_2mo = fy2016apr if indicator=="PMTCT_EID_POS_2MO" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen pmtct_eid_pos_12mo = fy2016apr if indicator=="PMTCT_EID_POS_12MO" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen pmtct_eid_yield = 0
	gen pmtct_fo = fy2016apr if indicator=="PMTCT_FO" & disaggregate=="Outcome" & otherdisaggregate=="HIV-Uninfected: Not Breastfeeding" & numeratordenom=="N"
	gen pmtct_stat_D = fy2016apr if indicator=="PMTCT_STAT" & disaggregate=="Total Denominator" & numeratordenom=="D"
	gen pmtct_stat_D_T = fy2017_targets if indicator=="PMTCT_STAT" & disaggregate=="Total Denominator" & numeratordenom=="D"
	gen pmtct_stat = fy2016apr if indicator=="PMTCT_STAT" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen pmtct_stat_T = fy2017_targets if indicator=="PMTCT_STAT" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen pmtct_stat_pos = fy2016apr if indicator=="PMTCT_STAT" & disaggregate=="Known/New" & numeratordenom=="N"
	gen pmtct_stat_yield = 0
	gen pmtct_stat_knownpos = fy2016apr if indicator=="PMTCT_STAT" & disaggregate=="Known/New" & resultstatus=="Positive" & otherdisaggregate=="Known at Entry" & numeratordenom=="N"
	gen pmtct_stat_known_T = fy2017_targets if indicator=="PMTCT_STAT" & disaggregate=="Known/New" & numeratordenom=="N"
	gen pmtct_stat_subnat = fy2016apr if indicator=="PMTCT_STAT_SUBNAT" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen pp_prev = fy2016apr if indicator=="PP_PREV" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen pp_prev_T = fy2017_targets if indicator=="PP_PREV" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen prevalence_num = fy2016apr if indicator=="PREVALENCE_NUM" & disaggregate=="NULL"
	gen tb_art_D = fy2016apr if indicator=="TB_ART" & disaggregate=="Total Denominator" & numeratordenom=="D"
	gen tb_art = fy2016apr if indicator=="TB_ART" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen tb_art_T = fy2017_targets if indicator=="TB_ART" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen tb_ipt = fy2016apr if indicator=="TB_IPT" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen tb_outcome_D = fy2016apr if indicator=="TB_OUTCOME" & disaggregate=="Total Denominator" & numeratordenom=="D"
	gen tb_screen = fy2016apr if indicator=="TB_SCREEN" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen tb_screen_T = fy2017_targets if indicator=="TB_SCREEN" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen tb_stat_D = fy2016apr if indicator=="TB_STAT" & disaggregate=="Total Denominator" & numeratordenom=="D"
	gen tb_stat_D_T = fy2017_targets if indicator=="TB_STAT" & disaggregate=="Total Denominator" & numeratordenom=="D"
	gen tb_stat_pos = fy2016apr if indicator=="TB_STAT" & disaggregate=="Result" & resultstatus=="Positive" & numeratordenom=="N"
	gen tb_stat_yield = 0
	gen tb_stat = fy2016apr if indicator=="TB_STAT" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen tb_stat_T = fy2017_targets if indicator=="TB_STAT" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen tx_curr = fy2016apr if indicator=="TX_CURR" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen tx_curr_T = fy2017_targets if indicator=="TX_CURR" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen tx_curr_f = fy2016apr if indicator=="TX_CURR" & disaggregate=="Age/Sex" & sex=="Female" & numeratordenom=="N"
	gen tx_curr_m = fy2016apr if indicator=="TX_CURR" & disaggregate=="Age/Sex" & sex=="Male" & numeratordenom=="N"
	gen tx_curr_u1 = fy2016apr if indicator=="TX_CURR" & disaggregate=="Age/Sex" & age=="<01" & numeratordenom=="N"
	gen tx_curr_u15 = fy2016apr if indicator=="TX_CURR" & disaggregate=="Age/Sex" & inlist(age, "<01", "01-04", "05-14") & numeratordenom=="N"
	gen tx_curr_u15_T = fy2017_targets if indicator=="TX_CURR" & disaggregate=="Age/Sex" & inlist(age, "<01", "01-04", "05-14") & numeratordenom=="N"
	gen tx_curr_1to15_T = fy2017_targets if indicator=="TX_CURR" & disaggregate=="Age/Sex" & inlist(age, "01-04", "05-14") & numeratordenom=="N"
	gen tx_curr_o15_T = fy2017_targets if indicator=="TX_CURR" & disaggregate=="Age/Sex" & inlist(age, "15-19", "20+") & numeratordenom=="N"
	gen tx_curr_fy16_T = fy2016_targets if indicator=="TX_CURR" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen tx_curr_1to15_fy16_T = fy2016_targets if indicator=="TX_CURR" & disaggregate=="Age/Sex" & inlist(age, "01-04", "05-14") & numeratordenom=="N"
	gen tx_curr_o15_fy16_T = fy2016_targets if indicator=="TX_CURR" & disaggregate=="Age/Sex" & inlist(age, "15-19", "20+") & numeratordenom=="N"
	gen pre_art_yield = 0
	gen pre_art_u15_yield = 0
	gen tx_curr_subnat_u15 = fy2016apr if indicator=="TX_CURR_SUBNAT" & disaggregate=="Age/Sex" & age=="<15" & numeratordenom=="N"
	gen tx_curr_subnat = fy2016apr if indicator=="TX_CURR_SUBNAT" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen tx_new = fy2016apr if indicator=="TX_NEW" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen tx_new_T = fy2017_targets if indicator=="TX_NEW" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen tx_new_u1 = fy2016apr if indicator=="TX_NEW" & disaggregate=="Age/Sex" & age=="<01" & numeratordenom=="N"
	gen tx_new_u1_T = fy2017_targets if indicator=="TX_NEW" & disaggregate=="Age/Sex" & age=="<01" & numeratordenom=="N"
	gen tx_new_fy16_T = fy2016_targets if indicator=="TX_NEW" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen tx_new_u15 = fy2016apr if indicator=="TX_NEW" & disaggregate=="Age/Sex" & inlist(age, "<01", "01-04", "05-09","10-14") & numeratordenom=="N"
	gen tx_ret_D = fy2016apr if indicator=="TX_RET" & disaggregate=="Total Denominator" & numeratordenom=="D"
	gen tx_ret = fy2016apr if indicator=="TX_RET" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen tx_ret_u15_D = fy2016apr if indicator=="TX_RET" & disaggregate=="Age/Sex" & inlist(age, "<05", "05-14") & numeratordenom=="D"
	gen tx_ret_yield = 0
	gen tx_ret_u15 = fy2016apr if indicator=="TX_RET" & disaggregate=="Age/Sex" & inlist(age, "<05", "05-14") & numeratordenom=="N"
	gen tx_ret_u15_yield = 0
	gen tx_undetect = fy2016apr if indicator=="TX_UNDETECT" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen tx_undetect_f = fy2016apr if indicator=="TX_UNDETECT" & disaggregate=="Age/Sex" & sex=="Female" & numeratordenom=="N"
	gen tx_undetect_m = fy2016apr if indicator=="TX_UNDETECT" & disaggregate=="Age/Sex" & sex=="Male" & numeratordenom=="N"
	gen tx_undetect_u15 = fy2016apr if indicator=="TX_UNDETECT" & disaggregate=="Age/Sex" & inlist(age, "<01", "01-04", "05-09","10-14") & numeratordenom=="N"
	gen tx_undetect_D = fy2016apr if indicator=="TX_UNDETECT" & disaggregate=="Total Denominator" & numeratordenom=="D"
	gen tx_viral = fy2016apr if indicator=="TX_VIRAL" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen tx_viral_T = fy2017_targets if indicator=="TX_VIRAL" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen tx_viral_f = fy2016apr if indicator=="TX_VIRAL" & disaggregate=="Age/Sex" & sex=="Female" & numeratordenom=="N"
	gen tx_viral_m = fy2016apr if indicator=="TX_VIRAL" & disaggregate=="Age/Sex" & sex=="Male" & numeratordenom=="N"
	gen tx_viral_u15 = fy2016apr if indicator=="TX_VIRAL" & disaggregate=="Age/Sex" & inlist(age, "<01", "01-04", "05-09","10-14") & numeratordenom=="N"
	gen vmmc_circ_T = fy2017_targets if indicator=="VMMC_CIRC" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen vmmc_circ_rng_T = fy2017_targets if indicator=="VMMC_CIRC" & disaggregate=="Age" & inlist(age, "05-19", "20-24", "25-29") & numeratordenom=="N"
	gen vmmc_circ_subnat = fy2016apr if indicator=="VMMC_CIRC_SUBNAT" & disaggregate=="Total Numerator" & numeratordenom=="N"



* aggregate up to PSNU level
	*drop mechanismid fy*
	drop fy*
	ds *, not(type string)
	collapse (sum) `r(varlist)', by(operatingunit psnu psnuuid snuprioritization)

* rename 
	rename psnu snulist
	rename snuprioritization priority_snu
	
*reorder columns
	order operatingunit psnuuid snulist
	
* rename prioritizations (due to spacing and to match last year)
	replace priority_snu = "ScaleUp Sat" if priority_snu=="1 - Scale-Up: Saturation"
	replace priority_snu = "ScaleUp Agg" if priority_snu=="2 - Scale-Up: Aggressive"
	replace priority_snu = "Sustained" if priority_snu=="4 - Sustained"
	replace priority_snu = "Ctrl Supported" if priority_snu=="5 - Centrally Supported"
	replace priority_snu = "Sustained Com" if priority_snu=="6 - Sustained: Commodities"
	replace priority_snu = "NOT DEFINED" if priority_snu==""
	replace priority_snu = "Mil" if strmatch(snulist, "*_Military*")
	
*sort by PLHIV
	gsort + operatingunit - plhiv + snulist

*replace zero values with missing & clear mil data, but keep as row placeholder for their entry
	ds *, not(type string)
	foreach v in `r(varlist)' {
		replace `v' = . if `v'==0
		replace `v' = . if strmatch(snulist, "*_Military*")
		}
		*end
*if no psnu
	replace psnu = "[no associated SNU]" if psnu==""
********************************************************************************
* REMOVE AFTER PILOTING
*due to incomplete targets, set to 110 of result for FY16
	global tlist care_curr_o15_T care_curr_T care_curr_u15_T care_new_T ///
		htc_tst_pos_T htc_tst_T kp_mat kp_mat_T kp_prev_fsw_T kp_prev_msmtg_T ///
		kp_prev_pwid_T ovc_acc_T ovc_serv_T pmtct_arv_curr_T pmtct_eid_12mo_T ///
		pmtct_stat_D_T pmtct_stat_T pp_prev_T tb_art tb_art_T tb_screen_T ///
		tb_stat_D_T tb_stat_T tx_curr_T ///
		tx_curr_u15_T tx_new_T tx_new_u1_T tx_viral_T 
	foreach t in $tlist{
	replace `t' = 1.1* `=regexr("`t'","_T","")' ///
				if inlist(operatingunit, "Mozambique", "Tanzania", "Zambia")
	}
	*end
	/*
	no results
	vmmc_circ_rng_T 
	vmmc_circ_T
	pmtct_stat_known_T
	pmtct_arv_T
	*/
********************************************************************************

*save 
	save "$output/global_temp", replace

*delete older version of the output
	fs "$dpexcel/Global*.xlsx"
	foreach f in `r(files)'{
		erase "$dpexcel/`f'"
		}
		*end
*export global list to data pack template
	export excel using "$dpexcel/Global_PSNU_${date}.xlsx", ///
		firstrow(variables) sheet("Indicator Table") replace
