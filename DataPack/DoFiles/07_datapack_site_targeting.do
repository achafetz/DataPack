**   Data Pack
**   COP FY17
**   Aaron Chafetz
**   Purpose: generate output for Excel site allocation of Data Pack targets
**   Date: January 3, 2017
**   Updated: 1/19/17


*define date for Fact View Files
	global datestamp "20161115_v2"

*set today's date for saving
	global date: di %tdCCYYNNDD date(c(current_date), "DMY")

/*
*loop over all ous
	cd "$fvdata/All Site Dataset 20161115_Q4v1_2/"
	fs "*.txt"
	foreach f in `r(files)'{
		di "`f'"
		}
	foreach ou in 
*/
	
	
*import/open data
	import delimited "$fvdata/All Site Dataset 20161230_Q4v2_1/ICPI_FactView_Site_By_IM_Malawi_20161230_Q4v2_1.txt", clear

*clean
	rename ïorgunituid orgunituid
	run "$dofiles/06_datapack_dup_snus"
	replace psnu = "[no associated SNU]" if psnu==""
	replace mechanismid = 0 if mechanismid==1 //keep just one dedup mechanism

*adjust prioritizations
	rename fy17snuprioritization snuprioritization
	drop fy16snuprioritization

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

* string mech and rename variables for aggregation
	tostring mechanismid, replace
*drop excess
	drop if psnu == "[no associated SNU]"
	drop fy2015q2-fy2016q4 fy2017_targets
* save
	save "$output/temp_site_Malawi", replace
	
* gen vars for distro tabs (see 01_datapack_outputs)
	// output generated in Data Pack template (POPsubset sheet)
	// updated 1/19
	gen tx_new = fy2016apr if indicator=="TX_NEW" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen tx_curr = fy2016apr if indicator=="TX_CURR" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen pmtct_stat = fy2016apr if indicator=="PMTCT_STAT" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen pmtct_stat_new_n = fy2016apr if indicator=="PMTCT_STAT" & disaggregate=="Known/New" & sex=="Newly Identified" & numeratordenom=="N"
	gen pmtct_arv = fy2016apr if indicator=="PMTCT_ARV" & disaggregate=="MaternalRegimenType"& inlist(otherdisaggregate, "Life-long ART Already", "Life-long ART New", "Triple-drug ARV") & numeratordenom=="N"
	gen pmtct_eid = fy2016apr if indicator=="PMTCT_EID" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen tx_new_u1 = fy2016apr if indicator=="TX_NEW" & disaggregate=="Age/Sex" & age=="<01" & numeratordenom=="N"
	gen tx_new_u15 = fy2016apr if indicator=="TX_NEW" & disaggregate=="Age/Sex" & inlist(age, "<01", "01-04", "05-14") & numeratordenom=="N"
	gen tx_curr_u15 = fy2016apr if indicator=="TX_CURR" & disaggregate=="Age/Sex" & inlist(age, "<01", "01-04", "05-14") & numeratordenom=="N"
	gen tb_stat = fy2016apr if indicator=="TB_STAT" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen tb_art = fy2016apr if indicator=="TB_ART" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen htc_tst_u15 = fy2016apr if indicator=="HTC_TST" & disaggregate=="Age/Sex/Result" & inlist(age, "<01", "01-04", "05-09","10-14") & numeratordenom=="N"
	gen htc_tst_o15 = fy2016apr if indicator=="HTC_TST" & disaggregate=="Age/Sex/Result" & inlist(age, "15-19", "20-24", "25-49", "50+") & numeratordenom=="N"
	gen htc_tst = fy2016apr if indicator=="HTC_TST" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen vmmc_circ = fy2016apr if indicator=="VMMC_CIRC" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen ovc_serv = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen ovc_serv_u18 = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & inlist(age, "01-04", "05-09", "10-14", "15-17") & numeratordenom=="N"
	gen kp_prev_fsw = fy2016apr if indicator=="KP_PREV" & disaggregate=="KeyPop" & otherdisaggregate=="FSW" & numeratordenom=="N"
	gen kp_prev_msmtg = fy2016apr if indicator=="KP_PREV" & disaggregate=="KeyPop" & otherdisaggregate=="MSM/TG" & numeratordenom=="N"
	gen kp_prev_pwid = fy2016apr if indicator=="KP_PREV" & disaggregate=="KeyPop"& inlist(otherdisaggregate, "Female PWID", "Male PWID") & numeratordenom=="N"
	gen kp_prev = fy2016apr if indicator=="KP_PREV" & disaggregate=="KeyPop" & numeratordenom=="N"

	
	*fix TX_CURR disaggs
	/*J. Houston
	- HTC_TST: fine disags for most countries; fine + coarse for Haiti, Mozambique, Nigeria, South Africa, Tanzania, Uganda, Ukraine, and (coarse) Vietnam
	- TX_CURR: fine disags for all countries except (coarse) Mozambique and Vietnam, (fine + coarse)  Uganda and South Africa */
	foreach v in htc_tst_u15 htc_tst_o15{
		replace `v' = . if inlist(operatingunit, "Haiti", "Mozambique", ///
			"Nigeria", "South Africa", "Tanzania", "Uganda", "Ukraine", "Vietnam")
		}
		*end
	replace htc_tst_u15 = fy2016apr if indicator=="HTC_TST" & inlist(disaggregate, "Age/Sex/Result", "Age/Sex Aggregated/Result") & inlist(age, "<01", "01-04", "05-09","10-14", "<15") & numeratordenom=="N" & inlist(operatingunit, "Haiti", "Mozambique", "Nigeria", "South Africa", "Tanzania", "Uganda", "Ukraine")
	replace htc_tst_u15 = fy2016apr if indicator=="HTC_TST" & disaggregate=="Age/Sex Aggregated/Result" & age=="<15" & numeratordenom=="N" & operatingunit=="Vietnam"
	replace htc_tst_o15 = fy2016apr if indicator=="HTC_TST" & inlist(disaggregate, "Age/Sex/Result", "Age/Sex Aggregated/Result") & inlist(age, "15-19", "20-24", "25-49", "50+", ">15") & numeratordenom=="N" & inlist(operatingunit, "Haiti", "Mozambique", "Nigeria", "South Africa", "Tanzania", "Uganda", "Ukraine")
	replace htc_tst_o15 = fy2016apr if indicator=="HTC_TST" & disaggregate=="Age/Sex Aggregated/Result" & age==">15" & numeratordenom=="N" & operatingunit=="Vietnam"
	replace tx_curr_u15 = . if inlist(operatingunit, "Mozambique", "South Africa", "Uganda", "Vietnam")
	replace tx_curr_u15 = fy2016apr if indicator=="TX_CURR" & inlist(disaggregate, "Age/Sex", "Age/Sex Aggregated", "Age/Sex, Aggregated") & inlist(age, "01-04", "05-14", "01-14") & numeratordenom=="N" & inlist(operatingunit, "Uganda", "South Africa")
	replace tx_curr_u15 = fy2016apr if indicator=="TX_CURR" & inlist(disaggregate, "Age/Sex Aggregated", "Age/Sex, Aggregated") & age=="01-14" & numeratordenom=="N" & inlist(operatingunit, "Mozambique", "Vietnam")

*add common name
	drop fy*
	ds *, not(type string)
	foreach v in `r(varlist)'{
		rename `v' val_`v'
		}
	*end
	
* drop if no data in row
	egen data = rownonmiss(val_*)
	drop if data==0 & mechanismid!="0"
	drop data
	
*collapse
	collapse (sum) val_*, by(operatingunit psnu psnuuid orgunituid indicatortype mechanismid)

*sort
	sort operatingunit indicatortype mechanismid psnu orgunituid
	
*distro
	ds val_*
	foreach v in `r(varlist)' {
		egen `v'_tot = total(`v'), by(operatingunit psnuuid)
		gen `=subinstr("`v'", "val_","S_",.)'_fy18 = `v'/`v'_tot
		}
		*end
	drop val_*
	
*clean up
	recode S_* (0 = .)
	destring mechanismid, replace
	order operatingunit psnuuid psnu orgunituid mechanismid indicatortype
	sort operatingunit psnu orgunituid mechanismid  indicatortype	

*export
	*export excel using "$dpexcel/Global_Sites_${date}.xlsx", ///
		*sheet("`ou'") firstrow(variables) sheetreplace
	export excel using "$dpexcel/Global_Site_${date}.xlsx", ///
		firstrow(variables) sheet("Site Allocation") sheetreplace
