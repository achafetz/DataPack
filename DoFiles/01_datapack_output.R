##   Data Pack
##   COP FY18
##   Aaron Chafetz
##   Purpose: generate output for Excel based Data Pack at SNU level
##   Adopted from COP17 Stata code
##   Date: Oct 8, 2017
##   Updated: 


### SETUP ###
  
  #define date for Fact View Files
    datestamp <- "20170922_v2_1" #currently Q3, needs to be updated with Q4 when available

  #set today's date for saving
    date <-  format(Sys.Date(), format="%d%b%Y")
	
### NAT_SUBNAT ###

  #import data
    df_subnat  <- read_delim(file.path(fvdata, paste("ICPI_FactView_NAT_SUBNAT_", datestamp, ".txt", sep="")), 
                        "\t", escape_double = FALSE, trim_ws = TRUE)
    names(df_subnat) <- tolower(names(df_subnat))
    
  #align nat_subnat names with what is in fact view
    df_subnat <- df_subnat %>%
      rename(fy2015apr= fy2015q4, fy2016apr = fy2016, fy2017apr = fy2017)
    

### MER - PSNUxIM ###
    
  #import
    df_mer  <- read_delim(file.path(fvdata, paste("ICPI_FactView_PSNU_IM_", datestamp, ".txt", sep="")), 
                          "\t", escape_double = FALSE, trim_ws = TRUE)
    names(df_mer) <- tolower(names(df_mer))
    
  
### APPEND ###
    df_indtbl <- bind_rows(df_mer, df_subnat)
      rm(df_mer, df_subnat)
    
    #cleanup PSNUs (dups & clusters)
      df_curr <- df_indtbl
      source(file.path(dofiles, "06_datapack_snu_adj.R"))
      df_indtbl <- df_curr
      rm(df_curr)
      
      
### GENERATE VARIABLES/COLUMNS ###
  # generate
  # output generated in Data Pack template (POPsubset sheet)
  #  updated 10/8
  
    df_indtble <- df_indtble %>%
      mutate(
         hts_tst = ifelse(indicator=="HTS_TST", standardizeddisaggregate=="Total Numerator", numeratordenom=="N", fy2017apr, 0), 
         hts_tst_pos = ifelse(indicator=="HTS_TST_POS", standardizeddisaggregate=="Total Numerator", numeratordenom=="N", fy2017apr, 0), 
         hts_tst_u15 = ifelse(indicator=="HTS_TST", standardizeddisaggregate=="Modality/AgeLessThanTen/Result", numeratordenom=="N", fy2017apr, 0), 
         hts_tst_pos_u15 = ifelse(indicator=="HTS_TST_POS", standardizeddisaggregate=="Modality/AgeLessThanTen/Result", numeratordenom=="N", fy2017apr, 0), 
         hts_tst_u15_yield = 0, 
         hts_tst_neg_inpat = ifelse(indicator=="HTS_TST_NEG", standardizeddisaggregate=="Modality/MostCompleteAgeDisagg", modality=="Inpat", numeratordenom=="N", fy2017apr, 0), 
         hts_tst_neg_index = ifelse(indicator=="HTS_TST_NEG", standardizeddisaggregate=="Modality/MostCompleteAgeDisagg", modality=="Index", numeratordenom=="N", fy2017apr, 0), 
         hts_tst_neg_tbclinic = ifelse(indicator=="HTS_TST_NEG", standardizeddisaggregate=="Modality/MostCompleteAgeDisagg", modality=="TBClinic", numeratordenom=="N", fy2017apr, 0), 
         hts_tst_neg_vmmc = ifelse(indicator=="HTS_TST_NEG", standardizeddisaggregate=="Modality/MostCompleteAgeDisagg", modality=="VMMC", numeratordenom=="N", fy2017apr, 0), 
         hts_tst_neg_vct = ifelse(indicator=="HTS_TST_NEG", standardizeddisaggregate=="Modality/MostCompleteAgeDisagg", modality=="VCT", numeratordenom=="N", fy2017apr, 0), 
         hts_tst_neg_otherpitc = ifelse(indicator=="HTS_TST_NEG", standardizeddisaggregate=="Modality/MostCompleteAgeDisagg", modality=="OtherPITC", numeratordenom=="N", fy2017apr, 0), 
         hts_tst_neg_homemod = ifelse(indicator=="HTS_TST_NEG", standardizeddisaggregate=="Modality/MostCompleteAgeDisagg", modality=="HomeMod", numeratordenom=="N", fy2017apr, 0), 
         hts_tst_neg_indexmod = ifelse(indicator=="HTS_TST_NEG", standardizeddisaggregate=="Modality/MostCompleteAgeDisagg", modality=="IndexMod", numeratordenom=="N", fy2017apr, 0), 
         hts_tst_neg_mobilemod = ifelse(indicator=="HTS_TST_NEG", standardizeddisaggregate=="Modality/MostCompleteAgeDisagg", modality=="MobileMod", numeratordenom=="N", fy2017apr, 0), 
         hts_tst_neg_vctmod = ifelse(indicator=="HTS_TST_NEG", standardizeddisaggregate=="Modality/MostCompleteAgeDisagg", modality=="VCTMod", numeratordenom=="N", fy2017apr, 0), 
         hts_tst_neg_othermod = ifelse(indicator=="HTS_TST_NEG", standardizeddisaggregate=="Modality/MostCompleteAgeDisagg", modality=="OtherMod", numeratordenom=="N", fy2017apr, 0), 
         hts_tst_pos_inpat = ifelse(indicator=="HTS_TST_POS", standardizeddisaggregate=="Modality/MostCompleteAgeDisagg", modality=="Inpat", numeratordenom=="N", fy2017apr, 0), 
         hts_tst_pos_index = ifelse(indicator=="HTS_TST_POS", standardizeddisaggregate=="Modality/MostCompleteAgeDisagg", modality=="Index", numeratordenom=="N", fy2017apr, 0), 
         hts_tst_pos_tbclinic = ifelse(indicator=="HTS_TST_POS", standardizeddisaggregate=="Modality/MostCompleteAgeDisagg", modality=="TBClinic", numeratordenom=="N", fy2017apr, 0), 
         hts_tst_pos_vmmc = ifelse(indicator=="HTS_TST_POS", standardizeddisaggregate=="Modality/MostCompleteAgeDisagg", modality=="VMMC", numeratordenom=="N", fy2017apr, 0), 
         hts_tst_pos_vct = ifelse(indicator=="HTS_TST_POS", standardizeddisaggregate=="Modality/MostCompleteAgeDisagg", modality=="VCT", numeratordenom=="N", fy2017apr, 0), 
         hts_tst_pos_otherpitc = ifelse(indicator=="HTS_TST_POS", standardizeddisaggregate=="Modality/MostCompleteAgeDisagg", modality=="OtherPITC", numeratordenom=="N", fy2017apr, 0), 
         hts_tst_pos_homemod = ifelse(indicator=="HTS_TST_POS", standardizeddisaggregate=="Modality/MostCompleteAgeDisagg", modality=="HomeMod", numeratordenom=="N", fy2017apr, 0), 
         hts_tst_pos_indexmod = ifelse(indicator=="HTS_TST_POS", standardizeddisaggregate=="Modality/MostCompleteAgeDisagg", modality=="IndexMod", numeratordenom=="N", fy2017apr, 0), 
         hts_tst_pos_mobilemod = ifelse(indicator=="HTS_TST_POS", standardizeddisaggregate=="Modality/MostCompleteAgeDisagg", modality=="MobileMod", numeratordenom=="N", fy2017apr, 0), 
         hts_tst_pos_vctmod = ifelse(indicator=="HTS_TST_POS", standardizeddisaggregate=="Modality/MostCompleteAgeDisagg", modality=="VCTMod", numeratordenom=="N", fy2017apr, 0), 
         hts_tst_pos_othermod = ifelse(indicator=="HTS_TST_POS", standardizeddisaggregate=="Modality/MostCompleteAgeDisagg", modality=="OtherMod", numeratordenom=="N", fy2017apr, 0), 
         hts_tst_spd_tot_pos = 0, 
         kp_prev_fsw = ifelse(indicator=="KP_PREV", standardizeddisaggregate=="KeyPop", otherdisaggregate=="FSW", numeratordenom=="N", fy2017apr, 0), 
         kp_prev_fsw_T = ifelse(indicator=="KP_PREV", standardizeddisaggregate=="KeyPop", otherdisaggregate=="FSW", numeratordenom=="N", fy2018_targets, 0), 
         kp_prev_msm = ifelse(indicator=="KP_PREV", standardizeddisaggregate=="KeyPop", otherdisaggregate=="MSM", numeratordenom=="N", fy2017apr, 0), 
         kp_prev_msm_T = ifelse(indicator=="KP_PREV", standardizeddisaggregate=="KeyPop", otherdisaggregate=="MSM", numeratordenom=="N", fy2018_targets, 0), 
         kp_prev_tg = ifelse(indicator=="KP_PREV", standardizeddisaggregate=="KeyPop", otherdisaggregate=="TG", numeratordenom=="N", fy2017apr, 0), 
         kp_prev_tg_T = ifelse(indicator=="KP_PREV", standardizeddisaggregate=="KeyPop", otherdisaggregate=="TG", numeratordenom=="N", fy2018_targets, 0), 
         kp_prev_pwid = ifelse(indicator=="KP_PREV", standardizeddisaggregate=="KeyPop", otherdisaggregate %in% c("Female PWID", "Male PWID"), numeratordenom=="N", fy2017apr, 0), 
         kp_prev_pwid_T = ifelse(indicator=="KP_PREV", standardizeddisaggregate=="KeyPop", otherdisaggregate %in% c("Female PWID", "Male PWID"), numeratordenom=="N", fy2018_targets, 0), 
         kp_prev_prison = ifelse(indicator=="KP_PREV", standardizeddisaggregate=="KeyPop", otherdisaggregate=="People in prisons and other enclosed settings", numeratordenom=="N", fy2017apr, 0), 
         kp_prev_prison_T = ifelse(indicator=="KP_PREV", standardizeddisaggregate=="KeyPop", otherdisaggregate=="People in prisons and other enclosed settings", numeratordenom=="N", fy2018_targets, 0), 
         kp_mat = ifelse(indicator=="KP_MAT", standardizeddisaggregate=="Total Numerator", numeratordenom=="N", fy2017apr, 0), 
         kp_mat_T = ifelse(indicator=="KP_MAT", standardizeddisaggregate=="Total Numerator", numeratordenom=="N", fy2018_targets, 0), 
         ovc_serv = ifelse(indicator=="OVC_SERV", standardizeddisaggregate=="Total Numerator", numeratordenom=="N", fy2017apr, 0), 
         ovc_serv_T = ifelse(indicator=="OVC_SERV", standardizeddisaggregate=="Total Numerator", numeratordenom=="N", fy2018_targets, 0), 
         ovc_serv_u18 = ifelse(indicator=="OVC_SERV", standardizeddisaggregate %in% c("AgeLessThanTen", "AgeAboveTen/Sex"), age %in% c("<01", "01-09", "10-14", "15-17"), numeratordenom=="N", fy2017apr, 0), 
         ovc_serv_u18_T = ifelse(indicator=="OVC_SERV", standardizeddisaggregate %in% c("AgeLessThanTen", "AgeAboveTen/Sex"), age %in% c("<01", "01-09", "10-14", "15-17"), numeratordenom=="N", fy2018_targets, 0), 
         plhivsubnat = ifelse(indicator=="PLHIV (SUBNAT)", standardizeddisaggregate=="Total Numerator", fy2017apr, 0), 
         plhivsubnat,age/sex_u15 = ifelse(indicator=="PLHIV (SUBNAT, Age/Sex)", standardizeddisaggregate=="Age/Sex", age=="<15", fy2017apr, 0), 
         plhivsubnat,age/sex_o15 = ifelse(indicator=="PLHIV (SUBNAT, Age/Sex)", standardizeddisaggregate=="Age/Sex", age=="15+", fy2017apr, 0), 
         pmtct_arv_already = ifelse(indicator=="PMTCT_ARV", standardizeddisaggregate=="MaternalRegimenType", otherdisaggregate=="Life-long ART Already", numeratordenom=="N", fy2017apr, 0), 
         pmtct_art_already_T = ifelse(indicator=="PMTCT_ART", standardizeddisaggregate=="MaternalRegimenType2017", otherdisaggregate=="Life-long ART Already", numeratordenom=="N", fy2018_targets, 0), 
         pmtct_arv_curr = ifelse(indicator=="PMTCT_ARV", standardizeddisaggregate=="MaternalRegimenType", otherdisaggregate %in% c("Life-long ART New", "Triple-drug ARV"), numeratordenom=="N", fy2017apr, 0), 
         pmtct_art_curr_T = ifelse(indicator=="PMTCT_ART", standardizeddisaggregate=="MaternalRegimenType2017", otherdisaggregate=="Life-long ART New", numeratordenom=="N", fy2018_targets, 0), 
         pmtct_eid = ifelse(indicator=="PMTCT_EID", standardizeddisaggregate=="Total Numerator", numeratordenom=="N", fy2017apr, 0), 
         pmtct_eid_T = ifelse(indicator=="PMTCT_EID", standardizeddisaggregate=="InfantTest", numeratordenom=="N", fy2018_targets, 0), 
         pmtct_eid_pos_12mo = ifelse(indicator=="PMTCT_EID_POS_12MO", standardizeddisaggregate=="Total Numerator", numeratordenom=="N", fy2017apr, 0), 
         pmtct_eid_yield = 0, 
         pmtct_stat_D = ifelse(indicator=="PMTCT_STAT", standardizeddisaggregate=="Total Denominator", numeratordenom=="D", fy2017apr, 0), 
         pmtct_stat_D_T = ifelse(indicator=="PMTCT_STAT", standardizeddisaggregate=="Total Denominator", numeratordenom=="D", fy2018_targets, 0), 
         pmtct_stat = ifelse(indicator=="PMTCT_STAT", standardizeddisaggregate=="Total Numerator", numeratordenom=="N", fy2017apr, 0), 
         pmtct_stat_T = ifelse(indicator=="PMTCT_STAT", standardizeddisaggregate=="Total Numerator", numeratordenom=="N", fy2018_targets, 0), 
         pmtct_stat_pos = ifelse(indicator=="PMTCT_STAT", standardizeddisaggregate=="Known/New", numeratordenom=="N", fy2017apr, 0), 
         pmtct_stat_yield = 0, 
         pmtct_stat_knownpos = ifelse(indicator=="PMTCT_STAT", standardizeddisaggregate=="Known/New",resultstatus=="Positive", otherdisaggregate=="Known at Entry", numeratordenom=="N", fy2017apr, 0), 
         pop_estsubnat = ifelse(indicator=="POP_EST (SUBNAT)", standardizeddisaggregate=="Total Numerator", fy2017apr, 0), 
         pop_estsubnat,sex_m = ifelse(indicator=="POP_EST (SUBNAT, Sex)", standardizeddisaggregate=="Total Numerator", sex=="Male", fy2017apr, 0), 
         pp_prev = ifelse(indicator=="PP_PREV", standardizeddisaggregate=="Total Numerator", numeratordenom=="N", fy2017apr, 0), 
         pp_prev_T = ifelse(indicator=="PP_PREV", standardizeddisaggregate=="Total Numerator", numeratordenom=="N", fy2018_targets, 0), 
         tb_art_T = ifelse(indicator=="TB_ART", standardizeddisaggregate=="Total Numerator", numeratordenom=="N", fy2018_targets, 0), 
         tb_stat_D = ifelse(indicator=="TB_STAT", standardizeddisaggregate=="Total Denominator", numeratordenom=="D", fy2017apr, 0), 
         tb_stat_D_T = ifelse(indicator=="TB_STAT", standardizeddisaggregate=="Total Denominator", numeratordenom=="D", fy2018_targets, 0), 
         tb_stat = ifelse(indicator=="TB_STAT", standardizeddisaggregate=="Total Numerator", numeratordenom=="N", fy2017apr, 0), 
         tb_stat_pos = ifelse(indicator=="TB_STAT_POS", standardizeddisaggregate=="Total Numerator", numeratordenom=="N", fy2017apr, 0), 
         tb_stat_T = ifelse(indicator=="TB_STAT", standardizeddisaggregate=="Total Numerator", numeratordenom=="N", fy2018_targets, 0), 
         tb_stat_yield = 0, 
         tx_curr = ifelse(indicator=="TX_CURR", standardizeddisaggregate=="Total Numerator", numeratordenom=="N", fy2017apr, 0), 
         tx_curr_T = ifelse(indicator=="TX_CURR", standardizeddisaggregate=="Total Numerator", numeratordenom=="N", fy2018_targets, 0), 
         tx_curr_u15 = ifelse(indicator=="TX_CURR", standardizeddisaggregate=="MostCompleteAgeDisagg", age=="<15", numeratordenom=="N", fy2017apr, 0), 
         tx_curr_u15_T = ifelse(indicator=="TX_CURR", standardizeddisaggregate=="MostCompleteAgeDisagg", age=="<15", numeratordenom=="N", fy2018_targets, 0), 
         tx_curr_o15_T = ifelse(indicator=="TX_CURR", standardizeddisaggregate=="MostCompleteAgeDisagg", age=="15+", numeratordenom=="N", fy2018_targets, 0), 
         tx_curr_subnat = ifelse(indicator=="TX_CURR_SUBNAT", standardizeddisaggregate=="Total Numerator", numeratordenom=="N", fy2017apr, 0), 
         tx_curr_subnat_u15 = ifelse(indicator=="TX_CURR_SUBNAT", standardizeddisaggregate=="Age/Sex", age=="<15", numeratordenom=="N", fy2017apr, 0), 
         tx_new_u1 = ifelse(indicator=="TX_NEW", standardizeddisaggregate=="AgeLessThanTen", age=="<01", numeratordenom=="N", fy2017apr, 0), 
         tx_new_u1_T = ifelse(indicator=="TX_NEW", standardizeddisaggregate=="AgeLessThanTen", age=="<01", numeratordenom=="N", fy2018_targets, 0), 
         tx_ret_D = ifelse(indicator=="TX_RET", standardizeddisaggregate=="Total Denominator", numeratordenom=="D", fy2017apr, 0), 
         tx_ret = ifelse(indicator=="TX_RET", standardizeddisaggregate=="Total Numerator", numeratordenom=="N", fy2017apr, 0), 
         tx_ret_u15_D = ifelse(indicator=="TX_RET", standardizeddisaggregate %in% c("AgeLessThanTen", "AgeAboveTen/Sex"), age %in% c("<01", "01-09", "10-14"), numeratordenom=="D", fy2017apr, 0), 
         tx_ret_yield = 0, 
         tx_ret_u15 = ifelse(indicator=="TX_RET", standardizeddisaggregate %in% c("AgeLessThanTen", "AgeAboveTen/Sex"), age %in% c("<01", "01-09", "10-14"), numeratordenom=="N", fy2017apr, 0), 
         tx_ret_u15_yield = 0, 
         vmmc_circ_T = ifelse(indicator=="VMMC_CIRC", standardizeddisaggregate=="Total Numerator", numeratordenom=="N", fy2018_targets, 0), 
         vmmc_circ_rng_T = ifelse(indicator=="VMMC_CIRC", standardizeddisaggregate=="Age", age %in% c("15-19", "20-24", "25-29"), numeratordenom=="N", fy2018_targets, 0), 
         vmmc_circ_subnat = ifelse(indicator=="VMMC_CIRC_SUBNAT", standardizeddisaggregate=="Total Numerator", numeratordenom=="N", fy2017apr, 0)
         
      )
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    