**   Data Pack
**   COP FY17
**   Aaron Chafetz
**   Purpose: remove/combine duplicate SNUs with different UIDs
**   Date: January 9, 2017
**   Updated:

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
