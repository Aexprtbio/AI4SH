# CREATED ON 09 MAY 2025
# PRÉTAT

# Last update : 25/09/2025

rm(list=ls())

library(ade4)
library(car)
library(dplyr)
library(hms)
library(lubridate)
library(reticulate) # to import Python functions and script
library(tidyr)
library(vegan)

##### Source python
use_python('C:/Users/PRETAT/anaconda3/')
use_condaenv('torch13')


##### Import homemade module for APIs
setwd('D:/GitHub/AI4SH/1-ModulesPython/inatuapi/')
source_python("inatuapi_funcs.py")

# the use of python functions in r with reticulate must be preceded by 'py$'
rouen <- py$getobs_proj('262646') # --> get obs from the aifsh 2025 project on inat

rouen <- py_to_r(rouen) # convert python object to r object.


##### Setting work directory
setwd('D:/GitHub/POLLSOL-AIFSH/AIFSH/4-SAFARI-method/')


# import dataset and process the first time
soil <- read.csv2('merged_dataxa_26092025_process.csv', h = TRUE, sep = ';', stringsAsFactor = TRUE, na=c('', 'NA', 'na'))
#soil2 <- read.csv2('soil.csv', h = TRUE, sep = ',', stringsAsFactor = TRUE)

colnames(soil)
length(soil$observed_on_string)
soil$observed_on_string <- ymd_hms(soil$time_observed_at)

################################################################################
# use the safari func script
setwd('D:/GitHub/AI4SH')
source('safari_func.r')


# soil <- read.csv2('soil_lu.csv', h = TRUE, sep = ',', stringsAsFactor = FALSE)

soil$transect_id <- as.factor(soil$transect_id)
#soil <- getuser(soil)
soil <- gettaxa(soil)
soil<-gettransect(soil)

soil$sample_order <- NA
soil<-getorder(soil)

# work day time part process ----------------------------------------------------
soil$time <- as_hms(soil$observed_on_string)
soil$day <- day(soil$observed_on_string)
soil$month <- month(soil$observed_on_string)
soil$year <- year(soil$observed_on_string)

# convert to factor -------------------------------------------------------------
soil$day <- as.factor(soil$day)
soil$month <- as.factor(soil$month)
soil$year <- as.factor(soil$year)
soil$hour <- as.factor(soil$hour)


soil <- subset(soil, is.na(soil$transect_id)==FALSE)


# try plots ----------------------------------------------------------------------
boxplot(soil$time~soil$month) ## cool

#lets rewwork the DF

View(soil)

soil$ident_taxon_ids



################################################################################

# let's now process the number of individuals on time by user.

boxplot(soil$time~soil$observer)

# and remove outliers / non-macrofauna ------------------------------------------

soil <- subset(soil, soil$taxa != ('d_acari'))
soil <- subset(soil, soil$taxa != ('d_collembola'))


##################################################################################
# work with SAMPLE ORDER
soil <- soil %>%
  arrange(sample_order, observer, transect_id) %>%
  group_by(observer, transect_id) %>%
  mutate(obs_id=row_number()) %>%
  mutate(ord_taxa = sapply(1:n(), function(i) n_distinct(taxa[1:i])))


##################################################################################
#taxa as seen on inaturalist
soil <- soil %>%
  arrange(observed_on_string, observer, transect_id) %>%
  group_by(observer, transect_id) %>%
  mutate(obs_id = row_number()) %>%
  mutate(cum_taxa_true = sapply(1:n(), function(i) n_distinct(ident_taxon_ids[1:i])),
         cum_indiv = 1:n())




# plots :) ------------------------------------------------------------------------
library(ggplot2)

x11()
ggplot(soil, aes(x = sample_order, y = ord_taxa, color = observer, group = transect_id)) +
  geom_line(linewidth = 1.2) +
  facet_wrap(~ transect_id) +
  labs(
    title = "Courbe d'accumulation de la biodiversité",
    subtitle = "Taxa en fonction du nombre d'individus par jour et observateur",
    x = "Nombre cumulé d'individus observés",
    y = "Richesse spécifique (taxa uniques)") +
  theme_minimal()


#second plot
x11()
ggplot(soil, aes(x = time, y = ord_taxa, color = transect_id, group = transect_id)) +
  geom_line(linewidth = 1.2) +
  facet_wrap(~ observer) +
  labs(
    title = "Courbe d'accumulation de la biodiversité",
    subtitle = "Taxa en fonction du temps d'observation",
    x = "Nombre cumulé d'individus observés",
    y = "Richesse spécifique (taxa uniques)") +
  theme_minimal()










###################################################################################################
###################################################################################################
###################################################################################################
# RARE CURVE WITH VEGAN

# ON GSMF TAXA

# need to make a count of taxa per sample order and transect id for community matrix --------------
collector1 <- subset(soil, soil$observer=="Collector1")
commucoll1 <- table(collector1$transect_id, collector1$ord_taxa)
x11()
par(mfrow=c(1,3))
rarecurve(commucoll1, step=1, 
  xlab="Rarefaction curves, 2025 Finland LUKE team \n collector1 - Cropfields", ylim=c(1,10))

collector2 <- subset(soil, soil$observer=="Collector2")
commucoll2 <- table(collector2$transect_id, collector2$ord_taxa)
rarecurve(commucoll2, step=1, 
  xlab="Rarefaction curves, 2025 Finland LUKE team \n collector2 - Cropfields", ylim=c(1,10))

collector3 <- subset(soil, soil$observer=="Collector3")
commucoll3 <- table(collector3$transect_id, collector3$ord_taxa)
rarecurve(commucoll3, step=1, 
  xlab="Rarefaction curves, 2025 Finland LUKE team \n collector3 - Cropfields", ylim=c(1,10))




# need to make a count of taxa per transect id for community matrix --------------

soil$taxa <- as.factor(soil$taxa)
soil$transect_id <- as.factor(soil$transect_id)
soil$observer <- as.factor(soil$observer)

# community matrix per observer --------------------------------------------------

# Créer une variable combinée
soil$obs_transect <- paste(soil$observer, soil$transect_id, sep = "_")

# Table de contingence avec la variable combinée
obs_trans <- table(soil$obs_transect, soil$taxa)

# Metadata avec les informations séparées
metadata <- data.frame(
  "Site" = rownames(obs_trans),
  "observer" = sapply(strsplit(rownames(obs_trans), "_"), `[`, 1),
  "transect_id" = sapply(strsplit(rownames(obs_trans), "_"), `[`, 2)
)

# Courbes de raréfaction
plotobs <- rarecurve(obs_trans, step=2, tidy=TRUE,
                     xlab="Courbe d'accumulation de la diversité de taxas") %>%
  left_join(metadata, by = "Site")

# Graphique
ggplot(plotobs) +
  geom_line(aes(x = Sample, y = Species, group = Site, colour = observer)) +
  facet_wrap(~transect_id) +
  theme_bw() +
  labs(colour = "Observateur")


ggplot(plotobs) + 
  geom_line(aes(x = Sample, y = Species, group = Site, colour = transect_id)) +
  facet_wrap(~observer) +
  theme_bw()+
  labs(
    title = "Rarefaction curves from the 'Safari' sampling",
    subtitle = "1 plot per observer",
    x = "Number of invertebrates sampled",
    y = "Species Richness")






# same but with original taxas --------------------------------------------------

soil$taxon_id <- as.factor(soil$ident_taxon_ids)


obs_trans <- table(soil$obs_transect, soil$taxon_id)

# Metadata avec les informations séparées
metadata <- data.frame(
  "Site" = rownames(obs_trans),
  "observer" = sapply(strsplit(rownames(obs_trans), "_"), `[`, 1),
  "transect_id" = sapply(strsplit(rownames(obs_trans), "_"), `[`, 2)
)

# Courbes de raréfaction
plotobs2 <- rarecurve(obs_trans, step=2, tidy=TRUE,
                     xlab="Courbe d'accumulation de la diversité de taxas") %>%
  left_join(metadata, by = "Site")

#ggplot graph

x11()
ggplot(plotobs2) +
  geom_line(aes(x = Sample, y = Species, group = Site), colour="red") +
  geom_line(data = plotobs, aes(x = Sample, y = Species, group=Site))+

  facet_wrap(~transect_id) +
  theme_bw() +
  labs(
    title = "Rarefaction curves from the 'Safari' sampling",
    subtitle = "1 plot per observer",
    x = "Number of invertebrates sampled",
    y = "Species Richness")







##################################################################################
##################################################################################
# Rare curves depending on time

# we want curves with on X axis => the time in seconds since the first picture
# on the Y axis => the number of taxas found
# a different curve per transect

soil <- lapsed_time(soil)

# taxa as proposed on GSMF dataset
soil <- soil %>%
  arrange(observed_on_string, observer, transect_id) %>%
  group_by(observer, transect_id) %>%
  mutate(obs_id = row_number()) %>%
  mutate(cum_taxa = sapply(1:n(), function(i) n_distinct(taxa[1:i])),
         cum_indiv = 1:n())


setwd('D:/GitHub/AI4SH/')
write.csv(soil, 'soil_for_mod.csv')

soil_ord <- soil %>%
  arrange(transect_id, lapsed_time)



x11()
ggplot(soil_ord, aes(x = lapsed_time, y = cum_taxa, color = transect_id)) +
  geom_line(linewidth = 1.2) +
  facet_wrap(~ observer) +
  labs(
    title = "Courbe d'accumulation de la biodiversité",
    subtitle = "Taxa en fonction du nombre d'individus par jour et observateur",
    x = "Nombre cumulé d'individus observés",
    y = "Richesse spécifique (taxa uniques)") +
  theme_minimal()












##################################################################################
##################################################################################
##################################################################################
# Let's get interesting

#  work on ACP now : LIBS -----------------------------------------------------------
library(FactoMineR)
library(factoextra)
library(seriation)
library(clustertend)
library(cluster)

# working on FINLAND results only at first
# on transects ----------------------------------------------------------------------
FIN<-subset(soil, grepl("Helsinki", observed_time_zone, ignore.case = TRUE))

commFIN <- table(FIN$transect_id, FIN$taxa)

AFinC <- CA(commFIN)
summary(AFinC)

fviz_ca(AFinC, title="AFC on the community matrix of taxas per transect \n in Finland (LUKE team data)", 
col.col = "contrib", arrow = c(FALSE, TRUE))+
 scale_color_gradient2(low = "grey", mid = "orange", high = "red", midpoint = 25)


# On the whole dataset on a 2nd time -------------------------------------------------
AFC <- CA(commu) # on transects
summary(AFC)

# représentations -------------------------------------------------------------------
barplot(AFC$eig[,2])
transects <- plot(AFC, invisible='col', title='RP des transects')
taxa <- plot(AFC, invisible='row', title='RP des taxa')

x11()
fviz_ca(AFC, title="AFC on the community matrix of taxas per transect", 
col.col = "contrib", arrow = c(FALSE, TRUE))+
 scale_color_gradient2(low = "grey", mid = "orange", high = "red", midpoint = 25)

# on habitats ----------------------------------------------------------------------
x11()
AFC2 <- CA(veg) #on habitats
summary(AFC2)


# on observers ---------------------------------------------------------------------
x11()
AFCobs <- CA(obs)
summary(AFCobs)

barplot(AFCobs$eig[,2], title="Percentage of explanation of dimensions to variables")

x11()
fviz_ca(AFCobs, col.col = "contrib", title="AFC on the community matrix of taxas per observer",
  arrow = c(TRUE, FALSE))+
 scale_color_gradient2(low = "grey", mid = "orange", high = "red", midpoint = 25)


# distance matrixes -----------------------------------------------------------------
distobs <- dist(obs)
distveg <- dist(veg)
disttrans <- dist(commu)

x11()
dissplot(distveg)

x11()
dissplot(disttrans)


# ON INAT TAXA ---------------------------------------------------------------------
commu <- table(soil$transect_id, soil$ident_taxon_ids)

rarecurve(commu, step=1)

tab2025 <- subset(soil, soil$observer=='Alex')
commu2 <- table(tab2025$transect_id, tab2025$ident_taxon_ids)
rarecurve(commu2, step=1)
