**   Data Pack
**   COP FY17
**   Aaron Chafetz
**   Purpose: remove/combine duplicate SNUs with different UIDs & cluster SNUs
**   Date: January 9, 2017
**   Updated:

** COMBINE/DELETE SNUS **
/*	
List of PSNUs that have the same name but different UIDs
Duplicate list produced from following do file
	https://github.com/achafetz/ICPI/blob/master/Other/dupSNUs.do
N. Barlett identified whether to combine/delete each

| operatingunit                    | psnu                | psnuuid     | action              |
|----------------------------------|---------------------|-------------|---------------------|
| Democratic Republic of the Congo | Mont-Ngafula 2      | Oz0qJ8kNbKx | Combine             |
| Democratic Republic of the Congo | Mont-Ngafula 2      | gxf4z0agDsk | Combine             |
| Ghana                            | Jomoro              | dASd72VnJPh | Combine             |
| Ghana                            | Jomoro              | dOQ8r7iwZvS | Combine             |
| Nigeria                          | eb Abakaliki        | EzsXkY9WARj | Combine             |
| Nigeria                          | eb Abakaliki        | URj9zYi533e | Combine             |
| Nigeria                          | eb Afikpo North     | KN2TmcAVqzi | Combine             |
| Nigeria                          | eb Afikpo North     | bDoKaxNx2Xb | Combine             |
| Nigeria                          | en Enugu South      | HHDEeZbVEaw | Combine             |
| Nigeria                          | en Enugu South      | HhCbsjlKoWA | Combine             |
| Nigeria                          | im Ezinihitte       | IxeWi5YG9lE | Combine             |
| Nigeria                          | im Ezinihitte       | dzjXm8e1cNs | Combine             |
| Nigeria                          | im Owerri Municipal | kxsmKGMZ5QF | Combine             |
| Nigeria                          | im Owerri Municipal | mVuyipSx9aU | Combine             |
| Nigeria                          | im Owerri North     | FjiNyXde6Ae | Combine             |
| Nigeria                          | im Owerri North     | xmRjV3Gx1H6 | Combine             |
| Haiti                            | ValliÃ¨res          | ONUWhpgEbVk | Keep                |
| Haiti                            | ValliÃ¨res          | RVzTHBO9fgR | Delete (Blank)      |
| Nigeria                          | eb Ebonyi           | J4yYjIqL7mG | Keep                |
| Nigeria                          | eb Ebonyi           | oygNEfySnMl | Delete (Blank)      |
| Nigeria                          | en Enugu East       | HlABmTwBpu6 | Keep                |
| Nigeria                          | en Enugu East       | h61xiVptz4A | Delete (Duplicates) |
| Nigeria                          | en Nsukka           | ITdnyCiBvz7 | Keep                |
| Nigeria                          | en Nsukka           | lC1wneS1GR5 | Delete (Duplicates) |
| Nigeria                          | im Ngor Okpala      | vpCKW3gWNhV | Keep                |
| Nigeria                          | im Ngor Okpala      | D47MUIzTapM | Delete (Duplicates) |
*/

*Combine 
    replace psnuuid = "Oz0qJ8kNbKx" if psnuuid=="gxf4z0agDsk"
	replace psnuuid = "gxf4z0agDsk" if psnuuid=="dASd72VnJPh"
	replace psnuuid = "dASd72VnJPh" if psnuuid=="dOQ8r7iwZvS"
	replace psnuuid = "dOQ8r7iwZvS" if psnuuid=="EzsXkY9WARj"
	replace psnuuid = "EzsXkY9WARj" if psnuuid=="URj9zYi533e"
	replace psnuuid = "URj9zYi533e" if psnuuid=="KN2TmcAVqzi"
	replace psnuuid = "KN2TmcAVqzi" if psnuuid=="bDoKaxNx2Xb"
	replace psnuuid = "bDoKaxNx2Xb" if psnuuid=="HHDEeZbVEaw"
	
*Remove duplicates/blanks
	drop if psnuuid == "HhCbsjlKoWA"
	drop if psnuuid == "IxeWi5YG9lE"
	drop if psnuuid == "dzjXm8e1cNs"
	drop if psnuuid == "kxsmKGMZ5QF"
	drop if psnuuid == "mVuyipSx9aU"
	
	
** Cluster SNUs **

/*Botswana (J. Rofenbender, 1/9/17)
	| operatingunit | psnu                        | fy17snuprioritization    | psnuuid     | cluster |
	|---------------|-----------------------------|--------------------------|-------------|---------|
	| Botswana      | Greater Gabarone Cluster    | 2 - Scale-Up: Aggressive | VB7am4futjm | 1       |
	| Botswana      | Gaborone District           | 2 - Scale-Up: Aggressive | VB7am4futjm |         |
	| Botswana      | Kgatleng District           | 2 - Scale-Up: Aggressive | yNcvm7JYBfi |         |
	| Botswana      | Kweneng East District       | 2 - Scale-Up: Aggressive | Uz8LWtC0vYF |         |
	| Botswana      | South East District         | 2 - Scale-Up: Aggressive | YksWHI1yLuv |         |
	| Botswana      | Greater Francistown Cluster | 4 - Sustained            | h1CepDrLWib | 1       |
	| Botswana      | Francistown District        | 4 - Sustained            | h1CepDrLWib |         |
	| Botswana      | North East District         | 4 - Sustained            | psnuuid     |         |
	| Botswana      | Tutume District             | 4 - Sustained            | gchw5PMi4N2 |         |
	*/
	*Greater Gabarone Cluster
		replace psnuuid = "VB7am4futjm" if inlist(psnuuid, "yNcvm7JYBfi", "Uz8LWtC0vYF", "YksWHI1yLuv")
		replace psnu = "Greater Cabrone Cluster" if psnuuid=="VB7am4futjm"
		replace fy17snuprioritization = "2 - Scale-Up: Aggressive" if psnuuid=="VB7am4futjm"
		replace snu1 = "[Clustered]" if psnuuid=="VB7am4futjm"	
	*Greater Francistown Cluster
		replace psnuuid = "h1CepDrLWib" if inlist(psnuuid, "nszh0FzynAQ", "gchw5PMi4N2")
		replace psnu = "Greater Francistown Cluster" if psnuuid=="h1CepDrLWib"
		replace fy17snuprioritization = "4 - Sustained" if psnuuid=="h1CepDrLWib"
		replace snu1 = "[Clustered]" if psnuuid=="h1CepDrLWib"



