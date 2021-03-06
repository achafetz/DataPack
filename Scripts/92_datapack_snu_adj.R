##   Data Pack
##   COP FY18
##   Aaron Chafetz
##   Purpose: remove/combine duplicate SNUs with different UIDs & cluster SNUs
##   Date: January 12, 2017
##   Updated: 2018.02.15


##List of PSNUs that have the same name but different UIDs
## Duplicate list produced from following do file
## https://github.com/achafetz/ICPI_Projects/blob/master/Other/dupSNUs.do
## N. Bartlett identified whether to combine/delete each

#   | operatingunit | psnu                    | psnuuid     | COP17 action        | COP18 action   |
#   |---------------|-------------------------|-------------|---------------------|----------------|
#   | Burma         | Dagon Myothit (Seikkan) | Z6b0Advh1f8 | N/A                 | Combine        |
#   | Burma         | Dagon Myothit (Seikkan) | qPyHEwO7X6D | N/A                 | Combine        |
#   | Ghana         | Jomoro                  | dASd72VnJPh | Combine             | Keep           |
#   | Ghana         | Jomoro                  | dOQ8r7iwZvS | Combine             | Delete (Blank) |
#   | Nigeria       | eb Abakaliki            | EzsXkY9WARj | Combine             | Combine        |
#   | Nigeria       | eb Abakaliki            | URj9zYi533e | Combine             | Combine        |
#   | Nigeria       | eb Afikpo North         | KN2TmcAVqzi | Combine             | Combine        |
#   | Nigeria       | eb Afikpo North         | bDoKaxNx2Xb | Combine             | Combine        |
#   | Nigeria       | en Enugu South          | HHDEeZbVEaw | Combine             | Delete (Blank) |
#   | Nigeria       | en Enugu South          | HhCbsjlKoWA | Combine             | Keep           |
#   | Nigeria       | im Ezinihitte           | IxeWi5YG9lE | Combine             | Delete (Blank) |
#   | Nigeria       | im Ezinihitte           | dzjXm8e1cNs | Combine             | Keep           |
#   | Nigeria       | im Owerri Municipal     | kxsmKGMZ5QF | Combine             | Combine        |
#   | Nigeria       | im Owerri Municipal     | mVuyipSx9aU | Combine             | Combine        |
#   | Nigeria       | im Owerri North         | FjiNyXde6Ae | Combine             | Combine        |
#   | Nigeria       | im Owerri North         | xmRjV3Gx1H6 | Combine             | Combine        |
#   | Nigeria       | ek Ikere                | FLIkT6NShZE | Combine             | Keep           |
#   | Nigeria       | ek Ikere-Ekiti          | KT3e5pmPdfB | Combine             | Delete (Blank) |
#   | Nigeria       | eb Ebonyi               | J4yYjIqL7mG | Keep                | Combine        |
#   | Nigeria       | eb Ebonyi               | oygNEfySnMl | Delete (Blank)      | Combine        |
#   | Nigeria       | en Enugu East           | HlABmTwBpu6 | Keep                | Keep           |
#   | Nigeria       | en Enugu East           | h61xiVptz4A | Delete (Duplicates) | Delete (Blank) |
#   | Nigeria       | en Nsukka               | ITdnyCiBvz7 | Keep                | Keep           |
#   | Nigeria       | en Nsukka               | lC1wneS1GR5 | Delete (Duplicates) | Delete (Blank) |
#   | Nigeria       | im Ngor Okpala          | vpCKW3gWNhV | Keep                | Keep           |
#   | Nigeria       | im Ngor Okpala          | D47MUIzTapM | Delete (Duplicates) | Delete (Blank) |
#   | Haiti         | Valli?res               | RVzTHBO9fgR | N/A                 | Delete (Blank) |
#   | Haiti         | Valli?res               | ONUWhpgEbVk | N/A                 | Keep           |
#   | India         | Chandigarh              | rdZgJxh6GA6 | N/A                 | No FY17 data   |
#   | India         | Chandigarh              | eknq1Uf5JK6 | N/A                 | No FY17 data   |


## COMBINE/DELETE SNUS -----------------------------------------------------------------------------

cleanup_snus <- function(df) {
  
  #table of dup PSNUs(psnuuid) & their replacments (psnuuid_adj)
  df_adj <- tribble(
    ~psnuuid,	    ~psnuuid_adj,
    "Z6b0Advh1f8",    "qPyHEwO7X6D",
    "EzsXkY9WARj",    "URj9zYi533e",
    "KN2TmcAVqzi",    "bDoKaxNx2Xb",
    "kxsmKGMZ5QF",    "mVuyipSx9aU",
    "FjiNyXde6Ae",    "xmRjV3Gx1H6",
    "J4yYjIqL7mG",    "oygNEfySnMl"
  )
  
  #replace duplicate UIDs so only one per PSNU
  df <- df %>%
    left_join(df_adj, by = "psnuuid") %>%
    mutate(psnuuid = ifelse(is.na(psnuuid_adj), psnuuid, psnuuid_adj)) %>%
    select(-psnuuid_adj) %>%
    
    #replace PNSU ek Ikere-Ekiti with ek Ikere
    mutate(psnu = ifelse(psnuuid=="KT3e5pmPdfB","ek Ikere", psnu)) %>%
    
    #remove all duplicates/blank PSNUs
    filter(!psnuuid %in% c("dOQ8r7iwZvS", "HHDEeZbVEaw", "IxeWi5YG9lE", "KT3e5pmPdfB", "h61xiVptz4A", 
                           "lC1wneS1GR5", "D47MUIzTapM", "RVzTHBO9fgR")) %>%
    
    #add country name to regional programs
    mutate(psnu = ifelse((operatingunit %in% 
                            c("Asia Regional Program", "Caribbean Region", "Central America Region", "Central Asia Region")), 
                         paste(snu1, psnu, sep = "/"), psnu)) %>%
    
    ## REMOVE SNUs ##
    #S.Ally (1/17/17) - no Sustained - Commodities districts 
    filter(!psnuuid %in% c("O1kvkveo6Kt", "hbnRmYRVabV", "N7L1LQMsQKd", "nlS6OMUb6s3")) %>%
    
    ## SNU NAMING ISSUES ##
    # M. Melchior (1/21/17) - txt import issue with French names 
    mutate( psnu = ifelse(psnuuid == "JVXPyu8T2fO", "Cap-Haïtien", psnu), 
            psnu = ifelse(psnuuid == "XXuTiMjae3r", "Anse à Veau", psnu),
            psnu = ifelse(psnuuid == "prA0IseYHWD", "Fort Liberté", psnu),
            psnu = ifelse(psnuuid == "xBsmGxPgQaw", "Gonaïves", psnu),
            psnu = ifelse(psnuuid == "fXIAya9MTsp", "Grande Rivière du Nord", psnu),
            psnu = ifelse(psnuuid == "lqOb8ytz3VU", "Jérémie", psnu),
            psnu = ifelse(psnuuid == "aIbf3wlRYB1", "La Gonave", psnu),
            psnu = ifelse(psnuuid == "nbvAsGLaXdk", "Léogâne", psnu),
            psnu = ifelse(psnuuid == "rrAWd6oORtj", "Limbé", psnu),
            psnu = ifelse(psnuuid == "nbvAsGLaXdk", "Léogâne", psnu),
            psnu = ifelse(psnuuid == "c0oeZEJ8qXk", "Môle Saint Nicolas", psnu),
            psnu = ifelse(psnuuid == "Y0udgSlBzfb", "Miragoâne", psnu),
            psnu = ifelse(psnuuid == "R2NsUDhdF8x", "Saint-Raphaël", psnu),
            psnu = ifelse(psnuuid == "mLFKTGjlEg1", "Chardonniàres", psnu),
            psnu = ifelse((psnuuid %in% c("ONUWhpgEbVk", "RVzTHBO9fgR")), "Vallières", psnu)
    ) %>% 
    
    #replace the 2 _unallocated cities in Mozambique with the PSNUs they fall within
    #C.Hill (2/15/2018)
        mutate(psnu = ifelse(psnuuid == "uMXJsbSbXBS", "Xai-Xai", psnu),
               psnuuid = ifelse(psnuuid == "uMXJsbSbXBS", "kKXWgaF11TT", psnuuid),
               currentsnuprioritization = ifelse(psnuuid == "uMXJsbSbXBS", "1 - Scale-Up: Saturation", currentsnuprioritization),
               psnu = ifelse(psnuuid == "nOE2NPIf8vq", "Nampula", psnu),
               psnuuid = ifelse(psnuuid == "nOE2NPIf8vq", "jwLNNIw1MjY", psnuuid),
               currentsnuprioritization = ifelse(psnuuid == "nOE2NPIf8vq", "2 - Scale-Up: Aggressive", currentsnuprioritization))
  
    #fix issue of snus having mutliple prioritizations over time --> use FY17Q4 value, otherwise take NA
    #create prioritization list if it doesn't exist already
    if (!file.exists(file.path(rawdata, "COP18prioritizations.csv"))) {
      df_priority <- read_rds(Sys.glob(file.path(fvdata, "ICPI_FactView_PSNU_2*.Rds"))) %>% 
        #remove missing values (only keeping what is available in Q4)
        filter(!is.na(fy2017q4), fy2017q4!= 0, !is.na(psnuuid), !is.na(currentsnuprioritization)) %>%
        #keep unique values of psnus and their prioritization
        distinct(psnuuid, currentsnuprioritization) %>% 
        #save to raw data for efficiency going forward
        write_csv(file.path(rawdata, "COP18prioritizations.csv"))
    } else {
      df_priority <- read_csv(file.path(rawdata, "COP18prioritizations.csv"))  
    }
    #remove problematic prioritization
    df <- df %>% 
      select(-currentsnuprioritization)
    
    #merge q4 priority in and reorder
    df <- left_join(df, df_priority) %>% 
      select(region:psnuuid, currentsnuprioritization, everything())
  
    #rename prioritizations (due to spacing and to match last year)
    df <- df %>% 
      mutate(currentsnuprioritization = ifelse(is.na(currentsnuprioritization), "NOT DEFINED", currentsnuprioritization),
             currentsnuprioritization = parse_factor(currentsnuprioritization, 
                                                     levels = c("1 - Scale-Up: Saturation", "2 - Scale-Up: Aggressive", 
                                                                "4 - Sustained", "5 - Centrally Supported", "6 - Sustained: Commodities", 
                                                                "7 - Attained", "8 - Not PEPFAR Supported", "Mil", "NOT DEFINED"), 
                                                     include_na = TRUE),
             currentsnuprioritization = fct_recode(currentsnuprioritization,
                                                   "ScaleUp Sat"    =  "1 - Scale-Up: Saturation", 
                                                   "ScaleUp Agg"    =  "2 - Scale-Up: Aggressive", 
                                                   "Sustained"      =  "4 - Sustained", 
                                                   "Ctrl Supported" =  "5 - Centrally Supported",  
                                                   "Sustained Com"  =  "6 - Sustained: Commodities",
                                                   "Attained"       =  "7 - Attained",  
                                                   "Not Supported"  =  "8 - Not PEPFAR Supported"))
    
    
}





## Cluster SNUs --------------------------------------------------------------------------------------------
# clusters submitted by SI advisors - https://github.com/achafetz/ICPI/tree/master/DataPack/RawData
# only for psnu and psnu x im datasets, not site (orgunituid should not exist in PSNU or PSNU IM dataset) 

cluster_snus <- function(df){
  # import cluster dataset
    df_cluster  <- read_csv(file.path(rawdata, "COP18Clusters.csv", sep=""))
    #gh <- getURL("https://raw.githubusercontent.com/achafetz/DataPack/master/RawData/COP18Clusters.csv")
    #df_cluster <- read.csv(text = gh)
  
  # remove duplicate data/headers
    df_cluster <- select(df_cluster, -operatingunit, -psnu, -currentsnuprioritization, -cluster_set:-cluster_date)
  
  # merge clusters onto factview
    df <- left_join(df, df_cluster, by = "psnuuid")
  
  # replace with cluster info
    df <- df %>%
      mutate(
        psnu = ifelse(is.na(cluster_psnu), psnu, cluster_psnu),
        snu1 = ifelse(is.na(cluster_snu1), snu1, cluster_snu1),
        psnuuid = ifelse(is.na(cluster_psnuuid), psnuuid, cluster_psnuuid),
        currentsnuprioritization = ifelse(is.na(cluster_currentsnuprioritization), currentsnuprioritization, cluster_currentsnuprioritization)
      ) %>%
      select(-cluster_psnu:-cluster_currentsnuprioritization)
  
} 

