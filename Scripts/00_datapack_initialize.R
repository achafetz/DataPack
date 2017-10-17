##  Data Pack COP18 
##  A.Chafetz, USAID
##  Purpose: initialize packages, folder structure, and global file paths
##  Adapted from T. Essam, USAID
##  Updated: 10/11/17 
##  https://github.com/achafetz/DataPack

## DEPENDENT PACKAGES -------------------------------------------------------------------------
  #load libraries 
    lib <- c("tidyverse", "stringr", "forcats")
    lapply(lib, require, character.only = TRUE)
  
## FILE PATHS ---------------------------------------------------------------------------------
  #must be run each time R project is opened
  #Choose the project path location to where you want the project parent 
  #folder to go on your machine.
    projectpath <- "C:/Users/achafetz/Documents/GitHub"
    setwd(projectpath)

  # Run a macro to set up study folder
    pfolder <- "DataPack" # Name the folder name here
    dir.create(file.path(pfolder), showWarnings = FALSE)
    setwd(file.path(projectpath, pfolder))

  #Run initially to set up folder structure
  #Choose your folders to createa and and stored as values
    folderlist <- c("RawData", "StataOutput", "ExcelOutput", "DoFiles")
    for (f in folderlist){
      dir.create(file.path(projectpath, pfolder, f))
      assign(tolower(f), file.path(projectpath, pfolder, f,"/"))
    }
    
  #additional folders outside of project folder (due to large file size)
    fvdata <- "C:/Users/achafetz/Documents/ICPI/Data"
    dpexcel <- "C:/Users/achafetz/Documents/DataPack/DataPulls"
  
  
## CLEAN UP STORED GLOBALS -------------------------------------------------------------------
  rm(lib, projectpath, pfolder, folderlist, f)