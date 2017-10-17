##   Data Pack
##   COP FY18
##   Aaron Chafetz
##   Purpose: remove/combine duplicate SNUs with different UIDs & cluster SNUs
##   Date: January 12, 2017
##   Updated: 10/17/17

## COMBINE/DELETE SNUS ##

  ##List of PSNUs that have the same name but different UIDs
  ## Duplicate list produced from following do file
  ## https://github.com/achafetz/ICPI_Projects/blob/master/Other/dupSNUs.do
  ## N. Bartlett identified whether to combine/delete each
  
  #  | operatingunit                    | psnu                | psnuuid     | action              |
  #  |----------------------------------|---------------------|-------------|---------------------|
  #  | Ghana                            | Jomoro              | dASd72VnJPh | Combine             |
  #  | Ghana                            | Jomoro              | dOQ8r7iwZvS | Combine             |
  #  | Nigeria                          | eb Abakaliki        | EzsXkY9WARj | Combine             |
  #  | Nigeria                          | eb Abakaliki        | URj9zYi533e | Combine             |
  #  | Nigeria                          | eb Afikpo North     | KN2TmcAVqzi | Combine             |
  #  | Nigeria                          | eb Afikpo North     | bDoKaxNx2Xb | Combine             |
  #  | Nigeria                          | en Enugu South      | HHDEeZbVEaw | Combine             |
  #  | Nigeria                          | en Enugu South      | HhCbsjlKoWA | Combine             |
  #  | Nigeria                          | im Ezinihitte       | IxeWi5YG9lE | Combine             |
  #  | Nigeria                          | im Ezinihitte       | dzjXm8e1cNs | Combine             |
  #  | Nigeria                          | im Owerri Municipal | kxsmKGMZ5QF | Combine             |
  #  | Nigeria                          | im Owerri Municipal | mVuyipSx9aU | Combine             |
  #  | Nigeria                          | im Owerri North     | FjiNyXde6Ae | Combine             |
  #  | Nigeria                          | im Owerri North     | xmRjV3Gx1H6 | Combine             |
  #  | Nigeria                          | ek Ikere            | FLIkT6NShZE | Combine             |
  #  | Nigeria                          | ek Ikere-Ekiti      | KT3e5pmPdfB | Combine             |
  #  | Nigeria                          | eb Ebonyi           | J4yYjIqL7mG | Keep                |
  #  | Nigeria                          | eb Ebonyi           | oygNEfySnMl | Delete (Blank)      |
  #  | Nigeria                          | en Enugu East       | HlABmTwBpu6 | Keep                |
  #  | Nigeria                          | en Enugu East       | h61xiVptz4A | Delete (Duplicates) |
  #  | Nigeria                          | en Nsukka           | ITdnyCiBvz7 | Keep                |
  #  | Nigeria                          | en Nsukka           | lC1wneS1GR5 | Delete (Duplicates) |
  #  | Nigeria                          | im Ngor Okpala      | vpCKW3gWNhV | Keep                |
  #  | Nigeria                          | im Ngor Okpala      | D47MUIzTapM | Delete (Duplicates) |

  
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
    df_curr <- df_curr %>%
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
                         paste(snu1, psnu, sep = "/"), psnu))
    rm(df_adj)

    
## REMOVE SNUs ##
  #S.Ally (1/17/17) - no Sustained - Commodities districts 
      df_curr <- df_curr %>%
        filter(!psnuuid %in% c("O1kvkveo6Kt", "hbnRmYRVabV", "N7L1LQMsQKd", "nlS6OMUb6s3"))

    

## SNU NAMING ISSUES ##
  # M. Melchior (1/21/17) - txt import issue with French names 
   df_curr <- df_curr %>%
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
            ) 
   
   
## Cluster SNUs ##
  # clusters submitted by SI advisors - https://github.com/achafetz/ICPI/tree/master/DataPack/RawData
  # only for psnu and psnu x im datasets, not site (orgunituid should not exist in PSNU or PSNU IM dataset) 

  # import cluster dataset
    df_cluster  <- read_csv(file.path(rawdata, "COP17Clusters.csv", sep=""))
    
  # remove duplicate data/headers
    df_cluster <- select(df_cluster, -operatingunit, -psnu, -fy17snuprioritization, -cluster_set:-cluster_date)
    
  # merge clusters onto factview
    df_curr <- left_join(df_curr, df_cluster, by = "psnuuid")
    rm(df_cluster)
      
  # replace with cluster info
    df_curr <- df_curr %>%
      mutate(
        psnu = ifelse(is.na(cluster_psnu), psnu, cluster_psnu),
        snu1 = ifelse(is.na(cluster_snu1), snu1, cluster_snu1),
        psnuuid = ifelse(is.na(cluster_psnuuid), psnuuid, cluster_psnuuid),
        fy17snuprioritization = ifelse(is.na(cluster_fy17snuprioritization), fy17snuprioritization, cluster_fy17snuprioritization)
        ) %>%
      select(-cluster_psnu:-cluster_fy17snuprioritization)
    
    
    
    