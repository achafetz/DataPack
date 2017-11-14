##   Data Pack COP FY18
##   A.Chafetz, USAID
##   Purpose: identify official names from FACTSInfo
##   Adopted from COP17 Stata code/PPR 03_partnerreport_dashoardoutput
##   Date: Oct 13, 2017
##   Updated: 11/14/17


## DEPENDENCIES -------------------------------------------------------------------------------------------------
  # Standard COP Matrix Report from FACTSInfo
    	
## OFFICIAL NAMES -------------------------------------------------------------------------------------------------

cleanup_mechs <- function(df_to_clean, report_folder_path, report_start_year = 2014) {

  #import official mech and partner names; source: FACTS Info
    df_names <- read_excel(Sys.glob(file.path(report_folder_path,"*Standard COP Matrix Report*.xls")), skip = 1)
  	
  #rename variable stubs
    names(df_names) <- gsub("Prime Partner", "primepartner", names(df_names))
    names(df_names) <- gsub("Mechanism Name", "implementingmechanismname", names(df_names))
  	
  #figure out latest name for IM and partner (should both be from the same year)
  	df_names <- df_names %>%
  	  
  	  #rename variables that don't fit pattern
  	    rename(operatingunit =  `Operating Unit`, mechanismid = `Mechanism Identifier`, 
  	           primepartner__0 = primepartner, implementingmechanismname__0 = implementingmechanismname) %>% 
  	  #reshape long
    	  gather(type, name, -operatingunit, -mechanismid) %>%
    	  
  	  #split out type and year (eg type = primeparnter__1 --> type = primepartner,  year = 1)
  	    separate(type, c("type", "year"), sep="__") %>%
  	  
  	  #add year (assumes first year if report is 2014)
  	    mutate(year = as.numeric(year) + report_start_year) %>%
  	
  	  #drop lines/years with missing names
  	    filter(!is.na(name)) %>%
  	  
  	  #group to figure out latest year with names and keep only latest year's names (one obs per mech)
    	  group_by(operatingunit, mechanismid, type) %>%
    	  filter(year==max(year)) %>%
    	  ungroup() %>%
  	  
  	  #reshape wide so primepartner and implementingmechanismname are two seperate columsn to match fact view dataset
  	    spread(type, name) %>%
  	  
  	  #convert mechanism id to string for merging back onto main df
  	    mutate(mechanismid = as.character(mechanismid)) %>%
  	      
  	  #keep only names with mechid and renaming with _F to identify as from FACTS  
    	  select(mechanismid, implementingmechanismname, primepartner) %>%
    	  rename(implementingmechanismname_F = implementingmechanismname, primepartner_F = primepartner) 
  	    
    #match mechanism id type for compatible merge
	    df_to_clean <- mutate(df_to_clean, as.character(mechanismid))
  	   
    #merge in official names
    	df_to_clean <- left_join(df_to_clean, df_names, by="mechanismid")
      
    #replace prime partner and mech names with official names
    	df_to_clean <- df_to_clean %>%
    	   mutate(implementingmechanismname = ifelse(is.na(implementingmechanismname_F), implementingmechanismname, implementingmechanismname_F), 
    	                  primepartner = ifelse(is.na(primepartner_F), primepartner, primepartner_F)) %>%
    	   select(-ends_with("_F"))
}
  	 