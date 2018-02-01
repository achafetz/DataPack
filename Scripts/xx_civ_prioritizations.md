xx\_civ\_prioritizations.R
================
achafetz
Thu Feb 01 11:13:49 2018

Review Cote D'Ivoire's prioritizations

``` r
library(tidyverse)
```

    ## -- Attaching packages -------------------------------------------------------------------------------------------------------------------------- tidyverse 1.2.1 --

    ## v ggplot2 2.2.1     v purrr   0.2.4
    ## v tibble  1.3.4     v dplyr   0.7.4
    ## v tidyr   0.7.2     v stringr 1.2.0
    ## v readr   1.1.1     v forcats 0.2.0

    ## -- Conflicts ----------------------------------------------------------------------------------------------------------------------------- tidyverse_conflicts() --
    ## x dplyr::filter() masks stats::filter()
    ## x dplyr::lag()    masks stats::lag()

import FactView

``` r
civ_mer <- read_rds("~/ICPI/Data/ICPI_FactView_PSNU_20171222_v2_2.Rds") %>%
  filter(operatingunit == "Cote d'Ivoire") %>% 
  distinct(psnu, psnuuid, currentsnuprioritization) %>% 
  mutate(mer = "X")
```

import subnat

``` r
civ_subnat <- read_rds("~/ICPI/Data/ICPI_FactView_NAT_SUBNAT_20171222_v2_1.Rds") %>%
  filter(operatingunit == "Cote d'Ivoire") %>% 
  distinct(psnu, psnuuid, currentsnuprioritization) %>% 
  mutate(sunnat = "X")
```

join two datasets

``` r
civ <- full_join(civ_mer, civ_subnat) %>% 
  arrange(psnu) 
```

    ## Joining, by = c("psnu", "psnuuid")

which psnus have multiple prioritizations?

``` r
multi <- civ %>% 
  count(psnu) %>% 
  filter(n>1)
(multi_lst <- unique(multi$psnu))
```

    ## [1] "Abengourou"   "Aboisso"      "Adiake"       "Bondoukou"   
    ## [5] "Grand-Bassam" "Tanda"

review psnus, their prioritzations and which dataset they exist in

``` r
civ %>% 
  filter(psnu %in% multi_lst)
```

    ## # A tibble: 12 x 5
    ##            psnu     psnuuid currentsnuprioritization   mer sunnat
    ##           <chr>       <chr>                    <chr> <chr>  <chr>
    ##  1   Abengourou qHfnRvlDq0u 1 - Scale-Up: Saturation     X      X
    ##  2   Abengourou qHfnRvlDq0u 2 - Scale-Up: Aggressive     X      X
    ##  3      Aboisso qzPP0iILjH9                     <NA>     X      X
    ##  4      Aboisso qzPP0iILjH9 8 - Not PEPFAR Supported     X      X
    ##  5       Adiake auvAbmX414m                     <NA>     X      X
    ##  6       Adiake auvAbmX414m 8 - Not PEPFAR Supported     X      X
    ##  7    Bondoukou bPtyVLYWLS1 1 - Scale-Up: Saturation     X      X
    ##  8    Bondoukou bPtyVLYWLS1 2 - Scale-Up: Aggressive     X      X
    ##  9 Grand-Bassam vwUs4s32SzY                     <NA>     X      X
    ## 10 Grand-Bassam vwUs4s32SzY 8 - Not PEPFAR Supported     X      X
    ## 11        Tanda hGbktMoaboh 1 - Scale-Up: Saturation     X      X
    ## 12        Tanda hGbktMoaboh 2 - Scale-Up: Aggressive     X      X
