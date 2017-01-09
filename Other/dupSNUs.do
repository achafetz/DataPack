** Identifying Duplicated SNUs in the Fact View Dataset
** Aaron Chafetz
** Date: Jan 6, 2017

use "C:\Users\achafetz\Documents\ICPI\Data\ICPI_FactView_PSNU_20161115_v2.dta"

keep operatingunit psnu psnuuid

gen n = 1

collapse (max) n, by(operatingunit psnu psnuuid)

sort operatingunit psnu

gen flag = 1 if psnu==psnu[_n-1] | psnu==psnu[_n+1]

br if flag==1

****

use "C:\Users\achafetz\Documents\ICPI\Data\ICPI_FactView_NAT_SUBNAT_20161115_v2.dta", clear

append using "C:\Users\achafetz\Documents\ICPI\Data\ICPI_FactView_PSNU_20161115_v2.dta", force

keep operatingunit psnu psnuuid

gen n = 1

collapse (max) n, by(operatingunit psnu psnuuid)

sort operatingunit psnu

gen flag = 1 if psnu==psnu[_n-1] | psnu==psnu[_n+1]

br if flag==1



****

preserve
clear
input str11 psnuuid	dup
"Oz0qJ8kNbKx"	1
"gxf4z0agDsk"	1
"dASd72VnJPh"	1
"dOQ8r7iwZvS"	1
"ONUWhpgEbVk"	1
"RVzTHBO9fgR"	1
"EzsXkY9WARj"	1
"URj9zYi533e"	1
"KN2TmcAVqzi"	1
"bDoKaxNx2Xb"	1
"J4yYjIqL7mG"	1
"oygNEfySnMl"	1
"HlABmTwBpu6"	1
"h61xiVptz4A"	1
"HHDEeZbVEaw"	1
"HhCbsjlKoWA"	1
"ITdnyCiBvz7"	1
"lC1wneS1GR5"	1
"IxeWi5YG9lE"	1
"dzjXm8e1cNs"	1
"D47MUIzTapM"	1
"vpCKW3gWNhV"	1
"kxsmKGMZ5QF"	1
"mVuyipSx9aU"	1
"FjiNyXde6Ae"	1
"xmRjV3Gx1H6"	1
end
save "$data/temp_dups"

restore

merge m:1 psnuuid using "$data/temp_dups"

keep if dup==1

export excel using "$dpexcel/Dup_PSNU_NAT_SUBNAT_${date}.xlsx", ///
		firstrow(variables)


