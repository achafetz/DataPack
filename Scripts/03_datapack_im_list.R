##   Data Pack COP FY18
##   A.Chafetz, USAID
##   Purpose: output unique mechanism list
##   Adopted from COP17 Stata code
##   Date: Oct 13, 2017
##   Updated: 2/6

## DEPENDENCIES
    # run 00_datapack_initialize.R
    # ICPI Fact View OU_IM
    # 91_datapack_officialnames.R


## MECH LIST ----------------------------------------------------------------------------------------------
    
  #import
    df_mechlist  <- read_rds(file.path(fvdata, paste0("ICPI_FactView_OU_IM_", datestamp, ".RDS"))) 
  
  #add South Sudan's data, missing from Q1+Q2 in regular Q4v2_2 FV
    source(file.path(scripts, "97_datapack_ssd_adjustment.R"))
    df_mechlist <- add_ssd_fv(df_mechlist, "OUxIM")
      rm(add_ssd_fv)
    
  #update all partner and mech to offical names (based on FACTS Info)
  #cleanup PSNUs (dups & clusters)
      source(file.path(scripts, "91_datapack_officialnames.R"))
      df_mechlist <- cleanup_mechs(df_mechlist, rawdata)
  
  #unique list of mechanisms
    df_mechlist <- df_mechlist %>%
      distinct(operatingunit, fundingagency, mechanismid, implementingmechanismname) %>%
      filter(mechanismid>1) #remove dedups
  
  ## EXPORT -----------------------------------------------------------------------------------------------------  
    
    write_csv(df_mechlist, file.path(output, "Global_MechList.csv"), na = "")
    rm(df_mechlist, cleanup_mechs)
    