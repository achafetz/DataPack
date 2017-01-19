**   Data Pack
**   COP FY17
**   Aaron Chafetz
**   Purpose: generate output for Excel disagg allocation of Data Pack targets
**   Date: January 19, 2017
**   Updated: 


*define date for Fact View Files
	global datestamp "20161115_v2"

*set today's date for saving
	global date: di %tdCCYYNNDD date(c(current_date), "DMY")

*open site dataset
	use "$output/temp_site_Malawi", clear

** TX_NEW tab
	*create variables
	// output generated in Site & Disagg template (POPsubset sheet)
	// updated 1/19
	gen tx_new_asa_f_u1 = fy2016apr if indicator=="TX_NEW" & disaggregate=="Age/Sex Aggregated" & sex=="Female" & age=="<01" & numeratordenom=="N"
	gen tx_new_asa_f_1to14 = fy2016apr if indicator=="TX_NEW" & disaggregate=="Age/Sex Aggregated" & sex=="Female" & age=="01-14" & numeratordenom=="N"
	gen tx_new_asa_f_o15 = fy2016apr if indicator=="TX_NEW" & disaggregate=="Age/Sex Aggregated" & sex=="Female" & age=="15+" & numeratordenom=="N"
	gen tx_new_asa_m_u1 = fy2016apr if indicator=="TX_NEW" & disaggregate=="Age/Sex Aggregated" & sex=="Male" & age=="<01" & numeratordenom=="N"
	gen tx_new_asa_m_1to14 = fy2016apr if indicator=="TX_NEW" & disaggregate=="Age/Sex Aggregated" & sex=="Male" & age=="01-14" & numeratordenom=="N"
	gen tx_new_asa_m_o15 = fy2016apr if indicator=="TX_NEW" & disaggregate=="Age/Sex Aggregated" & sex=="Male" & age=="15+" & numeratordenom=="N"
	gen tx_new_as_f_u1 = fy2016apr if indicator=="TX_NEW" & disaggregate=="Age/Sex" & sex=="Female" & age=="<01" & numeratordenom=="N"
	gen tx_new_as_f_1to4 = fy2016apr if indicator=="TX_NEW" & disaggregate=="Age/Sex" & sex=="Female" & age=="01-04" & numeratordenom=="N"
	gen tx_new_as_f_5to9 = fy2016apr if indicator=="TX_NEW" & disaggregate=="Age/Sex" & sex=="Female" & age=="05-09" & numeratordenom=="N"
	gen tx_new_as_f_10to14 = fy2016apr if indicator=="TX_NEW" & disaggregate=="Age/Sex" & sex=="Female" & age=="10-14" & numeratordenom=="N"
	gen tx_new_as_f_15to19 = fy2016apr if indicator=="TX_NEW" & disaggregate=="Age/Sex" & sex=="Female" & age=="15-19" & numeratordenom=="N"
	gen tx_new_as_f_20to24 = fy2016apr if indicator=="TX_NEW" & disaggregate=="Age/Sex" & sex=="Female" & age=="20-24" & numeratordenom=="N"
	gen tx_new_as_f_25to49 = fy2016apr if indicator=="TX_NEW" & disaggregate=="Age/Sex" & sex=="Female" & age=="25-49" & numeratordenom=="N"
	gen tx_new_as_f_o50 = fy2016apr if indicator=="TX_NEW" & disaggregate=="Age/Sex" & sex=="Female" & age=="50+" & numeratordenom=="N"
	gen tx_new_as_m_u1 = fy2016apr if indicator=="TX_NEW" & disaggregate=="Age/Sex" & sex=="Male" & age=="<01" & numeratordenom=="N"
	gen tx_new_as_m_1to4 = fy2016apr if indicator=="TX_NEW" & disaggregate=="Age/Sex" & sex=="Male" & age=="01-04" & numeratordenom=="N"
	gen tx_new_as_m_5to9 = fy2016apr if indicator=="TX_NEW" & disaggregate=="Age/Sex" & sex=="Male" & age=="05-09" & numeratordenom=="N"
	gen tx_new_as_m_10to14 = fy2016apr if indicator=="TX_NEW" & disaggregate=="Age/Sex" & sex=="Male" & age=="10-14" & numeratordenom=="N"
	gen tx_new_as_m_15to19 = fy2016apr if indicator=="TX_NEW" & disaggregate=="Age/Sex" & sex=="Male" & age=="15-19" & numeratordenom=="N"
	gen tx_new_as_m_20to24 = fy2016apr if indicator=="TX_NEW" & disaggregate=="Age/Sex" & sex=="Male" & age=="20-24" & numeratordenom=="N"
	gen tx_new_as_m_25to49 = fy2016apr if indicator=="TX_NEW" & disaggregate=="Age/Sex" & sex=="Male" & age=="25-49" & numeratordenom=="N"
	gen tx_new_as_m_o50 = fy2016apr if indicator=="TX_NEW" & disaggregate=="Age/Sex" & sex=="Male" & age=="50+" & numeratordenom=="N"
	gen tx_curr_asa_f_u1 = fy2016apr if indicator=="TX_CURR" & inlist(disaggregate, "Age/Sex Aggregated", "Age/Sex, Aggregated") & sex=="Female" & age=="<01" & numeratordenom=="N"
	gen tx_curr_asa_f_1to14 = fy2016apr if indicator=="TX_CURR" & inlist(disaggregate, "Age/Sex Aggregated", "Age/Sex, Aggregated") & sex=="Female" & age=="01-14" & numeratordenom=="N"
	gen tx_curr_asa_f_o15 = fy2016apr if indicator=="TX_CURR" & inlist(disaggregate, "Age/Sex Aggregated", "Age/Sex, Aggregated") & sex=="Female" & age=="15+" & numeratordenom=="N"
	gen tx_curr_asa_m_u1 = fy2016apr if indicator=="TX_CURR" & inlist(disaggregate, "Age/Sex Aggregated", "Age/Sex, Aggregated") & sex=="Male" & age=="<01" & numeratordenom=="N"
	gen tx_curr_asa_m_1to14 = fy2016apr if indicator=="TX_CURR" & inlist(disaggregate, "Age/Sex Aggregated", "Age/Sex, Aggregated") & sex=="Male" & age=="01-14" & numeratordenom=="N"
	gen tx_curr_asa_m_o15 = fy2016apr if indicator=="TX_CURR" & inlist(disaggregate, "Age/Sex Aggregated", "Age/Sex, Aggregated") & sex=="Male" & age=="15+" & numeratordenom=="N"
	gen tx_curr_as_f_u1 = fy2016apr if indicator=="TX_CURR" & disaggregate=="Age/Sex" & sex=="Female" & age=="<01" & numeratordenom=="N"
	gen tx_curr_as_f_1to4 = fy2016apr if indicator=="TX_CURR" & disaggregate=="Age/Sex" & sex=="Female" & age=="01-04" & numeratordenom=="N"
	gen tx_curr_as_f_5to9 = fy2016apr if indicator=="TX_CURR" & disaggregate=="Age/Sex" & sex=="Female" & age=="05-09" & numeratordenom=="N"
	gen tx_curr_as_f_10to14 = fy2016apr if indicator=="TX_CURR" & disaggregate=="Age/Sex" & sex=="Female" & age=="10-14" & numeratordenom=="N"
	gen tx_curr_as_f_15to19 = fy2016apr if indicator=="TX_CURR" & disaggregate=="Age/Sex" & sex=="Female" & age=="15-19" & numeratordenom=="N"
	gen tx_curr_as_f_20to24 = fy2016apr if indicator=="TX_CURR" & disaggregate=="Age/Sex" & sex=="Female" & age=="20-24" & numeratordenom=="N"
	gen tx_curr_as_f_25to49 = fy2016apr if indicator=="TX_CURR" & disaggregate=="Age/Sex" & sex=="Female" & age=="25-49" & numeratordenom=="N"
	gen tx_curr_as_f_o50 = fy2016apr if indicator=="TX_CURR" & disaggregate=="Age/Sex" & sex=="Female" & age=="50+" & numeratordenom=="N"
	gen tx_curr_as_m_u1 = fy2016apr if indicator=="TX_CURR" & disaggregate=="Age/Sex" & sex=="Male" & age=="<01" & numeratordenom=="N"
	gen tx_curr_as_m_1to4 = fy2016apr if indicator=="TX_CURR" & disaggregate=="Age/Sex" & sex=="Male" & age=="01-04" & numeratordenom=="N"
	gen tx_curr_as_m_5to9 = fy2016apr if indicator=="TX_CURR" & disaggregate=="Age/Sex" & sex=="Male" & age=="05-09" & numeratordenom=="N"
	gen tx_curr_as_m_10to14 = fy2016apr if indicator=="TX_CURR" & disaggregate=="Age/Sex" & sex=="Male" & age=="10-14" & numeratordenom=="N"
	gen tx_curr_as_m_15to19 = fy2016apr if indicator=="TX_CURR" & disaggregate=="Age/Sex" & sex=="Male" & age=="15-19" & numeratordenom=="N"
	gen tx_curr_as_m_20to24 = fy2016apr if indicator=="TX_CURR" & disaggregate=="Age/Sex" & sex=="Male" & age=="20-24" & numeratordenom=="N"
	gen tx_curr_as_m_25to49 = fy2016apr if indicator=="TX_CURR" & disaggregate=="Age/Sex" & sex=="Male" & age=="25-49" & numeratordenom=="N"
	gen tx_curr_as_m_o50 = fy2016apr if indicator=="TX_CURR" & disaggregate=="Age/Sex" & sex=="Male" & age=="50+" & numeratordenom=="N"
	gen pmtct_stat_kn_known = fy2016apr if indicator=="PMTCT_STAT" & disaggregate=="Known/New" & sex=="Known at Entry" & numeratordenom=="N"
	gen pmtct_stat_kn_new2 = fy2016apr if indicator=="PMTCT_STAT" & disaggregate=="Known/New" & sex=="Newly Identified" & numeratordenom=="N"
	gen pmtct_stat_kna_known_u15 = fy2016apr if indicator=="PMTCT_STAT" & disaggregate=="Known/New/Age" & sex=="Known at Entry" & age=="<15" & numeratordenom=="N"
	gen pmtct_stat_kna_know_15to19 = fy2016apr if indicator=="PMTCT_STAT" & disaggregate=="Known/New/Age" & sex=="Known at Entry" & age=="15-19" & numeratordenom=="N"
	gen pmtct_stat_kna_know_20to24 = fy2016apr if indicator=="PMTCT_STAT" & disaggregate=="Known/New/Age" & sex=="Known at Entry" & age=="20-24" & numeratordenom=="N"
	gen pmtct_stat_kna_know_o25 = fy2016apr if indicator=="PMTCT_STAT" & disaggregate=="Known/New/Age" & sex=="Known at Entry" & age=="25+" & numeratordenom=="N"
	gen pmtct_stat_kna_newn_u15 = fy2016apr if indicator=="PMTCT_STAT" & disaggregate=="Known/New/Age" & sex=="Newly Identified" & age=="<15" & numeratordenom=="N"
	gen pmtct_stat_kna_new_15to19 = fy2016apr if indicator=="PMTCT_STAT" & disaggregate=="Known/New/Age" & sex=="Newly Identified" & age=="15-19" & numeratordenom=="N"
	gen pmtct_stat_kna_new_20to24 = fy2016apr if indicator=="PMTCT_STAT" & disaggregate=="Known/New/Age" & sex=="Newly Identified" & age=="20-24" & numeratordenom=="N"
	gen pmtct_stat_kna_new_o25 = fy2016apr if indicator=="PMTCT_STAT" & disaggregate=="Known/New/Age" & sex=="Newly Identified" & age=="25+" & numeratordenom=="N"
	gen pmtct_stat_a_u15 = fy2016apr if indicator=="PMTCT_STAT" & disaggregate=="Age" & age=="<15" & numeratordenom=="N"
	gen pmtct_stat_a_15to19 = fy2016apr if indicator=="PMTCT_STAT" & disaggregate=="Age" & age=="15-19" & numeratordenom=="N"
	gen pmtct_stat_a_20to24 = fy2016apr if indicator=="PMTCT_STAT" & disaggregate=="Age" & age=="20-24" & numeratordenom=="N"
	gen pmtct_stat_a_o25 = fy2016apr if indicator=="PMTCT_STAT" & disaggregate=="Age" & age=="25+" & numeratordenom=="N"
	gen pmtct_art_m_azt = fy2016apr if indicator=="PMTCT_ART" & disaggregate=="MaternalRegimeType" & otherdisaggregate=="AZT" & numeratordenom=="N"
	gen pmtct_art_m_lifealready = fy2016apr if indicator=="PMTCT_ART" & disaggregate=="MaternalRegimeType" & otherdisaggregate=="Life-long ART Already" & numeratordenom=="N"
	gen pmtct_art_m_lifenew = fy2016apr if indicator=="PMTCT_ART" & disaggregate=="MaternalRegimeType" & otherdisaggregate=="Life-long ART New" & numeratordenom=="N"
	gen pmtct_art_m_single = fy2016apr if indicator=="PMTCT_ART" & disaggregate=="MaternalRegimeType" & otherdisaggregate=="Single-dose NVP" & numeratordenom=="N"
	gen pmtct_art_m_tripe = fy2016apr if indicator=="PMTCT_ART" & disaggregate=="MaternalRegimeType" & otherdisaggregate=="Triple-drug ARV" & numeratordenom=="N"
	gen pmtct_eid_i_u2m = fy2016apr if indicator=="PMTCT_EID" & disaggregate=="InfantTest" & age=="[months] 00-02" & numeratordenom=="N"
	gen pmtct_eid_i_2to12mo = fy2016apr if indicator=="PMTCT_EID" & disaggregate=="InfantTest" & age=="[months] 02-12" & numeratordenom=="N"
	gen tb_art_s_f = fy2016apr if indicator=="TB_ART" & disaggregate=="Sex" & sex=="Female" & numeratordenom=="N"
	gen tb_art_s_m = fy2016apr if indicator=="TB_ART" & disaggregate=="Sex" & sex=="Male" & numeratordenom=="N"
	gen tb_art_a_u1 = fy2016apr if indicator=="TB_ART" & disaggregate=="Age" & age=="<01" & numeratordenom=="N"
	gen tb_art_a_1to4 = fy2016apr if indicator=="TB_ART" & disaggregate=="Age" & age=="01-04" & numeratordenom=="N"
	gen tb_art_a_5to9 = fy2016apr if indicator=="TB_ART" & disaggregate=="Age" & age=="05-09" & numeratordenom=="N"
	gen tb_art_a_10to14 = fy2016apr if indicator=="TB_ART" & disaggregate=="Age" & age=="10-14" & numeratordenom=="N"
	gen tb_art_a_15to19 = fy2016apr if indicator=="TB_ART" & disaggregate=="Age" & age=="15-19" & numeratordenom=="N"
	gen tb_art_a_o20 = fy2016apr if indicator=="TB_ART" & disaggregate=="Age" & age=="20+" & numeratordenom=="N"
	gen tb_stat_s_f = fy2016apr if indicator=="TB_STAT" & disaggregate=="Sex" & sex=="Female" & numeratordenom=="N"
	gen tb_stat_s_m = fy2016apr if indicator=="TB_STAT" & disaggregate=="Sex" & sex=="Male" & numeratordenom=="N"
	gen tb_stat_a_u1 = fy2016apr if indicator=="TB_STAT" & disaggregate=="Age" & age=="<01" & numeratordenom=="N"
	gen tb_stat_a_1to4 = fy2016apr if indicator=="TB_STAT" & disaggregate=="Age" & age=="01-04" & numeratordenom=="N"
	gen tb_stat_a_5to9 = fy2016apr if indicator=="TB_STAT" & disaggregate=="Age" & age=="05-09" & numeratordenom=="N"
	gen tb_stat_a_10to14 = fy2016apr if indicator=="TB_STAT" & disaggregate=="Age" & age=="10-14" & numeratordenom=="N"
	gen tb_stat_a_15to19 = fy2016apr if indicator=="TB_STAT" & disaggregate=="Age" & age=="15-19" & numeratordenom=="N"
	gen tb_stat_a_o20 = fy2016apr if indicator=="TB_STAT" & disaggregate=="Age" & age=="20+" & numeratordenom=="N"
	gen vmmc_circ_a_u1 = fy2016apr if indicator=="VMMC_CIRC" & disaggregate=="Age" & age=="<01" & numeratordenom=="N"
	gen vmmc_circ_a_1to9 = fy2016apr if indicator=="VMMC_CIRC" & disaggregate=="Age" & age=="01-09" & numeratordenom=="N"
	gen vmmc_circ_a_10to14 = fy2016apr if indicator=="VMMC_CIRC" & disaggregate=="Age" & age=="10-14" & numeratordenom=="N"
	gen vmmc_circ_a_15to19 = fy2016apr if indicator=="VMMC_CIRC" & disaggregate=="Age" & age=="15-19" & numeratordenom=="N"
	gen vmmc_circ_a_20to24 = fy2016apr if indicator=="VMMC_CIRC" & disaggregate=="Age" & age=="20-24" & numeratordenom=="N"
	gen vmmc_circ_a_25to29 = fy2016apr if indicator=="VMMC_CIRC" & disaggregate=="Age" & age=="25-29" & numeratordenom=="N"
	gen vmmc_circ_a_30to49 = fy2016apr if indicator=="VMMC_CIRC" & disaggregate=="Age" & age=="30-49" & numeratordenom=="N"
	gen vmmc_circ_a_o50 = fy2016apr if indicator=="VMMC_CIRC" & disaggregate=="Age" & age=="50+" & numeratordenom=="N"
	gen vmmc_circ_t_device = fy2016apr if indicator=="VMMC_CIRC" & disaggregate=="Technique" & otherdisaggregate=="Device based" & numeratordenom=="N"
	gen vmmc_circ_t_surg = fy2016apr if indicator=="VMMC_CIRC" & disaggregate=="Technique" & otherdisaggregate=="Surgical Technique" & numeratordenom=="N"
	gen ovc_serv_as_f_u1 = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Female" & age=="<01" & numeratordenom=="N"
	gen ovc_serv_as_f_1to4 = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Female" & age=="01-04" & numeratordenom=="N"
	gen ovc_serv_as_f_5to9 = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Female" & age=="05-09" & numeratordenom=="N"
	gen ovc_serv_as_f_10to14 = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Female" & age=="10-14" & numeratordenom=="N"
	gen ovc_serv_as_f_15to17 = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Female" & age=="15-17" & numeratordenom=="N"
	gen ovc_serv_as_f_18to24 = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Female" & age=="18-24" & numeratordenom=="N"
	gen ovc_serv_as_f_o25 = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Female" & age=="25+" & numeratordenom=="N"
	gen ovc_serv_as_m_u1 = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Male" & age=="<01" & numeratordenom=="N"
	gen ovc_serv_as_m_1to4 = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Male" & age=="01-04" & numeratordenom=="N"
	gen ovc_serv_as_m_5to9 = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Male" & age=="05-09" & numeratordenom=="N"
	gen ovc_serv_as_m_10to14 = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Male" & age=="10-14" & numeratordenom=="N"
	gen ovc_serv_as_m_15to17 = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Male" & age=="15-17" & numeratordenom=="N"
	gen ovc_serv_as_m_18to24 = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Male" & age=="18-24" & numeratordenom=="N"
	gen ovc_serv_as_m_o25 = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Male" & age=="25+" & numeratordenom=="N"
	gen ovc_serv_as_f_u1_econ = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Female" & age=="<01" & otherdisaggregate=="Economic Strengthening" & numeratordenom=="N"
	gen ovc_serv_as_f_u1_edu = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Female" & age=="<01" & otherdisaggregate=="Education Support" & numeratordenom=="N"
	gen ovc_serv_as_f_u1_oth = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Female" & age=="<01" & otherdisaggregate=="Other Service Areas" & numeratordenom=="N"
	gen ovc_serv_as_f_u1_care = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Female" & age=="<01" & otherdisaggregate=="Parenting/Caregiver Programs" & numeratordenom=="N"
	gen ovc_serv_as_f_u1_soc = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Female" & age=="<01" & otherdisaggregate=="Social Protection" & numeratordenom=="N"
	gen ovc_serv_as_f_1to4_econ = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Female" & age=="01-04" & otherdisaggregate=="Economic Strengthening" & numeratordenom=="N"
	gen ovc_serv_as_f_1to4_edu = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Female" & age=="01-04" & otherdisaggregate=="Education Support" & numeratordenom=="N"
	gen ovc_serv_as_f_1to4_oth = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Female" & age=="01-04" & otherdisaggregate=="Other Service Areas" & numeratordenom=="N"
	gen ovc_serv_as_f_1to4_care = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Female" & age=="01-04" & otherdisaggregate=="Parenting/Caregiver Programs" & numeratordenom=="N"
	gen ovc_serv_as_f_1to4_soc = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Female" & age=="01-04" & otherdisaggregate=="Social Protection" & numeratordenom=="N"
	gen ovc_serv_as_f_5to9_econ = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Female" & age=="05-09" & otherdisaggregate=="Economic Strengthening" & numeratordenom=="N"
	gen ovc_serv_as_f_5to9_edu = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Female" & age=="05-09" & otherdisaggregate=="Education Support" & numeratordenom=="N"
	gen ovc_serv_as_f_5to9_oth = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Female" & age=="05-09" & otherdisaggregate=="Other Service Areas" & numeratordenom=="N"
	gen ovc_serv_as_f_5to9_care = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Female" & age=="05-09" & otherdisaggregate=="Parenting/Caregiver Programs" & numeratordenom=="N"
	gen ovc_serv_as_f_5to9_soc = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Female" & age=="05-09" & otherdisaggregate=="Social Protection" & numeratordenom=="N"
	gen ovc_serv_as_f_10to14_econ = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Female" & age=="10-14" & otherdisaggregate=="Economic Strengthening" & numeratordenom=="N"
	gen ovc_serv_as_f_10to14_edu = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Female" & age=="10-14" & otherdisaggregate=="Education Support" & numeratordenom=="N"
	gen ovc_serv_as_f_10to14_oth = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Female" & age=="10-14" & otherdisaggregate=="Other Service Areas" & numeratordenom=="N"
	gen ovc_serv_as_f_10to14_care = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Female" & age=="10-14" & otherdisaggregate=="Parenting/Caregiver Programs" & numeratordenom=="N"
	gen ovc_serv_as_f_10to14_soc = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Female" & age=="10-14" & otherdisaggregate=="Social Protection" & numeratordenom=="N"
	gen ovc_serv_as_f_15to17_econ = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Female" & age=="15-17" & otherdisaggregate=="Economic Strengthening" & numeratordenom=="N"
	gen ovc_serv_as_f_15to17_edu = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Female" & age=="15-17" & otherdisaggregate=="Education Support" & numeratordenom=="N"
	gen ovc_serv_as_f_15to17_oth = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Female" & age=="15-17" & otherdisaggregate=="Other Service Areas" & numeratordenom=="N"
	gen ovc_serv_as_f_15to17_care = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Female" & age=="15-17" & otherdisaggregate=="Parenting/Caregiver Programs" & numeratordenom=="N"
	gen ovc_serv_as_f_15to17_soc = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Female" & age=="15-17" & otherdisaggregate=="Social Protection" & numeratordenom=="N"
	gen ovc_serv_as_f_18to24_econ = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Female" & age=="18-24" & otherdisaggregate=="Economic Strengthening" & numeratordenom=="N"
	gen ovc_serv_as_f_18to24_edu = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Female" & age=="18-24" & otherdisaggregate=="Education Support" & numeratordenom=="N"
	gen ovc_serv_as_f_18to24_oth = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Female" & age=="18-24" & otherdisaggregate=="Other Service Areas" & numeratordenom=="N"
	gen ovc_serv_as_f_18to24_care = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Female" & age=="18-24" & otherdisaggregate=="Parenting/Caregiver Programs" & numeratordenom=="N"
	gen ovc_serv_as_f_18to24_soc = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Female" & age=="18-24" & otherdisaggregate=="Social Protection" & numeratordenom=="N"
	gen ovc_serv_as_f_o25_econ = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Female" & age=="25+" & otherdisaggregate=="Economic Strengthening" & numeratordenom=="N"
	gen ovc_serv_as_f_o25_edu = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Female" & age=="25+" & otherdisaggregate=="Education Support" & numeratordenom=="N"
	gen ovc_serv_as_f_o25_oth = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Female" & age=="25+" & otherdisaggregate=="Other Service Areas" & numeratordenom=="N"
	gen ovc_serv_as_f_o25_care = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Female" & age=="25+" & otherdisaggregate=="Parenting/Caregiver Programs" & numeratordenom=="N"
	gen ovc_serv_as_f_o25_soc = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Female" & age=="25+" & otherdisaggregate=="Social Protection" & numeratordenom=="N"
	gen ovc_serv_as_m_u1_econ = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Male" & age=="<01" & otherdisaggregate=="Economic Strengthening" & numeratordenom=="N"
	gen ovc_serv_as_m_u1_edu = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Male" & age=="<01" & otherdisaggregate=="Education Support" & numeratordenom=="N"
	gen ovc_serv_as_m_u1_oth = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Male" & age=="<01" & otherdisaggregate=="Other Service Areas" & numeratordenom=="N"
	gen ovc_serv_as_m_u1_care = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Male" & age=="<01" & otherdisaggregate=="Parenting/Caregiver Programs" & numeratordenom=="N"
	gen ovc_serv_as_m_u1_soc = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Male" & age=="<01" & otherdisaggregate=="Social Protection" & numeratordenom=="N"
	gen ovc_serv_as_m_1to4_econ = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Male" & age=="01-04" & otherdisaggregate=="Economic Strengthening" & numeratordenom=="N"
	gen ovc_serv_as_m_1to4_edu = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Male" & age=="01-04" & otherdisaggregate=="Education Support" & numeratordenom=="N"
	gen ovc_serv_as_m_1to4_oth = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Male" & age=="01-04" & otherdisaggregate=="Other Service Areas" & numeratordenom=="N"
	gen ovc_serv_as_m_1to4_care = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Male" & age=="01-04" & otherdisaggregate=="Parenting/Caregiver Programs" & numeratordenom=="N"
	gen ovc_serv_as_m_1to4_soc = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Male" & age=="01-04" & otherdisaggregate=="Social Protection" & numeratordenom=="N"
	gen ovc_serv_as_m_5to9_econ = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Male" & age=="05-09" & otherdisaggregate=="Economic Strengthening" & numeratordenom=="N"
	gen ovc_serv_as_m_5to9_edu = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Male" & age=="05-09" & otherdisaggregate=="Education Support" & numeratordenom=="N"
	gen ovc_serv_as_m_5to9_oth = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Male" & age=="05-09" & otherdisaggregate=="Other Service Areas" & numeratordenom=="N"
	gen ovc_serv_as_m_5to9_care = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Male" & age=="05-09" & otherdisaggregate=="Parenting/Caregiver Programs" & numeratordenom=="N"
	gen ovc_serv_as_m_5to9_soc = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Male" & age=="05-09" & otherdisaggregate=="Social Protection" & numeratordenom=="N"
	gen ovc_serv_as_m_10to14_econ = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Male" & age=="10-14" & otherdisaggregate=="Economic Strengthening" & numeratordenom=="N"
	gen ovc_serv_as_m_10to14_edu = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Male" & age=="10-14" & otherdisaggregate=="Education Support" & numeratordenom=="N"
	gen ovc_serv_as_m_10to14_oth = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Male" & age=="10-14" & otherdisaggregate=="Other Service Areas" & numeratordenom=="N"
	gen ovc_serv_as_m_10to14_care = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Male" & age=="10-14" & otherdisaggregate=="Parenting/Caregiver Programs" & numeratordenom=="N"
	gen ovc_serv_as_m_10to14_soc = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Male" & age=="10-14" & otherdisaggregate=="Social Protection" & numeratordenom=="N"
	gen ovc_serv_as_m_15to17_econ = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Male" & age=="15-17" & otherdisaggregate=="Economic Strengthening" & numeratordenom=="N"
	gen ovc_serv_as_m_15to17_edu = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Male" & age=="15-17" & otherdisaggregate=="Education Support" & numeratordenom=="N"
	gen ovc_serv_as_m_15to17_oth = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Male" & age=="15-17" & otherdisaggregate=="Other Service Areas" & numeratordenom=="N"
	gen ovc_serv_as_m_15to17_care = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Male" & age=="15-17" & otherdisaggregate=="Parenting/Caregiver Programs" & numeratordenom=="N"
	gen ovc_serv_as_m_15to17_soc = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Male" & age=="15-17" & otherdisaggregate=="Social Protection" & numeratordenom=="N"
	gen ovc_serv_as_m_18to24_econ = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Male" & age=="18-24" & otherdisaggregate=="Economic Strengthening" & numeratordenom=="N"
	gen ovc_serv_as_m_18to24_edu = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Male" & age=="18-24" & otherdisaggregate=="Education Support" & numeratordenom=="N"
	gen ovc_serv_as_m_18to24_oth = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Male" & age=="18-24" & otherdisaggregate=="Other Service Areas" & numeratordenom=="N"
	gen ovc_serv_as_m_18to24_care = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Male" & age=="18-24" & otherdisaggregate=="Parenting/Caregiver Programs" & numeratordenom=="N"
	gen ovc_serv_as_m_18to24_soc = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Male" & age=="18-24" & otherdisaggregate=="Social Protection" & numeratordenom=="N"
	gen ovc_serv_as_m_o25_econ = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Male" & age=="25+" & otherdisaggregate=="Economic Strengthening" & numeratordenom=="N"
	gen ovc_serv_as_m_o25_edu = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Male" & age=="25+" & otherdisaggregate=="Education Support" & numeratordenom=="N"
	gen ovc_serv_as_m_o25_oth = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Male" & age=="25+" & otherdisaggregate=="Other Service Areas" & numeratordenom=="N"
	gen ovc_serv_as_m_o25_care = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Male" & age=="25+" & otherdisaggregate=="Parenting/Caregiver Programs" & numeratordenom=="N"
	gen ovc_serv_as_m_o25_soc = fy2016apr if indicator=="OVC_SERV" & disaggregate=="Age/Sex" & sex=="Male" & age=="25+" & otherdisaggregate=="Social Protection" & numeratordenom=="N"
	gen kp_prev_k_fsw2 = fy2016apr if indicator=="KP_PREV" & disaggregate=="KeyPop" & otherdisaggregate=="FSW" & numeratordenom=="N"
	gen kp_prev_k_pwid2 = fy2016apr if indicator=="KP_PREV" & disaggregate=="KeyPop"& inlist(otherdisaggregate, "Female PWID", "Male PWID") & numeratordenom=="N"
	gen kp_prev_k_msmtg2 = fy2016apr if indicator=="KP_PREV" & disaggregate=="KeyPop" & otherdisaggregate=="MSM/TG" & numeratordenom=="N"
	gen kp_mat_s_f = fy2016apr if indicator=="KP_MAT" & disaggregate=="Sex" & sex=="Female" & otherdisaggregate=="MSM/TG" & numeratordenom=="N"
	gen kp_mat_s_m = fy2016apr if indicator=="KP_MAT" & disaggregate=="Sex" & sex=="Male" & otherdisaggregate=="MSM/TG" & numeratordenom=="N"
	gen pp_prev_as_f_10to14 = fy2016apr if indicator=="PP_PREV" & disaggregate=="Age/Sex" & sex=="Female" & age=="10-14" & numeratordenom=="N"
	gen pp_prev_as_f_15to19 = fy2016apr if indicator=="PP_PREV" & disaggregate=="Age/Sex" & sex=="Female" & age=="15-19" & numeratordenom=="N"
	gen pp_prev_as_f_20to24 = fy2016apr if indicator=="PP_PREV" & disaggregate=="Age/Sex" & sex=="Female" & age=="20-24" & numeratordenom=="N"
	gen pp_prev_as_f_25to49 = fy2016apr if indicator=="PP_PREV" & disaggregate=="Age/Sex" & sex=="Female" & age=="25-49" & numeratordenom=="N"
	gen pp_prev_as_f_o50 = fy2016apr if indicator=="PP_PREV" & disaggregate=="Age/Sex" & sex=="Female" & age=="50+" & numeratordenom=="N"
	gen pp_prev_as_m_10to14 = fy2016apr if indicator=="PP_PREV" & disaggregate=="Age/Sex" & sex=="Male" & age=="10-14" & numeratordenom=="N"
	gen pp_prev_as_m_15to19 = fy2016apr if indicator=="PP_PREV" & disaggregate=="Age/Sex" & sex=="Male" & age=="15-19" & numeratordenom=="N"
	gen pp_prev_as_m_20to24 = fy2016apr if indicator=="PP_PREV" & disaggregate=="Age/Sex" & sex=="Male" & age=="20-24" & numeratordenom=="N"
	gen pp_prev_as_m_25to49 = fy2016apr if indicator=="PP_PREV" & disaggregate=="Age/Sex" & sex=="Male" & age=="25-49" & numeratordenom=="N"
	gen pp_prev_as_m_o50 = fy2016apr if indicator=="PP_PREV" & disaggregate=="Age/Sex" & sex=="Male" & age=="50+" & numeratordenom=="N"

* drop if no data in row
	egen data = rownonmiss(tx_new_*)
	drop if data==0 & mechanismid!="0"
	drop data
	
*collapse
	drop fy2016apr
	ds, not(type string)
	collapse (sum) `r(varlist)', by(operatingunit psnu psnuuid orgunituid indicatortype mechanismid)
	
	
*create distribution
	foreach t in tx_new_asa tx_new_as tx_curr_asa tx_curr_as ///
		pmtct_stat_kn pmtct_stat_kna pmtct_stat_a pmtct_art_m ///
		pmtct_eid_i tb_art_s tb_art_a tb_stat_s tb_stat_a ///
		vmmc_circ_a vmmc_circ_t ovc_serv_as kp_prev_k ///
		kp_mat_s pp_prev_as {

		egen tot_`t' = rowtotal(`t'_*)
		qui: ds `t'_*
		foreach v in `r(varlist)'{
			qui: gen d_`v' = round(`v'/tot_`t',0.0001)
			qui: drop `v'
			}
		}
	*end
	
	drop tot*
	recode d_* (0 = .)
		
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
