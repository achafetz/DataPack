##   Data Pack COP FY18
##   A.Chafetz, USAID
##   Purpose: export codebooks from templates
##   Date: Jan 28, 2018
##   Updated:  

## DEPENDENCIES
# run 00_datapack_initialize.R
# Data Pack Template


## EXPORT PUBLIC CODEBOOKS -------------------------------------------------------------------------------------------

#export codebook for DATIM Indicator table
  read_excel(Sys.glob(file.path(templategeneration,"COP18DataPackTemplate v*.xlsm")), 
                           sheet = "POPsubset", col_names = TRUE) %>% 
     select(`Data Pack Indicator Title`,	`Data Pack Indicator Name`,	indicator,	standardizeddisaggregate,	sex,
             age,	resultstatus,	otherdisaggregate,	modality,	numeratorDenom,	resulttarget) %>% 
     write_csv(file.path(documents, "COP18 Data Pack Indicators.csv"), na = "")
  
#export cookbook for IM Allocation
  read_excel(Sys.glob(file.path(templategeneration,"COP18DataPackTemplate v*.xlsm")), 
                           sheet = "POPsubsetIM", col_names = TRUE) %>% 
    select(`Data Pack Indicator Title`,	`Data Pack Indicator Name`,	indicator,	standardizeddisaggregate,	sex,
            age,	resultstatus,	otherdisaggregate,	modality,	numeratorDenom,	resulttarget) %>% 
    write_csv(file.path(documents, "COP18 Data Pack Indicators - IM Allocation.csv"), na = "")
  
#export codebook for Disagg tool
  read_excel(Sys.glob(file.path(templategeneration,"COP18DisaggToolTemplate v*.xlsm")), 
             sheet = "POPsubset", col_names = TRUE) %>% 
    select(`Disagg Tool Indicator Title` = dt_categoryoptioncombo,	`Disagg Tool Indicator Name` = dt_ind_name,	indicator,	standardizeddisaggregate,	sex,
           age,	resultstatus,	otherdisaggregate,	modality,	numeratordenom) %>% 
    write_csv(file.path(documents, "COP18 Disagg Tool Indicators.csv"), na = "")

#export codebook for HTS Disagg tool
  read_excel(Sys.glob(file.path(templategeneration,"COP18DisaggToolTemplate_HTS v*.xlsm")), 
             sheet = "POPsubset", col_names = TRUE) %>% 
    select(`Disagg Tool Indicator Title` = dt_categoryoptioncombo,	`Disagg Tool Indicator Name` = dt_ind_name,	indicator,	standardizeddisaggregate,	sex,
           age,	resultstatus,	otherdisaggregate,	modality,	numeratordenom) %>% 
    write_csv(file.path(documents, "COP18 Disagg Tool HTS Indicators.csv"), na = "") 
  
  
  