##   Data Pack COP FY18
##   A.Chafetz, USAID
##   Purpose: generate output for Excel based Data Pack at SNU level
##   Adopted from COP17 Stata code
##   Date: Oct 8, 2017
##   Updated: 10/19

## DEPENDENCIES
    # run 00_datapack_initialize.R
    # append_temp.Rdata (01_datapack_output.R)


## FILTER DATA ------------------------------------------------------------------------------------------------------    
  
    #import data
      load(file.path(tempoutput, "append_temp.Rdata"), verbose = FALSE)
        
    #filter
      df_keyindtbl <- df_indtbl %>%
        filter((indicator %in% c("PLHIV (SUBNAT)", "HTS_TST", "HTS_TST_POS", "TB_ART", "TX_CURR", "TX_NEW",
                                 "VMMC_CIRC") & standardizeddisaggregate == "Total Numerator") |
               (indicator=="PMTCT_ART" & standardizeddisaggregate == "NewExistingArt")) %>%
        
    #aggregate
        group_by(operatingunit, snulist, psnuuid, priority_snu, indicator) %>%
        summarise_at(vars(fy2015apr, fy2016apr, fy2017apr, fy2018_targets), funs(sum(., na.rm = TRUE)))
      
      rm(df_indtbl)
      
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
        select(operatingunit, psnuuid, priority_snu, snulist, a_sp1:VMMC_CIRC_fy2018_targets)
      
## EXPORT -----------------------------------------------------------------------------------------------------  
   
    #export 
      write_csv(df_keyindtbl, file.path(output, paste("Global_KeyTrends.csv", sep="")), na = "")
        rm(df_keyindtbl)
        file.remove(file.path(tempoutput, "append_temp.Rdata"))
        
      
      
      