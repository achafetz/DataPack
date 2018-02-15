##   Data Pack COP FY18
##   A.Chafetz, USAID
##   Purpose: generate output for Excel based Data Pack at SNU level
##   Adopted from COP17 Stata code
##   Date: Oct 8, 2017
##   Updated: 2018.02.13

## DEPENDENCIES
    # run 00_datapack_initialize.R
    # append_temp.Rdata (01_datapack_output.R)


## FILTER DATA ------------------------------------------------------------------------------------------------------    
  
    #import data
      df_keyindtbl <- read_rds(file.path(tempoutput, "append_temp.Rds"))
        
    #filterread_rds()
      df_keyindtbl <- df_keyindtbl %>%
        filter((indicator %in% c("PLHIV", "HTS_TST", "HTS_TST_POS", "TB_ART", "TX_CURR", "TX_NEW",
                                 "VMMC_CIRC") & standardizeddisaggregate == "Total Numerator") |
               (indicator=="PMTCT_ART" & standardizeddisaggregate == "NewExistingArt/HIVStatus")) %>%
        
    #aggregate
        group_by(operatingunit, snulist, psnuuid, priority_snu, indicator) %>%
        summarise_at(vars(fy2015apr, fy2016apr, fy2017apr, fy2018_targets), funs(sum(., na.rm = TRUE)))

      
## RESHAPE ------------------------------------------------------------------------------------------------------ 
     
    #reshape long 
      df_keyindtbl <- df_keyindtbl %>%
        gather(pd, value, fy2015apr, fy2016apr, fy2017apr, fy2018_targets, na.rm = TRUE) %>%
    
    #concatenate variables
        mutate(header = paste(indicator, pd, sep = "_")) %>%
        select(-indicator, -pd) %>%   #remove varables used for concatenation
      
    #add "indicators" for spaces
        bind_rows(
          tribble(~header, "a_sp1", "a_sp2", "HTS_TST_msp1", "HTS_TST_msp2", "HTS_TST_msp3", 
                           "HTS_TST_POS_sp1", "HTS_TST_POS_sp2", "HTS_TST_POS_sp3", "PMTCT_ART_sp1", 
                           "PMTCT_ART_sp2", "PMTCT_ART_sp3", "TB_ART_sp1", "TB_ART_sp2", "TB_ART_sp3", 
                           "TX_CURR_sp1", "TX_CURR_sp2", "TX_CURR_sp3", "TX_NEW_sp1", "TX_NEW_sp2", "TX_NEW_sp3")
          ) %>%
        
    #reshape with variables as column headers 
        spread(header, value) %>%
    
    #reorder
        select(operatingunit, psnuuid, priority_snu, snulist, a_sp1:VMMC_CIRC_fy2018_targets) %>%
        
    #sort by PLHIV
        arrange(operatingunit, desc(PLHIV_fy2017apr), snulist) %>% 
    
    #remove all PLHIV (just included for sorting)
        select(-starts_with("PLHIV"))
      
## EXPORT -----------------------------------------------------------------------------------------------------  
   
    #export 
      write_csv(df_keyindtbl, file.path(output, "Global_KeyTrends.csv"), na = "")
        rm(df_keyindtbl)
        file.remove(file.path(tempoutput, "append_temp.Rds"))
        
      
      
      