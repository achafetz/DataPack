**   Data Pack
**   COP FY17
**   Aaron Chafetz
**   Purpose: generate HTC output for Excel based Data Pack at SNU level
**   Date: December 1, 2016
**   Updated: 

*** SETUP ***

*define date for Fact View Files
	global datestamp "20161115_v2"
	
*set today's date for saving
	global date: di %tdCCYYNNDD date(c(current_date), "DMY")

*open data
	use "$fvdata/ICPI_FactView_PSNU_IM_${datestamp}.dta", clear
	
*clean
	rename ïregion region
	
*just HTC
	keep if (indicator=="HTC_TST" & disaggregate=="ServiceDeliveryPoint/Result") | ///
		(indicator=="PLHIV" & disaggregate=="Total Numerator")
	
	gen plhiv = fy2016apr if indicator=="PLHIV" & disaggregate=="Total Numerator"
	gen htc_tst_spd_ctclinic_neg = fy2016apr if indicator=="HTC_TST" & disaggregate=="ServiceDeliveryPoint/Result" & resultstatus=="Negative" & otherdisaggregate=="HIV Care and Treatment Clinic" & numeratordenom=="N"
	gen htc_tst_spd_home_neg = fy2016apr if indicator=="HTC_TST" & disaggregate=="ServiceDeliveryPoint/Result" & resultstatus=="Negative" & otherdisaggregate=="Home-based" & numeratordenom=="N"
	gen htc_tst_spd_inpatient_neg = fy2016apr if indicator=="HTC_TST" & disaggregate=="ServiceDeliveryPoint/Result" & resultstatus=="Negative" & otherdisaggregate=="Inpatient" & numeratordenom=="N"
	gen htc_tst_spd_mobile_neg = fy2016apr if indicator=="HTC_TST" & disaggregate=="ServiceDeliveryPoint/Result" & resultstatus=="Negative" & otherdisaggregate=="Mobile" & numeratordenom=="N"
	gen htc_tst_spd_outpatient_neg = fy2016apr if indicator=="HTC_TST" & disaggregate=="ServiceDeliveryPoint/Result" & resultstatus=="Negative" & otherdisaggregate=="Outpatient Department" & numeratordenom=="N"
	gen htc_tst_spd_sti_neg = fy2016apr if indicator=="HTC_TST" & disaggregate=="ServiceDeliveryPoint/Result" & resultstatus=="Negative" & otherdisaggregate=="Sexually Transmitted Infections" & numeratordenom=="N"
	gen htc_tst_spd_tb_neg = fy2016apr if indicator=="HTC_TST" & disaggregate=="ServiceDeliveryPoint/Result" & resultstatus=="Negative" & otherdisaggregate=="Tuberculosis" & numeratordenom=="N"
	gen htc_tst_spd_vtcalone_neg = fy2016apr if indicator=="HTC_TST" & disaggregate=="ServiceDeliveryPoint/Result" & resultstatus=="Negative" & otherdisaggregate=="Voluntary Counseling & Testing standalone" & numeratordenom=="N"
	gen htc_tst_spd_vtccoloc_neg = fy2016apr if indicator=="HTC_TST" & disaggregate=="ServiceDeliveryPoint/Result" & resultstatus=="Negative" & otherdisaggregate=="Voluntary Counseling & Testing co-located" & numeratordenom=="N"
	gen htc_tst_spd_vmmc_neg = fy2016apr if indicator=="HTC_TST" & disaggregate=="ServiceDeliveryPoint/Result" & resultstatus=="Negative" & otherdisaggregate=="Voluntary Medical Male Circumcision" & numeratordenom=="N"
	gen htc_tst_spd_oth_neg = fy2016apr if indicator=="HTC_TST" & disaggregate=="ServiceDeliveryPoint/Result" & resultstatus=="Negative" & otherdisaggregate=="Other Service Delivery Point" & numeratordenom=="N"
	gen htc_tst_spd_ctclinic_pos = fy2016apr if indicator=="HTC_TST" & disaggregate=="ServiceDeliveryPoint/Result" & resultstatus=="Positive" & otherdisaggregate=="HIV Care and Treatment Clinic" & numeratordenom=="N"
	gen htc_tst_spd_home_pos = fy2016apr if indicator=="HTC_TST" & disaggregate=="ServiceDeliveryPoint/Result" & resultstatus=="Positive" & otherdisaggregate=="Home-based" & numeratordenom=="N"
	gen htc_tst_spd_inpatient_pos = fy2016apr if indicator=="HTC_TST" & disaggregate=="ServiceDeliveryPoint/Result" & resultstatus=="Positive" & otherdisaggregate=="Inpatient" & numeratordenom=="N"
	gen htc_tst_spd_mobile_pos = fy2016apr if indicator=="HTC_TST" & disaggregate=="ServiceDeliveryPoint/Result" & resultstatus=="Positive" & otherdisaggregate=="Mobile" & numeratordenom=="N"
	gen htc_tst_spd_outpatient_pos = fy2016apr if indicator=="HTC_TST" & disaggregate=="ServiceDeliveryPoint/Result" & resultstatus=="Positive" & otherdisaggregate=="Outpatient Department" & numeratordenom=="N"
	gen htc_tst_spd_sti_pos = fy2016apr if indicator=="HTC_TST" & disaggregate=="ServiceDeliveryPoint/Result" & resultstatus=="Positive" & otherdisaggregate=="Sexually Transmitted Infections" & numeratordenom=="N"
	gen htc_tst_spd_tb_pos = fy2016apr if indicator=="HTC_TST" & disaggregate=="ServiceDeliveryPoint/Result" & resultstatus=="Positive" & otherdisaggregate=="Tuberculosis" & numeratordenom=="N"
	gen htc_tst_spd_vtcalone_pos = fy2016apr if indicator=="HTC_TST" & disaggregate=="ServiceDeliveryPoint/Result" & resultstatus=="Positive" & otherdisaggregate=="Voluntary Counseling & Testing standalone" & numeratordenom=="N"
	gen htc_tst_spd_vtccoloc_pos = fy2016apr if indicator=="HTC_TST" & disaggregate=="ServiceDeliveryPoint/Result" & resultstatus=="Positive" & otherdisaggregate=="Voluntary Counseling & Testing co-located" & numeratordenom=="N"
	gen htc_tst_spd_vmmc_pos = fy2016apr if indicator=="HTC_TST" & disaggregate=="ServiceDeliveryPoint/Result" & resultstatus=="Positive" & otherdisaggregate=="Voluntary Medical Male Circumcision" & numeratordenom=="N"
	gen htc_tst_spd_oth_pos = fy2016apr if indicator=="HTC_TST" & disaggregate=="ServiceDeliveryPoint/Result" & resultstatus=="Positive" & otherdisaggregate=="Other Service Delivery Point" & numeratordenom=="N"
	gen htc_tst_spd_tot_pos = fy2016apr if indicator=="HTC_TST" & disaggregate=="ServiceDeliveryPoint/Result" & resultstatus=="Positive" & numeratordenom=="N"

	
* collapse up to PSNU level
	drop mechanismid fy*
	ds *, not(type string)
	collapse (sum) `r(varlist)', by(operatingunit psnu psnuuid)

* rename 
	rename psnu snulist


*sort by PLHIV
	gsort + operatingunit - plhiv + snulist

*drop plhiv (only needed for ordering)
	drop plhiv
	
*replace zero values with missing & clear mil data, but keep as row placeholder for their entry
	ds *, not(type string)
	foreach v in `r(varlist)' {
		replace `v' = . if `v'==0
		replace `v' = . if strmatch(snulist, "*_Military*")
		}
		*end
*export global list to data pack template
	export excel using "$dpexcel/Global_PSNU_${date}.xlsx", ///
		sheet("HTC Indicator Table") firstrow(variables) sheetreplace
