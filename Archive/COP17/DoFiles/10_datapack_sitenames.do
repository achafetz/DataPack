**   Data Pack
**   COP FY17
**   Aaron Chafetz
**   Purpose: add site names to UIDs
**   Date: January 25, 2017
**   Updated: 

/* NOTES
	- Data source: Site List [A. Agedew], Jan 15, 2017

*/
********************************************************************************



*import/open data
	capture confirm file "$output/sitenames20170125.dta"
		if _rc{
			preserve
			import delimited using "$fvdata/SiteList_20170125.txt", clear
			*clean
				rename ïorgunituid orgunituid
				replace orgunitname="DON Slovyansk City Hospital 'Lenin' (Temp Regional AIDS Center)" if orgunituid=="z4W6nb87lYY" //issue with site name, didn't match
				gen n = 1
				collapse n, by(orgunituid orgunitname)
				drop n
			save "$output/sitenames20170125.dta", replace
			restore
		}
	*end

*merge
	merge m:1 orgunituid using "$output/sitenames20170125.dta", ///
		nogen keep(1 3 4 5) //keep all but non match from using
	replace orgunitname = "[" + orgunituid + "]" if orgunitname==""
	
*clean
	order orgunitname, after(orgunituid)
