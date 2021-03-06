**   Data Pack
**   COP FY17
**   Aaron Chafetz
**   Purpose: generate output for Excel site allocation of Data Pack targets
**   Date: January 3, 2017
**   Updated: 3/2/17

*******************************
/*
*define OU remove after piloting
	global ou "Tanzania"
	global ou_ns = subinstr(subinstr("${ou}", " ","",.),"'","",.)
*/
*******************************

*define date for Fact View Files
	global datestamp "20161230_Q4v2_1"

*set today's date for saving
	global date: di %tdCCYYNNDD date(c(current_date), "DMY")

*import/open data
	import delimited "$fvdata/All Site Dataset 20161230_Q4v2_1/ICPI_FactView_Site_By_IM_${ou_ns}_${datestamp}.txt", clear
	rename ïorgunituid orgunituid

*********************
* MCAD file for aggregated <15/15+
* TODO
*import
	preserve
	import delimited "$fvdata/All MCAD Site Dataset ${datestamp}/ICPI_FactView_MCAD_Site_By_IM_${ou_ns}_${datestamp}.txt", clear
	tempfile temp_mcad
	save "`temp_mcad'"
	restore

*drop Fact View duplicatoin
	drop if (indicator=="HTC_TST" & disaggregate=="Age/Sex Aggregated") | ///
		(inlist(indicator, "TX_CURR", "TX_NEW") & ///
		disaggregate=="Age/Sex Aggregated")
*append MCAD file on
	append using "`temp_mcad'", force

*********************

*clean
	*run "$dofiles/06_datapack_dup_snus"
	*drop if operatingunit!="$ou"
	replace psnu = "[no associated SNU]" if psnu==""
	replace mechanismid = 0 if mechanismid==1 //keep just one dedup mechanism

*adjust prioritizations
	rename fy17snuprioritization snuprioritization
	drop fy16snuprioritization

*update all partner and mech to offical names (based on FACTS Info)
	run "$dofiles/05_datapack_officialnames"

*merge facility names onto dataset
	run "$dofiles/10_datapack_sitenames"

* string mech and rename variables for aggregation
	tostring mechanismid, replace

*drop excess
	drop if psnu == "[no associated SNU]"
	drop fy2015q2-fy2016apr

* save
	save "$output/temp_site_${ou_ns}_base", replace

* gen vars for distro tabs (see 01_datapack_outputs)
	// output generated in Data Pack template (POPsubset sheet)
	// updated 1/26
	gen tx_new = fy2017_targets if indicator=="TX_NEW" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen tx_curr = fy2017_targets if indicator=="TX_CURR" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen pmtct_stat_D = fy2017_targets if indicator=="PMTCT_STAT" & disaggregate=="Total Denominator" & numeratordenom=="D"
	gen pmtct_stat = fy2017_targets if indicator=="PMTCT_STAT" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen pmtct_stat_new = fy2017_targets if indicator=="PMTCT_STAT" & disaggregate=="Known/New" & otherdisaggregate=="Newly Identified" & numeratordenom=="N"
	gen pmtct_arv = fy2017_targets if indicator=="PMTCT_ART" & disaggregate=="MaternalRegimenType2017"& inlist(otherdisaggregate, "Life-long ART Already", "Life-long ART New") & numeratordenom=="N"
	gen pmtct_eid = fy2017_targets if indicator=="PMTCT_EID" & disaggregate=="InfantTest" & numeratordenom=="N"
	gen tx_new_u1 = fy2017_targets if indicator=="TX_NEW" & disaggregate=="Aggregated Age/Sex" & age=="<01" & numeratordenom=="N"
	gen tx_new_u15 = fy2017_targets if indicator=="TX_NEW" & disaggregate=="Aggregated Age/Sex" & age=="<15" & numeratordenom=="N"
	gen tx_curr_u15 = fy2017_targets if indicator=="TX_CURR" & disaggregate=="Aggregated Age/Sex" & age=="<15" & numeratordenom=="N"
	gen tb_stat_D = fy2017_targets if indicator=="TB_STAT" & disaggregate=="Total Denominator" & numeratordenom=="D"
	gen tb_stat = fy2017_targets if indicator=="TB_STAT" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen tb_art = fy2017_targets if indicator=="TB_ART" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen htc_tst_u15 = fy2017_targets if indicator=="HTC_TST" & disaggregate=="Age/Sex Aggregated/Result" & age=="<15" & numeratordenom=="N"
	gen htc_tst_o15 = fy2017_targets if indicator=="HTC_TST" & disaggregate=="Age/Sex Aggregated/Result" & age=="15+"  & numeratordenom=="N"
	gen htc_tst = fy2017_targets if indicator=="HTC_TST" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen vmmc_circ = fy2017_targets if indicator=="VMMC_CIRC" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen ovc_serv = fy2017_targets if indicator=="OVC_SERV" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen ovc_serv_u18 = fy2017_targets if indicator=="OVC_SERV" & disaggregate=="Age/Sex2017" & age=="<18" & numeratordenom=="N"
	gen pp_prev = fy2017_targets if indicator=="PP_PREV" & disaggregate=="Total Numerator" & numeratordenom=="N"


*add common surname
	drop fy*
	ds *, not(type string)
	foreach v in `r(varlist)'{
		rename `v' val_`v'
		}
	*end

* drop if no data in row
	recode val_* (0 = .)
	egen data = rownonmiss(val_*)
	drop if data==0 //& mechanismid!="0"
	drop data

*collapse
	collapse (sum) val_*, by(operatingunit psnu psnuuid orgunituid orgunitname indicatortype mechanismid implementingmechanismname primepartner)

*sort
	sort operatingunit indicatortype mechanismid psnu orgunituid

*distro
	ds val_*
	foreach v in `r(varlist)' {
		egen `v'_tot = total(`v'), by(operatingunit psnuuid)
		gen `=subinstr("`v'", "val_","S_",.)' = `v'/`v'_tot
		}
		*end
	drop val_*

*clean up
	recode S_* (0 = .)
	gen combo = orgunituid + "/" + mechanismid + "/" + indicatortype
	destring mechanismid, replace
	order operatingunit psnuuid psnu orgunituid orgunitname mechanismid implementingmechanismname primepartner indicatortype combo
	sort operatingunit psnu orgunituid mechanismid  indicatortype

	*save
		save "$output/temp_site_${ou_ns}_alloc", replace
