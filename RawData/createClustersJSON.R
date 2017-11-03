library(rlist)
d<-read.csv("COP17Clusters.csv")
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


cat(toJSON(clusters_l,auto_unbox = TRUE),file="cop_clusters_17.json")