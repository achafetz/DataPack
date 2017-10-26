##   Data Pack COP FY18
##   A.Chafetz, USAID
##   Purpose: generate output for IM targeting in Data Pack
##   Adopted from COP17 Stata code
##   Date: October 19, 2017
##   Updated: 10/26/17

## DEPENDENCIES
    # run 00_datapack_initialize.R
    # ICPI Fact View PSNU_IM
    # 91_datapack_officialnames.R
    # 92_datapack_snu_adj.R

## SETUP ---------------------------------------------------------------------------------------------------

  #import
    df_mechdistro <- read_tsv(file.path(fvdata, paste("ICPI_FactView_PSNU_IM_", datestamp, ".txt", sep="")))
    df_mechdistro <- rename_all(df_mechdistro, tolower)
  
  #cleanup PSNUs (dups & clusters)
    source(file.path(scripts, "91_datapack_officialnames.R"))
      cleanup_mechs(df_mechdistro, rawdata)
      
    source(file.path(scripts, "92_datapack_snu_adj.R"))
      cleanup_snus(df_mechdistro)
      cluster_snus(df_mechdistro)

## DEDUPLICATION -------------------------------------------------------------------------------------------
  #create a deduplication mechanism for every SNU
  
  #collapse to unique list of psnus
    df_dedups <- df_mechdistro %>%
        filter(is.na(typemilitary)) %>%
        distinct(operatingunit, psnuuid, psnu) %>%
        filter(!is.na(psnuuid)) %>%
        mutate(DSD = "00000", TA = "00000") %>%
        gather(indicatortype, mechanismid, DSD, TA)

## REMOVE BELOW  -------------------------------------------------------------------------------------------------
      
  ## FOR TESTING ONLY ## REMOVE after FY17 APR becomes available ##
  df_mechdistro[is.na(df_mechdistro)] <- 0
  df_mechdistro <- df_mechdistro %>% 
    mutate(fy2017apr = ifelse(indicator=="TX_CURR", fy2017q3, 
                              ifelse(indicator %in% c("KP_PREV","PP_PREV", "OVC_HIVSTAT", "OVC_SERV", 
                                                      "TB_ART", "TB_STAT", "TX_TB", "GEND_GBV", "PMTCT_FO", 
                                                      "TX_RET", "KP_MAT"), fy2017q2, 
                                     fy2017q1 + fy2017q2 + fy2017q3)),
           fy2018_targets = fy2017_targets * 1.5,
           fy18snuprioritization = as.character(fy16snuprioritization))
  df_mechdistro[df_mechdistro==0] <- NA
      
#  ^^^^^^ REMOVE ABOVE ^^^^^^

## SAVE TEMP FILE -------------------------------------------------------------------------------------------------
  #save temp file as starting point for 11_datapack_output_keyind
  save(df_indtbl, file = file.path(tempoutput, "cleanim_temp.RData"))  
  
## MECH DISTRIBUTION ---------------------------------------------------------------------------------------
  # output formulas created in Data Pack template (POPsubset sheet)
      
      ## TESTING, NOT FINAL DATA --> Need to figure out all final targets and what non-Total Numerators are included
      df_mechdistro <- df_mechdistro %>%
        mutate(
          hts_tst = ifelse((indicator=="HTS_TST" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2017apr, 0), 
          hts_tst_pos = ifelse((indicator=="HTS_TST_POS" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2017apr, 0), 
          kp_prev = ifelse((indicator=="KP_PREV" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2017apr, 0), 
          kp_mat = ifelse((indicator=="KP_MAT" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2017apr, 0), 
          ovc_serv = ifelse((indicator=="OVC_SERV" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2017apr, 0), 
          pmtct_eid = ifelse((indicator=="PMTCT_EID" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2017apr, 0), 
          pmtct_eid_pos_12mo = ifelse((indicator=="PMTCT_EID_POS_12MO" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2017apr, 0), 
          pmtct_stat_D = ifelse((indicator=="PMTCT_STAT" & standardizeddisaggregate=="Total Denominator" & numeratordenom=="D"), fy2017apr, 0), 
          pmtct_stat = ifelse((indicator=="PMTCT_STAT" & standardizeddisaggregate=="Total Numerator"), fy2017apr, 0), 
          pp_prev = ifelse((indicator=="PP_PREV" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2017apr, 0), 
          tb_stat_D = ifelse((indicator=="TB_STAT" & standardizeddisaggregate=="Total Denominator" & numeratordenom=="D"), fy2017apr, 0),
          tb_stat = ifelse((indicator=="TB_STAT" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2017apr, 0),
          tx_curr = ifelse((indicator=="TX_CURR" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2017apr, 0),
          tx_new = ifelse((indicator=="TX_NEW" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2017apr, 0),
          tx_ret_D = ifelse((indicator=="TX_RET" & standardizeddisaggregate=="Total Denominator" & numeratordenom=="D"), fy2017apr, 0),
          tx_ret = ifelse((indicator=="TX_RET" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2017apr, 0),
          vmmc_circ = ifelse((indicator=="VMMC_CIRC" & standardizeddisaggregate=="Total Numerator" & numeratordenom=="N"), fy2017apr, 0)
        )
      
      
      
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
      select(-contains("fy2")) %>% #only want "new" variables
      rename_if(is_numeric, funs(paste("D",.,"fy19", sep = "_"))) %>% #rename with common stub
      group_by(operatingunit, psnu, psnuuid, indicatortype, mechanismid) %>%
      summarise_if(is_numeric, funs(sum(., na.rm = TRUE))) %>% #summarize all numeric (new) variables
      ungroup

      
## CREATE DISTRIBUTION -------------------------------------------------------------------------------------------------
    
  #reshape
    df_mechdistro <- df_mechdistro %>% 
      gather(ind, val, starts_with("D_")) %>%
      filter(val!=0)

  #PSNU totals for each variable
    df_psnutot <- df_mechdistro %>% 
      group_by(psnuuid, indicatortype, ind) %>% #at psnu level, mechanismid removed
      summarise_at(vars(val), funs(sum(.))) %>% #summarize all numeric (new) variables
      ungroup %>% 
      rename(tot = val)
    
    df_mechdistro <- full_join(df_mechdistro, df_psnutot, by = c("psnuuid", "indicatortype", "ind")) #merge onto df_mechdistro
      rm(df_psnutot)
      
  #create distribution - IM's variable share of PSNU total      
    df_mechdistro <- df_mechdistro %>% 
      mutate(distro = val/tot) %>% 
      select(-val, -tot) %>%
    
  #reshape wide
      spread(ind, distro) %>%
  
  #clean up for export
      mutate(placeholder = NA) %>% 
      select(operatingunit, psnuuid, psnu, placeholder, mechanismid, indicatortype, starts_with("D_")) %>% 
      arrange(operatingunit, psnu, mechanismid, indicatortype)

 

## EXPORT -----------------------------------------------------------------------------------------------------  
    
    write_csv(df_mechdistro, file.path(output, "Global_AllocbyIM.csv", na = ""))
      rm(df_mechdistro, cleanup_mechs, cleanup_snus, cluster_snus)
    
  