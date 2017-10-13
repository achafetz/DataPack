##   Data Pack COP FY18
##   A.Chafetz, USAID
##   Purpose: generate output for Excel based Data Pack at SNU level
##   Adopted from COP17 Stata code
##   Date: Oct 8, 2017
##   Updated: 10/13

## DEPENDENCIES
    # run 00_datapack_initialize
    # ICPI Fact View NAT_SUBNAT
    # ICPI Fact View PSNU

## SETUP ------------------------------------------------------------------------------------------------------
  
  #define date for Fact View Files
    datestamp <- "20170922_v2_1" #currently Q3, needs to be updated with Q4 when available

  #set today's date for saving
    date <-  format(Sys.Date(), format="%d%b%Y")
	
## NAT_SUBNAT --------------------------------------------------------------------------------------------------

  #import data
    df_subnat  <- read_tsv(file.path(fvdata, paste("ICPI_FactView_NAT_SUBNAT_", datestamp, ".txt", sep="")))
    names(df_subnat) <- tolower(names(df_subnat))
    
  #align nat_subnat names with what is in fact view
    df_subnat <- df_subnat %>%
      rename(fy2015apr= fy2015q4, fy2016apr = fy2016, fy2017apr = fy2017)
    

## MER - PSNUxIM ----------------------------------------------------------------------------------------------
    
  #import
    df_mer  <- read_tsv(file.path(fvdata, paste("ICPI_FactView_PSNU_", datestamp, ".txt", sep="")))
    names(df_mer) <- tolower(names(df_mer))
    
  
## APPEND -----------------------------------------------------------------------------------------------------
    df_indtbl <- bind_rows(df_mer, df_subnat)
      rm(df_mer, df_subnat)
    
    #cleanup PSNUs (dups & clusters)
      df_curr <- df_indtbl
      source(file.path(dofiles, "06_datapack_snu_adj.R"))
      df_indtbl <- df_curr
      rm(df_curr)
      
## REMOVE BELOW  -------------------------------------------------------------------------------------------------
      
      ## FOR TESTING ONLY ## REMOVE after FY17 APR becomes available ##
      df_indtbl[is.na(df_indtbl)] <- 0
      df_indtbl <- df_indtbl %>% 
        mutate(fy2017apr = ifelse(indicator=="TX_CURR", fy2017q3, 
                                  ifelse(indicator %in% c("KP_PREV","PP_PREV", "OVC_HIVSTAT", "OVC_SERV", 
                                                          "TB_ART", "TB_STAT", "TX_TB", "GEND_GBV", "PMTCT_FO", 
                                                          "TX_RET", "KP_MAT"), fy2017q2, 
                                         fy2017q1 + fy2017q2 + fy2017q3)),
               fy2018_targets = fy2017_targets * 1.5,
               fy18snuprioritization = as.character(fy16snuprioritization))
      df_indtbl[df_indtbl==0] <- NA
#  ^^^^^^ REMOVE ABOVE ^^^^^^
      
## AGGREGATE TO PNSU X DISAGGS LEVEL ------------------------------------------------------------------------------
    #remove military data (will only use placeholders in the data pack)
    df_indtbl <- filter(df_indtbl, is.na(typemilitary))
      
    #have to aggregate here; otherwise variable generation vector (next section) is too large to run
    df_indtbl <- rename(df_indtbl, snuprioritization = fy18snuprioritization)  
    
    df_indtbl <- df_indtbl %>%
      group_by(operatingunit, snu1, psnu, psnuuid, snuprioritization, indicator, standardizeddisaggregate, 
               sex, age, resultstatus, otherdisaggregate, modality, numeratordenom) %>%
        summarize_at(vars(fy2015apr, fy2016apr, fy2017apr, fy2017_targets, fy2018_targets), funs(sum(., na.rm=TRUE))) %>%
        ungroup

## CLEAN UP -------------------------------------------------------------------------------------------------------
    
    df_indtbl <- df_indtbl %>%
      
      #remove blank rows(and military)
      drop_na(psnuuid)  %>%
      
      #rename
      rename(snulist = psnu, 
             priority_snu = snuprioritization)

    
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
    #save temp file as starting point for  02_datapack_output_keyind
      save(df_indtbl, file = file.path(stataoutput, "append_temp.RData"))
    
## GENERATE VARIABLES/COLUMNS -------------------------------------------------------------------------------------
  # output formulas created in Data Pack template (POPsubset sheet)
  # updated 10/12
    
    df_indtbl <- df_indtbl %>%
    mutate(
      hts_tst = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_pos = ifelse((indicator=="HTS_TST_POS" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_u15 = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="Modality/AgeLessThanTen/Result" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_pos_u15 = ifelse((indicator=="HTS_TST_POS" & standardizeddisaggregate=="Modality/AgeLessThanTen/Result" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_u15_yield = 0, 
      hts_tst_neg_inpat = ifelse((indicator=="HTS_TST_NEG" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & modality=="Inpat" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_neg_index = ifelse((indicator=="HTS_TST_NEG" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & modality=="Index" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_neg_tbclinic = ifelse((indicator=="HTS_TST_NEG" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & modality=="TBClinic" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_neg_vmmc = ifelse((indicator=="HTS_TST_NEG" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & modality=="VMMC" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_neg_vct = ifelse((indicator=="HTS_TST_NEG" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & modality=="VCT" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_neg_otherpitc = ifelse((indicator=="HTS_TST_NEG" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & modality=="OtherPITC" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_neg_homemod = ifelse((indicator=="HTS_TST_NEG" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & modality=="HomeMod" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_neg_indexmod = ifelse((indicator=="HTS_TST_NEG" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & modality=="IndexMod" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_neg_mobilemod = ifelse((indicator=="HTS_TST_NEG" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & modality=="MobileMod" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_neg_vctmod = ifelse((indicator=="HTS_TST_NEG" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & modality=="VCTMod" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_neg_othermod = ifelse((indicator=="HTS_TST_NEG" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & modality=="OtherMod" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_pos_inpat = ifelse((indicator=="HTS_TST_POS" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & modality=="Inpat" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_pos_index = ifelse((indicator=="HTS_TST_POS" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & modality=="Index" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_pos_tbclinic = ifelse((indicator=="HTS_TST_POS" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & modality=="TBClinic" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_pos_vmmc = ifelse((indicator=="HTS_TST_POS" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & modality=="VMMC" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_pos_vct = ifelse((indicator=="HTS_TST_POS" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & modality=="VCT" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_pos_otherpitc = ifelse((indicator=="HTS_TST_POS" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & modality=="OtherPITC" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_pos_homemod = ifelse((indicator=="HTS_TST_POS" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & modality=="HomeMod" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_pos_indexmod = ifelse((indicator=="HTS_TST_POS" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & modality=="IndexMod" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_pos_mobilemod = ifelse((indicator=="HTS_TST_POS" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & modality=="MobileMod" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_pos_vctmod = ifelse((indicator=="HTS_TST_POS" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & modality=="VCTMod" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_pos_othermod = ifelse((indicator=="HTS_TST_POS" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & modality=="OtherMod" & numeratordenom=="N"), fy2017apr, 0), 
      hts_tst_spd_tot_pos = 0, 
      kp_prev_fsw = ifelse((indicator=="KP_PREV" & standardizeddisaggregate=="KeyPop" & otherdisaggregate=="FSW" & numeratordenom=="N"), fy2017apr, 0), 
      kp_prev_fsw_T = ifelse((indicator=="KP_PREV" & standardizeddisaggregate=="KeyPop" & otherdisaggregate=="FSW" & numeratordenom=="N"), fy2018_targets, 0), 
      kp_prev_msm = ifelse((indicator=="KP_PREV" & standardizeddisaggregate=="KeyPop" & otherdisaggregate=="MSM" & numeratordenom=="N"), fy2017apr, 0), 
      kp_prev_msm_T = ifelse((indicator=="KP_PREV" & standardizeddisaggregate=="KeyPop" & otherdisaggregate=="MSM" & numeratordenom=="N"), fy2018_targets, 0), 
      kp_prev_tg = ifelse((indicator=="KP_PREV" & standardizeddisaggregate=="KeyPop" & otherdisaggregate=="TG" & numeratordenom=="N"), fy2017apr, 0), 
      kp_prev_tg_T = ifelse((indicator=="KP_PREV" & standardizeddisaggregate=="KeyPop" & otherdisaggregate=="TG" & numeratordenom=="N"), fy2018_targets, 0), 
      kp_prev_pwid = ifelse((indicator=="KP_PREV" & standardizeddisaggregate=="KeyPop" & otherdisaggregate %in% c("Female PWID", "Male PWID") & numeratordenom=="N"), fy2017apr, 0), 
      kp_prev_pwid_T = ifelse((indicator=="KP_PREV" & standardizeddisaggregate=="KeyPop" & otherdisaggregate %in% c("Female PWID", "Male PWID") & numeratordenom=="N"), fy2018_targets, 0), 
      kp_prev_prison = ifelse((indicator=="KP_PREV" & standardizeddisaggregate=="KeyPop" & otherdisaggregate=="People in prisons and other enclosed settings" & numeratordenom=="N"), fy2017apr, 0), 
      kp_prev_prison_T = ifelse((indicator=="KP_PREV" & standardizeddisaggregate=="KeyPop" & otherdisaggregate=="People in prisons and other enclosed settings" & numeratordenom=="N"), fy2018_targets, 0), 
      kp_mat = ifelse((indicator=="KP_MAT" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2017apr, 0), 
      kp_mat_T = ifelse((indicator=="KP_MAT" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2018_targets, 0), 
      ovc_serv = ifelse((indicator=="OVC_SERV" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2017apr, 0), 
      ovc_serv_T = ifelse((indicator=="OVC_SERV" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2018_targets, 0), 
      ovc_serv_u18 = ifelse((indicator=="OVC_SERV" & standardizeddisaggregate %in% c("AgeLessThanTen", "AgeAboveTen/Sex") & age %in% c("<01", "01-09", "10-14", "15-17") & numeratordenom=="N"), fy2017apr, 0), 
      ovc_serv_u18_T = ifelse((indicator=="OVC_SERV" & standardizeddisaggregate %in% c("AgeLessThanTen", "AgeAboveTen/Sex") & age %in% c("<01", "01-09", "10-14", "15-17") & numeratordenom=="N"), fy2018_targets, 0), 
      plhivsubnat = ifelse((indicator=="PLHIV (SUBNAT)" & standardizeddisaggregate=="Total Numerator"), fy2017apr, 0), 
      plhivsubnatagesex_u15 = ifelse((indicator=="PLHIV (SUBNAT, Age/Sex)" & standardizeddisaggregate=="Age/Sex" & age=="<15"), fy2017apr, 0), 
      plhivsubnatagesex_o15 = ifelse((indicator=="PLHIV (SUBNAT, Age/Sex)" & standardizeddisaggregate=="Age/Sex" & age=="15+"), fy2017apr, 0), 
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
      pmtct_stat_pos = ifelse((indicator=="PMTCT_STAT" & standardizeddisaggregate=="Known/New" & numeratordenom=="N"), fy2017apr, 0), 
      pmtct_stat_yield = 0, 
      pmtct_stat_knownpos = ifelse((indicator=="PMTCT_STAT" & standardizeddisaggregate=="Known/New" & resultstatus=="Positive" & otherdisaggregate=="Known at Entry" & numeratordenom=="N"), fy2017apr, 0), 
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
      tx_new_u1 = ifelse((indicator=="TX_NEW" & standardizeddisaggregate=="AgeLessThanTen" & age=="<01" & numeratordenom=="N"), fy2017apr, 0), 
      tx_new_u1_T = ifelse((indicator=="TX_NEW" & standardizeddisaggregate=="AgeLessThanTen" & age=="<01" & numeratordenom=="N"), fy2018_targets, 0), 
      tx_ret_D = ifelse((indicator=="TX_RET" & standardizeddisaggregate=="Total Denominator" & numeratordenom=="D"), fy2017apr, 0), 
      tx_ret = ifelse((indicator=="TX_RET" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2017apr, 0), 
      tx_ret_u15_D = ifelse((indicator=="TX_RET" & standardizeddisaggregate %in% c("AgeLessThanTen", "AgeAboveTen/Sex") & age %in% c("<01", "01-09", "10-14") & numeratordenom=="D"), fy2017apr, 0), 
      tx_ret_yield = 0, 
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
      
  write_csv(df_indtbl, file.path(exceloutput, paste("Global_IndTbl", date, ".csv", sep="")))
    rm(df_indtbl, priority_levels, date, datestamp)
    