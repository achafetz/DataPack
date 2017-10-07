
import delimited C:\Users\achafetz\Downloads\PSNU_IM_Ethiopia_20170221\PSNU_IM_Ethiopia_20170221.txt

replace psnu= snu2 if psnu!="_Military Ethiopia"
replace psnuuid = snu2uid if psnu!="_Military Ethiopia"

replace fy16snuprioritization = "" 
replace fy17snuprioritization = ""

drop snu2*

save "C:\Users\achafetz\Downloads\temp_eth.dta", replace

import delimited "$fvdata/ICPI_FactView_PSNU_IM_${datestamp}.txt", clear

drop if operatingunit=="Ethiopia"
append using "C:\Users\achafetz\Downloads\temp_eth.dta"

save "$fvdata/ICPI_FactView_PSNU_IM_${datestamp}.dta", replace


use "C:\Users\achafetz\Downloads\temp_eth.dta", clear

collapse fy2*, fast by(ïregion-typemilitary indicator-coarsedisaggregate)

save "C:\Users\achafetz\Downloads\temp_eth.dta", replace

import delimited "$fvdata/ICPI_FactView_PSNU_${datestamp}.txt", clear

drop if operatingunit=="Ethiopia"
append using "C:\Users\achafetz\Downloads\temp_eth.dta"
save "$fvdata/ICPI_FactView_PSNU_${datestamp}.dta", replace
