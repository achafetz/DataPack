##   Data Pack COP FY18
##   A.Chafetz, USAID
##   Purpose: generate disagg distribution for targeting
##   Adopted from COP17 Stata code
##   Date: Oct 26, 2017
##   Updated: 12/06/17 

## DEPENDENCIES
# run 00_datapack_initialize.R
# ICPI Fact View PSNU


## FILTER DATA ------------------------------------------------------------------------------------------------------    

  # import
    df_psnualloc  <- read_tsv(file.path(fvdata, paste("ICPI_FactView_PSNU_", datestamp, ".txt", sep=""))) %>% 
      rename_all(tolower)
  
  #cleanup PSNUs (dups & clusters)
    source(file.path(scripts, "92_datapack_snu_adj.R"))
    cleanup_snus(df_psnualloc)
    cluster_snus(df_psnualloc)
      rm(cleanup_snus, cluster_snus)
    
  
## SUBSET DATA OF INTEREST  ---------------------------------------------------------------------------------------  

  df_psnualloc <- df_psnualloc %>% 
    
    # limit to indicators with targets for COP18 (no MCAD disaggs)
      filter(indicator %in% c("GEND_GBV", "OVC_SERV", "PMTCT_EID", "PMTCT_STAT", 
                              "PP_PREV", "PrEP_NEW", "TB_ART", "TB_PREV", "TB_STAT", 
                              "TX_CURR", "TX_NEW", "TX_PVLS", "TX_RET", "TX_TB", 
                              "VMMC_CIRC"),
             ismcad == "N",
             !is.na(fy2017apr), 
             fy2017apr!=0) %>% 
    # limit to just key variables
      select(operatingunit, psnuuid, psnu, fy17snuprioritization, indicator:indicatortype, standardizeddisaggregate, age:modality, fy2017apr) %>% 
    
    # aggregate to psnu x disagg [type] level to have one line per obs
      group_by_if(is.character) %>%
      summarise_at(vars(fy2017apr), funs(sum(., na.rm = TRUE))) %>%
      ungroup() 


## MAP VARIABLES -------------------------------------------------------------------------------------
    # rather than use ifelse formulas, going to tag each unique variable combo with it's associated disagg tool variable
    
    #import disagg mapping table
      df_disaggs <- read_tsv(file.path(rawdata, "disagg_ind_grps.txt")) %>% 
    #remove rows where there are no associated MER indicators in FY17 (eg Tx_NEW Age/Sex 24-29 M)
        filter(!is.na(standardizeddisaggregate))  %>% 
    #remove columns that just identify information in the disagg tool
        select(-dt_dataelementgrp, -dt_categoryoptioncombo)

    #need to replace all the "NULL" in modality to NA in order to match disaggs & make it a character
      df_psnualloc <- df_psnualloc %>% 
          mutate(modality = ifelse(modality == "NULL", NA, modality),
                 modality = as.character(modality))
    
    #check if there are variables from the disagg files that do not match with the PSNU allocation
      #notjoined <- anti_join(df_disaggs, df_psnualloc)
      
    #map onto main PSNU allocation dataframe
      df_psnualloc <- left_join(df_psnualloc, df_disaggs)
        rm(df_disaggs)
      
 ## RESHAPE  ---------------------------------------------------------------------------------------    
  
    test <- df_psnualloc %>%
      #reshape to long form to then create aggregate group denominator for distro
        select(-indicator:-fy2017apr) %>% 
        gather(ind, val, -operatingunit:-fy17snuprioritization)
      
      test <- test %>%  filter(val!=0)
      
## DISAGG ALLOCATION  ---------------------------------------------------------------------------------------  
    
  df_psnualloc <- df_psnualloc %>% 
    # create a disagg group total as the denominator for the allocation share
      group_by(operatingunit, psnuuid, psnu, fy18snuprioritization, indicator, numeratordenom, indicatortype, disagg) %>% 
      mutate(total = sum(fy2017apr)) %>% 
      ungroup() %>% 
        
    # create allocation share for each disagg type   
      mutate(share = round(fy2017apr/total, 3))
  
      
      
      filter(!str_detect(otherdisaggregate, "Unknown Sex")) %>% 
        mutate(grouping = ifelse(indicator == "OVC_SERV" & standardizeddisaggregate == "Age/Sex/Service", paste(standardizeddisaggregate, otherdisaggregate, sep = " - "), grouping),
               grouping = ifelse(indicator == "OVC_SERV" & standardizeddisaggregate == "Age/Sex" & (age %in% c("<01", "01-04", "05-09","10-14", "15-17")), paste(standardizeddisaggregate, "<18", sep = " - "), grouping),
               grouping = ifelse(indicator == "OVC_SERV" & standardizeddisaggregate == "Age/Sex" & (age %in% c("18-24", "25+")), paste(standardizeddisaggregate, "18+", sep = " - "), grouping),
               grouping = ifelse(indicator == "PMTCT_STAT" & standardizeddisaggregate == "Age/KnownNewResult", paste(standardizeddisaggregate, otherdisaggregate, resultstatus, sep = " "), grouping),
               grouping = ifelse(indicator == "TB_STAT" & standardizeddisaggregate == "Age/Sex/KnownNewPosNeg", paste(standardizeddisaggregate, otherdisaggregate, resultstatus, sep = " "), grouping),
               grouping = ifelse((indicator %in% c("TX_CURR", "TX_NEW")) & (standardizeddisaggregate %in% c("AgeLessThanTen", "AgeAboveTen/Sex")) & (age %in% c("<01", "01-09", "10-14")), paste(standardizeddisaggregate, "<15", sep = " - "), grouping),
               grouping = ifelse((indicator %in% c("TX_CURR", "TX_NEW")) & standardizeddisaggregate=="AgeAboveTen/Sex" & (age %in% c("15-19", "20-24", "50+")), paste(standardizeddisaggregate, "15+", sep = " - "), grouping),
               grouping = ifelse(indicator == "TX_RET" & standardizeddisaggregate == "Aggregated Age/Sex" & age != "Unknown Age", paste(standardizeddisaggregate, age, sep = " - "),
               grouping = ifelse(indicator == "VMMC_CIRC" & standardizeddisaggregate == "Age" & (age %in% c("15-19", "20-24", "25-29")), paste(standardizeddisaggregate, "Primary", sep = " - "), grouping),
               grouping = ifelse(indicator == "VMMC_CIRC" & standardizeddisaggregate == "Age" & (age %in% c("[months] 00-02", "02 months - 09 years", "10-14", "50+")), paste(standardizeddisaggregate, "Other", sep = " - "), grouping))
        )

      
     
