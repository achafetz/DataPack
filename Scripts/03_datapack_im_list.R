##   Data Pack COP FY18
##   A.Chafetz, USAID
##   Purpose: output unique mechanism list
##   Adopted from COP17 Stata code
##   Date: Oct 13, 2017
##   Updated: 10/19/17

## DEPENDENCIES
    # run 00_datapack_initialize.R
    # ICPI Fact View OU_IM
    # 05_datapack_officialnames.R


## MECH LIST ----------------------------------------------------------------------------------------------
    
  #import
    df_mechlist  <- read_tsv(file.path(fvdata, paste("ICPI_FactView_OU_IM_", datestamp, ".txt", sep="")))
      names(df_mechlist) <- tolower(names(df_mechlist)) 
  
  #update all partner and mech to offical names (based on FACTS Info)
  #cleanup PSNUs (dups & clusters)
      source(file.path(scripts, "05_datapack_officialnames.R"))
      cleanup_mechs(df_mechlist, rawdata)
  
  #unique list of mechanisms
    df_mechlist <- df_mechlist %>%
      distinct(operatingunit, fundingagency, mechanismid, implementingmechanismname) %>%
      filter(mechanismid>1) #remove dedups
  
  ## EXPORT -----------------------------------------------------------------------------------------------------  
    
    write_csv(df_mechlist, file.path(output, "Global_MechList.csv"))
    rm(df_mechlist)
    