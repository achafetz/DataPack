##   Data Pack COP FY18
##   A.Chafetz, USAID
##   Purpose: generate disagg distribution for targeting
##   Adopted from COP17 Stata code
##   Date: Oct 26, 2017
##   Updated: 

## DEPENDENCIES
# run 00_datapack_initialize.R
# cleanim_temp.Rdata (04_datapack_im_targeting.R)


## FILTER DATA ------------------------------------------------------------------------------------------------------    

  #import data
    load(file.path(tempoutput, "cleanim_temp.RData"), verbose = FALSE)
