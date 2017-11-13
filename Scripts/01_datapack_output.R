##   Data Pack COP FY18
##   A.Chafetz, USAID
##   Purpose: generate output for Excel based Data Pack at SNU level
##   Adopted from COP17 Stata code
##   Date: Oct 8, 2017
##   Updated: 11/7

## DEPENDENCIES
    # run 00_datapack_initialize.R
    # ICPI Fact View NAT_SUBNAT
    # ICPI Fact View PSNU
    # 92_datapack_snu_adj.R


## NAT_SUBNAT --------------------------------------------------------------------------------------------------

  #import data
    df_subnat <- read_tsv(file.path(fvdata, paste("ICPI_FactView_NAT_SUBNAT_", datestamp, ".txt", sep=""))) %>% 
        rename_all(df_subnat, tolower) %>% 
    
  #align nat_subnat names with what is in fact view
      rename(fy2015apr= fy2015q4, fy2016apr = fy2016, fy2017apr = fy2017)
    

## MER - PSNUxIM ----------------------------------------------------------------------------------------------
    
  #import
    df_mer  <- read_tsv(file.path(fvdata, paste("ICPI_FactView_PSNU_", datestamp, ".txt", sep=""))) %>% 
                rename_all(tolower)
    
  
## APPEND -----------------------------------------------------------------------------------------------------
    df_indtbl <- bind_rows(df_mer, df_subnat)
      rm(df_mer, df_subnat)
    
    #cleanup PSNUs (dups & clusters)
      source(file.path(scripts, "92_datapack_snu_adj.R"))
      cleanup_snus(df_indtbl)
      cluster_snus(df_indtbl)

      
## REMOVE BELOW  -------------------------------------------------------------------------------------------------
      
    ## FOR TESTING ONLY ## REMOVE after FY17 APR becomes available ##
      
      source(file.path(scripts, "93_datapack_testingdata.R"))
      testing_dummydata(df_indtbl)
      
#  ^^^^^^ REMOVE ABOVE ^^^^^^
      
## AGGREGATE TO PNSU X DISAGGS LEVEL ------------------------------------------------------------------------------
    
    #have to aggregate here; otherwise variable generation vector (next section) is too large to run
      df_indtbl <- df_indtbl %>%
        filter(is.na(typemilitary)) %>% #remove military data (will only use placeholders in the data pack)
        group_by(operatingunit, snu1, psnu, psnuuid, fy18snuprioritization, indicator, standardizeddisaggregate, 
                 sex, age, resultstatus, otherdisaggregate, modality, numeratordenom) %>%
          summarize_at(vars(fy2015apr, fy2016apr, fy2017apr, fy2017_targets, fy2018_targets), funs(sum(., na.rm=TRUE))) %>%
          ungroup

## CLEAN UP -------------------------------------------------------------------------------------------------------
    
    df_indtbl <- df_indtbl %>%
      
    #remove blank rows(and military)
      drop_na(psnuuid)  %>%
      
    #rename
      rename(snulist = psnu, 
             priority_snu = fy18snuprioritization)

    #add military districts back in as row placeholder for country entry
      df_mil <- read_csv(file.path(rawdata, "COP18_mil_psnus.csv"))
    
    #append military data onto indicator table 
      df_indtbl <- bind_rows(df_indtbl, df_mil)
      rm(df_mil)
    
    #rename prioritizations (due to spacing and to match last year)
      priority_levels <- c("1 - Scale-Up: Saturation", "2 - Scale-Up: Aggressive", "4 - Sustained", "5 - Centrally Supported",
                           "6 - Sustained: Commodities", "7 - Attained", "8 - Not PEPFAR Supported", "Mil", "NOT DEFINED")
      df_indtbl <- mutate(df_indtbl, priority_snu = ifelse(is.na(priority_snu), "NOT DEFINED", priority_snu))
      df_indtbl$priority_snu <- parse_factor(df_indtbl$priority_snu, priority_levels, include_na = TRUE) #convert to factor
      
      df_indtbl <- df_indtbl %>%
        mutate(priority_snu = fct_recode(priority_snu,
                                         "ScaleUp Sat"    =  "1 - Scale-Up: Saturation", 
                                         "ScaleUp Agg"    =  "2 - Scale-Up: Aggressive", 
                                         "Sustained"      =  "4 - Sustained", 
                                         "Ctrl Supported" =  "5 - Centrally Supported",  
                                         "Sustained Com"  =  "6 - Sustained: Commodities",
                                         "Attained"       =  "7 - Attained",  
                                         "Not Supported"  =  "8 - Not PEPFAR Supported"))
      
## SAVE TEMP FILE -------------------------------------------------------------------------------------------------
    #save temp file as starting point for 02_datapack_output_keyind
      save(df_indtbl, file = file.path(tempoutput, "append_temp.RData"))
    
## GENERATE VARIABLES/COLUMNS -------------------------------------------------------------------------------------
  # output formulas created in Data Pack template (POPsubset sheet)
  # updated 11/13
    
    df_indtbl <- df_indtbl %>%
    mutate(
      hts_tst = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_pos = ifelse((indicator=="HTS_TST_POS" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_u15 = ifelse((indicator=="HTS_TST" & standardizeddisaggregate %in% c("Modality/AgeLessThanTen/Result", "Modality/AgeAboveTen/Sex/Result") & age %in% c("<01", "01-09", "10-14" ) & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_pos_u15 = ifelse((indicator=="HTS_TST_POS" & standardizeddisaggregate %in% c("Modality/AgeLessThanTen/Result", "Modality/AgeAboveTen/Sex/Result") & age %in% c("<01", "01-09", "10-14" ) & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_u15_yield = 0, 
      hts_tst_neg_indexmod_o15 = ifelse((indicator=="HTS_TST_NEG" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age==">15" & modality=="IndexMod" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_neg_mobilemod_o15 = ifelse((indicator=="HTS_TST_NEG" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age==">15" & modality=="MobileMod" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_neg_vctmod_o15 = ifelse((indicator=="HTS_TST_NEG" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age==">15" & modality=="VCTMod" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_neg_othermod_o15 = ifelse((indicator=="HTS_TST_NEG" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age==">15" & modality=="OtherMod" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_neg_index_o15 = ifelse((indicator=="HTS_TST_NEG" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age==">15" & modality=="Index" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_neg_sti_o15 = ifelse((indicator=="HTS_TST_NEG" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age==">15" & modality=="STI" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_neg_inpat_o15 = ifelse((indicator=="HTS_TST_NEG" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age==">15" & modality=="Inpat" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_neg_emergency_o15 = ifelse((indicator=="HTS_TST_NEG" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age==">15" & modality=="Emergency" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_neg_vct_o15 = ifelse((indicator=="HTS_TST_NEG" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age==">15" & modality=="VCT" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_neg_tbclinic_o15 = ifelse((indicator=="HTS_TST_NEG" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age==">15" & modality=="TBClinic" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_neg_vmmc_o15 = ifelse((indicator=="HTS_TST_NEG" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age==">15" & modality=="VMMC" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_neg_pediatric_o15 = ifelse((indicator=="HTS_TST_NEG" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age==">15" & modality=="Pediatric" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_neg_malnutrition_o15 = ifelse((indicator=="HTS_TST_NEG" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age==">15" & modality=="Malnutrition" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_neg_otherpitc_o15 = ifelse((indicator=="HTS_TST_NEG" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age==">15" & modality=="OtherPITC" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_pos_indexmod_o15 = ifelse((indicator=="HTS_TST_POS" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age==">15" & modality=="IndexMod" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_pos_mobilemod_o15 = ifelse((indicator=="HTS_TST_POS" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age==">15" & modality=="MobileMod" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_pos_vctmod_o15 = ifelse((indicator=="HTS_TST_POS" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age==">15" & modality=="VCTMod" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_pos_othermod_o15 = ifelse((indicator=="HTS_TST_POS" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age==">15" & modality=="OtherMod" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_pos_index_o15 = ifelse((indicator=="HTS_TST_POS" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age==">15" & modality=="Index" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_pos_sti_o15 = ifelse((indicator=="HTS_TST_POS" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age==">15" & modality=="STI" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_pos_inpat_o15 = ifelse((indicator=="HTS_TST_POS" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age==">15" & modality=="Inpat" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_pos_emergency_o15 = ifelse((indicator=="HTS_TST_POS" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age==">15" & modality=="Emergency" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_pos_vct_o15 = ifelse((indicator=="HTS_TST_POS" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age==">15" & modality=="VCT" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_pos_tbclinic_o15 = ifelse((indicator=="HTS_TST_POS" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age==">15" & modality=="TBClinic" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_pos_vmmc_o15 = ifelse((indicator=="HTS_TST_POS" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age==">15" & modality=="VMMC" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_pos_pediatric_o15 = ifelse((indicator=="HTS_TST_POS" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age==">15" & modality=="Pediatric" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_pos_malnutrition_o15 = ifelse((indicator=="HTS_TST_POS" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age==">15" & modality=="Malnutrition" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_pos_otherpitc_o15 = ifelse((indicator=="HTS_TST_POS" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age==">15" & modality=="OtherPITC" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_spd_tot_pos_o15 = 0, 
      hts_tst_neg_indexmod_u15 = ifelse((indicator=="HTS_TST_NEG" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="<15" & modality=="IndexMod" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_neg_mobilemod_u15 = ifelse((indicator=="HTS_TST_NEG" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="<15" & modality=="MobileMod" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_neg_vctmod_u15 = ifelse((indicator=="HTS_TST_NEG" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="<15" & modality=="VCTMod" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_neg_othermod_u15 = ifelse((indicator=="HTS_TST_NEG" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="<15" & modality=="OtherMod" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_neg_index_u15 = ifelse((indicator=="HTS_TST_NEG" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="<15" & modality=="Index" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_neg_sti_u15 = ifelse((indicator=="HTS_TST_NEG" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="<15" & modality=="STI" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_neg_inpat_u15 = ifelse((indicator=="HTS_TST_NEG" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="<15" & modality=="Inpat" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_neg_emergency_u15 = ifelse((indicator=="HTS_TST_NEG" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="<15" & modality=="Emergency" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_neg_vct_u15 = ifelse((indicator=="HTS_TST_NEG" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="<15" & modality=="VCT" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_neg_tbclinic_u15 = ifelse((indicator=="HTS_TST_NEG" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="<15" & modality=="TBClinic" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_neg_vmmc_u15 = ifelse((indicator=="HTS_TST_NEG" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="<15" & modality=="VMMC" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_neg_pmtctanc_u15 = ifelse((indicator=="HTS_TST_NEG" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="<15" & modality=="PMTCT ANC" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_neg_pediatric_u15 = ifelse((indicator=="HTS_TST_NEG" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="<15" & modality=="Pediatric" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_neg_malnutrition_u15 = ifelse((indicator=="HTS_TST_NEG" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="<15" & modality=="Malnutrition" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_neg_otherpitc_u15 = ifelse((indicator=="HTS_TST_NEG" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="<15" & modality=="OtherPITC" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_pos_indexmod_u15 = ifelse((indicator=="HTS_TST_POS" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="<15" & modality=="IndexMod" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_pos_mobilemod_u15 = ifelse((indicator=="HTS_TST_POS" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="<15" & modality=="MobileMod" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_pos_vctmod_u15 = ifelse((indicator=="HTS_TST_POS" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="<15" & modality=="VCTMod" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_pos_othermod_u15 = ifelse((indicator=="HTS_TST_POS" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="<15" & modality=="OtherMod" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_pos_index_u15 = ifelse((indicator=="HTS_TST_POS" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="<15" & modality=="Index" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_pos_sti_u15 = ifelse((indicator=="HTS_TST_POS" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="<15" & modality=="STI" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_pos_inpat_u15 = ifelse((indicator=="HTS_TST_POS" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="<15" & modality=="Inpat" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_pos_emergency_u15 = ifelse((indicator=="HTS_TST_POS" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="<15" & modality=="Emergency" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_pos_vct_u15 = ifelse((indicator=="HTS_TST_POS" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="<15" & modality=="VCT" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_pos_tbclinic_u15 = ifelse((indicator=="HTS_TST_POS" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="<15" & modality=="TBClinic" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_pos_vmmc_u15 = ifelse((indicator=="HTS_TST_POS" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="<15" & modality=="VMMC" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_pos_pmtctanc_u15 = ifelse((indicator=="HTS_TST_POS" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="<15" & modality=="PMTCT ANC" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_pos_pediatric_u15 = ifelse((indicator=="HTS_TST_POS" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="<15" & modality=="Pediatric" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_pos_malnutrition_u15 = ifelse((indicator=="HTS_TST_POS" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="<15" & modality=="Malnutrition" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_pos_otherpitc_u15 = ifelse((indicator=="HTS_TST_POS" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="<15" & modality=="OtherPITC" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_spd_tot_pos_u15 = 0, 
      hts_tst_kp = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="KeyPop/Result" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_kp_T = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="KeyPop/Result" & numeratordenom=="N"), fy2018_targets, 0), 
      kp_prev_msm_D = ifelse((indicator=="KP_PREV" & standardizeddisaggregate=="KeyPop" & otherdisaggregate=="MSM" & numeratordenom=="D"), fy2017apr, 0), 
      kp_prev_msm_sw = ifelse((indicator=="KP_PREV" & standardizeddisaggregate=="KeyPop" & otherdisaggregate=="MSM SW" & numeratordenom=="N"), fy2017apr, 0), 
      kp_prev_msm_sw_T = ifelse((indicator=="KP_PREV" & standardizeddisaggregate=="KeyPop" & otherdisaggregate=="MSM SW" & numeratordenom=="N"), fy2018_targets, 0), 
      kp_prev_msm_not_sw = ifelse((indicator=="KP_PREV" & standardizeddisaggregate=="KeyPop" & otherdisaggregate=="MSM not SW" & numeratordenom=="N"), fy2017apr, 0), 
      kp_prev_msm_not_sw_T = ifelse((indicator=="KP_PREV" & standardizeddisaggregate=="KeyPop" & otherdisaggregate=="MSM not SW" & numeratordenom=="N"), fy2018_targets, 0), 
      kp_prev_tg_D = ifelse((indicator=="KP_PREV" & standardizeddisaggregate=="KeyPop" & otherdisaggregate=="TG" & numeratordenom=="D"), fy2017apr, 0), 
      kp_prev_tg_sw = ifelse((indicator=="KP_PREV" & standardizeddisaggregate=="KeyPop" & otherdisaggregate=="TG SW" & numeratordenom=="N"), fy2017apr, 0), 
      kp_prev_tg_sw_T = ifelse((indicator=="KP_PREV" & standardizeddisaggregate=="KeyPop" & otherdisaggregate=="TG SW" & numeratordenom=="N"), fy2018_targets, 0), 
      kp_prev_tg_not_sw = ifelse((indicator=="KP_PREV" & standardizeddisaggregate=="KeyPop" & otherdisaggregate=="TG not SW" & numeratordenom=="N"), fy2017apr, 0), 
      kp_prev_tg_not_sw_T = ifelse((indicator=="KP_PREV" & standardizeddisaggregate=="KeyPop" & otherdisaggregate=="TG not SW" & numeratordenom=="N"), fy2018_targets, 0), 
      kp_prev_fsw_D = ifelse((indicator=="KP_PREV" & standardizeddisaggregate=="KeyPop" & otherdisaggregate=="FSW" & numeratordenom=="D"), fy2017apr, 0), 
      kp_prev_fsw = ifelse((indicator=="KP_PREV" & standardizeddisaggregate=="KeyPop" & otherdisaggregate=="FSW" & numeratordenom=="N"), fy2017apr, 0), 
      kp_prev_fsw_T = ifelse((indicator=="KP_PREV" & standardizeddisaggregate=="KeyPop" & otherdisaggregate=="FSW" & numeratordenom=="N"), fy2018_targets, 0), 
      kp_prev_pwid_m_D = ifelse((indicator=="KP_PREV" & standardizeddisaggregate=="KeyPop" & otherdisaggregate=="Male PWID" & numeratordenom=="D"), fy2017apr, 0), 
      kp_prev_pwid_m = ifelse((indicator=="KP_PREV" & standardizeddisaggregate=="KeyPop" & otherdisaggregate=="Male PWID" & numeratordenom=="N"), fy2017apr, 0), 
      kp_prev_pwid_m_T = ifelse((indicator=="KP_PREV" & standardizeddisaggregate=="KeyPop" & otherdisaggregate=="Male PWID" & numeratordenom=="N"), fy2018_targets, 0), 
      kp_prev_pwid_f_D = ifelse((indicator=="KP_PREV" & standardizeddisaggregate=="KeyPop" & otherdisaggregate=="Female PWID" & numeratordenom=="D"), fy2017apr, 0), 
      kp_prev_pwid_f = ifelse((indicator=="KP_PREV" & standardizeddisaggregate=="KeyPop" & otherdisaggregate=="Female PWID" & numeratordenom=="N"), fy2017apr, 0), 
      kp_prev_pwid_f_T = ifelse((indicator=="KP_PREV" & standardizeddisaggregate=="KeyPop" & otherdisaggregate=="Female PWID" & numeratordenom=="N"), fy2018_targets, 0), 
      kp_prev_prison_D = ifelse((indicator=="KP_PREV" & standardizeddisaggregate=="KeyPop" & otherdisaggregate=="People in prisons and other enclosed settings" & numeratordenom=="D"), fy2017apr, 0), 
      kp_prev_prison = ifelse((indicator=="KP_PREV" & standardizeddisaggregate=="KeyPop" & otherdisaggregate=="People in prisons and other enclosed settings" & numeratordenom=="N"), fy2017apr, 0), 
      kp_prev_prison_T = ifelse((indicator=="KP_PREV" & standardizeddisaggregate=="KeyPop" & otherdisaggregate=="People in prisons and other enclosed settings" & numeratordenom=="N"), fy2018_targets, 0), 
      kp_mat = ifelse((indicator=="KP_MAT" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2017apr, 0), 
      kp_mat_T = ifelse((indicator=="KP_MAT" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2018_targets, 0), 
      ovc_serv = ifelse((indicator=="OVC_SERV" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2017apr, 0), 
      ovc_serv_T = ifelse((indicator=="OVC_SERV" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2018_targets, 0), 
      ovc_serv_u18 = ifelse((indicator=="OVC_SERV" & standardizeddisaggregate %in% c("AgeLessThanTen", "AgeAboveTen/Sex") & age %in% c("<01", "01-09", "10-14", "15-17") & numeratordenom=="N"), fy2017apr, 0), 
      ovc_serv_u18_T = ifelse((indicator=="OVC_SERV" & standardizeddisaggregate %in% c("AgeLessThanTen", "AgeAboveTen/Sex") & age %in% c("<01", "01-09", "10-14", "15-17") & numeratordenom=="N"), fy2018_targets, 0), 
      ovc_serv_grad_T = ifelse((indicator=="OVC_SERV" & standardizeddisaggregate=="Program Status" & otherdisaggregate=="Beneficiaries Served Graduated" & numeratordenom=="N"), fy2018_targets, 0), 
      ovc_serv_active_T = ifelse((indicator=="OVC_SERV" & standardizeddisaggregate=="Program Status" & otherdisaggregate=="Beneficiaries Served Active" & numeratordenom=="N"), fy2018_targets, 0), 
      ovc_serv_exited_T = ifelse((indicator=="OVC_SERV" & standardizeddisaggregate=="Program Status" & otherdisaggregate=="Beneficiaries Served Exited without Graduation" & numeratordenom=="N"), fy2018_targets, 0), 
      ovc_serv_trans_T = ifelse((indicator=="OVC_SERV" & standardizeddisaggregate=="Program Status" & otherdisaggregate=="Beneficiaries Served Transferred" & numeratordenom=="N"), fy2018_targets, 0), 
      ovc_serv_edu_T = ifelse((indicator=="OVC_SERV" & standardizeddisaggregate=="Age/Sex/Service" & otherdisaggregate=="Education Support" & numeratordenom=="N"), fy2018_targets, 0), 
      ovc_serv_care_T = ifelse((indicator=="OVC_SERV" & standardizeddisaggregate=="Age/Sex/Service" & otherdisaggregate=="Parenting/Caregiver Programs" & numeratordenom=="N"), fy2018_targets, 0), 
      ovc_serv_econ_T = ifelse((indicator=="OVC_SERV" & standardizeddisaggregate=="Age/Sex/Service" & otherdisaggregate=="Economic Strengthening" & numeratordenom=="N"), fy2018_targets, 0), 
      ovc_serv_sp_T = ifelse((indicator=="OVC_SERV" & standardizeddisaggregate=="Age/Sex/Service" & otherdisaggregate=="Social Protection" & numeratordenom=="N"), fy2018_targets, 0), 
      ovc_serv_oth_T = ifelse((indicator=="OVC_SERV" & standardizeddisaggregate=="Age/Sex/Service" & otherdisaggregate=="Other Service Areas" & numeratordenom=="N"), fy2018_targets, 0), 
      plhivsubnat = ifelse((indicator=="PLHIV (SUBNAT)" & standardizeddisaggregate=="Total Numerator"), fy2017apr, 0), 
      plhivsubnat,age/sex_u15 = ifelse((indicator=="PLHIV (SUBNAT, Age/Sex)" & standardizeddisaggregate=="Age/Sex" & age=="<15"), fy2017apr, 0), 
      plhivsubnat,age/sex_o15 = ifelse((indicator=="PLHIV (SUBNAT, Age/Sex)" & standardizeddisaggregate=="Age/Sex" & age=="15+"), fy2017apr, 0), 
      pmtct_art_already = ifelse((indicator=="PMTCT_ART" & standardizeddisaggregate=="NewExistingArt" & otherdisaggregate=="Life-long ART Already" & numeratordenom=="N"), fy2017apr, 0), 
      pmtct_art_already_T = ifelse((indicator=="PMTCT_ART" & standardizeddisaggregate=="NewExistingArt" & otherdisaggregate=="Life-long ART Already" & numeratordenom=="N"), fy2018_targets, 0), 
      pmtct_art_curr = ifelse((indicator=="PMTCT_ART" & standardizeddisaggregate=="NewExistingArt" & otherdisaggregate %in% c("Life-long ART New", "Triple-drug ARV") & numeratordenom=="N"), fy2017apr, 0), 
      pmtct_art_curr_T = ifelse((indicator=="PMTCT_ART" & standardizeddisaggregate=="NewExistingArt" & otherdisaggregate=="Life-long ART New" & numeratordenom=="N"), fy2018_targets, 0), 
      pmtct_eid = ifelse((indicator=="PMTCT_EID" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2017apr, 0), 
      pmtct_eid_T = ifelse((indicator=="PMTCT_EID" & standardizeddisaggregate=="InfantTest" & numeratordenom=="N"), fy2018_targets, 0), 
      pmtct_eid_pos_12mo = ifelse((indicator=="PMTCT_EID_POS_12MO" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2017apr, 0), 
      pmtct_eid_yield = 0, 
      pmtct_stat_D = ifelse((indicator=="PMTCT_STAT" & standardizeddisaggregate=="Total Denominator" & numeratordenom=="D"), fy2017apr, 0), 
      pmtct_stat_D_T = ifelse((indicator=="PMTCT_STAT" & standardizeddisaggregate=="Total Denominator" & numeratordenom=="D"), fy2018_targets, 0), 
      pmtct_stat = ifelse((indicator=="PMTCT_STAT" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2017apr, 0), 
      pmtct_stat_T = ifelse((indicator=="PMTCT_STAT" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2018_targets, 0), 
      pmtct_stat_pos = ifelse((indicator=="PMTCT_STAT" & standardizeddisaggregate=="Age/KnownNewResult" & resultstatus=="Positive" & numeratordenom=="N"), fy2017apr, 0), 
      pmtct_stat_yield = 0, 
      pmtct_stat_knownpos = ifelse((indicator=="PMTCT_STAT" & standardizeddisaggregate=="Age/KnownNewResult" & resultstatus=="Positive" & otherdisaggregate=="Known at Entry" & numeratordenom=="N"), fy2017apr, 0), 
      pop_estsubnat = ifelse((indicator=="POP_EST (SUBNAT)" & standardizeddisaggregate=="Total Numerator"), fy2017apr, 0), 
      pop_estsubnat,sex_m = ifelse((indicator=="POP_EST (SUBNAT, Sex)" & standardizeddisaggregate=="Total Numerator" & sex=="Male"), fy2017apr, 0), 
      pp_prev = ifelse((indicator=="PP_PREV" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2017apr, 0), 
      pp_prev_T = ifelse((indicator=="PP_PREV" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2018_targets, 0), 
      tb_art_T = ifelse((indicator=="TB_ART" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2018_targets, 0), 
      tb_stat_D = ifelse((indicator=="TB_STAT" & standardizeddisaggregate=="Total Denominator" & numeratordenom=="D"), fy2017apr, 0), 
      tb_stat_D_T = ifelse((indicator=="TB_STAT" & standardizeddisaggregate=="Total Denominator" & numeratordenom=="D"), fy2018_targets, 0), 
      tb_stat = ifelse((indicator=="TB_STAT" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2017apr, 0), 
      tb_stat_pos = ifelse((indicator=="TB_STAT_POS" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2017apr, 0), 
      tb_stat_T = ifelse((indicator=="TB_STAT" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2018_targets, 0), 
      tb_stat_yield = 0, 
      tx_curr = ifelse((indicator=="TX_CURR" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2017apr, 0), 
      tx_curr_T = ifelse((indicator=="TX_CURR" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2018_targets, 0), 
      tx_curr_u15 = ifelse((indicator=="TX_CURR" & standardizeddisaggregate=="MostCompleteAgeDisagg" & age=="<15" & numeratordenom=="N"), fy2017apr, 0), 
      tx_curr_u15_T = ifelse((indicator=="TX_CURR" & standardizeddisaggregate=="MostCompleteAgeDisagg" & age=="<15" & numeratordenom=="N"), fy2018_targets, 0), 
      tx_curr_o15_T = ifelse((indicator=="TX_CURR" & standardizeddisaggregate=="MostCompleteAgeDisagg" & age=="15+" & numeratordenom=="N"), fy2018_targets, 0), 
      tx_curr_subnat = ifelse((indicator=="TX_CURR_SUBNAT" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2017apr, 0), 
      tx_curr_subnat_u15 = ifelse((indicator=="TX_CURR_SUBNAT" & standardizeddisaggregate=="Age/Sex" & age=="<15" & numeratordenom=="N"), fy2017apr, 0), 
      tx_new = ifelse((indicator=="TX_NEW" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2017apr, 0), 
      tx_new_T = ifelse((indicator=="TX_NEW" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2018_targets, 0), 
      tx_new_u15 = ifelse((indicator=="TX_NEW" & standardizeddisaggregate=="MostCompleteAgeDisagg" & age=="<15" & numeratordenom=="N"), fy2017apr, 0), 
      tx_new_u15_T = ifelse((indicator=="TX_NEW" & standardizeddisaggregate=="MostCompleteAgeDisagg" & age=="<15" & numeratordenom=="N"), fy2018_targets, 0), 
      tx_new_u1 = ifelse((indicator=="TX_NEW" & standardizeddisaggregate=="AgeLessThanTen" & age=="<01" & numeratordenom=="N"), fy2017apr, 0), 
      tx_new_u1_T = ifelse((indicator=="TX_NEW" & standardizeddisaggregate=="AgeLessThanTen" & age=="<01" & numeratordenom=="N"), fy2018_targets, 0), 
      tx_ret_D = ifelse((indicator=="TX_RET" & standardizeddisaggregate=="Total Denominator" & numeratordenom=="D"), fy2017apr, 0), 
      tx_ret = ifelse((indicator=="TX_RET" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2017apr, 0), 
      tx_ret_yield = 0, 
      tx_ret_u15_D = ifelse((indicator=="TX_RET" & standardizeddisaggregate %in% c("AgeLessThanTen", "AgeAboveTen/Sex") & age %in% c("<01", "01-09", "10-14") & numeratordenom=="D"), fy2017apr, 0), 
      tx_ret_u15 = ifelse((indicator=="TX_RET" & standardizeddisaggregate %in% c("AgeLessThanTen", "AgeAboveTen/Sex") & age %in% c("<01", "01-09", "10-14") & numeratordenom=="N"), fy2017apr, 0), 
      tx_ret_u15_yield = 0, 
      vmmc_circ_T = ifelse((indicator=="VMMC_CIRC" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2018_targets, 0), 
      vmmc_circ_rng_T = ifelse((indicator=="VMMC_CIRC" & standardizeddisaggregate=="Age" & age %in% c("15-19", "20-24", "25-29") & numeratordenom=="N"), fy2018_targets, 0), 
      vmmc_circ_subnat = ifelse((indicator=="VMMC_CIRC_SUBNAT" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2017apr, 0))
      
      
## AGGREGATE TO PSNU LEVEL ----------------------------------------------------------------------------------------
    #have to aggregate here; otherwise variable generation vector (next section) is too large to run
    
    df_indtbl <- df_indtbl %>%
      group_by(operatingunit, snu1, snulist, psnuuid, priority_snu) %>%
      summarize_at(vars(hts_tst:vmmc_circ_subnat), funs(sum(., na.rm=TRUE))) %>%
      ungroup  %>%
    
    #reorder columns
      select(operatingunit, psnuuid, snulist, snu1, priority_snu, hts_tst:vmmc_circ_subnat) %>%
    
    #sort by PLHIV
      arrange(operatingunit, desc(plhivsubnat), snulist) 
      
## EXPORT -------------------------------------------------------------------------------------------------------
      
  write_csv(df_indtbl, file.path(output, paste("Global_IndTbl.csv", sep="")), na = "")
    rm(df_indtbl, priority_levels)
    