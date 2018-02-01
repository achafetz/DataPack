#' ---
#' output: github_document
#' ---

#' Review Cote D'Ivoire's prioritizations

library(tidyverse)

#'import FactView
civ_mer <- read_rds("~/ICPI/Data/ICPI_FactView_PSNU_20171222_v2_2.Rds") %>%
  filter(operatingunit == "Cote d'Ivoire") %>% 
  distinct(psnu, psnuuid, currentsnuprioritization) %>% 
  mutate(mer = "X")

#' import subnat
civ_subnat <- read_rds("~/ICPI/Data/ICPI_FactView_NAT_SUBNAT_20171222_v2_1.Rds") %>%
  filter(operatingunit == "Cote d'Ivoire") %>% 
  distinct(psnu, psnuuid, currentsnuprioritization) %>% 
  mutate(sunnat = "X")

#' join two datasets
civ <- full_join(civ_mer, civ_subnat) %>% 
  arrange(psnu) 

#' which psnus have multiple prioritizations?
multi <- civ %>% 
  count(psnu) %>% 
  filter(n>1)
(multi_lst <- unique(multi$psnu))

#' review psnus, their prioritzations and which dataset they exist in
civ %>% 
  filter(psnu %in% multi_lst)
