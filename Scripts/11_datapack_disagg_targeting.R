##   Data Pack COP FY18
##   A.Chafetz, USAID
##   Purpose: generate disagg distribution for targeting
##   Adopted from COP17 Stata code
##   Date: Oct 26, 2017
##   Updated: 11/9/17 

## DEPENDENCIES
# run 00_datapack_initialize.R
# ICPI Fact View PSNU


## FILTER DATA ------------------------------------------------------------------------------------------------------    

  # import
    df_imalloc  <- read_tsv(file.path(fvdata, paste("ICPI_FactView_PSNU_", datestamp, ".txt", sep=""))) %>% 
      rename_all(tolower)
    
    df_imalloc <- df_factview
  
  #cleanup PSNUs (dups & clusters)
    source(file.path(scripts, "92_datapack_snu_adj.R"))
    cleanup_snus(df_imalloc)
    cluster_snus(df_imalloc)
    
  ## REMOVE BELOW  -------------------------------------------------------------------------------------------------
  
  ## FOR TESTING ONLY ## REMOVE after FY17 APR becomes available ##
  df_imalloc[is.na(df_imalloc)] <- 0
  df_imalloc <- df_imalloc %>% 
    mutate(fy2017apr = ifelse(indicator=="TX_CURR", fy2017q3, 
                              ifelse(indicator %in% c("KP_PREV","PP_PREV", "OVC_HIVSTAT", "OVC_SERV", 
                                                      "TB_ART", "TB_STAT", "TX_TB", "GEND_GBV", "PMTCT_FO", 
                                                      "TX_RET", "KP_MAT"), fy2017q2, 
                                     fy2017q1 + fy2017q2 + fy2017q3)),
           fy2018_targets = fy2017_targets * 1.5,
           fy18snuprioritization = as.character(fy16snuprioritization))
  df_imalloc[df_imalloc==0] <- NA
  
  #  ^^^^^^ REMOVE ABOVE ^^^^^^
  
## SUBSET DATA OF INTEREST  ---------------------------------------------------------------------------------------  

  df_imalloc <- df_imalloc %>% 
    
    # limit to indicators with targets for COP18 (no MCAD disaggs)
      filter(indicator %in% c("GEND_GBV", "HTS_SELF", "HTS_TST_POS", "HTS_TST_NEG", "KP_MAT", 
                               "KP_PREV", "OVC_HIVSTAT", "OVC_SERV", "PMTCT_ART", 
                               "PMTCT_EID", "PMTCT_STAT", "PP_PREV", "PREP_NEW", 
                               "TB_ART", "TB_PREV", "TB_STAT", "TX_CURR", "TX_NEW", 
                               "TX_PVLS", "TX_RET", "TX_TB", "VMMC_CIRC"),
             ismcad == "N",
             !is.na(fy2017apr))
    # limit to just key variables
      select(operatingunit, psnuuid, psnu, fy18snuprioritization, indicator:indicatortype, standardizeddisaggregate, age:otherdisaggregate, modality, fy2017apr) %>% 
    
    # aggregate to psnu x disagg [type] level to have one line per obs
      group_by_if(is.character) %>%
      summarise_at(vars(fy2017apr), funs(sum(., na.rm = TRUE))) %>%
      ungroup() 


## SUBSET DATA OF INTEREST  ---------------------------------------------------------------------------------------  
    
  df_imalloc <- df_imalloc %>% 
    
    # adjust disagg name so can create shares for Peds + Adults for TX_CURR, TX_NEW, and HTS_TST
      mutate(disagg = ifelse(indicator %in% c("TX_CURR", "TX_NEW", "HTS_TST_POS", "HTS_TST_NEG") & age %in% c("<01", "01-09", "10-14"), "Peds Age/Sex",
                             ifelse(indicator %in% c("TX_CURR", "TX_NEW", "HTS_TST", "HTS_TST_POS", "HTS_TST_NEG") & grepl("AgeAbove", standardizeddisaggregate), "Adult Age/Sex",
                                    standardizeddisaggregate)
                             )) %>% 
    # remove old disagg indicator
      select(-standardizeddisaggregate)
  

## DISAGG ALLOCATION  ---------------------------------------------------------------------------------------  
    
  df_imalloc <- df_imalloc %>% 
    # create a disagg group total as the denominator for the allocation share
      group_by(operatingunit, psnuuid, psnu, fy18snuprioritization, indicator, numeratordenom, indicatortype, disagg) %>% 
      mutate(total = sum(fy2017apr)) %>% 
      ungroup() %>% 
        
    # create allocation share for each disagg type   
      mutate(share = round(fy2017apr/total, 3))
  


