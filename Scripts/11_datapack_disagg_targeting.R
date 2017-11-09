##   Data Pack COP FY18
##   A.Chafetz, USAID
##   Purpose: generate disagg distribution for targeting
##   Adopted from COP17 Stata code
##   Date: Oct 26, 2017
##   Updated: 

## DEPENDENCIES
# run 00_datapack_initialize.R
# ICPI Fact View PSNU


## FILTER DATA ------------------------------------------------------------------------------------------------------    

# import
  df_imalloc  <- read_tsv(file.path(fvdata, paste("ICPI_FactView_PSNU_", datestamp, ".txt", sep=""))) %>% 
    rename_all(tolower)
  
# remove indicators with no targets
  t <- filter(df_imalloc, !indicator %in% c("EMR_SITE", "FPINT_SITE", "HRH_CURR", "HRH_PRE", "HRH_STAFF",
                                        "LAB_PTCQI", "PMTCT_FO", "PMTCT_HEI_POS", "SC_STOCK"))

  ind <- t %>% 
    distinct(indicator) %>% 
    arrange(indicator) %>% 
    print(n=80)
  