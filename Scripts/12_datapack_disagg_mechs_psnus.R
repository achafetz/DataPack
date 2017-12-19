##   Data Pack COP FY18
##   A.Chafetz, USAID
##   Purpose: output unique mechanism list and PSNU list
##   Date: Dec 8, 2017
##   Updated: 

## DEPENDENCIES
# run 00_datapack_initialize.R
# ICPI Fact View PSNU_IM
# 91_datapack_officialnames.R
# 92_datapack_snu_adj.R

## SETUP  ----------------------------------------------------------------------------------------------

  #import
    df_factview  <- read_tsv(file.path(fvdata, paste("ICPI_FactView_PSNU_IM_", datestamp, ".txt", sep=""))) %>% 
      rename_all(tolower) 
    
  #cleanup PSNUs (dups & clusters)
    source(file.path(scripts, "91_datapack_officialnames.R"))
    df_factview <- cleanup_mechs(df_factview, rawdata)
      
    source(file.path(scripts, "92_datapack_snu_adj.R"))
      df_factview <- cleanup_snus(df_factview)
      df_factview <- cluster_snus(df_factview)
    
    rm(cleanup_mechs, cleanup_snus, cluster_snus)
  
    
## MECHANISM LIST  ----------------------------------------------------------------------------------------------
    
  #unique list of mechanisms
    df_mechlist <- df_factview %>%
      filter(indicator %in% c("GEND_GBV", "HTS_SELF", "HTS_TST", "KP_PREV", "KP_MAT", "OVC_SERV", "OVC_HIVSTAT",  
                              "PMTCT_ART", "PMTCT_EID", "PMTCT_STAT", "PP_PREV","PrEP_NEW", "TB_ART", "TB_PREV", 
                              "TB_STAT", "TX_CURR","TX_NEW", "TX_PVLS", "TX_RET", "TX_TB", "VMMC_CIRC")) %>% 
      filter(mechanismid>1) %>% #remove dedups 
      distinct(operatingunit, psnuuid, psnu, fy17snuprioritization, mechanismid, implementingmechanismname, indicatortype) %>% 
      select(operatingunit, psnuuid, psnu, fy17snuprioritization, mechanismid, implementingmechanismname, indicatortype) %>% 
      arrange(operatingunit, psnu, mechanismid, indicatortype)
    

## EXPORT -----------------------------------------------------------------------------------------------------  

  write_csv(df_mechlist, file.path(output, "Global_DT_MechList.csv"), na = "")
    

## PSNU LIST  ----------------------------------------------------------------------------------------------
    
    #unique list of PSNUs
    df_psnulist <- df_mechlist %>%
      distinct(operatingunit, psnuuid, psnu, fy17snuprioritization, indicatortype) %>% 
      select(operatingunit, psnuuid, psnu, fy17snuprioritization, indicatortype) %>% 
      arrange(operatingunit, psnu, indicatortype)

    
## EXPORT -----------------------------------------------------------------------------------------------------  
    
    write_csv(df_psnulist, file.path(output, "Global_DT_PSNUList.csv"), na = "")
    
    rm(df_factview, df_mechlist, df_psnulist)
    