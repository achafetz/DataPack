**   Data Pack
**   COP FY17
**   Aaron Chafetz
**   Purpose: generate output for Excel disagg allocation of Data Pack targets
**   Date: January 19, 2017
**   Updated: 3/2/17


*******************************
/*
*define OU remove after piloting
	global ou "Tanzania"
	global ou_ns = subinstr(subinstr("${ou}", " ","",.),"'","",.)
*/
*******************************

*open site dataset
	use "$output/temp_site_${ou_ns}_base", clear

** TX_NEW tab
	*create variables
	// output generated in Site & Disagg template (POPsubset sheet)
	// updated 1/26
	gen tx_new_aas_f_u15 = fy2017_targets if indicator=="TX_NEW" & disaggregate=="Aggregated Age/Sex" & sex=="Female" & age=="<15" & numeratordenom=="N"
	gen tx_new_aas_f_o15 = fy2017_targets if indicator=="TX_NEW" & disaggregate=="Aggregated Age/Sex" & sex=="Female" & age=="15+" & numeratordenom=="N"
	gen tx_new_aas_m_u15 = fy2017_targets if indicator=="TX_NEW" & disaggregate=="Aggregated Age/Sex" & sex=="Male" & age=="<15" & numeratordenom=="N"
	gen tx_new_aas_m_o15 = fy2017_targets if indicator=="TX_NEW" & disaggregate=="Aggregated Age/Sex" & sex=="Male" & age=="15+" & numeratordenom=="N"
	gen tx_new_as_u1 = fy2017_targets if indicator=="TX_NEW" & disaggregate=="AgeLessThanTen" & age=="<01" & numeratordenom=="N"
	gen tx_new_as_1to9 = fy2017_targets if indicator=="TX_NEW" & disaggregate=="AgeLessThanTen" & age=="01-09" & numeratordenom=="N"
	gen tx_new_as_f_10to14 = fy2017_targets if indicator=="TX_NEW" & disaggregate=="AgeAboveTen/Sex" & sex=="Female" & age=="10-14" & numeratordenom=="N"
	gen tx_new_as_f_15to19 = fy2017_targets if indicator=="TX_NEW" & disaggregate=="AgeAboveTen/Sex" & sex=="Female" & age=="15-19" & numeratordenom=="N"
	gen tx_new_as_f_20to24 = fy2017_targets if indicator=="TX_NEW" & disaggregate=="AgeAboveTen/Sex" & sex=="Female" & age=="20-24" & numeratordenom=="N"
	gen tx_new_as_f_25to49 = fy2017_targets if indicator=="TX_NEW" & disaggregate=="AgeAboveTen/Sex" & sex=="Female" & age=="25-49" & numeratordenom=="N"
	gen tx_new_as_f_o50 = fy2017_targets if indicator=="TX_NEW" & disaggregate=="AgeAboveTen/Sex" & sex=="Female" & age=="50+" & numeratordenom=="N"
	gen tx_new_as_m_10to14 = fy2017_targets if indicator=="TX_NEW" & disaggregate=="AgeAboveTen/Sex" & sex=="Male" & age=="10-14" & numeratordenom=="N"
	gen tx_new_as_m_15to19 = fy2017_targets if indicator=="TX_NEW" & disaggregate=="AgeAboveTen/Sex" & sex=="Male" & age=="15-19" & numeratordenom=="N"
	gen tx_new_as_m_20to24 = fy2017_targets if indicator=="TX_NEW" & disaggregate=="AgeAboveTen/Sex" & sex=="Male" & age=="20-24" & numeratordenom=="N"
	gen tx_new_as_m_25to49 = fy2017_targets if indicator=="TX_NEW" & disaggregate=="AgeAboveTen/Sex" & sex=="Male" & age=="25-49" & numeratordenom=="N"
	gen tx_new_as_m_o50 = fy2017_targets if indicator=="TX_NEW" & disaggregate=="AgeAboveTen/Sex" & sex=="Male" & age=="50+" & numeratordenom=="N"
	gen tx_curr_aas_f_u15 = fy2017_targets if indicator=="TX_CURR" & disaggregate=="Aggregated Age/Sex" & sex=="Female" & age=="<15" & numeratordenom=="N"
	gen tx_curr_aas_f_o15 = fy2017_targets if indicator=="TX_CURR" & disaggregate=="Aggregated Age/Sex" & sex=="Female" & age=="15+" & numeratordenom=="N"
	gen tx_curr_aas_m_u15 = fy2017_targets if indicator=="TX_CURR" & disaggregate=="Aggregated Age/Sex" & sex=="Male" & age=="<15" & numeratordenom=="N"
	gen tx_curr_aas_m_o15 = fy2017_targets if indicator=="TX_CURR" & disaggregate=="Aggregated Age/Sex" & sex=="Male" & age=="15+" & numeratordenom=="N"
	gen tx_curr_as_u1 = fy2017_targets if indicator=="TX_CURR" & disaggregate=="AgeLessThanTen" & age=="<01" & numeratordenom=="N"
	gen tx_curr_as_1to9 = fy2017_targets if indicator=="TX_CURR" & disaggregate=="AgeLessThanTen" & age=="01-09" & numeratordenom=="N"
	gen tx_curr_as_f_10to14 = fy2017_targets if indicator=="TX_CURR" & disaggregate=="AgeAboveTen/Sex" & sex=="Female" & age=="10-14" & numeratordenom=="N"
	gen tx_curr_as_f_15to19 = fy2017_targets if indicator=="TX_CURR" & disaggregate=="AgeAboveTen/Sex" & sex=="Female" & age=="15-19" & numeratordenom=="N"
	gen tx_curr_as_f_20to24 = fy2017_targets if indicator=="TX_CURR" & disaggregate=="AgeAboveTen/Sex" & sex=="Female" & age=="20-24" & numeratordenom=="N"
	gen tx_curr_as_f_25to49 = fy2017_targets if indicator=="TX_CURR" & disaggregate=="AgeAboveTen/Sex" & sex=="Female" & age=="25-49" & numeratordenom=="N"
	gen tx_curr_as_f_o50 = fy2017_targets if indicator=="TX_CURR" & disaggregate=="AgeAboveTen/Sex" & sex=="Female" & age=="50+" & numeratordenom=="N"
	gen tx_curr_as_m_10to14 = fy2017_targets if indicator=="TX_CURR" & disaggregate=="AgeAboveTen/Sex" & sex=="Male" & age=="10-14" & numeratordenom=="N"
	gen tx_curr_as_m_15to19 = fy2017_targets if indicator=="TX_CURR" & disaggregate=="AgeAboveTen/Sex" & sex=="Male" & age=="15-19" & numeratordenom=="N"
	gen tx_curr_as_m_20to24 = fy2017_targets if indicator=="TX_CURR" & disaggregate=="AgeAboveTen/Sex" & sex=="Male" & age=="20-24" & numeratordenom=="N"
	gen tx_curr_as_m_25to49 = fy2017_targets if indicator=="TX_CURR" & disaggregate=="AgeAboveTen/Sex" & sex=="Male" & age=="25-49" & numeratordenom=="N"
	gen tx_curr_as_m_o50 = fy2017_targets if indicator=="TX_CURR" & disaggregate=="AgeAboveTen/Sex" & sex=="Male" & age=="50+" & numeratordenom=="N"
	gen pmtct_stat_kn_known = fy2017_targets if indicator=="PMTCT_STAT" & disaggregate=="Known/New" & otherdisaggregate=="Known at Entry" & numeratordenom=="N"
	gen pmtct_stat_kn_new = fy2017_targets if indicator=="PMTCT_STAT" & disaggregate=="Known/New" & otherdisaggregate=="Newly Identified" & numeratordenom=="N"
	gen pmtct_arv_m_azt = fy2017_targets if indicator=="PMTCT_ARV" & disaggregate=="MaternalRegimenType" & otherdisaggregate=="AZT" & numeratordenom=="N"
	gen pmtct_arv_m_lifealready = fy2017_targets if indicator=="PMTCT_ART" & disaggregate=="MaternalRegimenType2017" & otherdisaggregate=="Life-long ART Already" & numeratordenom=="N"
	gen pmtct_arv_m_lifenew = fy2017_targets if indicator=="PMTCT_ART" & disaggregate=="MaternalRegimenType2017" & otherdisaggregate=="Life-long ART New" & numeratordenom=="N"
	gen pmtct_arv_m_single = .
	gen pmtct_arv_m_tripe = fy2017_targets if indicator=="PMTCT_ARV" & disaggregate=="MaternalRegimenType" & otherdisaggregate=="Triple-drug ARV" & numeratordenom=="N"
	gen pmtct_eid_i_u2mo = fy2017_targets if indicator=="PMTCT_EID" & disaggregate=="InfantTest" & age=="[months] 00-02" & numeratordenom=="N"
	gen pmtct_eid_i_2to12mo = fy2017_targets if indicator=="PMTCT_EID" & disaggregate=="InfantTest" & age=="[months] 02-12" & numeratordenom=="N"
	gen pmtct_eid_pos_2mo = fy2017_targets if indicator=="PMTCT_EID_POS_2MO" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen pmtct_eid_pos_12mo = fy2017_targets if indicator=="PMTCT_EID_POS_12MO" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen tb_art = fy2017_targets if indicator=="TB_ART" & disaggregate=="Total Numerator" & numeratordenom=="N"
	gen tb_art_D = fy2017_targets if indicator=="TB_ART" & disaggregate=="Total Denominator" & numeratordenom=="D"
	gen tb_art_aas_f_u15 = fy2017_targets if indicator=="TB_ART" & disaggregate=="Aggregated Age/Sex" & sex=="Female" & age=="<15" & numeratordenom=="N"
	gen tb_art_aas_f_o15 = fy2017_targets if indicator=="TB_ART" & disaggregate=="Aggregated Age/Sex" & sex=="Female" & age=="15+" & numeratordenom=="N"
	gen tb_art_aas_m_u15 = fy2017_targets if indicator=="TB_ART" & disaggregate=="Aggregated Age/Sex" & sex=="Male" & age=="<15" & numeratordenom=="N"
	gen tb_art_aas_m_o15 = fy2017_targets if indicator=="TB_ART" & disaggregate=="Aggregated Age/Sex" & sex=="Male" & age=="15+" & numeratordenom=="N"
	gen tb_stat_aas_f_u15 = fy2017_targets if indicator=="TB_STAT" & disaggregate=="Aggregated Age/Sex" & sex=="Female" & age=="<15" & numeratordenom=="N"
	gen tb_stat_aas_f_o15 = fy2017_targets if indicator=="TB_STAT" & disaggregate=="Aggregated Age/Sex" & sex=="Female" & age=="15+" & numeratordenom=="N"
	gen tb_stat_aas_m_u15 = fy2017_targets if indicator=="TB_STAT" & disaggregate=="Aggregated Age/Sex" & sex=="Male" & age=="<15" & numeratordenom=="N"
	gen tb_stat_aas_m_o15 = fy2017_targets if indicator=="TB_STAT" & disaggregate=="Aggregated Age/Sex" & sex=="Male" & age=="15+" & numeratordenom=="N"
	gen tb_stat_s_f = fy2017_targets if indicator=="TB_STAT" & disaggregate=="Sex" & sex=="Female" & numeratordenom=="N"
	gen tb_stat_s_m = fy2017_targets if indicator=="TB_STAT" & disaggregate=="Sex" & sex=="Male" & numeratordenom=="N"
	gen tb_stat_a_u1 = fy2017_targets if indicator=="TB_STAT" & disaggregate=="Age" & age=="<01" & numeratordenom=="N"
	gen tb_stat_a_1to4 = fy2017_targets if indicator=="TB_STAT" & disaggregate=="Age" & age=="01-04" & numeratordenom=="N"
	gen tb_stat_a_5to9 = fy2017_targets if indicator=="TB_STAT" & disaggregate=="Age" & age=="05-09" & numeratordenom=="N"
	gen tb_stat_a_10to14 = fy2017_targets if indicator=="TB_STAT" & disaggregate=="Age" & age=="10-14" & numeratordenom=="N"
	gen tb_stat_a_15to19 = fy2017_targets if indicator=="TB_STAT" & disaggregate=="Age" & age=="15-19" & numeratordenom=="N"
	gen tb_stat_a_o20 = fy2017_targets if indicator=="TB_STAT" & disaggregate=="Age" & age=="20+" & numeratordenom=="N"
	gen htc_tst_aas_f_u15 = fy2017_targets if indicator=="HTC_TST" & disaggregate=="Age/Sex Aggregated/Result" & sex=="Female" & age=="<15" & numeratordenom=="N"
	gen htc_tst_aas_f_o15 = fy2017_targets if indicator=="HTC_TST" & disaggregate=="Age/Sex Aggregated/Result" & sex=="Female" & age=="15+" & numeratordenom=="N"
	gen htc_tst_aas_m_u15 = fy2017_targets if indicator=="HTC_TST" & disaggregate=="Age/Sex Aggregated/Result" & sex=="Male" & age=="<15" & numeratordenom=="N"
	gen htc_tst_aas_m_o15 = fy2017_targets if indicator=="HTC_TST" & disaggregate=="Age/Sex Aggregated/Result" & sex=="Male" & age=="15+" & numeratordenom=="N"
	gen htc_tst_asr_u1 = fy2017_targets if indicator=="HTC_TST" & disaggregate=="AgeLessThanTen/Positive" & age=="<01" & numeratordenom=="N"
	gen htc_tst_asr_1to9 = fy2017_targets if indicator=="HTC_TST" & disaggregate=="AgeLessThanTen/Positive" & age=="01-09" & numeratordenom=="N"
	gen htc_tst_asr_f_10to14 = fy2017_targets if indicator=="HTC_TST" & disaggregate=="AgeAboveTen/Sex/Positive" & sex=="Female" & age=="10-14" & numeratordenom=="N"
	gen htc_tst_asr_f_15to19 = fy2017_targets if indicator=="HTC_TST" & disaggregate=="AgeAboveTen/Sex/Positive" & sex=="Female" & age=="15-19" & numeratordenom=="N"
	gen htc_tst_asr_f_20to24 = fy2017_targets if indicator=="HTC_TST" & disaggregate=="AgeAboveTen/Sex/Positive" & sex=="Female" & age=="20-24" & numeratordenom=="N"
	gen htc_tst_asr_f_25to49 = fy2017_targets if indicator=="HTC_TST" & disaggregate=="AgeAboveTen/Sex/Positive" & sex=="Female" & age=="25-49" & numeratordenom=="N"
	gen htc_tst_asr_f_o50 = fy2017_targets if indicator=="HTC_TST" & disaggregate=="AgeAboveTen/Sex/Positive" & sex=="Female" & age=="50+" & numeratordenom=="N"
	gen htc_tst_asr_m_10to14 = fy2017_targets if indicator=="HTC_TST" & disaggregate=="AgeAboveTen/Sex/Positive" & sex=="Male" & age=="10-14" & numeratordenom=="N"
	gen htc_tst_asr_m_15to19 = fy2017_targets if indicator=="HTC_TST" & disaggregate=="AgeAboveTen/Sex/Positive" & sex=="Male" & age=="15-19" & numeratordenom=="N"
	gen htc_tst_asr_m_20to24 = fy2017_targets if indicator=="HTC_TST" & disaggregate=="AgeAboveTen/Sex/Positive" & sex=="Male" & age=="20-24" & numeratordenom=="N"
	gen htc_tst_asr_m_25to49 = fy2017_targets if indicator=="HTC_TST" & disaggregate=="AgeAboveTen/Sex/Positive" & sex=="Male" & age=="25-49" & numeratordenom=="N"
	gen htc_tst_asr_m_o50 = fy2017_targets if indicator=="HTC_TST" & disaggregate=="AgeAboveTen/Sex/Positive" & sex=="Male" & age=="50+" & numeratordenom=="N"
	gen vmmc_circ_a_u1 = fy2017_targets if indicator=="VMMC_CIRC" & disaggregate=="Age2017" & age=="<01" & numeratordenom=="N"
	gen vmmc_circ_a_1to9 = fy2017_targets if indicator=="VMMC_CIRC" & disaggregate=="Age2017" & age=="01-09" & numeratordenom=="N"
	gen vmmc_circ_a_10to14 = fy2017_targets if indicator=="VMMC_CIRC" & disaggregate=="Age2017" & age=="10-14" & numeratordenom=="N"
	gen vmmc_circ_a_15to19 = fy2017_targets if indicator=="VMMC_CIRC" & disaggregate=="Age2017" & age=="15-19" & numeratordenom=="N"
	gen vmmc_circ_a_20to24 = fy2017_targets if indicator=="VMMC_CIRC" & disaggregate=="Age2017" & age=="20-24" & numeratordenom=="N"
	gen vmmc_circ_a_25to29 = fy2017_targets if indicator=="VMMC_CIRC" & disaggregate=="Age2017" & age=="25-29" & numeratordenom=="N"
	gen vmmc_circ_a_30to49 = fy2017_targets if indicator=="VMMC_CIRC" & disaggregate=="Age2017" & age=="30-49" & numeratordenom=="N"
	gen vmmc_circ_a_o50 = fy2017_targets if indicator=="VMMC_CIRC" & disaggregate=="Age2017" & age=="50+" & numeratordenom=="N"
	gen vmmc_circ_t_device = fy2017_targets if indicator=="VMMC_CIRC" & disaggregate=="Technique" & otherdisaggregate=="Device based" & numeratordenom=="N"
	gen vmmc_circ_t_surg = fy2017_targets if indicator=="VMMC_CIRC" & disaggregate=="Technique" & otherdisaggregate=="Surgical Technique" & numeratordenom=="N"
	gen ovc_serv_aas_f_u18 = fy2017_targets if indicator=="OVC_SERV" & disaggregate=="Age/Sex2017" & sex=="Female" & age=="<18" & numeratordenom=="N"
	gen ovc_serv_aas_f_o18 = fy2017_targets if indicator=="OVC_SERV" & disaggregate=="Age/Sex2017" & sex=="Female" & age=="18+" & numeratordenom=="N"
	gen ovc_serv_aas_m_u18 = fy2017_targets if indicator=="OVC_SERV" & disaggregate=="Age/Sex2017" & sex=="Male" & age=="<18" & numeratordenom=="N"
	gen ovc_serv_aas_m_o18 = fy2017_targets if indicator=="OVC_SERV" & disaggregate=="Age/Sex2017" & sex=="Male" & age=="18+" & numeratordenom=="N"
	gen ovc_serv_as_f_15to17 = .
	gen ovc_serv_as_f_18to24 = .
	gen ovc_serv_as_f_o25 = .
	gen ovc_serv_as_m_u1 = .
	gen ovc_serv_as_m_1to4 = .
	gen ovc_serv_as_m_5to9 = .
	gen ovc_serv_as_m_10to14 = .
	gen ovc_serv_as_m_15to17 = .
	gen ovc_serv_as_m_18to24 = .
	gen ovc_serv_as_m_o25 = .
	gen ovc_serv_as2_f_u1_econ = fy2017_targets if indicator=="OVC_SERV" & disaggregate=="Age/Sex/Service" & sex=="Female" & age=="<01" & otherdisaggregate=="Economic Strengthening" & numeratordenom=="N"
	gen ovc_serv_as2_f_u1_edu = fy2017_targets if indicator=="OVC_SERV" & disaggregate=="Age/Sex/Service" & sex=="Female" & age=="<01" & otherdisaggregate=="Education Support" & numeratordenom=="N"
	gen ovc_serv_as2_f_u1_oth = fy2017_targets if indicator=="OVC_SERV" & disaggregate=="Age/Sex/Service" & sex=="Female" & age=="<01" & otherdisaggregate=="Other Service Areas" & numeratordenom=="N"
	gen ovc_serv_as2_f_u1_care = fy2017_targets if indicator=="OVC_SERV" & disaggregate=="Age/Sex/Service" & sex=="Female" & age=="<01" & otherdisaggregate=="Parenting/Caregiver Programs" & numeratordenom=="N"
	gen ovc_serv_as2_f_u1_soc = fy2017_targets if indicator=="OVC_SERV" & disaggregate=="Age/Sex/Service" & sex=="Female" & age=="<01" & otherdisaggregate=="Social Protection" & numeratordenom=="N"
	gen ovc_serv_as2_f_1to4_econ = fy2017_targets if indicator=="OVC_SERV" & disaggregate=="Age/Sex/Service" & sex=="Female" & age=="01-04" & otherdisaggregate=="Economic Strengthening" & numeratordenom=="N"
	gen ovc_serv_as2_f_1to4_edu = fy2017_targets if indicator=="OVC_SERV" & disaggregate=="Age/Sex/Service" & sex=="Female" & age=="01-04" & otherdisaggregate=="Education Support" & numeratordenom=="N"
	gen ovc_serv_as2_f_1to4_oth = fy2017_targets if indicator=="OVC_SERV" & disaggregate=="Age/Sex/Service" & sex=="Female" & age=="01-04" & otherdisaggregate=="Other Service Areas" & numeratordenom=="N"
	gen ovc_serv_as2_f_1to4_care = fy2017_targets if indicator=="OVC_SERV" & disaggregate=="Age/Sex/Service" & sex=="Female" & age=="01-04" & otherdisaggregate=="Parenting/Caregiver Programs" & numeratordenom=="N"
	gen ovc_serv_as2_f_1to4_soc = fy2017_targets if indicator=="OVC_SERV" & disaggregate=="Age/Sex/Service" & sex=="Female" & age=="01-04" & otherdisaggregate=="Social Protection" & numeratordenom=="N"
	gen ovc_serv_as2_f_5to9_econ = fy2017_targets if indicator=="OVC_SERV" & disaggregate=="Age/Sex/Service" & sex=="Female" & age=="05-09" & otherdisaggregate=="Economic Strengthening" & numeratordenom=="N"
	gen ovc_serv_as2_f_5to9_edu = fy2017_targets if indicator=="OVC_SERV" & disaggregate=="Age/Sex/Service" & sex=="Female" & age=="05-09" & otherdisaggregate=="Education Support" & numeratordenom=="N"
	gen ovc_serv_as2_f_5to9_oth = fy2017_targets if indicator=="OVC_SERV" & disaggregate=="Age/Sex/Service" & sex=="Female" & age=="05-09" & otherdisaggregate=="Other Service Areas" & numeratordenom=="N"
	gen ovc_serv_as2_f_5to9_care = fy2017_targets if indicator=="OVC_SERV" & disaggregate=="Age/Sex/Service" & sex=="Female" & age=="05-09" & otherdisaggregate=="Parenting/Caregiver Programs" & numeratordenom=="N"
	gen ovc_serv_as2_f_5to9_soc = fy2017_targets if indicator=="OVC_SERV" & disaggregate=="Age/Sex/Service" & sex=="Female" & age=="05-09" & otherdisaggregate=="Social Protection" & numeratordenom=="N"
	gen ovc_serv_as2_f_10to14_econ = fy2017_targets if indicator=="OVC_SERV" & disaggregate=="Age/Sex/Service" & sex=="Female" & age=="10-14" & otherdisaggregate=="Economic Strengthening" & numeratordenom=="N"
	gen ovc_serv_as2_f_10to14_edu = fy2017_targets if indicator=="OVC_SERV" & disaggregate=="Age/Sex/Service" & sex=="Female" & age=="10-14" & otherdisaggregate=="Education Support" & numeratordenom=="N"
	gen ovc_serv_as2_f_10to14_oth = fy2017_targets if indicator=="OVC_SERV" & disaggregate=="Age/Sex/Service" & sex=="Female" & age=="10-14" & otherdisaggregate=="Other Service Areas" & numeratordenom=="N"
	gen ovc_serv_as2_f_10to14_care = fy2017_targets if indicator=="OVC_SERV" & disaggregate=="Age/Sex/Service" & sex=="Female" & age=="10-14" & otherdisaggregate=="Parenting/Caregiver Programs" & numeratordenom=="N"
	gen ovc_serv_as2_f_10to14_soc = fy2017_targets if indicator=="OVC_SERV" & disaggregate=="Age/Sex/Service" & sex=="Female" & age=="10-14" & otherdisaggregate=="Social Protection" & numeratordenom=="N"
	gen ovc_serv_as2_f_15to17_econ = fy2017_targets if indicator=="OVC_SERV" & disaggregate=="Age/Sex/Service" & sex=="Female" & age=="15-17" & otherdisaggregate=="Economic Strengthening" & numeratordenom=="N"
	gen ovc_serv_as2_f_15to17_edu = fy2017_targets if indicator=="OVC_SERV" & disaggregate=="Age/Sex/Service" & sex=="Female" & age=="15-17" & otherdisaggregate=="Education Support" & numeratordenom=="N"
	gen ovc_serv_as2_f_15to17_oth = fy2017_targets if indicator=="OVC_SERV" & disaggregate=="Age/Sex/Service" & sex=="Female" & age=="15-17" & otherdisaggregate=="Other Service Areas" & numeratordenom=="N"
	gen ovc_serv_as2_f_15to17_care = fy2017_targets if indicator=="OVC_SERV" & disaggregate=="Age/Sex/Service" & sex=="Female" & age=="15-17" & otherdisaggregate=="Parenting/Caregiver Programs" & numeratordenom=="N"
	gen ovc_serv_as2_f_15to17_soc = fy2017_targets if indicator=="OVC_SERV" & disaggregate=="Age/Sex/Service" & sex=="Female" & age=="15-17" & otherdisaggregate=="Social Protection" & numeratordenom=="N"
	gen ovc_serv_as2_f_18to24_econ = fy2017_targets if indicator=="OVC_SERV" & disaggregate=="Age/Sex/Service" & sex=="Female" & age=="18-24" & otherdisaggregate=="Economic Strengthening" & numeratordenom=="N"
	gen ovc_serv_as2_f_18to24_edu = fy2017_targets if indicator=="OVC_SERV" & disaggregate=="Age/Sex/Service" & sex=="Female" & age=="18-24" & otherdisaggregate=="Education Support" & numeratordenom=="N"
	gen ovc_serv_as2_f_18to24_oth = fy2017_targets if indicator=="OVC_SERV" & disaggregate=="Age/Sex/Service" & sex=="Female" & age=="18-24" & otherdisaggregate=="Other Service Areas" & numeratordenom=="N"
	gen ovc_serv_as2_f_18to24_care = fy2017_targets if indicator=="OVC_SERV" & disaggregate=="Age/Sex/Service" & sex=="Female" & age=="18-24" & otherdisaggregate=="Parenting/Caregiver Programs" & numeratordenom=="N"
	gen ovc_serv_as2_f_18to24_soc = fy2017_targets if indicator=="OVC_SERV" & disaggregate=="Age/Sex/Service" & sex=="Female" & age=="18-24" & otherdisaggregate=="Social Protection" & numeratordenom=="N"
	gen ovc_serv_as2_f_o25_econ = fy2017_targets if indicator=="OVC_SERV" & disaggregate=="Age/Sex/Service" & sex=="Female" & age=="25+" & otherdisaggregate=="Economic Strengthening" & numeratordenom=="N"
	gen ovc_serv_as2_f_o25_edu = fy2017_targets if indicator=="OVC_SERV" & disaggregate=="Age/Sex/Service" & sex=="Female" & age=="25+" & otherdisaggregate=="Education Support" & numeratordenom=="N"
	gen ovc_serv_as2_f_o25_oth = fy2017_targets if indicator=="OVC_SERV" & disaggregate=="Age/Sex/Service" & sex=="Female" & age=="25+" & otherdisaggregate=="Other Service Areas" & numeratordenom=="N"
	gen ovc_serv_as2_f_o25_care = fy2017_targets if indicator=="OVC_SERV" & disaggregate=="Age/Sex/Service" & sex=="Female" & age=="25+" & otherdisaggregate=="Parenting/Caregiver Programs" & numeratordenom=="N"
	gen ovc_serv_as2_f_o25_soc = fy2017_targets if indicator=="OVC_SERV" & disaggregate=="Age/Sex/Service" & sex=="Female" & age=="25+" & otherdisaggregate=="Social Protection" & numeratordenom=="N"
	gen ovc_serv_as2_m_u1_econ = fy2017_targets if indicator=="OVC_SERV" & disaggregate=="Age/Sex/Service" & sex=="Male" & age=="<01" & otherdisaggregate=="Economic Strengthening" & numeratordenom=="N"
	gen ovc_serv_as2_m_u1_edu = fy2017_targets if indicator=="OVC_SERV" & disaggregate=="Age/Sex/Service" & sex=="Male" & age=="<01" & otherdisaggregate=="Education Support" & numeratordenom=="N"
	gen ovc_serv_as2_m_u1_oth = fy2017_targets if indicator=="OVC_SERV" & disaggregate=="Age/Sex/Service" & sex=="Male" & age=="<01" & otherdisaggregate=="Other Service Areas" & numeratordenom=="N"
	gen ovc_serv_as2_m_u1_care = fy2017_targets if indicator=="OVC_SERV" & disaggregate=="Age/Sex/Service" & sex=="Male" & age=="<01" & otherdisaggregate=="Parenting/Caregiver Programs" & numeratordenom=="N"
	gen ovc_serv_as2_m_u1_soc = fy2017_targets if indicator=="OVC_SERV" & disaggregate=="Age/Sex/Service" & sex=="Male" & age=="<01" & otherdisaggregate=="Social Protection" & numeratordenom=="N"
	gen ovc_serv_as2_m_1to4_econ = fy2017_targets if indicator=="OVC_SERV" & disaggregate=="Age/Sex/Service" & sex=="Male" & age=="01-04" & otherdisaggregate=="Economic Strengthening" & numeratordenom=="N"
	gen ovc_serv_as2_m_1to4_edu = fy2017_targets if indicator=="OVC_SERV" & disaggregate=="Age/Sex/Service" & sex=="Male" & age=="01-04" & otherdisaggregate=="Education Support" & numeratordenom=="N"
	gen ovc_serv_as2_m_1to4_oth = fy2017_targets if indicator=="OVC_SERV" & disaggregate=="Age/Sex/Service" & sex=="Male" & age=="01-04" & otherdisaggregate=="Other Service Areas" & numeratordenom=="N"
	gen ovc_serv_as2_m_1to4_care = fy2017_targets if indicator=="OVC_SERV" & disaggregate=="Age/Sex/Service" & sex=="Male" & age=="01-04" & otherdisaggregate=="Parenting/Caregiver Programs" & numeratordenom=="N"
	gen ovc_serv_as2_m_1to4_soc = fy2017_targets if indicator=="OVC_SERV" & disaggregate=="Age/Sex/Service" & sex=="Male" & age=="01-04" & otherdisaggregate=="Social Protection" & numeratordenom=="N"
	gen ovc_serv_as2_m_5to9_econ = fy2017_targets if indicator=="OVC_SERV" & disaggregate=="Age/Sex/Service" & sex=="Male" & age=="05-09" & otherdisaggregate=="Economic Strengthening" & numeratordenom=="N"
	gen ovc_serv_as2_m_5to9_edu = fy2017_targets if indicator=="OVC_SERV" & disaggregate=="Age/Sex/Service" & sex=="Male" & age=="05-09" & otherdisaggregate=="Education Support" & numeratordenom=="N"
	gen ovc_serv_as2_m_5to9_oth = fy2017_targets if indicator=="OVC_SERV" & disaggregate=="Age/Sex/Service" & sex=="Male" & age=="05-09" & otherdisaggregate=="Other Service Areas" & numeratordenom=="N"
	gen ovc_serv_as2_m_5to9_care = fy2017_targets if indicator=="OVC_SERV" & disaggregate=="Age/Sex/Service" & sex=="Male" & age=="05-09" & otherdisaggregate=="Parenting/Caregiver Programs" & numeratordenom=="N"
	gen ovc_serv_as2_m_5to9_soc = fy2017_targets if indicator=="OVC_SERV" & disaggregate=="Age/Sex/Service" & sex=="Male" & age=="05-09" & otherdisaggregate=="Social Protection" & numeratordenom=="N"
	gen ovc_serv_as2_m_10to14_econ = fy2017_targets if indicator=="OVC_SERV" & disaggregate=="Age/Sex/Service" & sex=="Male" & age=="10-14" & otherdisaggregate=="Economic Strengthening" & numeratordenom=="N"
	gen ovc_serv_as2_m_10to14_edu = fy2017_targets if indicator=="OVC_SERV" & disaggregate=="Age/Sex/Service" & sex=="Male" & age=="10-14" & otherdisaggregate=="Education Support" & numeratordenom=="N"
	gen ovc_serv_as2_m_10to14_oth = fy2017_targets if indicator=="OVC_SERV" & disaggregate=="Age/Sex/Service" & sex=="Male" & age=="10-14" & otherdisaggregate=="Other Service Areas" & numeratordenom=="N"
	gen ovc_serv_as2_m_10to14_care = fy2017_targets if indicator=="OVC_SERV" & disaggregate=="Age/Sex/Service" & sex=="Male" & age=="10-14" & otherdisaggregate=="Parenting/Caregiver Programs" & numeratordenom=="N"
	gen ovc_serv_as2_m_10to14_soc = fy2017_targets if indicator=="OVC_SERV" & disaggregate=="Age/Sex/Service" & sex=="Male" & age=="10-14" & otherdisaggregate=="Social Protection" & numeratordenom=="N"
	gen ovc_serv_as2_m_15to17_econ = fy2017_targets if indicator=="OVC_SERV" & disaggregate=="Age/Sex/Service" & sex=="Male" & age=="15-17" & otherdisaggregate=="Economic Strengthening" & numeratordenom=="N"
	gen ovc_serv_as2_m_15to17_edu = fy2017_targets if indicator=="OVC_SERV" & disaggregate=="Age/Sex/Service" & sex=="Male" & age=="15-17" & otherdisaggregate=="Education Support" & numeratordenom=="N"
	gen ovc_serv_as2_m_15to17_oth = fy2017_targets if indicator=="OVC_SERV" & disaggregate=="Age/Sex/Service" & sex=="Male" & age=="15-17" & otherdisaggregate=="Other Service Areas" & numeratordenom=="N"
	gen ovc_serv_as2_m_15to17_care = fy2017_targets if indicator=="OVC_SERV" & disaggregate=="Age/Sex/Service" & sex=="Male" & age=="15-17" & otherdisaggregate=="Parenting/Caregiver Programs" & numeratordenom=="N"
	gen ovc_serv_as2_m_15to17_soc = fy2017_targets if indicator=="OVC_SERV" & disaggregate=="Age/Sex/Service" & sex=="Male" & age=="15-17" & otherdisaggregate=="Social Protection" & numeratordenom=="N"
	gen ovc_serv_as2_m_18to24_econ = fy2017_targets if indicator=="OVC_SERV" & disaggregate=="Age/Sex/Service" & sex=="Male" & age=="18-24" & otherdisaggregate=="Economic Strengthening" & numeratordenom=="N"
	gen ovc_serv_as2_m_18to24_edu = fy2017_targets if indicator=="OVC_SERV" & disaggregate=="Age/Sex/Service" & sex=="Male" & age=="18-24" & otherdisaggregate=="Education Support" & numeratordenom=="N"
	gen ovc_serv_as2_m_18to24_oth = fy2017_targets if indicator=="OVC_SERV" & disaggregate=="Age/Sex/Service" & sex=="Male" & age=="18-24" & otherdisaggregate=="Other Service Areas" & numeratordenom=="N"
	gen ovc_serv_as2_m_18to24_care = fy2017_targets if indicator=="OVC_SERV" & disaggregate=="Age/Sex/Service" & sex=="Male" & age=="18-24" & otherdisaggregate=="Parenting/Caregiver Programs" & numeratordenom=="N"
	gen ovc_serv_as2_m_18to24_soc = fy2017_targets if indicator=="OVC_SERV" & disaggregate=="Age/Sex/Service" & sex=="Male" & age=="18-24" & otherdisaggregate=="Social Protection" & numeratordenom=="N"
	gen ovc_serv_as2_m_o25_econ = fy2017_targets if indicator=="OVC_SERV" & disaggregate=="Age/Sex/Service" & sex=="Male" & age=="25+" & otherdisaggregate=="Economic Strengthening" & numeratordenom=="N"
	gen ovc_serv_as2_m_o25_edu = fy2017_targets if indicator=="OVC_SERV" & disaggregate=="Age/Sex/Service" & sex=="Male" & age=="25+" & otherdisaggregate=="Education Support" & numeratordenom=="N"
	gen ovc_serv_as2_m_o25_oth = fy2017_targets if indicator=="OVC_SERV" & disaggregate=="Age/Sex/Service" & sex=="Male" & age=="25+" & otherdisaggregate=="Other Service Areas" & numeratordenom=="N"
	gen ovc_serv_as2_m_o25_care = fy2017_targets if indicator=="OVC_SERV" & disaggregate=="Age/Sex/Service" & sex=="Male" & age=="25+" & otherdisaggregate=="Parenting/Caregiver Programs" & numeratordenom=="N"
	gen ovc_serv_as2_m_o25_soc = fy2017_targets if indicator=="OVC_SERV" & disaggregate=="Age/Sex/Service" & sex=="Male" & age=="25+" & otherdisaggregate=="Social Protection" & numeratordenom=="N"
	gen pp_prev_aas_f_u15 = fy2017_targets if indicator=="PP_PREV" & disaggregate=="Aggregated Age/Sex" & sex=="Female" & age=="<15" & numeratordenom=="N"
	gen pp_prev_aas_f_o15 = fy2017_targets if indicator=="PP_PREV" & disaggregate=="Aggregated Age/Sex" & sex=="Female" & age=="15+" & numeratordenom=="N"
	gen pp_prev_aas_m_u15 = fy2017_targets if indicator=="PP_PREV" & disaggregate=="Aggregated Age/Sex" & sex=="Male" & age=="<15" & numeratordenom=="N"
	gen pp_prev_aas_m_o15 = fy2017_targets if indicator=="PP_PREV" & disaggregate=="Aggregated Age/Sex" & sex=="Male" & age=="15+" & numeratordenom=="N"
	gen pp_prev_as_f_o50 = .
	gen pp_prev_as_m_10to14 = .
	gen pp_prev_as_m_15to19 = .
	gen pp_prev_as_m_20to24 = .
	gen pp_prev_as_m_25to49 = .
	gen pp_prev_as_m_o50 = .

* drop if no data in row
	foreach x of varlist tx_new_aas_f_u1-pp_prev_as_m_o50 {
		recode `x' (0 = .)
		}
		*end
	egen data = rownonmiss(tx_new_aas_f_u1-pp_prev_as_m_o50)
	drop if data==0 //& mechanismid!="0"
	drop data

*collapse
	drop fy2017_targets
	ds, not(type string)
	collapse (sum) `r(varlist)', by(operatingunit psnu psnuuid orgunituid orgunitname indicatortype mechanismid implementingmechanismname primepartner)

*create distro for denominators and eid_pos
	gen d_tb_art_D = round(tb_art_D/tb_art,0.0001)
	gen d_pmtct_eid_pos_2mo = round(pmtct_eid_pos_2mo/pmtct_eid_i_u2mo,0.0001)
	gen d_pmtct_eid_pos_12mo = round(pmtct_eid_pos_12mo/(pmtct_eid_i_u2mo + pmtct_eid_i_2to12mo),0.0001)
	drop tb_art_D tb_art pmtct_eid_pos_2mo pmtct_eid_pos_12mo

*create distribution
	foreach t in tx_new_aas tx_new_as tx_curr_aas tx_curr_as ///
		pmtct_stat_kn pmtct_arv_m pmtct_eid_i  ///
		tb_art_aas tb_stat_aas tb_stat_s tb_stat_a htc_tst_aas htc_tst_asr ///
		vmmc_circ_a vmmc_circ_t ovc_serv_aas ovc_serv_as ovc_serv_as2 pp_prev_aas pp_prev_as {
		egen tot_`t' = rowtotal(`t'_*)
		qui: ds `t'_*
		foreach v in `r(varlist)'{
			qui: gen d_`v' = round(`v'/tot_`t',0.0001)
			qui: drop `v'
			}
		}
	*end


*clean up
	drop tot*
	recode d_* (0 = .)
	order d_tb_art_D, before(d_tb_art_aas_f_u15)
	order d_pmtct_eid_pos_2mo d_pmtct_eid_pos_12mo, after(d_pmtct_eid_i_2to12mo)
	gen combo = orgunituid + "/" + mechanismid + "/" + indicatortype
	destring mechanismid, replace
	order operatingunit psnuuid psnu orgunituid orgunitname mechanismid implementingmechanismname primepartner indicatortype combo
	sort operatingunit psnu orgunituid mechanismid indicatortype

	*save
		save "$output/temp_site_${ou_ns}_disaggs", replace
