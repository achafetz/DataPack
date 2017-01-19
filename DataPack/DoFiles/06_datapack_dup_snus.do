**   Data Pack
**   COP FY17
**   Aaron Chafetz
**   Purpose: remove/combine duplicate SNUs with different UIDs & cluster SNUs
**   Date: January 12, 2017
**   Updated: 1/17/17

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
	drop if inlist(psnuuid, "HhCbsjlKoWA", "IxeWi5YG9lE", "dzjXm8e1cNs", "kxsmKGMZ5QF", "mVuyipSx9aU")
	
*add Country Name to Regional Programs
	replace psnu = snu1 + "/" + psnu if inlist(operatingunit, "Asia Regional Program", "Caribbean Region", "Central America Region", "Central Asia Region")

** Remove SNUs **
* S.Ally (1/17/17) - no Sustained - Commodities districts
	drop if inlist(psnuuid, "O1kvkveo6Kt", "hbnRmYRVabV", "N7L1LQMsQKd", "nlS6OMUb6s3")

** Cluster SNUs **
* clusters submitted by SI advisors - https://github.com/achafetz/ICPI/tree/master/DataPack/RawData

* import cluster dataset
	preserve
		import delimited "$data/COP17Clusters.csv", clear
		tempfile tempcluster
		save "`tempcluster'"
	restore
* merge clusters onto factview
	merge m:1 psnuuid using "`tempcluster'", nogen 

* replace with cluster info
	foreach x in psnu snu1 psnuuid fy17snuprioritization {
		replace `x' = cluster_`x' if cluster_set==1
		}
		*end do
	drop cluster*

