##   Data Pack COP FY18
##   A.Chafetz, USAID
##   Purpose: recreate South Sudan dataset to include Q1 and Q2 (missing in DATIm)
##   Date: Jan 31, 2017



library(tidyverse)
library(readxl)


#file path
fvdata <- "~/ICPI/Data"


#import South Sudan's data
  df_ssd_psnuim <- read_excel(file.path(fvdata, "SSudan PSNUxIM FactView Dec22V2.xlsx")) %>% 
    rename_all(tolower) 
  
  df_ssd_psnuim %>% 
    #convert to integer/double/character for merge
    mutate_at(vars(contains("q")), ~ as.integer(.),
              vars(contains("apr"), contains("targets")), ~ as.double(.),
              vars(mehcanismid), ~ as.character(.)) 
    glimpse()

  
#convert PSNUxIM to PSNU to append to Fact View
  df_ssd_psnu <- df_ssd_psnuim %>% 
    select(-mechanismuid:-implementingmechanismname)

#convert PSNUxIM to OUxIm to append to FactView
  df_ssd_ouim <- df_ssd_psnuim %>% 
    select(-snu1:-typemilitary)
  

write_tsv(df_ssd_psnuim, "~/GitHub/DataPack/TempOutput/df_ssd_psnuim.txt", na = "")


## Check -----

df_test <- df_ssd_psnuim %>% 
  group_by(indicator, standardizeddisaggregate) %>% 
  summarize_at(vars(contains("fy2017q"), fy2017apr), ~sum(., na.rm = TRUE)) %>% 
  ungroup()

write_csv(df_test, "C:/Users/achafetz/Downloads/ssd_apr.csv")  


df_ssd_psnuim %>% 
  filter(standardizeddisaggregate == "ProgramStatus") %>% 
  group_by(indicator, otherdisaggregate) %>% 
  summarize_at(vars(contains("fy2017q"), fy2017apr), ~sum(., na.rm = TRUE)) %>% 
  ungroup()

df_mer %>% 
  filter(operatingunit == "South Sudan", standardizeddisaggregate == "ProgramStatus") %>% 
  group_by(indicator, otherdisaggregate) %>% 
  summarize_at(vars(contains("fy2017q"), fy2017apr), ~sum(., na.rm = TRUE)) %>% 
  ungroup()


read_excel(file.path(loc, "SSudan PSNUxIM FactView Dec22V2.xlsx")) %>% 
  rename_all(tolower) %>% 
  filter(operatingunit == "South Sudan", standardizeddisaggregate == "ProgramStatus") %>% 
  group_by(indicator, otherdisaggregate) %>% 
  summarize_at(vars(contains("fy2017q"), fy2017apr), ~sum(., na.rm = TRUE)) %>% 
  ungroup()


read_excel(file.path(loc, "SSudan PSNUxIM FactView Dec22V2.xlsx")) %>% 
  rename_all(tolower) %>% 
  group_by(indicator, standardizeddisaggregate) %>% 
  summarize_at(vars(contains("fy2017q"), fy2017apr), ~sum(., na.rm = TRUE)) %>% 
  ungroup() %>% 
  print(n = Inf)


#import normal Fact View PSNUxIM
df_mer <- read_rds("~/ICPI/Data/ICPI_FactView_PSNU_IM_20171222_v2_2.Rds") %>%
  #select just South Sudan

  
t <-  bind_rows(df_mer, df_ssd_psnuim)