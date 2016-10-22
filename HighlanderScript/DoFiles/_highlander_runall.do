**   Highlander Script
**   COP FY16
**   Aaron Chafetz
**   Purpose: run through all do files
**   Date: October 21, 2016
**   Updated:

** RUN ALL DO FILES FOR HIGHLANDER SCRIPT **

** SETUP **
	* 00 initialize folder structure
		*cd "C:\Users\achafetz\Documents\GitHubICPI\HighlanderScript"
		run DoFiles/00_highlander_initialize
	* 01 create a crosswalk table for highlander age groups and categories
		run DoFiles/01_highlander_agegroups
	*define list of countries to run the highlander script on
		/*global ctrylist angola asiaregional botswana burma burundi cambodia ///
			cameroon caribbeanregion centralamerica centralasia civ ///
			dominicanrepublic drc ethiopia ghana guyana haiti india indonesia ///
			kenya lesotho malawi mozambique namibia nigeria png rwanda ///
			southafrica southsudan swaziland tanzania uganda ukraine ////
			vietnam zambia zimbabwe
		*/
		global ctrylist  ///
			kenya lesotho malawi mozambique namibia nigeria png rwanda ///
			southafrica southsudan swaziland tanzania uganda ukraine ////
			vietnam zambia zimbabwe
	* 02 import data and structure it for use
		run DoFiles/02_highlander_import
		
** HIGHLANDER SCRIPT **
	foreach ou of global ctrylist{
		global ctry `ou'
	* 03 run Highlander Script on countries to make finer/coarse/... selection
		di in yellow "`=upper("${ctry}")': running 03 choice"
		run DoFiles/03_highlander_choice
	* 04 apply selection to full dataset
		di in yellow "`=upper("${ctry}")': running 04 apply"
		run DoFiles/04_highlander_apply
	}
	*end

** APPEND **
	* 05 append files
	
	* 06 add to PNSU file
	
** CLEAN UP **
	* 07 remove temp files
