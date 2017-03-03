**   Data Pack
**   COP FY17
**   Aaron Chafetz
**   Purpose: compile Site ouput & export
**   Date: March 2, 2017
**   Updated: 3/2/17

*open and merge
	use "$output/temp_site_${ou_ns}_alloc", clear
	merge 1:1 combo using "$output/temp_site_${ou_ns}_disaggs", nogen

*sort
	sort operatingunit psnu orgunituid mechanismid indicatortype	

*delete older version of the output
	fs "$dpexcel/${ou_ns}_Site*.xlsx"
	foreach f in `r(files)'{
		erase "$dpexcel/`f'"
		}
		*end
*export
	export excel using "$dpexcel/${ou_ns}_Site_${date}.xlsx", ///
		firstrow(variables) sheet("Site Allocation") sheetreplace

*erase site temp files
	clear
	fs "temp_site_${ou_ns}*.dta"
	foreach f in `r(files)'{
		erase "$output/`f'"
		}
		*end
