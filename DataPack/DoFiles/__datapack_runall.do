**   Data Pack
**   COP FY17
**   Aaron Chafetz
**   Purpose: run through all do files
**   Date: January 10, 2017
**	 Updated: 1/19/17

*** RUN ALL DO FILES FOR DATA PACK ***

/* Dependent external files: 
	- ICPI Fact View NAT_SUBNAT Q4v2.2
	- ICPI Fact View PSNU Q4v2.2
	- ICPI Fact View PSNU by IM Q4v2.2
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
	
** SITE & DISAGG DISTRIBUTION TOOL **
	*07 - setup distribution data for site targeting (mirrors 04)
		*run "$dofiles/07_datapack_site_targeting"
