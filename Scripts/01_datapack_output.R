##   Data Pack COP FY18
##   A.Chafetz, USAID
##   Purpose: generate output for Excel based Data Pack at SNU level
##   Adopted from COP17 Stata code
##   Date: Oct 8, 2017
##   Updated: 2/13

## DEPENDENCIES
# run 00_datapack_initialize.R
# ICPI Fact View NAT_SUBNAT
# ICPI Fact View PSNU
# South Sudan adjusted Fact View (out from 97_datapack_ssd_adjustment.R)
# 92_datapack_snu_adj.R


## NAT_SUBNAT --------------------------------------------------------------------------------------------------

  #import data
    df_subnat <- read_rds(Sys.glob(file.path(fvdata, "ICPI_FactView_NAT_SUBNAT_*.Rds"))) %>% 
  
  #align nat_subnat names with what is in fact view
    rename(fy2016apr = fy2016, fy2017apr = fy2017,
         currentsnuprioritization = fy17snuprioritization) %>% 
  
  #add in standardized disaggegate as column since missing and that's what's used to generate new vars
    mutate(standardizeddisaggregate = disaggregate)


## MER - PSNUxIM ----------------------------------------------------------------------------------------------

  #import
    df_mer <- read_rds(Sys.glob(file.path(fvdata, "ICPI_FactView_PSNU_2*.Rds")))
  
  #add South Sudan's data, missing from Q1+Q2 in regular Q4v2_2 FV
    source(file.path(scripts, "97_datapack_ssd_adjustment.R"))
    df_mer <- add_ssd_fv(df_mer, "PSNU")
      rm(add_ssd_fv)
      
    
## APPEND -----------------------------------------------------------------------------------------------------
    df_indtbl <- bind_rows(df_mer, df_subnat)
        rm(df_mer, df_subnat)

  #cleanup PSNUs (dups & clusters)
    source(file.path(scripts, "92_datapack_snu_adj.R"))
    df_indtbl <- cluster_snus(df_indtbl)
    df_indtbl <- cleanup_snus(df_indtbl)
      rm(cleanup_snus, cluster_snus)

## AGGREGATE TO PSNU X DISAGGS LEVEL ------------------------------------------------------------------------------
      
  #OVC Total Numerator Creation
    df_ovc <- df_indtbl %>% 
      #total numerator = sum of all program status -> filter
      filter(indicator=="OVC_SERV" & standardizeddisaggregate == "ProgramStatus") %>% 
      #group up to OUxIMxType level & summarize (will need to change grouping for different datasets)
      group_by(operatingunit, snu1, psnu, psnuuid, currentsnuprioritization, typemilitary, indicator, numeratordenom) %>% 
      summarize_at(vars(fy2017apr), funs(sum(., na.rm = TRUE))) %>% 
      ungroup() %>% 
      #add standardized disagg
      add_column(standardizeddisaggregate = "Total Numerator", .before = "numeratordenom")
    
  #add total numerator onto OUxIM
      df_indtbl <- bind_rows(df_indtbl, df_ovc) 
      rm(df_ovc)

  #have to aggregate here; otherwise variable generation vector (next section) is too large to run
    df_indtbl <- df_indtbl %>%
      filter(is.na(typemilitary)) %>% #remove military data (will only use placeholders in the data pack)
      group_by(operatingunit, snu1, psnu, psnuuid, currentsnuprioritization, indicator, standardizeddisaggregate, 
               sex, age, resultstatus, otherdisaggregate, modality, numeratordenom) %>%
      summarize_at(vars(fy2015apr, fy2016apr, fy2017apr, fy2017_targets, fy2018_targets), funs(sum(., na.rm=TRUE))) %>%
      ungroup

## CLEAN UP -------------------------------------------------------------------------------------------------------

  df_indtbl <- df_indtbl %>%
  
  #remove rows with no psnuuid attribution
    drop_na(psnuuid)  %>%
  
   #rename
    rename(snulist = psnu, 
         priority_snu = currentsnuprioritization)

  #add military districts back in as row placeholder for country entry
    df_mil <- read_csv(file.path(rawdata, "COP18_mil_psnus.csv"))

  #append military data onto indicator table 
    df_indtbl <- bind_rows(df_indtbl, df_mil)
    rm(df_mil)


## SAVE TEMP FILE -------------------------------------------------------------------------------------------------
  #save temp file as starting point for 02_datapack_output_keyind
    saveRDS(df_indtbl, file = file.path(tempoutput, "append_temp.Rds"))

## GENERATE VARIABLES/COLUMNS -------------------------------------------------------------------------------------
  # output formulas created in Data Pack template (POPsubset sheet)
  # updated 2/13
  
    df_indtbl <- df_indtbl %>%
      mutate(
        gend_gbv = ifelse((indicator=="GEND_GBV" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2017apr, 0), 
        gend_gbv_T = ifelse((indicator=="GEND_GBV" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2018_targets, 0), 
        hts_tst = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2017apr, 0), 
        hts_tst_pos = ifelse((indicator=="HTS_TST_POS" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2017apr, 0), 
        hts_tst_u15 = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="<15" & numeratordenom=="N"), fy2017apr, 0), 
        hts_tst_pos_u15 = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="15+" & resultstatus=="Positive" & numeratordenom=="N"), fy2017apr, 0), 
        hts_tst_u15_yield = 0, 
        hts_tst_kp = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="KeyPop/Result" & numeratordenom=="N"), fy2017apr, 0), 
        hts_tst_kp_T = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="KeyPop/Result" & numeratordenom=="N"), fy2018_targets, 0), 
        hts_tst_neg_indexmod_o15 = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="15+" & resultstatus=="Negative" & modality=="IndexMod" & numeratordenom=="N"), fy2017apr, 0), 
        hts_tst_neg_mobilemod_o15 = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="15+" & resultstatus=="Negative" & modality=="MobileMod" & numeratordenom=="N"), fy2017apr, 0), 
        hts_tst_neg_vctmod_o15 = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="15+" & resultstatus=="Negative" & modality=="VCTMod" & numeratordenom=="N"), fy2017apr, 0), 
        hts_tst_neg_othermod_o15 = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="15+" & resultstatus=="Negative" & modality=="OtherMod" & numeratordenom=="N"), fy2017apr, 0), 
        hts_tst_neg_index_o15 = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="15+" & resultstatus=="Negative" & modality=="Index" & numeratordenom=="N"), fy2017apr, 0), 
        hts_tst_neg_sti_o15 = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="15+" & resultstatus=="Negative" & modality=="STI" & numeratordenom=="N"), fy2017apr, 0), 
        hts_tst_neg_inpat_o15 = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="15+" & resultstatus=="Negative" & modality=="Inpat" & numeratordenom=="N"), fy2017apr, 0), 
        hts_tst_neg_emergency_o15 = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="15+" & resultstatus=="Negative" & modality=="Emergency" & numeratordenom=="N"), fy2017apr, 0), 
        hts_tst_neg_vct_o15 = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="15+" & resultstatus=="Negative" & modality=="VCT" & numeratordenom=="N"), fy2017apr, 0), 
        hts_tst_neg_otherpitc_o15 = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="15+" & resultstatus=="Negative" & modality=="OtherPITC" & numeratordenom=="N"), fy2017apr, 0), 
        hts_tst_pos_indexmod_o15 = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="15+" & resultstatus=="Positive" & modality=="IndexMod" & numeratordenom=="N"), fy2017apr, 0), 
        hts_tst_pos_mobilemod_o15 = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="15+" & resultstatus=="Positive" & modality=="MobileMod" & numeratordenom=="N"), fy2017apr, 0), 
        hts_tst_pos_vctmod_o15 = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="15+" & resultstatus=="Positive" & modality=="VCTMod" & numeratordenom=="N"), fy2017apr, 0), 
        hts_tst_pos_othermod_o15 = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="15+" & resultstatus=="Positive" & modality=="OtherMod" & numeratordenom=="N"), fy2017apr, 0), 
        hts_tst_pos_index_o15 = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="15+" & resultstatus=="Positive" & modality=="Index" & numeratordenom=="N"), fy2017apr, 0), 
        hts_tst_pos_sti_o15 = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="15+" & resultstatus=="Positive" & modality=="STI" & numeratordenom=="N"), fy2017apr, 0), 
        hts_tst_pos_inpat_o15 = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="15+" & resultstatus=="Positive" & modality=="Inpat" & numeratordenom=="N"), fy2017apr, 0), 
        hts_tst_pos_emergency_o15 = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="15+" & resultstatus=="Positive" & modality=="Emergency" & numeratordenom=="N"), fy2017apr, 0), 
        hts_tst_pos_vct_o15 = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="15+" & resultstatus=="Positive" & modality=="VCT" & numeratordenom=="N"), fy2017apr, 0), 
        hts_tst_pos_otherpitc_o15 = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="15+" & resultstatus=="Positive" & modality=="OtherPITC" & numeratordenom=="N"), fy2017apr, 0), 
        hts_tst_spd_tot_pos_o15 = 0, 
        hts_tst_neg_indexmod_u15 = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="<15" & resultstatus=="Negative" & modality=="IndexMod" & numeratordenom=="N"), fy2017apr, 0), 
        hts_tst_neg_mobilemod_u15 = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="<15" & resultstatus=="Negative" & modality=="MobileMod" & numeratordenom=="N"), fy2017apr, 0), 
        hts_tst_neg_vctmod_u15 = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="<15" & resultstatus=="Negative" & modality=="VCTMod" & numeratordenom=="N"), fy2017apr, 0), 
        hts_tst_neg_othermod_u15 = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="<15" & resultstatus=="Negative" & modality=="OtherMod" & numeratordenom=="N"), fy2017apr, 0), 
        hts_tst_neg_index_u15 = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="<15" & resultstatus=="Negative" & modality=="Index" & numeratordenom=="N"), fy2017apr, 0), 
        hts_tst_neg_sti_u15 = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="<15" & resultstatus=="Negative" & modality=="STI" & numeratordenom=="N"), fy2017apr, 0), 
        hts_tst_neg_inpat_u15 = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="<15" & resultstatus=="Negative" & modality=="Inpat" & numeratordenom=="N"), fy2017apr, 0), 
        hts_tst_neg_emergency_u15 = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="<15" & resultstatus=="Negative" & modality=="Emergency" & numeratordenom=="N"), fy2017apr, 0), 
        hts_tst_neg_vct_u15 = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="<15" & resultstatus=="Negative" & modality=="VCT" & numeratordenom=="N"), fy2017apr, 0), 
        hts_tst_neg_pediatric_u15 = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="<15" & resultstatus=="Negative" & modality=="Pediatric" & numeratordenom=="N"), fy2017apr, 0), 
        hts_tst_neg_malnutrition_u15 = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="<15" & resultstatus=="Negative" & modality=="Malnutrition" & numeratordenom=="N"), fy2017apr, 0), 
        hts_tst_neg_otherpitc_u15 = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="<15" & resultstatus=="Negative" & modality=="OtherPITC" & numeratordenom=="N"), fy2017apr, 0), 
        hts_tst_pos_indexmod_u15 = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="<15" & resultstatus=="Positive" & modality=="IndexMod" & numeratordenom=="N"), fy2017apr, 0), 
        hts_tst_pos_mobilemod_u15 = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="<15" & resultstatus=="Positive" & modality=="MobileMod" & numeratordenom=="N"), fy2017apr, 0), 
        hts_tst_pos_vctmod_u15 = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="<15" & resultstatus=="Positive" & modality=="VCTMod" & numeratordenom=="N"), fy2017apr, 0), 
        hts_tst_pos_othermod_u15 = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="<15" & resultstatus=="Positive" & modality=="OtherMod" & numeratordenom=="N"), fy2017apr, 0), 
        hts_tst_pos_index_u15 = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="<15" & resultstatus=="Positive" & modality=="Index" & numeratordenom=="N"), fy2017apr, 0), 
        hts_tst_pos_sti_u15 = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="<15" & resultstatus=="Positive" & modality=="STI" & numeratordenom=="N"), fy2017apr, 0), 
        hts_tst_pos_inpat_u15 = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="<15" & resultstatus=="Positive" & modality=="Inpat" & numeratordenom=="N"), fy2017apr, 0), 
        hts_tst_pos_emergency_u15 = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="<15" & resultstatus=="Positive" & modality=="Emergency" & numeratordenom=="N"), fy2017apr, 0), 
        hts_tst_pos_vct_u15 = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="<15" & resultstatus=="Positive" & modality=="VCT" & numeratordenom=="N"), fy2017apr, 0), 
        hts_tst_pos_pediatric_u15 = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="<15" & resultstatus=="Positive" & modality=="Pediatric" & numeratordenom=="N"), fy2017apr, 0), 
        hts_tst_pos_malnutrition_u15 = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="<15" & resultstatus=="Positive" & modality=="Malnutrition" & numeratordenom=="N"), fy2017apr, 0), 
        hts_tst_pos_otherpitc_u15 = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="<15" & resultstatus=="Positive" & modality=="OtherPITC" & numeratordenom=="N"), fy2017apr, 0), 
        hts_tst_spd_tot_pos_u15 = 0, 
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
        kp_mat_T = ifelse((indicator=="KP_MAT" & standardizeddisaggregate=="Sex" & numeratordenom=="N"), fy2018_targets, 0), 
        ovc_serv = ifelse((indicator=="OVC_SERV" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2017apr, 0), 
        ovc_serv_T = ifelse((indicator=="OVC_SERV" & standardizeddisaggregate=="ProgramStatus" & numeratordenom=="N"), fy2018_targets, 0), 
        ovc_serv_u18 = ifelse((indicator=="OVC_SERV" & standardizeddisaggregate %in% c("AgeLessThanTen", "AgeAboveTen/Sex") & age %in% c("<01", "01-09", "10-14", "15-17") & numeratordenom=="N"), fy2017apr, 0), 
        ovc_serv_u18_T = ifelse((indicator=="OVC_SERV" & standardizeddisaggregate %in% c("AgeLessThanTen", "AgeAboveTen/Sex") & age %in% c("<01", "01-09", "10-14", "15-17") & numeratordenom=="N"), fy2018_targets, 0), 
        ovc_serv_grad = ifelse((indicator=="OVC_SERV" & standardizeddisaggregate=="ProgramStatus" & otherdisaggregate=="Graduated" & numeratordenom=="N"), fy2017apr, 0), 
        ovc_serv_active = ifelse((indicator=="OVC_SERV" & standardizeddisaggregate=="ProgramStatus" & otherdisaggregate=="Active" & numeratordenom=="N"), fy2017apr, 0), 
        ovc_serv_exited = ifelse((indicator=="OVC_SERV" & standardizeddisaggregate=="ProgramStatus" & otherdisaggregate=="Exited without Graduation" & numeratordenom=="N"), fy2017apr, 0), 
        ovc_serv_trans = ifelse((indicator=="OVC_SERV" & standardizeddisaggregate=="ProgramStatus" & otherdisaggregate=="Transferred" & numeratordenom=="N"), fy2017apr, 0), 
        ovc_serv_edu = ifelse((indicator=="OVC_SERV" & standardizeddisaggregate=="Age/Sex/Service" & otherdisaggregate=="Education Support" & numeratordenom=="N"), fy2017apr, 0), 
        ovc_serv_care = ifelse((indicator=="OVC_SERV" & standardizeddisaggregate=="Age/Sex/Service" & otherdisaggregate=="Parenting/Caregiver Programs" & numeratordenom=="N"), fy2017apr, 0), 
        ovc_serv_econ = ifelse((indicator=="OVC_SERV" & standardizeddisaggregate=="Age/Sex/Service" & otherdisaggregate=="Economic Strengthening" & numeratordenom=="N"), fy2017apr, 0), 
        ovc_serv_sp = ifelse((indicator=="OVC_SERV" & standardizeddisaggregate=="Age/Sex/Service" & otherdisaggregate=="Social Protection" & numeratordenom=="N"), fy2017apr, 0), 
        ovc_serv_oth = ifelse((indicator=="OVC_SERV" & standardizeddisaggregate=="Age/Sex/Service" & otherdisaggregate=="Other Service Areas" & numeratordenom=="N"), fy2017apr, 0), 
        ovc_serv_grad_T = ifelse((indicator=="OVC_SERV" & standardizeddisaggregate=="ProgramStatus" & otherdisaggregate=="Graduated" & numeratordenom=="N"), fy2018_targets, 0), 
        ovc_serv_active_T = ifelse((indicator=="OVC_SERV" & standardizeddisaggregate=="ProgramStatus" & otherdisaggregate=="Active" & numeratordenom=="N"), fy2018_targets, 0), 
        ovc_serv_exited_T = ifelse((indicator=="OVC_SERV" & standardizeddisaggregate=="ProgramStatus" & otherdisaggregate=="Exited without Graduation" & numeratordenom=="N"), fy2018_targets, 0), 
        ovc_serv_trans_T = ifelse((indicator=="OVC_SERV" & standardizeddisaggregate=="ProgramStatus" & otherdisaggregate=="Transferred" & numeratordenom=="N"), fy2018_targets, 0), 
        ovc_serv_edu_T = ifelse((indicator=="OVC_SERV" & standardizeddisaggregate=="Age/Sex/Service" & otherdisaggregate=="Education Support" & numeratordenom=="N"), fy2018_targets, 0), 
        ovc_serv_care_T = ifelse((indicator=="OVC_SERV" & standardizeddisaggregate=="Age/Sex/Service" & otherdisaggregate=="Parenting/Caregiver Programs" & numeratordenom=="N"), fy2018_targets, 0), 
        ovc_serv_econ_T = ifelse((indicator=="OVC_SERV" & standardizeddisaggregate=="Age/Sex/Service" & otherdisaggregate=="Economic Strengthening" & numeratordenom=="N"), fy2018_targets, 0), 
        ovc_serv_sp_T = ifelse((indicator=="OVC_SERV" & standardizeddisaggregate=="Age/Sex/Service" & otherdisaggregate=="Social Protection" & numeratordenom=="N"), fy2018_targets, 0), 
        ovc_serv_oth_T = ifelse((indicator=="OVC_SERV" & standardizeddisaggregate=="Age/Sex/Service" & otherdisaggregate=="Other Service Areas" & numeratordenom=="N"), fy2018_targets, 0), 
        plhiv = ifelse((indicator=="PLHIV" & standardizeddisaggregate=="Total Numerator"), fy2017apr, 0), 
        plhiv_u15 = ifelse((indicator=="PLHIV" & standardizeddisaggregate=="Age/Sex" & age=="<15"), fy2017apr, 0), 
        plhiv_o15 = ifelse((indicator=="PLHIV" & standardizeddisaggregate=="Age/Sex" & age=="15+"), fy2017apr, 0), 
        pmtct_art = ifelse((indicator=="PMTCT_ART" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2017apr, 0), 
        pmtct_art_already = ifelse((indicator=="PMTCT_ART" & standardizeddisaggregate=="NewExistingArt/HIVStatus" & otherdisaggregate=="Life-long ART Already" & numeratordenom=="N"), fy2017apr, 0), 
        pmtct_art_T = ifelse((indicator=="PMTCT_ART" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2018_targets, 0), 
        pmtct_eid = ifelse((indicator=="PMTCT_EID" & standardizeddisaggregate=="Age/HIVStatus" & resultstatus %in% c("Positive", "Negative") & numeratordenom=="N"), fy2017apr, 0), 
        pmtct_eid_T = ifelse((indicator=="PMTCT_EID" & standardizeddisaggregate=="Age/HIVStatus" & resultstatus %in% c("Positive", "Negative") & numeratordenom=="N"), fy2018_targets, 0), 
        pmtct_eid_pos_12mo = ifelse((indicator=="PMTCT_EID" & standardizeddisaggregate=="Age/HIVStatus" & resultstatus=="Positive" & numeratordenom=="N"), fy2017apr, 0), 
        pmtct_eid_yield = 0, 
        pmtct_stat_D = ifelse((indicator=="PMTCT_STAT" & standardizeddisaggregate=="Total Denominator" & numeratordenom=="D"), fy2017apr, 0), 
        pmtct_stat_D_T = ifelse((indicator=="PMTCT_STAT" & standardizeddisaggregate=="Age" & numeratordenom=="D"), fy2018_targets, 0), 
        pmtct_stat = ifelse((indicator=="PMTCT_STAT" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2017apr, 0), 
        pmtct_stat_T = ifelse((indicator=="PMTCT_STAT" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2018_targets, 0), 
        pmtct_stat_pos = ifelse((indicator=="PMTCT_STAT" & standardizeddisaggregate=="Age/KnownNewResult" & resultstatus=="Positive" & numeratordenom=="N"), fy2017apr, 0), 
        pmtct_stat_yield = 0, 
        pmtct_stat_knownpos = ifelse((indicator=="PMTCT_STAT" & standardizeddisaggregate=="Age/KnownNewResult" & resultstatus=="Positive" & otherdisaggregate=="Known at Entry" & numeratordenom=="N"), fy2017apr, 0), 
        pop_num = ifelse((indicator=="POP_NUM" & standardizeddisaggregate=="Total Numerator"), fy2017apr, 0), 
        pop_num_m = ifelse((indicator=="POP_NUM" & standardizeddisaggregate=="Sex" & sex=="Male"), fy2017apr, 0), 
        pp_prev = ifelse((indicator=="PP_PREV" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2017apr, 0), 
        pp_prev_T = ifelse((indicator=="PP_PREV" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2018_targets, 0), 
        prep_new = ifelse((indicator=="PrEP_NEW" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2017apr, 0), 
        prep_new_T = ifelse((indicator=="PrEP_NEW" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2018_targets, 0), 
        tb_art_D = ifelse((indicator=="TB_ART" & standardizeddisaggregate=="Total Denominator" & numeratordenom=="D"), fy2017apr, 0), 
        tb_art = ifelse((indicator=="TB_ART" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2017apr, 0), 
        tb_art_already = ifelse((indicator=="TB_ART" & standardizeddisaggregate=="NewExistingArt/HIVStatus" & otherdisaggregate=="Life-long ART Already" & numeratordenom=="N"), fy2017apr, 0), 
        tb_art_D_T = ifelse((indicator=="TB_ART" & standardizeddisaggregate=="Total Denominator" & numeratordenom=="D"), fy2018_targets, 0), 
        tb_art_T = ifelse((indicator=="TB_ART" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2018_targets, 0), 
        tb_prev_D = ifelse((indicator=="TB_PREV" & standardizeddisaggregate=="Total Denominator" & numeratordenom=="D"), fy2017apr, 0), 
        tb_prev_D_T = ifelse((indicator=="TB_PREV" & standardizeddisaggregate=="Total Denominator" & numeratordenom=="D"), fy2018_targets, 0), 
        tb_prev = ifelse((indicator=="TB_PREV" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2017apr, 0), 
        tb_prev_T = ifelse((indicator=="TB_PREV" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2018_targets, 0), 
        tb_stat_D = ifelse((indicator=="TB_STAT" & standardizeddisaggregate=="Total Denominator" & numeratordenom=="D"), fy2017apr, 0), 
        tb_stat_D_T = ifelse((indicator=="TB_STAT" & standardizeddisaggregate=="Total Denominator" & numeratordenom=="D"), fy2018_targets, 0), 
        tb_stat = ifelse((indicator=="TB_STAT" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2017apr, 0), 
        tb_stat_pos = ifelse((indicator=="TB_STAT_POS" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2017apr, 0), 
        tb_stat_T = ifelse((indicator=="TB_STAT" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2018_targets, 0), 
        tb_stat_yield = 0, 
        tb_stat_knownpos = ifelse((indicator=="TB_STAT" & standardizeddisaggregate=="Age Aggregated/Sex/KnownNewPosNeg" & resultstatus=="Positive" & otherdisaggregate=="Known at Entry" & numeratordenom=="N"), fy2017apr, 0), 
        tx_tb_D = ifelse((indicator=="TX_TB" & standardizeddisaggregate=="Total Denominator" & numeratordenom=="D"), fy2017apr, 0), 
        tx_tb_D_T = ifelse((indicator=="TX_TB" & standardizeddisaggregate=="Total Denominator" & numeratordenom=="D"), fy2018_targets, 0), 
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
        vmmc_circ = ifelse((indicator=="VMMC_CIRC" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2017apr, 0), 
        vmmc_circ_pos = ifelse((indicator=="VMMC_CIRC" & standardizeddisaggregate=="HIVStatus/Sex" & resultstatus=="Positive" & numeratordenom=="N"), fy2017apr, 0), 
        vmmc_circ_neg = ifelse((indicator=="VMMC_CIRC" & standardizeddisaggregate=="HIVStatus/Sex" & resultstatus=="Negative" & numeratordenom=="N"), fy2017apr, 0), 
        vmmc_circ_T = ifelse((indicator=="VMMC_CIRC" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2018_targets, 0), 
        vmmc_circ_rng_T = ifelse((indicator=="VMMC_CIRC" & standardizeddisaggregate=="Age" & age %in% c("15-19", "20-24", "25-29") & numeratordenom=="N"), fy2018_targets, 0), 
        vmmc_circ_subnat = ifelse((indicator=="VMMC_CIRC_SUBNAT" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2017apr, 0))
    

## AGGREGATE TO PSNU LEVEL ----------------------------------------------------------------------------------------

    df_indtbl <- df_indtbl %>%
      select(-indicator:-fy2018_targets) %>% 
      group_by(operatingunit, snu1, snulist, psnuuid, priority_snu) %>%
      summarise_if(is.numeric, funs(sum(., na.rm=TRUE))) %>%
      ungroup %>% 
    
    #reorder columns
      select(operatingunit, psnuuid, snulist, snu1, priority_snu, gend_gbv:vmmc_circ_subnat) %>%
    
    #sort by PLHIV
      arrange(operatingunit, desc(plhiv), snulist) 
    
    #review to ensure all variables were actally created
      #skimr::skim(df_indtbl)

## EXPORT -------------------------------------------------------------------------------------------------------
    
  write_csv(df_indtbl, file.path(output, "Global_IndTbl.csv"), na = "")
    rm(df_indtbl)
