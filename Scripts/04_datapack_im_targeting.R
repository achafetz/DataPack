##   Data Pack COP FY18
##   A.Chafetz, USAID
##   Purpose: generate output for IM targeting in Data Pack
##   Adopted from COP17 Stata code
##   Date: October 19, 2017
##   Updated: 10/19/17

## DEPENDENCIES
    # run 00_datapack_initialize.R
    # ICPI Fact View PSNU_IM
    # 05_datapack_officialnames.R
    # 06_datapack_snu_adj.R

## SETUP ---------------------------------------------------------------------------------------------------

  #import
    df_mechdistro <- read_tsv(file.path(fvdata, paste("ICPI_FactView_PSNU_IM_", datestamp, ".txt", sep="")))
      names(df_mechdistro) <- tolower(names(df_mechdistro)) 
  
  #cleanup PSNUs (dups & clusters)
    source(file.path(scripts, "05_datapack_officialnames.R"))
      cleanup_mechs(df_mechdistro)
      
    source(file.path(scripts, "06_datapack_snu_adj.R"))
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
  
## MECH DISTRIBUTION ---------------------------------------------------------------------------------------
  #from 01_datapack_output

  ## TODO <<< ----    
      
      
      
## CLEAN UP -------------------------------------------------------------------------------------------------
  
  #keep just one dedup
    df_mechdistro <- mutate(df_mechdistro, mechanismid = ifelse(mechanismid == "00001", "00000", mechanismid))
      
  #append psnu DSD + TA dedups on 
    df_mechdistro <- bind_row(df_mechdistro, df_dedups)  
  
    # drop fy*
    # tostring mechanismid, replace
    # ds *, not(type string)
    # foreach v in `r(varlist)'{
		#   rename `v' val_`v'
		# }
	  #end
    
  #aggregate up to psnu level
    isnum <- sapply(df_mechdistro, is.numeric)
    df_mechdistro <- df_mechdistro %>% 
      group_by(operatingunit, psnu, psnuuid, indicatortype, mechanismid) %>%
      summarise(vars(isnum), funs(sum(., na.rm = TRUE)))
      
      
      
      
      
      
      
      
      
      
    
  