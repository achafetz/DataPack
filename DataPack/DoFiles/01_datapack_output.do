**   Data Pack
**   COP FY17
**   Aaron Chafetz
**   Purpose: generate output for Excel based Data Pack at SNU level
**   Date: November 10, 2016
**   Updated: 1/9/17

*** SETUP ***

*define date for Fact View Files
	global datestamp "20161230_v2_2"
	
*set today's date for saving
	global date: di %tdCCYYNNDD date(c(current_date), "DMY")
	
*** IMPATT ***

*import/open data
	capture confirm file "$fvdata/ICPI_FactView_NAT_SUBNAT_${datestamp}.dta"
		if !_rc{
			use "$fvdata/ICPI_FactView_NAT_SUBNAT_${datestamp}.dta", clear
		}
		else{
			import delimited "$fvdata/ICPI_FactView_NAT_SUBNAT_${datestamp}.txt", clear
			run "$dofiles/06_datapack_dup_snus"
			save "$fvdata/ICPI_FactView_NAT_SUBNAT_${datestamp}.dta", replace
		}
		*end
*clean
	rename ïregion region	
	
*rename variables to match PSNU dataset
	rename fy2015q4 fy2015apr
	rename fy2016q4 fy2016apr	
	
*save
	save "$output/impatt_temp", replace



*** PSNU ***

*import/open data
	capture confirm file "$fvdata/ICPI_FactView_PSNU_${datestamp}.dta"
		if !_rc{
			use "$fvdata/ICPI_FactView_PSNU_${datestamp}.dta", clear
		}
		else{
			import delimited "$fvdata/ICPI_FactView_PSNU_${datestamp}.txt", clear
			run "$dofiles/06_datapack_dup_snus"
			save "$fvdata/ICPI_FactView_PSNU_${datestamp}.dta", replace
		}
		*end
		
*clean
	rename ïregion region
	
*append
	append using "$output/impatt_temp", force

*adjust prioritizations
	rename fy17snuprioritization snuprioritization
	drop fy16snuprioritization
	
*save
	save "$output/append_temp", replace
 
* generate
	// output generated in Data Pack template (POPsubset sheet)
	// updated 1/4
	gen htc_tst = fy2016apr if indicator=="HTC_TST" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen htc_tst_pos = fy2016apr if indicator=="HTC_TST" & disaggregate=="Results" & resultstatus=="Positive" & numeratordenom=="N"
	gen htc_tst_u15 = fy2016apr if indicator=="HTC_TST" & disaggregate=="Age/Sex/Result" & inlist(age, "<01", "01-04", "05-09","10-14") & numeratordenom=="N"
	gen htc_tst_u15_pos = fy2016apr if indicator=="HTC_TST" & disaggregate=="Age/Sex/Result" & inlist(age, "<01", "01-04", "05-09","10-14") & resultstatus=="Positive" & numeratordenom=="N"
	gen htc_tst_u15_yield = 0
	gen htc_tst_spd_inpatient_neg = fy2016apr if indicator=="HTC_TST" & disaggregate=="ServiceDeliveryPoint/Result" & resultstatus=="Negative" & otherdisaggregate=="Inpatient" & numeratordenom=="N"
	gen htc_tst_spd_ct_neg = fy2016apr if indicator=="HTC_TST" & disaggregate=="ServiceDeliveryPoint/Result" & resultstatus=="Negative" & otherdisaggregate=="HIV Care and Treatment Clinic" & numeratordenom=="N"
	gen htc_tst_spd_out_neg = fy2016apr if indicator=="HTC_TST" & disaggregate=="ServiceDeliveryPoint/Result" & resultstatus=="Negative" & otherdisaggregate=="Outpatient Department" & numeratordenom=="N"
	gen htc_tst_spd_tb_neg = fy2016apr if indicator=="HTC_TST" & disaggregate=="ServiceDeliveryPoint/Result" & resultstatus=="Negative" & otherdisaggregate=="Tuberculosis" & numeratordenom=="N"
	gen htc_tst_spd_vmmc_neg = fy2016apr if indicator=="HTC_TST" & disaggregate=="ServiceDeliveryPoint/Result" & resultstatus=="Negative" & otherdisaggregate=="Voluntary Medical Male Circumcision" & numeratordenom=="N"
	gen htc_tst_spd_oth_neg = fy2016apr if indicator=="HTC_TST" & disaggregate=="ServiceDeliveryPoint/Result" & resultstatus=="Negative" & otherdisaggregate=="Other Service Delivery Point" & numeratordenom=="N"
	gen htc_tst_spd_home_neg = fy2016apr if indicator=="HTC_TST" & disaggregate=="ServiceDeliveryPoint/Result" & resultstatus=="Negative" & otherdisaggregate=="Home-based" & numeratordenom=="N"
	gen htc_tst_spd_mobile_neg = fy2016apr if indicator=="HTC_TST" & disaggregate=="ServiceDeliveryPoint/Result" & resultstatus=="Negative" & otherdisaggregate=="Mobile" & numeratordenom=="N"
	gen htc_tst_spd_vtcalone_neg = fy2016apr if indicator=="HTC_TST" & disaggregate=="ServiceDeliveryPoint/Result" & resultstatus=="Negative" & otherdisaggregate=="Voluntary Counseling & Testing standalone" & numeratordenom=="N"
	gen htc_tst_spd_vtccoloc_neg = fy2016apr if indicator=="HTC_TST" & disaggregate=="ServiceDeliveryPoint/Result" & resultstatus=="Negative" & otherdisaggregate=="Voluntary Counseling & Testing co-located" & numeratordenom=="N"
	gen htc_tst_spd_inpatient_pos = fy2016apr if indicator=="HTC_TST" & disaggregate=="ServiceDeliveryPoint/Result" & resultstatus=="Positive" & otherdisaggregate=="Inpatient" & numeratordenom=="N"
	gen htc_tst_spd_ct_pos = fy2016apr if indicator=="HTC_TST" & disaggregate=="ServiceDeliveryPoint/Result" & resultstatus=="Positive" & otherdisaggregate=="HIV Care and Treatment Clinic" & numeratordenom=="N"
	gen htc_tst_spd_out_pos = fy2016apr if indicator=="HTC_TST" & disaggregate=="ServiceDeliveryPoint/Result" & resultstatus=="Positive" & otherdisaggregate=="Outpatient Department" & numeratordenom=="N"
	gen htc_tst_spd_tb_pos = fy2016apr if indicator=="HTC_TST" & disaggregate=="ServiceDeliveryPoint/Result" & resultstatus=="Positive" & otherdisaggregate=="Tuberculosis" & numeratordenom=="N"
	gen htc_tst_spd_vmmc_pos = fy2016apr if indicator=="HTC_TST" & disaggregate=="ServiceDeliveryPoint/Result" & resultstatus=="Positive" & otherdisaggregate=="Voluntary Medical Male Circumcision" & numeratordenom=="N"
	gen htc_tst_spd_oth_pos = fy2016apr if indicator=="HTC_TST" & disaggregate=="ServiceDeliveryPoint/Result" & resultstatus=="Positive" & otherdisaggregate=="Other Service Delivery Point" & numeratordenom=="N"
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
	gen ovc_serv = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen ovc_serv_T = fy2017_targets if indicator=="OVC_SERV" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen plhiv = fy2016apr if indicator=="PLHIV" & disaggregate=="Total Numerator"
	gen plhiv_u15 = fy2016apr if indicator=="PLHIV" & disaggregate=="Age Aggregated/Sex" & age=="<15"
	gen plhiv_o15 = fy2016apr if indicator=="PLHIV" & disaggregate=="Age Aggregated/Sex" & age=="15+"
	gen pop_num = fy2016apr if indicator=="POP_NUM" & disaggregate=="Total Numerator"
	gen pop_num_m = fy2016apr if indicator=="POP_NUM" & disaggregate=="Age Aggregated/Sex" & sex=="Male"
	gen pmtct_arv_already = fy2016apr if indicator=="PMTCT_ARV" & disaggregate=="MaternalRegimenType" & otherdisaggregate=="Life-long ART Already" & numeratordenom=="N"
	gen pmtct_arv_already_T = fy2017_targets if indicator=="PMTCT_ARV" & disaggregate=="MaternalRegimenType" & otherdisaggregate=="Life-long ART Already" & numeratordenom=="N"
	gen pmtct_arv_curr = fy2016apr if indicator=="PMTCT_ARV" & disaggregate=="MaternalRegimenType"& inlist(otherdisaggregate, "Life-long ART New", "Triple-drug ARV") & numeratordenom=="N"
	gen pmtct_arv_curr_T = fy2017_targets if indicator=="PMTCT_ARV" & disaggregate=="MaternalRegimenType"& inlist(otherdisaggregate, "Life-long ART New", "Triple-drug ARV") & numeratordenom=="N"
	gen pmtct_eid = fy2016apr if indicator=="PMTCT_EID" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen pmtct_eid_12mo_T = fy2017_targets if indicator=="PMTCT_EID" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen pmtct_eid_pos_12mo = fy2016apr if indicator=="PMTCT_EID_POS_12MO" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen pmtct_eid_yield = 0
	gen pmtct_stat_D = fy2016apr if indicator=="PMTCT_STAT" & disaggregate=="Total Denominator" & numeratordenom=="D"
	gen pmtct_stat_D_T = fy2017_targets if indicator=="PMTCT_STAT" & disaggregate=="Total Denominator" & numeratordenom=="D"
	gen pmtct_stat = fy2016apr if indicator=="PMTCT_STAT" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen pmtct_stat_T = fy2017_targets if indicator=="PMTCT_STAT" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen pmtct_stat_pos = fy2016apr if indicator=="PMTCT_STAT" & disaggregate=="Known/New" & numeratordenom=="N"
	gen pmtct_stat_yield = 0
	gen pmtct_stat_knownpos = fy2016apr if indicator=="PMTCT_STAT" & disaggregate=="Known/New" & resultstatus=="Positive" & otherdisaggregate=="Known at Entry" & numeratordenom=="N"
	gen pp_prev = fy2016apr if indicator=="PP_PREV" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen pp_prev_T = fy2017_targets if indicator=="PP_PREV" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen tb_art_T = fy2017_targets if indicator=="TB_ART" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen tb_stat_D = fy2016apr if indicator=="TB_STAT" & disaggregate=="Total Denominator" & numeratordenom=="D"
	gen tb_stat_D_T = fy2017_targets if indicator=="TB_STAT" & disaggregate=="Total Denominator" & numeratordenom=="D"
	gen tb_stat = fy2016apr if indicator=="TB_STAT" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen tb_stat_pos = fy2016apr if indicator=="TB_STAT" & disaggregate=="Result" & resultstatus=="Positive" & numeratordenom=="N"
	gen tb_stat_T = fy2017_targets if indicator=="TB_STAT" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen tb_stat_yield = 0
	gen tx_curr = fy2016apr if indicator=="TX_CURR" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen tx_curr_T = fy2017_targets if indicator=="TX_CURR" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen tx_curr_u15 = fy2016apr if indicator=="TX_CURR" & disaggregate=="Age/Sex" & inlist(age, "<01", "01-04", "05-14") & numeratordenom=="N"
	gen tx_curr_u15_T = fy2017_targets if indicator=="TX_CURR" & disaggregate=="Age/Sex" & inlist(age, "<01", "01-04", "05-14") & numeratordenom=="N"
	gen tx_curr_1to15_T = fy2017_targets if indicator=="TX_CURR" & disaggregate=="Age/Sex" & inlist(age, "01-04", "05-14") & numeratordenom=="N"
	gen tx_curr_o15_T = fy2017_targets if indicator=="TX_CURR" & disaggregate=="Age/Sex" & inlist(age, "15-19", "20+") & numeratordenom=="N"
	gen tx_curr_subnat_u15 = fy2016apr if indicator=="TX_CURR_SUBNAT" & disaggregate=="Age/Sex" & age=="<15" & numeratordenom=="N"
	gen tx_curr_subnat = fy2016apr if indicator=="TX_CURR_SUBNAT" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen tx_new_u1 = fy2016apr if indicator=="TX_NEW" & disaggregate=="Age/Sex" & age=="<01" & numeratordenom=="N"
	gen tx_new_u1_T = fy2017_targets if indicator=="TX_NEW" & disaggregate=="Age/Sex" & age=="<01" & numeratordenom=="N"
	gen tx_ret_D = fy2016apr if indicator=="TX_RET" & disaggregate=="Total Denominator" & numeratordenom=="D"
	gen tx_ret = fy2016apr if indicator=="TX_RET" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen tx_ret_u15_D = fy2016apr if indicator=="TX_RET" & disaggregate=="Age/Sex" & inlist(age, "<05", "05-14") & numeratordenom=="D"
	gen tx_ret_yield = 0
	gen tx_ret_u15 = fy2016apr if indicator=="TX_RET" & disaggregate=="Age/Sex" & inlist(age, "<05", "05-14") & numeratordenom=="N"
	gen tx_ret_u15_yield = 0
	gen vmmc_circ_T = fy2017_targets if indicator=="VMMC_CIRC" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen vmmc_circ_rng_T = fy2017_targets if indicator=="VMMC_CIRC" & disaggregate=="Age" & inlist(age, "05-19", "20-24", "25-29") & numeratordenom=="N"
	gen vmmc_circ_subnat = fy2016apr if indicator=="VMMC_CIRC_SUBNAT" & disaggregate=="Total Numerator" & numeratordenom=="N"

*agg disags "fixes" (Fine --> Coarse or Fine + Coarse) above for select OUs
	/*J. Houston
	- HTC_TST: fine disags for most countries; fine + coarse for Haiti, Mozambique, Nigeria, South Africa, Tanzania, Uganda, Ukraine, and (coarse) Vietnam
	- TX_CURR: fine disags for all countries except (coarse) Mozambique and Vietnam, (fine + coarse)  Uganda and South Africa */
	*replace HTC data
	foreach v in htc_tst_u15 htc_tst_u15_pos{
		replace `v' = . if inlist(operatingunit, "Haiti", "Mozambique", ///
			"Nigeria", "South Africa", "Tanzania", "Uganda", "Ukraine", "Vietnam")
		}
		*end
	replace htc_tst_u15 = fy2016apr if indicator=="HTC_TST" & inlist(disaggregate, "Age/Sex/Result", "Age/Sex Aggregated/Result") & inlist(age, "<01", "01-04", "05-09","10-14", "<15") & numeratordenom=="N" & inlist(operatingunit, "Haiti", "Mozambique", "Nigeria", "South Africa", "Tanzania", "Uganda", "Ukraine")
	replace htc_tst_u15 = fy2016apr if indicator=="HTC_TST" & disaggregate=="Age/Sex Aggregated/Result" & age=="<15" & numeratordenom=="N" & operatingunit=="Vietnam"
	replace htc_tst_u15_pos = fy2016apr if indicator=="HTC_TST" & inlist(disaggregate, "Age/Sex/Result", "Age/Sex Aggregated/Result") & inlist(age, "<01", "01-04", "05-09","10-14", "<15") & resultstatus=="Positive" & numeratordenom=="N" & inlist(operatingunit, "Haiti", "Mozambique", "Nigeria", "South Africa", "Tanzania", "Uganda", "Ukraine")
	replace htc_tst_u15_pos = fy2016apr if indicator=="HTC_TST" & disaggregate=="Age/Sex Aggregated/Result" & age=="<15" & resultstatus=="Positive" & numeratordenom=="N" & operatingunit=="Vietnam"
	*replace TX_CURR data
	foreach v in 	tx_curr_u15 tx_curr_u15_T tx_curr_1to15_T tx_curr_o15_T {
		replace `v' = . if inlist(operatingunit, "Mozambique", "South Africa", ///
			"Uganda", "Vietnam")
		}
		*end
	replace tx_curr_u15 = fy2016apr if indicator=="TX_CURR" & inlist(disaggregate, "Age/Sex", "Age/Sex Aggregated", "Age/Sex, Aggregated") & inlist(age, "<01", "01-04", "05-14", "01-14") & numeratordenom=="N" & inlist(operatingunit, "Uganda", "South Africa")
	replace tx_curr_u15 = fy2016apr if indicator=="TX_CURR" & inlist(disaggregate, "Age/Sex Aggregated", "Age/Sex, Aggregated") & inlist(age, "<01", "01-14") & numeratordenom=="N" & inlist(operatingunit, "Mozambique", "Vietnam")
	replace tx_curr_u15_T = fy2017_targets if indicator=="TX_CURR" & inlist(disaggregate, "Age/Sex", "Age/Sex Aggregated", "Age/Sex, Aggregated") & inlist(age, "<01", "01-04", "05-14", "01-14") & numeratordenom=="N" & inlist(operatingunit, "Uganda", "South Africa")
	replace tx_curr_u15_T = fy2017_targets if indicator=="TX_CURR" & inlist(disaggregate, "Age/Sex Aggregated", "Age/Sex, Aggregated") & inlist(age, "<01", "01-14") & numeratordenom=="N" & inlist(operatingunit, "Mozambique", "Vietnam")
	replace tx_curr_1to15_T = fy2017_targets if indicator=="TX_CURR" & inlist(disaggregate, "Age/Sex", "Age/Sex Aggregated", "Age/Sex, Aggregated") & inlist(age, "01-04", "05-14", "01-14") & numeratordenom=="N" & inlist(operatingunit, "Uganda", "South Africa")
	replace tx_curr_1to15_T = fy2017_targets if indicator=="TX_CURR" & inlist(disaggregate, "Age/Sex Aggregated", "Age/Sex, Aggregated") & age=="01-14" & numeratordenom=="N" & inlist(operatingunit, "Mozambique", "Vietnam")
	replace tx_curr_o15_T = fy2017_targets if indicator=="TX_CURR" & inlist(disaggregate, "Age/Sex", "Age/Sex Aggregated", "Age/Sex, Aggregated") & inlist(age, "15-19", "20+", "15+") & numeratordenom=="N" & inlist(operatingunit, "Uganda", "South Africa")
	replace tx_curr_o15_T = fy2017_targets if indicator=="TX_CURR" & inlist(disaggregate, "Age/Sex Aggregated", "Age/Sex, Aggregated") & inlist(age, "15+") & numeratordenom=="N" & inlist(operatingunit, "Mozambique", "Vietnam")
		
* aggregate up to PSNU level
	drop fy*
	ds *, not(type string)
	collapse (sum) `r(varlist)', fast by(operatingunit snu1 psnu psnuuid snuprioritization)

* rename 
	rename psnu snulist
	rename snuprioritization priority_snu
	
*reorder columns
	order operatingunit psnuuid snulist snu1
	
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
		firstrow(variables) sheet("DATIM Indicator Table") sheetreplace

