import delimited "C:\Users\achafetz\Documents\ICPI\Data\ICPI_FactView_PSNU_20170922_v2_1.txt",clear

keep if operatingunit == "Malawi" & typemilitary != "Y"

drop ïregion regionuid operatingunituid countryname dataelementuid indicatortype ///
	snu1 snu1uid fy16snuprioritizationdisaggregate categoryoptioncombouid ///
	categoryoptioncomboname fy2015q2- fy2016apr

egen fy2017cum = rowtotal(fy2017q*)
		replace fy2017cum = . if fy2017cum==0
		*for semi annual indicators
		local i 2 //change at Q4
		replace fy2017cum = fy2017q`i' if inlist(indicator, "KP_PREV", ///
			"PP_PREV", "OVC_HIVSTAT", "OVC_SERV", "TB_ART",  ///
			"TB_STAT", "TX_TB") | inlist(indicator, "GEND_GBV", "PMTCT_FO", ///
			"TX_RET", "KP_MAT")
		*for quarterly snapshot indicators
		local i 3 //change every quarter
		replace fy2017cum = fy2017q`i' if indicator=="TX_CURR"
		*clean up
		replace fy2017cum =. if fy2017cum==0

table modality if ///
	indicator == "HTS_TST_POS" ///
	& inlist(standardizeddisaggregate, "Modality/MostCompleteAgeDisagg") ///
	, ///
	c(sum fy2017cum) format(%12.0fc)
	