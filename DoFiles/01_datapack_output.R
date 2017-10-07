##   Data Pack
##   COP FY18
##   Aaron Chafetz
##   Purpose: generate output for Excel based Data Pack at SNU level
##   Adopted from COP17 Stata code
##   Date: Oct 10, 2017
##   Updated: 


### SETUP ###
  
  #define date for Fact View Files
    datestamp <- "20170922_v2_1" #currently Q3, needs to be updated with Q4 when available

  #set today's date for saving
    date <-  format(Sys.Date(), format="%d%b%Y")
	
*** IMPATT ***

*import/open data
	capture confirm file "$fvdata/ICPI_FactView_NAT_SUBNAT_${datestamp}.dta"
		if !_rc{
			use "$fvdata/ICPI_FactView_NAT_SUBNAT_${datestamp}.dta", clear
		}
		else{
			import delimited "$fvdata/ICPI_FactView_NAT_SUBNAT_${datestamp}.txt", clear
			save "$fvdata/ICPI_FactView_NAT_SUBNAT_${datestamp}.dta", replace
		}
		*end