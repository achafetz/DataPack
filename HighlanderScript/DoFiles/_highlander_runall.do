**   Highlander Script
**   COP FY16
**   Aaron Chafetz
**   Purpose: run through all do files
**   Date: October 22, 2016
**   Updated:

** RUN ALL DO FILES FOR HIGHLANDER SCRIPT **

** GLOBAL VARIABLES **
	* a: list of countries to run the highlander script on
		global ctrylist angola asiaregional botswana burma burundi cambodia ///
			cameroon caribbeanregion centralamerica centralasia civ ///
			dominicanrepublic drc ethiopia ghana guyana haiti india indonesia ///
			kenya lesotho malawi mozambique namibia nigeria png rwanda ///
			southafrica southsudan swaziland tanzania uganda ukraine ////
			vietnam zambia zimbabwe
	
	* b: datestamp for latest site file
		global datestamp "20160915"
	

** SETUP **
	
	* 00 initialize folder structure
		*cd "C:\Users\achafetz\Documents\GitHubICPI\HighlanderScript"
		di in yellow "   00 initialize"
		run DoFiles/00_highlander_initialize
	* 01 create a crosswalk table for highlander age groups and categories
		di in yellow "   01 generate crosswalk table"
		run DoFiles/01_highlander_agegroups
	
	* 02 import data and structure it for use
		di in yellow "   03 import site data
		run DoFiles/02_highlander_import
		
** HIGHLANDER SCRIPT **
	foreach ou of global ctrylist{
		global ctry `ou'
	* 03 run Highlander Script on countries to make finer/coarse/... selection
		di in yellow "`=upper("${ctry}")':" _newline "   03 choice ...running "
		run DoFiles/03_highlander_choice
	* 04 apply selection to full dataset
		di in yellow "   04 apply  ...running"
		run DoFiles/04_highlander_apply
		di in yellow "             ...saved"
		
	}
	*end

** APPEND **
	* 05 append files
	
	* 06 add to PNSU file
	
** CLEAN UP **
	* 07 remove temp files
