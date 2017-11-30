##   Data Pack COP FY18
##   A.Chafetz, USAID
##   Purpose: generate output for IM targeting in Data Pack
##   Adopted from COP17 Stata code
##   Date: October 19, 2017
##   Updated: 11/30

## DEPENDENCIES
    # run 00_datapack_initialize.R
    # ICPI Fact View PSNU_IM
    # 91_datapack_officialnames.R
    # 92_datapack_snu_adj.R

## SETUP ---------------------------------------------------------------------------------------------------

  #import
    df_mechdistro <- read_tsv(file.path(fvdata, paste("ICPI_FactView_PSNU_IM_", datestamp, ".txt", sep=""))) %>% 
        rename_all(tolower)
  
  #cleanup PSNUs (dups & clusters)
    source(file.path(scripts, "91_datapack_officialnames.R"))
      df_mechdistro <-cleanup_mechs(df_mechdistro, rawdata)
      
    source(file.path(scripts, "92_datapack_snu_adj.R"))
      df_mechdistro <- cleanup_snus(df_mechdistro)
      df_mechdistro <- cluster_snus(df_mechdistro)
    
    rm(cleanup_mechs, cleanup_snus, cluster_snus)
    
## DEDUPLICATION -------------------------------------------------------------------------------------------
  #create a deduplication mechanism for every SNU
  
  #collapse to unique list of psnus
    df_dedups <- df_mechdistro %>%
        #filter(is.na(typemilitary)) %>%
        distinct(operatingunit, psnuuid, psnu) %>%
        filter(!is.na(psnuuid)) %>%
        mutate(DSD = "00000", TA = "00000") %>%
        gather(indicatortype, mechanismid, DSD, TA)

## REMOVE BELOW  -------------------------------------------------------------------------------------------------
      
  ## FOR TESTING ONLY ## REMOVE after FY17 APR becomes available ##
      
    # source(file.path(scripts, "93_datapack_testingdata.R"))
     # df_mechdistro <- testing_dummydata(df_mechdistro)
      
#  ^^^^^^ REMOVE ABOVE ^^^^^^

## SAVE TEMP FILE -------------------------------------------------------------------------------------------------
  #save temp file as starting point for 11_datapack_output_keyind
  save(df_mechdistro, file = file.path(tempoutput, "cleanim_temp.RData"))  
  
## MECH DISTRIBUTION ---------------------------------------------------------------------------------------
  # output formulas created in Data Pack template (POPsubset sheet)
  # updated 11/30
      
      ## TESTING, NOT FINAL DATA --> Need to figure out all final targets and what non-Total Numerators are included
      df_mechdistro <- df_mechdistro %>%
        mutate(
          tx_ret_D = ifelse((indicator=="TX_RET" & standardizeddisaggregate=="Total Denominator" & numeratordenom=="D"), fy2017apr, 0), 
          tx_ret = ifelse((indicator=="TX_RET" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2017apr, 0), 
          tx_new = ifelse((indicator=="TX_NEW" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2017apr, 0), 
          tx_curr = ifelse((indicator=="TX_CURR" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2017apr, 0), 
          tx_plvs_D = ifelse((indicator=="TX_PLVS" & standardizeddisaggregate=="Total Denominator" & numeratordenom=="D"), fy2017apr, 0), 
          pmtct_stat_D = ifelse((indicator=="PMTCT_STAT" & standardizeddisaggregate=="Total Denominator" & numeratordenom=="D"), fy2017apr, 0), 
          pmtct_stat = ifelse((indicator=="PMTCT_STAT" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2017apr, 0), 
          pmtct_stat_newpos = ifelse((indicator=="PMTCT_STAT" & standardizeddisaggregate=="Age/KnownNewResult" & resultstatus=="Positive" & otherdisaggregate=="Newly Identified" & numeratordenom=="N"), fy2017apr, 0), 
          pmtct_stat_newneg = ifelse((indicator=="PMTCT_STAT" & standardizeddisaggregate=="Age/KnownNewResult" & resultstatus=="Negative" & otherdisaggregate=="Newly Identified" & numeratordenom=="N"), fy2017apr, 0), 
          pmtct_stat_known = ifelse((indicator=="PMTCT_STAT" & standardizeddisaggregate=="Age/KnownNewResult" & otherdisaggregate=="Known at Entry" & numeratordenom=="N"), fy2017apr, 0), 
          pmtct_art = ifelse((indicator=="PMTCT_ART" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2017apr, 0), 
          pmtct_art_already = ifelse((indicator=="PMTCT_ART" & standardizeddisaggregate=="NewExistingArt" & otherdisaggregate=="Life-long ART Already" & numeratordenom=="N"), fy2017apr, 0), 
          pmtct_eid = ifelse((indicator=="PMTCT_EID" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2017apr, 0), 
          tb_stat = ifelse((indicator=="TB_STAT" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2017apr, 0), 
          tb_art = ifelse((indicator=="TB_ART" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2017apr, 0), 
          tb_prev_D = ifelse((indicator=="TB_PREV" & standardizeddisaggregate=="Total Denominator" & numeratordenom=="D"), fy2017apr, 0), 
          tb_prev = ifelse((indicator=="TB_PREV" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2017apr, 0), 
          tx_tb_D = ifelse((indicator=="TX_TB" & standardizeddisaggregate=="Total Denominator" & numeratordenom=="D"), fy2017apr, 0), 
          hts_tst_indexmod_o15 = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="15+" & modality=="IndexMod" & numeratordenom=="N"), fy2017apr, 0), 
          hts_tst_mobilemod_o15 = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="15+" & modality=="MobileMod" & numeratordenom=="N"), fy2017apr, 0), 
          hts_tst_vctmod_o15 = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="15+" & modality=="VCTMod" & numeratordenom=="N"), fy2017apr, 0), 
          hts_tst_othermod_o15 = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="15+" & modality=="OtherMod" & numeratordenom=="N"), fy2017apr, 0), 
          hts_tst_index_o15 = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="15+" & modality=="Index" & numeratordenom=="N"), fy2017apr, 0), 
          hts_tst_sti_o15 = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="15+" & modality=="STI" & numeratordenom=="N"), fy2017apr, 0), 
          hts_tst_inpat_o15 = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="15+" & modality=="Inpat" & numeratordenom=="N"), fy2017apr, 0), 
          hts_tst_emergency_o15 = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="15+" & modality=="Emergency" & numeratordenom=="N"), fy2017apr, 0), 
          hts_tst_vct_o15 = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="15+" & modality=="VCT" & numeratordenom=="N"), fy2017apr, 0), 
          hts_tst_tbclinic_o15 = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="15+" & modality=="TBClinic" & numeratordenom=="N"), fy2017apr, 0), 
          hts_tst_vmmc_o15 = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="15+" & modality=="VMMC" & numeratordenom=="N"), fy2017apr, 0), 
          hts_tst_pmtctanc_o15 = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="15+" & modality=="PMTCT ANC" & numeratordenom=="N"), fy2017apr, 0), 
          hts_tst_otherpitc_o15 = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="15+" & modality=="OtherPITC" & numeratordenom=="N"), fy2017apr, 0), 
          hts_tst_pos_indexmod_o15 = ifelse((indicator=="HTS_TST_POS" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="15+" & modality=="IndexMod" & numeratordenom=="N"), fy2017apr, 0), 
          hts_tst_pos_mobilemod_o15 = ifelse((indicator=="HTS_TST_POS" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="15+" & modality=="MobileMod" & numeratordenom=="N"), fy2017apr, 0), 
          hts_tst_pos_vctmod_o15 = ifelse((indicator=="HTS_TST_POS" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="15+" & modality=="VCTMod" & numeratordenom=="N"), fy2017apr, 0), 
          hts_tst_pos_othermod_o15 = ifelse((indicator=="HTS_TST_POS" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="15+" & modality=="OtherMod" & numeratordenom=="N"), fy2017apr, 0), 
          hts_tst_pos_index_o15 = ifelse((indicator=="HTS_TST_POS" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="15+" & modality=="Index" & numeratordenom=="N"), fy2017apr, 0), 
          hts_tst_pos_sti_o15 = ifelse((indicator=="HTS_TST_POS" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="15+" & modality=="STI" & numeratordenom=="N"), fy2017apr, 0), 
          hts_tst_pos_inpat_o15 = ifelse((indicator=="HTS_TST_POS" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="15+" & modality=="Inpat" & numeratordenom=="N"), fy2017apr, 0), 
          hts_tst_pos_emergency_o15 = ifelse((indicator=="HTS_TST_POS" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="15+" & modality=="Emergency" & numeratordenom=="N"), fy2017apr, 0), 
          hts_tst_pos_vct_o15 = ifelse((indicator=="HTS_TST_POS" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="15+" & modality=="VCT" & numeratordenom=="N"), fy2017apr, 0), 
          hts_tst_pos_tbclinic_o15 = ifelse((indicator=="HTS_TST_POS" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="15+" & modality=="TBClinic" & numeratordenom=="N"), fy2017apr, 0), 
          hts_tst_pos_vmmc_o15 = ifelse((indicator=="HTS_TST_POS" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="15+" & modality=="VMMC" & numeratordenom=="N"), fy2017apr, 0), 
          hts_tst_pos_pmtctanc_o15 = ifelse((indicator=="HTS_TST_POS" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="15+" & modality=="PMTCT ANC" & numeratordenom=="N"), fy2017apr, 0), 
          hts_tst_pos_otherpitc_o15 = ifelse((indicator=="HTS_TST_POS" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="15+" & modality=="OtherPITC" & numeratordenom=="N"), fy2017apr, 0), 
          hts_tst_indexmod_o15 = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="<15" & modality=="IndexMod" & numeratordenom=="N"), fy2017apr, 0), 
          hts_tst_mobilemod_o15 = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="<15" & modality=="MobileMod" & numeratordenom=="N"), fy2017apr, 0), 
          hts_tst_vctmod_o15 = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="<15" & modality=="VCTMod" & numeratordenom=="N"), fy2017apr, 0), 
          hts_tst_othermod_o15 = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="<15" & modality=="OtherMod" & numeratordenom=="N"), fy2017apr, 0), 
          hts_tst_index_u15 = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="<15" & modality=="Index" & numeratordenom=="N"), fy2017apr, 0), 
          hts_tst_sti_u15 = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="<15" & modality=="STI" & numeratordenom=="N"), fy2017apr, 0), 
          hts_tst_inpat_u15 = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="<15" & modality=="Inpat" & numeratordenom=="N"), fy2017apr, 0), 
          hts_tst_emergency_u15 = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="<15" & modality=="Emergency" & numeratordenom=="N"), fy2017apr, 0), 
          hts_tst_vct_u15 = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="<15" & modality=="VCT" & numeratordenom=="N"), fy2017apr, 0), 
          hts_tst_tbclinic_u15 = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="<15" & modality=="TBClinic" & numeratordenom=="N"), fy2017apr, 0), 
          hts_tst_vmmc_u15 = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="<15" & modality=="VMMC" & numeratordenom=="N"), fy2017apr, 0), 
          hts_tst_pmtctanc_u15 = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="<15" & modality=="PMTCT ANC" & numeratordenom=="N"), fy2017apr, 0), 
          hts_tst_pediatric_u15 = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="<15" & modality=="Pediatric" & numeratordenom=="N"), fy2017apr, 0), 
          hts_tst_malnutrition_u15 = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="<15" & modality=="Malnutrition" & numeratordenom=="N"), fy2017apr, 0), 
          hts_tst_otherpitc_u15 = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="Modality/MostCompleteAgeDisagg" & age=="<15" & modality=="OtherPITC" & numeratordenom=="N"), fy2017apr, 0), 
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
          hts_tst_keypop = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="KeyPop/Result" & numeratordenom=="N"), fy2017apr, 0), 
          hts_self = ifelse((indicator=="HTS_SELF" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2017apr, 0), 
          vmmc_circ = ifelse((indicator=="VMMC_CIRC" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2017apr, 0), 
          ovc_serv = ifelse((indicator=="OVC_SERV" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2017apr, 0), 
          ovc_serv_grad = ifelse((indicator=="OVC_SERV" & standardizeddisaggregate=="Program Status" & otherdisaggregate=="Graduated" & numeratordenom=="N"), fy2017apr, 0), 
          ovc_serv_active = ifelse((indicator=="OVC_SERV" & standardizeddisaggregate=="Program Status" & otherdisaggregate=="Active" & numeratordenom=="N"), fy2017apr, 0), 
          ovc_serv_exited = ifelse((indicator=="OVC_SERV" & standardizeddisaggregate=="Program Status" & otherdisaggregate=="Exited without Graduation" & numeratordenom=="N"), fy2017apr, 0), 
          ovc_serv_trans = ifelse((indicator=="OVC_SERV" & standardizeddisaggregate=="Program Status" & otherdisaggregate=="Transferred" & numeratordenom=="N"), fy2017apr, 0), 
          ovc_serv_u18 = ifelse((indicator=="OVC_SERV" & standardizeddisaggregate %in% c("AgeLessThanTen", "AgeAboveTen/Sex") & age %in% c("<01", "01-09", "10-14", "15-17") & numeratordenom=="N"), fy2017apr, 0), 
          ovc_hivstat = ifelse((indicator=="OVC_HIVSTAT" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2017apr, 0), 
          ovc_serv_edu = ifelse((indicator=="OVC_SERV" & standardizeddisaggregate=="Age/Sex/Service" & otherdisaggregate=="Education Support" & numeratordenom=="N"), fy2017apr, 0), 
          ovc_serv_care = ifelse((indicator=="OVC_SERV" & standardizeddisaggregate=="Age/Sex/Service" & otherdisaggregate=="Parenting/Caregiver Programs" & numeratordenom=="N"), fy2017apr, 0), 
          ovc_serv_econ = ifelse((indicator=="OVC_SERV" & standardizeddisaggregate=="Age/Sex/Service" & otherdisaggregate=="Economic Strengthening" & numeratordenom=="N"), fy2017apr, 0), 
          ovc_serv_sp = ifelse((indicator=="OVC_SERV" & standardizeddisaggregate=="Age/Sex/Service" & otherdisaggregate=="Social Protection" & numeratordenom=="N"), fy2017apr, 0), 
          ovc_serv_oth = ifelse((indicator=="OVC_SERV" & standardizeddisaggregate=="Age/Sex/Service" & otherdisaggregate=="Other Service Areas" & numeratordenom=="N"), fy2017apr, 0), 
          kp_prev_msm_sw_D = ifelse((indicator=="KP_PREV" & standardizeddisaggregate=="KeyPop" & otherdisaggregate=="MSM SW" & numeratordenom=="D"), fy2017apr, 0), 
          kp_prev_msm_sw = ifelse((indicator=="KP_PREV" & standardizeddisaggregate=="KeyPop" & otherdisaggregate=="MSM SW" & numeratordenom=="N"), fy2017apr, 0), 
          kp_prev_msm_not_sw_D = ifelse((indicator=="KP_PREV" & standardizeddisaggregate=="KeyPop" & otherdisaggregate=="MSM not SW" & numeratordenom=="D"), fy2017apr, 0), 
          kp_prev_msm_not_sw = ifelse((indicator=="KP_PREV" & standardizeddisaggregate=="KeyPop" & otherdisaggregate=="MSM not SW" & numeratordenom=="N"), fy2017apr, 0), 
          kp_prev_tg_sw_D = ifelse((indicator=="KP_PREV" & standardizeddisaggregate=="KeyPop" & otherdisaggregate=="TG SW" & numeratordenom=="D"), fy2017apr, 0), 
          kp_prev_tg_sw = ifelse((indicator=="KP_PREV" & standardizeddisaggregate=="KeyPop" & otherdisaggregate=="TG SW" & numeratordenom=="N"), fy2017apr, 0), 
          kp_prev_tg_not_sw_D = ifelse((indicator=="KP_PREV" & standardizeddisaggregate=="KeyPop" & otherdisaggregate=="TG not SW" & numeratordenom=="D"), fy2017apr, 0), 
          kp_prev_tg_not_sw = ifelse((indicator=="KP_PREV" & standardizeddisaggregate=="KeyPop" & otherdisaggregate=="TG not SW" & numeratordenom=="N"), fy2017apr, 0), 
          kp_prev_fsw_D = ifelse((indicator=="KP_PREV" & standardizeddisaggregate=="KeyPop" & otherdisaggregate=="FSW" & numeratordenom=="D"), fy2017apr, 0), 
          kp_prev_fsw = ifelse((indicator=="KP_PREV" & standardizeddisaggregate=="KeyPop" & otherdisaggregate=="FSW" & numeratordenom=="N"), fy2017apr, 0), 
          kp_prev_pwid_m_D = ifelse((indicator=="KP_PREV" & standardizeddisaggregate=="KeyPop" & otherdisaggregate=="Male PWID" & numeratordenom=="D"), fy2017apr, 0), 
          kp_prev_pwid_m = ifelse((indicator=="KP_PREV" & standardizeddisaggregate=="KeyPop" & otherdisaggregate=="Male PWID" & numeratordenom=="N"), fy2017apr, 0), 
          kp_prev_pwid_f_D = ifelse((indicator=="KP_PREV" & standardizeddisaggregate=="KeyPop" & otherdisaggregate=="Female PWID" & numeratordenom=="D"), fy2017apr, 0), 
          kp_prev_pwid_f = ifelse((indicator=="KP_PREV" & standardizeddisaggregate=="KeyPop" & otherdisaggregate=="Female PWID" & numeratordenom=="N"), fy2017apr, 0), 
          kp_prev_prison = ifelse((indicator=="KP_PREV" & standardizeddisaggregate=="KeyPop" & otherdisaggregate=="People in prisons and other enclosed settings" & numeratordenom=="N"), fy2017apr, 0), 
          kp_prev_prison = ifelse((indicator=="KP_PREV" & standardizeddisaggregate=="KeyPop" & otherdisaggregate=="People in prisons and other enclosed settings" & numeratordenom=="N"), fy2017apr, 0), 
          pp_prev = ifelse((indicator=="PP_PREV" & standardizeddisaggregate=="KeyPop" & numeratordenom=="N"), fy2017apr, 0), 
          kp_mat = ifelse((indicator=="KP_MAT" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2017apr, 0), 
          gend_gbv = ifelse((indicator=="GEND_GBV" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2017apr, 0), 
          prep_new = ifelse((indicator=="PrEP_NEW" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2017apr, 0))
      
      
## CLEAN UP -------------------------------------------------------------------------------------------------
  
  #keep just one dedup
    df_mechdistro <- mutate(df_mechdistro, mechanismid = ifelse(mechanismid == "00001", "00000", mechanismid))
      
  #append psnu DSD + TA dedups on 
    df_mechdistro <- bind_rows(df_mechdistro, df_dedups)  
      rm(df_dedups)
      
  #aggregate up to psnu level
    df_mechdistro <- df_mechdistro %>% 
      mutate(mechanismid = as.character(mechanismid), 
             coarsedisaggregate = as.character(coarsedisaggregate)) %>% #shouldn't be numeric
      select(-contains("fy2")) %>% #only want "new", mutated variables
      rename_if(is.numeric, funs(paste("D",.,"pct", sep = "_"))) %>% #rename with common stub
      group_by(operatingunit, psnu, psnuuid, indicatortype, mechanismid) %>%
      summarise_if(is.numeric, funs(sum(., na.rm = TRUE))) %>% #summarize all numeric (new) variables
      ungroup()

      
## CREATE DISTRIBUTION -------------------------------------------------------------------------------------------------
    
  #reshape
    df_mechdistro <- df_mechdistro %>% 
      gather(ind, val, starts_with("D_")) %>%
      filter(val!=0)

  #PSNU totals for each variable
    df_mechdistro <- df_mechdistro %>% 
      group_by(psnuuid, indicatortype, ind) %>% #at psnu level, mechanismid removed
      mutate(total = sum(val)) %>%  #summarize psnu level total
      ungroup() %>% 
      
  #create distribution - IM's variable share of PSNU total      
      mutate(distro = round(val/total, 3)) %>% 
      select(-val, -total) %>%
    
  #reshape wide
      spread(ind, distro) %>%
  
  #clean up for export
      mutate(placeholder = NA) %>% 
      select(operatingunit, psnuuid, psnu, placeholder, mechanismid, indicatortype, starts_with("D_")) %>% 
      arrange(operatingunit, psnu, mechanismid, indicatortype)

 

## EXPORT -----------------------------------------------------------------------------------------------------  
    
    write_csv(df_mechdistro, file.path(output, "Global_AllocbyIM.csv", sep=""), na = "")
      rm(df_mechdistro, cleanup_mechs, cleanup_snus, cluster_snus)
    
  