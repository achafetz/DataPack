##   Data Pack
##   COP FY18
##   A.Chafetz, USAID
##   Purpose: add in dummy APR and FY18 targets for testing purposes##   Date: Nov 10, 2017
##   Updated: 11/13


testing_dummydata <- function(df) {

  df <- df %>%
  
  # convert NA's to 0's to add together in cumulative APR value
    mutate_at(vars(starts_with("fy2017")), funs(ifelse(is.na(.), 0, .))) %>% 
  
  # create sumulative APR variable --> will be the value used to populate indicators in data pack
    mutate(fy2017apr = ifelse(indicator=="TX_CURR", fy2017q3, 
                              ifelse(indicator %in% c("KP_PREV","PP_PREV", "OVC_HIVSTAT", "OVC_SERV", 
                                                      "TB_ART", "TB_STAT", "TX_TB", "GEND_GBV", "PMTCT_FO", 
                                                      "TX_RET", "KP_MAT"), fy2017q2, 
                                     fy2017q1 + fy2017q2 + fy2017q3)),
           fy2018_targets = round(fy2017_targets * 1.5, 0),
           fy18snuprioritization = as.character(fy16snuprioritization)) %>% 
    
  # return 0's back to NA's
    mutate_at(vars(starts_with("fy2017"), starts_with("fy2018")), funs(ifelse(. == 0, NA, .)))
  
  return(df)
}
