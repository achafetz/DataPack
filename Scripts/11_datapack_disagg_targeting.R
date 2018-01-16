##   Data Pack COP FY18
##   A.Chafetz, USAID
##   Purpose: generate disagg distribution for targeting
##   Adopted from COP17 Stata code
##   Date: Oct 26, 2017
##   Updated: 1/16/18 

## DEPENDENCIES
# run 00_datapack_initialize.R
# ICPI Fact View PSNU
# list of all disagg indicators and denom groups (disagg_ind_grps.txt)


## IMPORT DATA ------------------------------------------------------------------------------------------------------    

  #import
    df_disaggdistro <- read_rds(file.path(fvdata, paste0("ICPI_FactView_PSNU_", datestamp, ".RDS")))
  
  #cleanup PSNUs (dups & clusters)
    source(file.path(scripts, "92_datapack_snu_adj.R"))
    df_disaggdistro <- cluster_snus(df_disaggdistro)
    df_disaggdistro <- cleanup_snus(df_disaggdistro)
      rm(cleanup_snus, cluster_snus)
  
  #import disagg mapping table
    df_disaggs <- read_csv(file.path(rawdata, "disagg_ind_grps.txt")) %>% 
      filter(!is.na(standardizeddisaggregate))  %>% #remove rows where there are no associated MER indicators in FY17 (eg Tx_NEW Age/Sex 24-29 M)
      select(-dt_dataelementgrp, -dt_categoryoptioncombo) #remove columns that just identify information in the disagg tool
  
## SUBSET DATA OF INTEREST  ---------------------------------------------------------------------------------------  
  
  #identify which indicators and disaggs to filter by to reduce file size we're working with
    lst_inds <- unique(df_disaggs$indicator)
    lst_disaggs <- unique(df_disaggs$standardizeddisaggregate)
    
  #limit to indicators with targets for COP18 (no MCAD disaggs)
    df_disaggdistro <- df_disaggdistro %>% 
      filter(indicator %in% lst_inds, standardizeddisaggregate %in% lst_disaggs,
             ismcad == "N",
             !is.na(fy2017apr), 
             fy2017apr!=0) %>% 
  #limit to just key variables
      select(operatingunit, psnuuid, psnu, currentsnuprioritization, indicator:indicatortype, standardizeddisaggregate, age:modality, fy2017apr) %>% 
  #convert snu prioritizations from factor to character    
      mutate(currentsnuprioritization = as.character(currentsnuprioritization)) %>% 
    
  #aggregate to psnu x disagg [type] level to have one line per obs
      group_by_if(is.character) %>%
      summarise_at(vars(fy2017apr), funs(sum(., na.rm = TRUE))) %>%
      ungroup() 

    rm(lst_disaggs, lst_inds)
    
## MAP VARIABLES -------------------------------------------------------------------------------------
  # rather than use ifelse formulas, going to tag each unique variable combo with it's associated disagg tool variable

  #need to replace all the "NULL" in modality to NA in order to match disaggs & make it a character
    df_disaggdistro <- df_disaggdistro %>% 
        mutate(modality = ifelse(modality == "NULL", NA, modality),
               modality = as.character(modality))
  
  #check if there are variables from the disagg files that do not match with the PSNU allocation
    if(nrow(anti_join(df_disaggs, df_disaggdistro))>0) {
      df_notjoined <- anti_join(df_disaggs, df_disaggdistro)
      stop("mapped variables no mapping; inspect df_notjoined")
    }
    
  #map onto main PSNU allocation dataframe
    df_disaggdistro <- left_join(df_disaggdistro, df_disaggs)
      rm(df_disaggs)
    
  #replace missing dt_ind with "none"
    df_disaggdistro <- df_disaggdistro %>% 
      mutate(dt_ind_name = if_else(is.na(dt_ind_name), "not_used", dt_ind_name))

## DISAGG GROUPING  ---------------------------------------------------------------------------------------  
        
  #create a disagg group as the denominator for the allocation share
  #default = standardizeddisaggregate (+ psnuuid +indicator + indicatortype + numeratordenom)
  #need to create unique groups where data pack creates multiple targets (eg TX_CURR <15 & TX_CURR)
    df_disaggdistro <- df_disaggdistro %>%   
      filter(!otherdisaggregate %in% c("Unknown Sex", "Known at Entry  Unknown Sex", "Newly Identified  Unknown Sex", 
                                      "Undocumented Test Indication Unknown Sex", "Routine Unknown Sex")) %>% #remove any unknown sex from group
      mutate(grouping = standardizeddisaggregate,
             grouping = ifelse(indicator == "OVC_SERV" & standardizeddisaggregate == "Age/Sex/Service", paste(standardizeddisaggregate, otherdisaggregate, sep = " - "), grouping),
             grouping = ifelse(indicator == "OVC_SERV" & (standardizeddisaggregate %in% c("AgeLessThanTen", "AgeAboveTen/Sex")) & (age %in% c("<01", "01-09", "10-14", "15-17")), paste(standardizeddisaggregate, "<18", sep = " - "), grouping),
             grouping = ifelse(indicator == "OVC_SERV" & standardizeddisaggregate == "AgeAboveTen/Sex" & (age %in% c("18-24", "25+")), paste(standardizeddisaggregate, "18+", sep = " - "), grouping),
             grouping = ifelse(indicator == "PMTCT_STAT" & standardizeddisaggregate == "Age/KnownNewResult", paste(standardizeddisaggregate, " - ", otherdisaggregate, resultstatus, sep = " "), grouping),
             grouping = ifelse(indicator == "TB_STAT" & standardizeddisaggregate == "Age/Sex/KnownNewPosNeg", paste(standardizeddisaggregate, " - ", otherdisaggregate, resultstatus, sep = " "), grouping),
             grouping = ifelse((indicator %in% c("TX_CURR", "TX_NEW")) & (standardizeddisaggregate %in% c("AgeLessThanTen", "AgeAboveTen/Sex")) & (age %in% c("<01", "01-09", "10-14")), paste(standardizeddisaggregate, "<15", sep = " - "), grouping),
             grouping = ifelse((indicator %in% c("TX_CURR", "TX_NEW")) & standardizeddisaggregate=="AgeAboveTen/Sex" & (age %in% c("15-19", "20-24", "25-49", "50+")), paste(standardizeddisaggregate, "15+", sep = " - "), grouping),
             grouping = ifelse(indicator == "TX_RET" & standardizeddisaggregate == "AgeAboveTen/Sex" & (age %in% c("15-19", "20-24", "25-49", "50+")), paste(standardizeddisaggregate, "- 15+", sep = ""), grouping),
             grouping = ifelse(indicator == "VMMC_CIRC" & standardizeddisaggregate == "Age" & (age %in% c("15-19", "20-24", "25-29")), paste(standardizeddisaggregate, "Primary", sep = " - "), grouping),
             grouping = ifelse(indicator == "VMMC_CIRC" & standardizeddisaggregate == "Age" & (age %in% c("[months] 00-02", "02 months - 09 years", "10-14", "50+")), paste(standardizeddisaggregate, "Other", sep = " - "), grouping)
      )
        
        
## AGGREGATE GROUPS  ---------------------------------------------------------------------------------------         
  
  #aggregate indicators (multiple combos need to sum up (eg <15 = <01,01-09, 10-14) before dividing by denom)
    df_disaggdistro <- df_disaggdistro %>% 
      select(operatingunit:psnu, indicator, dt_ind_name, grouping, indicatortype, fy2017apr) %>% 
      group_by_if(is.character) %>% 
      summarise_at(vars(fy2017apr), funs(sum(.))) %>% 
      ungroup
      
  #create a group denominator
    df_disaggdistro <- df_disaggdistro %>% 
        group_by(operatingunit, psnuuid, psnu, indicator, grouping, indicatortype) %>% 
        mutate(grp_denom = sum(fy2017apr)) %>% 
        ungroup
        
## CALCULATE DISTRIBUTION  -----------------------------------------------------------------------  

  #divide indicator totals by denoms to get the distribution
    df_disaggdistro <- df_disaggdistro %>% 
      mutate(distro = round(fy2017apr/grp_denom, 3))
               
    
## EXPORT  --------------------------------------------------------------------------------------- 

  #keep relevant variables
    df_disaggdistro <- df_disaggdistro %>% 
      select(operatingunit, psnu, psnuuid, dt_ind_name, indicatortype, distro) %>% 
      arrange(operatingunit, psnu, dt_ind_name, indicatortype) %>% 
  #remove indicators just used for denom calculation (ie not included/used in the disagg tool)
      filter(dt_ind_name != "not_used") 
  #convert to wide
      #spread(dt_ind_name, distro)
  
  #export
    write_csv(df_disaggdistro, file.path(output, paste("Global_DisaggDistro.csv", sep="")), na = "")
      rm(df_disaggdistro)

     
