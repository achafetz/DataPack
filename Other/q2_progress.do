**   Q2 Performance Report
**   COP FY17
**   Aaron Chafetz
**   Purpose: create dataset for cumulative results for key indicators that will
**		be evaluated during the COP meetings
**   Date: April 6, 2017
**   Updated: 

*import data
	cd C:\Users\achafetz\Documents\ICPI\Data\
	import delimited "ICPI_FactView_OU_IM_20170324_v2_2.txt", clear
	
*subset to 3 key indicators
	keep if inlist(indicator, "HTS_TST_POS", "TX_NEW", "VMMC_CIRC") ///
		& disaggregate=="Total Numerator"
*aggregate to IM level
	collapse (sum) fy2015q2-fy2017q1, by(operatingunit fundingagency ///
		mechanismid indicator)
		
*create cumulative results
	gen fy2015q2_cum = fy2015q2
	gen fy2015q3_cum = fy2015q2 + fy2015q3
	gen fy2015q4_cum = fy2015apr
	gen fy2016q1_cum = fy2016q1
	gen fy2016q2_cum = fy2016q1 + fy2016q2
	gen fy2016q3_cum = fy2016q2_cum + fy2016q3
	gen fy2016q4_cum = fy2016apr
	gen fy2017q1_cum = fy2017q1

*recode 0 as missing
	recode fy* (0 = .)
	
*copy dataset to excel
	br
