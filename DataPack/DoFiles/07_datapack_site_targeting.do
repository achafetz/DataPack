**   Data Pack
**   COP FY17
**   Aaron Chafetz
**   Purpose: generate output for Excel based IM targeting Data Pack appendix
**   Date: January 3, 2017
**   Updated: 1/12/17


*define date for Fact View Files
	global datestamp "20161115_v2"

*set today's date for saving
	global date: di %tdCCYYNNDD date(c(current_date), "DMY")

*import/open data
	import delimited "$fvdata/All Site Dataset 20161115_Q4v1_2/ICPI_FactView_Site_By_IM_Malawi_20161115_Q4v1_2.txt", clear

*clean
	rename snuprioritization fy17snuprioritization	//REMOVE AFTER USING v2
	run "$dofiles/06_datapack_dup_snus"
	rename ïregion region
	replace psnu = "[no associated SNU]" if psnu==""

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
	*PMTCDT_STAT_POS
		gen pmtct_stat_pos = fy2016apr if indicator=="PMTCT_STAT" & disaggregate=="Known/New" & numeratordenom=="N"
	*PP_PREV
		gen pp_prev = fy2016apr if indicator=="PP_PREV" & disaggregate=="Total Numerator" & numeratordenom=="N"
	*TX_CURR <1 [=EID]
		gen tx_curr_u1_fy18 = fy2016apr if indicator=="PMTCT_EID" & disaggregate=="Total Numerator" & numeratordenom=="N"
	*TX_CURR 1-14
		gen tx_curr_1to14 = fy2016apr if indicator=="TX_CURR" & disaggregate=="Age/Sex" & inlist(age, "01-04", "05-14") & numeratordenom=="N"
	*TX_CURR 15+
		gen tx_curr_o15 = fy2016apr if indicator=="TX_CURR" & disaggregate=="Age/Sex" & inlist(age, "15-19", "20+") & numeratordenom=="N"
	*VMMC_CIRC
		gen vmmc_circ = fy2016apr if indicator=="VMMC_CIRC" & disaggregate=="Total Numerator" & numeratordenom=="N"
		
	*fix TX_CURR disaggs
	/*J. Houston
	- TX_CURR: fine disags for all countries except (coarse) Mozambique and Vietnam, (fine + coarse)  Uganda and South Africa */
	replace tx_curr_1to14 = . if inlist(operatingunit, "Mozambique", ///
		"South Africa", "Uganda", "Vietnam")
	replace tx_curr_1to14 = fy2016apr if indicator=="TX_CURR" & inlist(disaggregate, "Age/Sex", "Age/Sex Aggregated", "Age/Sex, Aggregated") & inlist(age, "01-04", "05-14", "01-14") & numeratordenom=="N" & inlist(operatingunit, "Uganda", "South Africa")
	replace tx_curr_1to14 = fy2016apr if indicator=="TX_CURR" & inlist(disaggregate, "Age/Sex Aggregated", "Age/Sex, Aggregated") & age=="01-14" & numeratordenom=="N" & inlist(operatingunit, "Mozambique", "Vietnam")
	replace tx_curr_o15 = fy2016apr if indicator=="TX_CURR" & inlist(disaggregate, "Age/Sex", "Age/Sex Aggregated", "Age/Sex, Aggregated") & inlist(age, "15-19", "20+", "15+") & numeratordenom=="N" & inlist(operatingunit, "Uganda", "South Africa")
	replace tx_curr_o15 = fy2016apr if indicator=="TX_CURR" & inlist(disaggregate, "Age/Sex Aggregated", "Age/Sex, Aggregated") & inlist(age, "15+") & numeratordenom=="N" & inlist(operatingunit, "Mozambique", "Vietnam")

* keep just one dedup mechanism
	replace mechanismid = 0 if mechanismid==1

* aggregate up to PSNU level
	drop fy*
	tostring mechanismid, replace
	ds *, not(type string)
	foreach v in `r(varlist)'{
		rename `v' val_`v'
		}
	*end

* drop if no data in row
	egen data = rownonmiss(val_*)
	drop if data==0
	drop data
	
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


*export
	*export excel using "$dpexcel/Global_Sites_${date}.xlsx", ///
		*sheet("`ou'") firstrow(variables) sheetreplace
