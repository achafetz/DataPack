**   Data Pack
**   COP FY17
**   Aaron Chafetz
**   Purpose: run through all do files
**   Date: January 10, 2017
**	 Updated: 2/1317

*** RUN ALL DO FILES FOR DATA PACK ***

/* Dependent external files: 
	- ICPI Fact View NAT_SUBNAT Q4v2.2
	- ICPI Fact View PSNU Q4v2.2
	- ICPI Fact View PSNU by IM Q4v2.2
	- ICPI Fact View Site by IM Q4v2.1
	- ICPI MCAD Site Q4v2.1 [TX_CURR, TX_NEW, HTC_TST]
	- FACTS Info Official Names (derived from COP Matrix)
	- COP17 Clusters (submitted by SI advisors)
	*/	
	
** SETUP **
	*00 Initialize folder structure
		cd C:\Users\achafetz\Documents\GitHub\ICPI\DataPack\DoFiles
		run 00_datapack_initialize
	
** DATA PACK **
	*01 setup data to populate DATIM Indicator Table tab
		run "$dofiles/01_datapack_output" 
	*02 setup data to populate Key Ind Trends tab
		run "$dofiles/02_datapack_output_keyind"  
	*03 collapse to unique IM list
		run "$dofiles/03_datapack_im_list"
	*04 setup distribution data for IM targeting
		run "$dofiles/04_datapack_im_targeting"
bob	
** SITE & DISAGG DISTRIBUTION TOOL **
	*OUs to create site datasets [Tanzania removed] 
	/* "Angola" "Asia Regional Program" "Botswana" "Burma" "Burundi" "Cambodia" "Cameroon" "Caribbean Region"
			"Central America Region" "Central Asia Region"
			"Cote d'Ivoire" "Democratic Republic of the Congo" 
			"Dominican Republic" "Ethiopia" "Ghana" "Guyana"
			"Haiti" "India" "Indonesia" "Kenya" "Lesotho" "Malawi" "Mozambique" "Namibia" "Nigeria"
			"Papua New Guinea" "Rwanda" "South Africa"
			"South Sudan" "Swaziland" "Uganda"
			"Ukraine" "Vietnam" "Zambia" 
	*/
	set tr off
		#delimit ;
		local oulist `"  "Angola" "Asia Regional Program" "Botswana" "Burma" "Burundi" "Cambodia" "Cameroon" "Caribbean Region"
			"Central America Region" "Central Asia Region"
			"Cote d'Ivoire" "Democratic Republic of the Congo" 
			"Dominican Republic" "Ethiopia" "Ghana" "Guyana"
			"Haiti" "India" "Indonesia" "Kenya" "Lesotho" "Malawi" "Mozambique" "Namibia" "Nigeria"
			"Papua New Guinea" "Rwanda" "South Africa"
			"South Sudan" "Swaziland" "Uganda"
			"Ukraine" "Vietnam" "Zambia"   "' ;
		#delimit cr	
	
	foreach ou of local oulist{
	
	*globals
		global ou "`ou'"
		global ou_ns = subinstr(subinstr("`ou'", " ","",.),"'","",.)
		di "$ou_ns"
	*07 - setup distribution data for site targeting (mirrors 04)
		do "$dofiles/07_datapack_site_targeting"
	*08 - setup disagdistribution by indicator, site, IM, and type
		do "$dofiles/08_datapack_site_disaggs"
		
		}
		*end
