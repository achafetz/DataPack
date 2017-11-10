##  Data Pack COP18 
##  A.Chafetz, USAID
##  Purpose: initialize packages, folder structure, and global file paths
##  Adapted from T. Essam, USAID [Stata]
##  Updated: 10/19/17 
##  https://github.com/achafetz/DataPack

## DEPENDENT PACKAGES -------------------------------------------------------------------------
  #load libraries 
    pacman::p_load("readr", "dplyr", "tidyr", "tibble", "stringr", "forcats", "readxl", "RCurl", "rlist")

## FILE PATHS ---------------------------------------------------------------------------------
  #must be run each time R project is opened
  #Choose the project path location to where you want the project parent 
  #folder to go on your machine.
    projectpath <- "~/GitHub"
    setwd(projectpath)

  # Run a macro to set up study folder
    pfolder <- "DataPack" # Name the folder name here
    dir.create(file.path(pfolder), showWarnings = FALSE)
    setwd(file.path(projectpath, pfolder))

  #Run initially to set up folder structure
  #Choose your folders to createa and and stored as values
    folderlist <- c("RawData", "TempOutput", "Output", "Scripts")
    for (f in folderlist){
      dir.create(file.path(projectpath, pfolder, f), showWarnings = FALSE)
      assign(tolower(f), file.path(projectpath, pfolder, f,"/"))
    }

  #additional folders outside of project folder (due to large file size)
    fvdata <- "~/ICPI/Data"
    dpexcel <- "~/DataPack/DataPulls"


## DATES ---------------------------------------------------------------------------------------
    
  #define date for Fact View Files
    datestamp <- "20170922_v2_1" #currently 3, needs to be updated with 4 when available
    
  #set today's date for saving
    date <-  format(Sys.Date(), format="%d%b%Y")
    
    
## CLEAN UP STORED GLOBALS -------------------------------------------------------------------
  rm(projectpath, pfolder, folderlist, f)
    
    