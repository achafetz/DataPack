##   Data Pack
##   COP FY18
##   Aaron Chafetz
##   Purpose: assign clusters with their own UIDS
##   Date: January 10, 2018
##   Updated: 

#load libraries
  pacman::p_load(tidyverse, RCurl)

#import cluster dataset
  gh <- getURL("https://raw.githubusercontent.com/achafetz/DataPack/master/RawData/COP18Clusters.csv")
  df_cluster <- read.csv(text = gh)
    rm(gh)

#get list of unique cluster names so we can assign each with a UID
  uniq_clusters <- distinct(df_cluster, cluster_psnu) #table

#function to create UID from J.Pickering
  generateUID<-function(codeSize=11){
    #Generate a random seed
    runif(1)
    allowedLetters<-c(LETTERS,letters)
    allowedChars<-c(LETTERS,letters,0:9)
    #First character must be a letter according to the DHIS2 spec
    firstChar<-sample(allowedLetters,1)
    otherChars<-sample(allowedChars,codeSize-1)
    uid<-paste(c(firstChar,paste(otherChars,sep="",collapse="")),sep="",collapse="")
    return(uid)}

#map uids onto each psnu cluster
  uniq_clusters$uid<-sapply(rep(11,nrow(uniq_clusters)),generateUID)
  


                       