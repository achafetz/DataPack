##   Data Pack COP FY18
##   A.Chafetz, USAID
##   Purpose: identify official names from FACTSInfo
##   Adopted from COP17 Stata code/PPR 03_partnerreport_dashoardoutput
##   Date: Oct 13, 2017
##   Updated: 


## DEPENDENCIES
  # Standard COP Matrix Report from FACTSInfo
  # ICPI Fact View (df_curr)
    	
### OFFICIAL NAMES
	
  #import official mech and partner names; source: FACTS Info
  	df_names <- read_excel(file.path(rawdata,"FY12-16 Standard COP Matrix Report-20170822.xls"), skip = 1)
  	
  #rename variables
  	names(df_names) <- c("operatingunit", "mechanismid", "primepartner_2014", "implementingmechanismname_2014", 
  	                     "primepartner_2015", "implementingmechanismname_2015", "primepartner_2016", "implementingmechanismname_2016",
  	                     "primepartner_2017", "implementingmechanismname_2017")
  	
  #figure out latest name for IM and partner (should both be from the same year)
  	df_names <- df_names %>%
  	  
  	  #reshape long
  	    gather(type, name, primepartner_2014, implementingmechanismname_2014, 
  	         primepartner_2015, implementingmechanismname_2015, primepartner_2016, implementingmechanismname_2016,
  	         primepartner_2017, implementingmechanismname_2017) %>%
  	  
  	  #split out type and year (eg type = primeparnter_2015 --> type = primepartner,  year = 2015)
  	    separate(type, c("type", "year"), sep="_") %>%
  	  
  	  #drop lines/years with missing names
  	    filter(!is.na(name)) %>%
  	  
  	  #group to figure out latest year with names and keep only latest year's names (one obs per mech)
    	  group_by(operatingunit, mechanismid, type) %>%
    	  filter(year==max(year)) %>%
    	  ungroup() %>%
  	  
  	  #reshape wide so primepartner and implementingmechanismname are two seperate columsn to match fact view dataset
  	    spread(type, name) %>%
  	  
  	  #keep names with mechid (converted to string) for merging into main df, renaming (_F) to identify as from FACTS
    	  select(mechanismid, implementingmechanismname, primepartner) %>%
    	  mutate(mechanismid =  as.character(mechanismid)) %>%
    	  rename(implementingmechanismname_F = implementingmechanismname, primepartner_F = primepartner)
  	  
  #merge in official names
  	df_curr <- left_join(df_curr, df_names, by="mechanismid")
    rm(df_names)
     
  #replace prime partner and mech names with official names
    df_curr <- df_curr %>%
  	   mutate(implementingmechanismname = ifelse(is.na(implementingmechanismname_F), implementingmechanismname, implementingmechanismname_F), 
  	                  primepartner = ifelse(is.na(primepartner_F), primepartner, primepartner_F)) %>%
  	   select(-ends_with("_F"))
    
  	 