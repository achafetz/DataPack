##   Data Pack COP FY18
##   J.Pickering
##   Purpose: convert csv of clustes to json
##   Adopted from COP17 Stata code
##   Date: Nov 3, 2017
##   Updated: 

## DEPENDENCIES
  # run 00_datapack_initialize.R

## CONVERT -------------------------------------------------------------------------------

  library(rlist)
  d<-read.csv(file.path(rawdata,"COP17Clusters.csv"))
  clusters<-d[,c("cluster_psnu","cluster_psnuuid","psnu","psnuuid")]
  clusters_u<-unique(clusters[,c("cluster_psnu","cluster_psnuuid")])
  
  clusters_l<-list(period="2017Oct",clusters=list())
  
  for (i in 1:nrow(clusters_u)) {
    foo<-clusters[clusters$cluster_psnuuid == clusters_u[i,"cluster_psnuuid"],c("psnu","psnuuid")]
    cluster_l<-list(cluster_name = clusters_u[i,"cluster_psnu"],
                                  cluster_id = clusters_u[i,"cluster_psnuuid"],
                    psnus=foo)
    clusters_l$clusters<-list.append(clusters_l$clusters,cluster_l)
    
  }

## EXPORT -------------------------------------------------------------------------------
  cat(toJSON(clusters_l,auto_unbox = TRUE),file=file.path(rawdata, "cop_clusters_17.json"))