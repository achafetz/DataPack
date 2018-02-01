##   Data Pack COP FY18
##   A.Chafetz, USAID
##   Purpose: recreate South Sudan dataset to include Q1 and Q2 (missing in DATIm)
##   Date: Jan 31, 2017



library(tidyverse)


#file path
loc <- "~/ICPI/Data/"


#import normal Fact View PSNUxIM
  df_mer <- read_tsv(file.path(loc, "ICPI_FactView_PSNU_IM_20171222_v2_2.txt"),
             col_types = cols(FY2015APR = "d",
                              FY2016_TARGETS = "d",
                              FY2016APR = "d",
                              FY2017_TARGETS = "d",
                              FY2017APR = "d",
                              FY2018_TARGETS = "d")) %>%
    #select just South Sudan
    filter(operatingunit == "South Sudan") %>% 
    #remove quarters with missing data
    select(-fy2017q1, -fy2017q2) %>% 
    #covert to character for easier mutate later
    mutate(mechanismid = as.character(mechanismid),
           coarsedisaggregate = as.character(coarsedisaggregate))

#import South Sudan's data
  df_ssd_psnuim <- read_excel(file.path(loc, "SSudan PSNUxIM FactView Dec22V2.xlsx")) %>% 
    rename_all(tolower) %>% 
    #keep data only for quaters missing in FV dataset
    select(region:ismcad, fy2017q1, fy2017q2) %>% 
    #convert to integer for merge
    mutate_at(vars(fy2017q1, fy2017q2), funs(as.integer(.))) %>% 
    #convert to character for merge
    mutate(mechanismid = as.character(mechanismid))

#join FV and SSD provided datasets
  df_ssd_psnuim <- full_join(df_mer, df_ssd_psnuim) %>% 
    #replace na's with 0's in order to add in mutate
    replace_na(list(fy2017q1 = 0, fy2017q2 = 0)) %>% 
    #take Q4 value for annual and semi annual indicators, sum quaterly ones
    mutate(fy2017apr = ifelse(indicator %in% c("GEND_GBV", "KP_MAT", "TX_PVLS", "TX_RET", 
                                               "KP_PREV", "OVC_HIVSTAT", "OVC_SERV", "PP_PREV", 
                                               "TB_ART", "TB_PREV", "TB_STAT", "TB_STAT_POS", "TX_TB"), fy2017q4, 
                              fy2017q1 + fy2017q2 + fy2017q3 + fy2017q4)) %>% 
    #reorder
    select(region:fy2017_targets, fy2017q1, fy2017q2, fy2017q3, fy2017q4, fy2017apr, fy2018_targets)
  
#convert PSNUxIM to PSNU to append to Fact View
  df_ssd_psnu <- df_ssd_psnuim %>% 
    select(-mechanismuid:-implementingmechanismname) %>% 
    group_by_if(is.character) %>% 
    summarize_at(vars(fy2017q1, fy2017q2), funs(sum(., na.rm = TRUE))) %>% 
    ungroup 

#convert PSNUxIM to OUxIm to append to FactView
  df_ssd_ouim <- df_ssd_psnuim %>% 
    select(-snu1:-typemilitary) %>% 
    group_by_if(is.character) %>% 
    summarize_at(vars(fy2017q1, fy2017q2), funs(sum(., na.rm = TRUE))) %>% 
    ungroup 

