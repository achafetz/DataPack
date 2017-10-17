##  Data Pack COP18
##  A.Chafetz, USAID
##  Purpose: define all functions used in the scipting process
##  https://github.com/achafetz/DataPack



initialize_project <- function(pfolder, projectpath = "~/GitHub") {
  ##  Purpose: initialize packages, folder structure, and global file paths
  ##  Adapted from T. Essam, USAID
  ##  Updated: 10/11/17

  ## DEPENDENT PACKAGES -----
    #load libraries
      pacman::p_load("tidyverse", "stringr", "forcats")

  ## FILE PATHS -----
    # Setup subfolder structure
      dir.create(file.path(projectpath, pfolder), showWarnings = FALSE)
      setwd(file.path(projectpath, pfolder))
    
    # Choose your folders to create and and stored as values
      folderlist <- c("RawData", "TempOutput", "Output", "Scripts")
      for (f in folderlist){
        dir.create(file.path(projectpath, pfolder, f),showWarnings = FALSE)
        assign(tolower(f), file.path(projectpath, pfolder, f,"/"))
      }

    #additional folders outside of project folder (due to large file size)
      fvdata <- "~/ICPI/Data"
      dpexcel <- "~/DataPack/DataPulls"
  ## CLEAN UP STORED GLOBALS -----
    rm(projectpath, pfolder, folderlist, f)
}
