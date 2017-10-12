##   Data Pack COP FY18
##   A.Chafetz, USAID
##   Purpose: generate output for Excel based Data Pack at SNU level
##   Adopted from COP17 Stata code
##   Date: Oct 8, 2017
##   Updated: 10/11


## SETUP ------------------------------------------------------------------------------------------------------

  #define date for Fact View Files
    datestamp <- "20170922_v2_1" #currently Q3, needs to be updated with Q4 when available

  #set today's date for saving
    date <-  format(Sys.Date(), format="%d%b%Y")

## FILTER DATA ------------------------------------------------------------------------------------------------------    
  
    #import data
      load(file.path(stataoutput, "append_temp.Rdata"), verbose = FALSE)
      df_keyindtbl <- df_indtbl
        rm(df_indtbl)
    
    #filter
      df_keyindtbl <- df_keyindtbl %>%
        filter((indicator %in% c("PLHIV (SUBNAT)", "HTS_TST", "HTS_TST_POS", "TB_ART", "TX_CURR", "TX_NEW",
                                 "VMMC_CIRC") & standardizeddisaggregate == "Total Numerator") |
               (indicator=="PMTCT_ART" & standardizeddisaggregate == "NewExistingArt")) %>%
    #aggregate
        group_by(operatingunit, psnu, psnuuid, snuprioritization, indicator) %>%
        summarise_at(vars(fy2015apr, fy2016apr, fy2017apr, fy2018_targets), funs(sum(., na.rm = TRUE)))
                 
## RESHAPE ------------------------------------------------------------------------------------------------------ 
     
    #reshape long 
      df_keyindtbl <- df_keyindtbl %>% 
        gather(pd, value, fy2015apr, fy2016apr, fy2017apr, fy2018_targets, na.rm = TRUE)
    
    #concatenate variables
        mutate(header = paste(pd, indicator, sep = "")) %>%
        select(-indicator, -pd) %>%  #remove varables used for concatenation
      
    #reshape with variables as column headers 
        spread(header, value)
        
## CLEAN UP -----------------------------------------------------------------------------------------------------  
    
    #create spacers between indicator columns
      ind <- c( "HTS_TST", "HTS_TST_POS", "TB_ART", "TX_CURR", "TX_NEW", "VMMC_CIRC") #add PLHIV!!!
      for(i in ind) {
        df_keyindtbl <- df_keyindtbl %>%
          mutate(
            paste([i],"_spc1") = NA, 
            [i]_spc2 = NA,
            [i]_spc3 = NA
          )
      }   
      
      
      
      
      
      