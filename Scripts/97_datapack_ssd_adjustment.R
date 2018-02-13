##   Data Pack COP FY18
##   A.Chafetz, USAID
##   Purpose: recreate South Sudan dataset to include Q1 and Q2 (missing in DATIm)
##   Date: 
##   Updated: 2/13/18

## DEPENDENCIES
# run 00_datapack_initialize.R
# South Sudan Updated PSNUxIM FactView dataset (contains Q1 + Q2)

add_ssd_fv <- function(df, type) {
#import South Sudan's data (PSNUxIM)
  df_ssd <- read_tsv(file.path(fvdata, "SSudan PSNUxIM FactView Dec22V2.txt"),
                              col_types = cols(
                                               FY2015APR = "d",
                                               FY2016_TARGETS = "d",
                                               FY2016APR = "d",
                                               FY2017_TARGETS = "d",
                                               FY2017APR = "d")) %>%
    rename_all(tolower)  %>% 
  #convert to integer/double/character for merge
    mutate_at(vars(contains("q")), ~ as.integer(.),
              vars(contains("apr"), contains("targets")), ~ as.double(.))

  #convert PSNUxIM to PSNU to append to Fact View
   if (type == "PSNU") {
    df_ssd <- df_ssd %>% 
      select(-mechanismuid:-implementingmechanismname) %>%
      group_by_if(is.character) %>% 
      summarise_if(is.numeric, ~ sum(., na.rm = TRUE)) %>% 
      ungroup()
    }

  #convert PSNUxIM to OUxIm to append to FactView
    if (type == "OUxIM") {
    df_ssd <- df_ssd %>% 
      select(-snu1:-typemilitary) %>% 
      mutate(mechanismid = as.character(mechanismid)) %>% 
      group_by_if(is.character) %>% 
      summarise_if(is.numeric, ~ sum(., na.rm = TRUE)) %>% 
      ungroup() 
      # %>% mutate(mechanismid = as.integer(mechanismid))
    }
  #PSNUxIM should convert mech ID to int
    if(type == "PSNUxIM"){
      df <- df %>% 
        #mutate(mechanismid = as.integer(mechanismid))
        mutate(mechanismid = as.character(mechanismid))
    }

#remove old data except fy18_targets which are missing from fix
  df <- df  %>% 
    mutate_at(vars(fy2015q2:fy2017apr), ~ ifelse(df$operatingunit == "South Sudan", NA, .))

#append new data onto bottom of mer dataframe
  df <-  bind_rows(df, df_ssd)

}
