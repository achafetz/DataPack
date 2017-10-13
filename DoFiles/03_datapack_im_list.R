##   Data Pack COP FY18
##   A.Chafetz, USAID
##   Purpose: output unique mechanism list
##   Adopted from COP17 Stata code
##   Date: Oct 13, 2017
##   Updated: 

## DEPENDENCIES
    # run 00_datapack_initialize.R
    # ICPI Fact View OU_IM

## SETUP ------------------------------------------------------------------------------------------------------

  #define date for Fact View Files
    datestamp <- "20170922_v2_1" #currently 3, needs to be updated with 4 when available
  
  #set today's date for saving
    date <-  format(Sys.Date(), format="%d%b%Y")

## MECH LIST ----------------------------------------------------------------------------------------------
    
  #import
    df_mechlist  <- read_tsv(file.path(fvdata, paste("ICPI_FactView_OU_IM_", datestamp, ".txt", sep="")))
      names(df_mechlist) <- tolower(names(df_mechlist)) 
  
  
  #update all partner and mech to offical names (based on FACTS Info)
    df_curr <- df_mechlist
    source(file.path(dofiles, "06_datapack_snu_adj.R"))
    df_mechlist <- df_curr
      rm(df_curr)
  
  #unique list of mechanisms
    df_mechlist <- df_mechlist %>%
      distinct(operatingunit, fundingagency, mechanismid, implementingmechanismname) %>%
      filter(mechanismid>1) #remove dedups
  
  ## EXPORT -----------------------------------------------------------------------------------------------------  
    
    write_csv(df_mechlist, file.path(exceloutput, paste("Global_MechList", date, ".csv", sep="")))
    rm(df_mechlist, date, datestamp)
    