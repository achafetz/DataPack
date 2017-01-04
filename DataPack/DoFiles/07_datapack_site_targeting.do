**   Data Pack
**   COP FY17
**   Aaron Chafetz
**   Purpose: generate output for Excel based IM targeting Data Pack appendix
**   Date: January 3, 2017
**   Updated:


*set date of frozen instance - needs to be changed w/ updated data
	global datestamp "20161115_Q4v1_2"

* unzip folder containing all site data
	cd "C:\Users\achafetz\Documents\ICPI\Data"
	global folder "All Site Dataset ${datestamp}"
	*unzipfile "$folder"
	
*convert files from txt to dta for appending and keep only TX_CURR and TX_NEW (total numerator)
	cd "C:\Users\achafetz\Documents\ICPI\Data\All Site Dataset ${datestamp}"
	fs 
	foreach f in `r(files)'{
		local ou "`=subinstr("`=subinstr("`f'","icpi_factview_site_by_im_","",.)'","_20161115_q4v1_2.txt","",.)'"
	
		}
		*end
*append all ou files together
	clear
	fs *.dta
	append using `r(files)', force
	
*save all site file
	save "$output\ICPIFactView_ALLTX_Site_IM${datestamp}", replace
	
***


*** SETUP ***

*define date for Fact View Files
	global datestamp "20161115_v2"

*set today's date for saving
	global date: di %tdCCYYNNDD date(c(current_date), "DMY")

*import/open data
	import delimited "$fvdata/All Site Dataset 20161115_Q4v1_2/ICPI_FactView_Site_By_IM_Nigeria_20161115_Q4v1_2.txt", clear

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
	*PMTCD_ARV
		gen pmtct_arv = fy2016apr if indicator=="PMTCD_ARV" & disaggregate=="Total Numerator" & numeratordenom=="N"
	*PMTCD_EID
		gen pmtct_eid = fy2016apr if indicator=="PMTCD_EID" & disaggregate=="Total Numerator" & numeratordenom=="N"
	*PMTCD_STAT
		gen pmtct_stat = fy2016apr if indicator=="PMTCD_STAT" & disaggregate=="Total Numerator" & numeratordenom=="N"
	*PMTCD_STAD_POS
		gen pmtct_stat_pos = fy2016apr if indicator=="PMTCD_STAT" & disaggregate=="Known/New" & numeratordenom=="N"
	*PP_PREV
		gen pp_prev = fy2016apr if indicator=="PP_PREV" & disaggregate=="Total Numerator" & numeratordenom=="N"
	*TX_CURR <1 [=EID]
		gen tx_curr_u1_fy18 = fy2016apr if indicator=="PMTCD_EID" & disaggregate=="Total Numerator" & numeratordenom=="N"
	*TX_CURR 1-14
		gen tx_curr_1to14 = fy2016apr if indicator=="TX_CURR" & disaggregate=="Age/Sex" & inlist(age, "01-04", "05-14") & numeratordenom=="N"
	*TX_CURR 15+
		gen tx_curr_o15 = fy2016apr if indicator=="TX_CURR" & disaggregate=="Age/Sex" & inlist(age, "15-19", "20+") & numeratordenom=="N"
	*VMMC_CIRC
		gen vmmc_circ = fy2016apr if indicator=="VMMC_CIRC" & disaggregate=="Total Numerator" & numeratordenom=="N"

* aggregate up to PSNU level
	drop fy*
	tostring mechanismid, replace
	ds *, not(type string)
	foreach v in `r(varlist)'{
		rename `v' val_`v'
		}
	*end
	
* create a unique id by type (facility, community, military)
			* demarcated by f_, c_, and m_ at front
			* military doesn't have a unique id so script uses mechanism uid
		qui: tostring type*, replace //in OUs with no data, . is recorded and 
			* seen as numeric, so need to first string variables 
		qui: gen fcm_uid = ""
			replace fcm_uid = "f_" + facilityuid if facilityuid!=""
			replace fcm_uid = "c_" + communityuid if facilityuid=="" &  ///
				(typecommunity =="Y" | communityuid!="") & typemilitary!="Y"
			replace fcm_uid = "m_" + mechanismuid if typemilitary=="Y" 
		
		
*collapse
	collapse (sum) val_*, by(operatingunit psnu psnuuid fcm_uid indicatortype mechanismid)
*destring mechanism
	destring mechanismid, replace
*update all partner and mech to offical names (based on FACTS Info)
	capture confirm file "$output/officialnames.dta"
	if _rc{
		preserve
		run "$dofiles/05_datapack_officialnames"
		restore
		}
		*end
	merge m:1 mechanismid using "$output/officialnames.dta", ///
		update replace nogen keep(1 3 4 5) //keep all but non match from using

*sort
	sort operatingunit indicatortype mechanismid psnu fcm_uid
	
*distro
	ds val_*
	foreach v in `r(varlist)' {
		egen `v'_tot = total(`v'), by(operatingunit psnuuid)
		gen `=subinstr("`v'", "val_","D_",.)'_fy18 = `v'/`v'_tot
		}
		*end
	drop val_*
	
*clean up
	recode D_* (0 = .)
	destring mechanismid, replace
	local varlist D_tx_curr_1to14_fy18 ///
		D_tx_curr_o15_fy18	D_tx_curr_u1_fy18 D_pmtct_arv_fy18 ///
		D_pmtct_eid_fy18 D_pmtct_stat_fy18 D_pmtct_stat_pos_fy18 ///
		D_vmmc_circ_fy18	D_htc_tst_fy18	D_htc_tst_pitc_fy18	D_htc_tst_vct_fy18 ///
		D_htc_tst_cbtc_fy18	D_ovc_serv_fy18	D_kp_prev_pwid_fy18 ///
		D_kp_prev_msmtg_fy18 D_kp_prev_fsw_fy18	D_pp_prev_fy18 ///
		D_kp_mat_fy18
	foreach v in `varlist'{
		capture confirm variable `v'
		if _rc gen `v' = .
		}
		*end
	gen placeholder = .
	order operatingunit psnuuid psnu placeholder mechanismid indicatortype `varlist'
	sort operatingunit psnu mechanismid indicatortype

*export
	export excel using "$dpexcel/Global_Sites_${date}.xlsx", ///
		sheet("`ou'") firstrow(variables) sheetreplace
