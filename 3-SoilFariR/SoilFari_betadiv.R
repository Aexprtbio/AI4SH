# CREATED ON 12 mar 2026
# PRÉTAT

# Last update : 12/03/2026

rm(list=ls())

# libraries --------------------------------------------------------------------------
library(ade4)
library(car)
library(dplyr)
library(igraph)
library(ggplot2)
library(hms)
library(lubridate)
library(tidyr)
library(vegan)
library(wesanderson)
library(RColorBrewer)

#  work on ACP now : LIBS -----------------------------------------------------------
library(FactoMineR)
library(factoextra)
library(seriation)
library(clustertend)
library(RVAideMemoire)
library(cluster)

# import functions from SoilFariR_functions.r ---------------------------------------
setwd('D:/GitHub/AI4SH/3-SoilFariR')
source('SoilFariR_functions.r')

# import up to date DataFrame -------------------------------------------------------
setwd('D:/GitHub/AI4SH/4-DataFrames_ready')

safari <- read.csv2('safari_all_projects_dataframe.csv', h=TRUE, stringsAsFactor=TRUE, sep=',')

commu <- table(safari$transect_id, safari$taxa)
commu <- decostand(commu, method="pa")

species <- data.frame(transect_id=rownames(commu))
species$transect_id<-as.factor(species$transect_id)
species$abundance <- rowSums(commu)


summary(species)

################################ PLOTS ################################################

plot(species$abundance~species$transect_id)


######################## BETA DIVERSITY INDEXES #######################################

########################### SORENSEN ##################################################

soren <- matrix(nrow=length(levels(safari$transect_id)), 
	ncol=length(levels(safari$transect_id)), 
	dimnames=list(levels(safari$transect_id),levels(safari$transect_id)))

# calculate sorensen index on the matrix (so pairwise) --------------------------------

sor <- sorensen(safari, commu)
colnames(sor)<-levels(safari$transect_id)
rownames(sor)<-levels(safari$transect_id)
sor[1,] <- sor[,1]




################################ GRAPH OF NETWORKSSSS #################################

diag(sor)=0
g <- graph_from_adjacency_matrix(sor, mode='undirected', weighted=TRUE)

plot(g)