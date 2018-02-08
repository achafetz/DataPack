##   Data Pack COP FY18
##   A.Chafetz, USAID
##   Purpose: output unique mechanism list and PSNU list
##   Date: Dec 8, 2017
##   Updated: 2/7/18

## DEPENDENCIES
# run 00_datapack_initialize.R
# ICPI Fact View PSNU_IM and PSNU
# 91_datapack_officialnames.R
# 92_datapack_snu_adj.R

## SETUP  ----------------------------------------------------------------------------------------------

  #import
    df_mechlist  <- read_rds(file.path(fvdata, paste0("ICPI_FactView_PSNU_IM_", datestamp, ".RDS")))
  
  #add South Sudan's data, missing from Q1+Q2 in regular Q4v2_2 FV
    source(file.path(scripts, "97_datapack_ssd_adjustment.R"))
    df_mechlist <- add_ssd_fv(df_mechlist, "PSNUxIM")
    rm(add_ssd_fv)
    
  #cleanup PSNUs (dups & clusters)
    source(file.path(scripts, "91_datapack_officialnames.R"))
      df_mechlist <- cleanup_mechs(df_mechlist, rawdata)
      
    source(file.path(scripts, "92_datapack_snu_adj.R"))
      df_mechlist <- cluster_snus(df_mechlist)
      df_mechlist <- cleanup_snus(df_mechlist)
    
    rm(cleanup_mechs, cleanup_snus, cluster_snus)
  
    
## MECHANISM LIST  ----------------------------------------------------------------------------------------------
    
  #unique list of mechanisms
    df_mechlist <- df_mechlist %>%
      filter(indicator %in% c("GEND_GBV", "HTS_SELF", "HTS_TST", "KP_PREV", "KP_MAT", "OVC_SERV", "OVC_HIVSTAT",  
                              "PMTCT_ART", "PMTCT_EID", "PMTCT_STAT", "PP_PREV","PrEP_NEW", "TB_ART", "TB_PREV", 
                              "TB_STAT", "TX_CURR","TX_NEW", "TX_PVLS", "TX_RET", "TX_TB", "VMMC_CIRC")) %>% 
      filter(mechanismid>1) %>% #remove dedups 
      distinct(operatingunit, psnu, psnuuid, currentsnuprioritization, mechanismid, implementingmechanismname, indicatortype) %>% 
      select(operatingunit, psnu, psnuuid, currentsnuprioritization, mechanismid, implementingmechanismname, indicatortype) %>% 
      arrange(operatingunit, psnu, mechanismid, indicatortype) %>%
      mutate(psnu_type = paste(psnu, indicatortype, sep = " "))
    
  # export
    write_csv(df_mechlist, file.path(output, "Global_DT_MechList.csv"), na = "")
      rm(df_mechlist)

## PSNU LIST  ----------------------------------------------------------------------------------------------
    
  #import
    df_psnulist  <- read_rds(file.path(fvdata, paste0("ICPI_FactView_PSNU_", datestamp, ".RDS")))
      
  #add South Sudan's data, missing from Q1+Q2 in regular Q4v2_2 FV
      source(file.path(scripts, "97_datapack_ssd_adjustment.R"))
      df_psnulist <- add_ssd_fv(df_psnulist, "PSNU")
      rm(add_ssd_fv)
      
  #unique list of PSNUs (non clusters for PLHIV import)
    df_psnulist <- df_psnulist %>%
      distinct(operatingunit, psnu, psnuuid) %>% 
      filter(!is.na(psnuuid)) %>% 
      select(operatingunit, psnu, psnuuid) %>% 
      arrange(operatingunit, psnu, psnuuid)
    
  #export
    write_csv(df_psnulist, file.path(output, "Global_DT_PSNUList.csv"), na = "")
      rm(df_psnulist)
    