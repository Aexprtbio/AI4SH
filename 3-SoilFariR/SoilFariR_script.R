# CREATED ON 09 MAY 2025
# PRÉTAT

# Last update : 11/02/2026

rm(list=ls())

# libraries --------------------------------------------------------------------------
library(ade4)
library(car)
library(dplyr)
library(ggplot2)
library(hms)
library(lubridate)
library(tidyr)
library(vegan)
library(wesanderson)

#  work on ACP now : LIBS -----------------------------------------------------------
library(FactoMineR)
library(factoextra)
library(seriation)
library(clustertend)
library(cluster)

# import functions from SoilFariR_functions.r ---------------------------------------
setwd('D:/GitHub/AI4SH/3-SoilFariR')
source('SoilFariR_functions.r')


# import up to date DataFrame -------------------------------------------------------
setwd('D:/GitHub/AI4SH/4-DataFrames_ready')

tsbf_rou <- read.csv2('L3EBO_macrofaune.csv', h=TRUE, stringsAsFactor=TRUE, na.strings=c('', 'na'))
tsbf_env <- read.csv2('L3EBO_environnement.csv', h=TRUE, stringsAsFactor=TRUE, dec='.')
tsbf_fin <- read.csv2('tsbf_finland2025.csv', h=TRUE, stringsAsFactor=TRUE, sep=';')
safa_esol <- read.csv2('ESOL-observations.csv', h=TRUE, stringsAsFactor=TRUE, sep=',')
soil <- read.csv2('uptodate_DataFrame.csv', h=TRUE, stringsAsFactor=TRUE, sep=';')

summary(tsbf_rou)
summary(tsbf_fin)
summary(soil)

soil <- gettaxa(soil)
soil <- milieu(soil)
soil <- gemethod(soil) 

soil <- subset(soil, is.na(soil$transect_id)==FALSE)
soil <- subset(soil, is.na(soil$taxa)==FALSE)

#soil$location<-as.character(soil$location)
#soil %>%
#  separate(soil, location,
#    sep=",", into=c("latitude", "longitude"))

tsbf_rou$vegetation="forest"

# TEMPORARY CONCATENATION OF DFS

temprou <- data.frame(tsbf_rou$groupe_tp, tsbf_rou$gsmf_taxa, tsbf_rou$vegetation, tsbf_rou$etudiant)
tempfin <- data.frame(tsbf_fin$Field_ID, tsbf_fin$gsmf_taxa, tsbf_fin$vegetation, tsbf_fin$observer)
tempsaf <- data.frame(soil$transect_id, soil$taxa, soil$vegetation, soil$observer)

temprou$method <- "TSBF"
tempfin$method <- "TSBF"
tempsaf$method <- "SAFARI"


colnames(temprou)<-c("ID", "taxa", "vegetation", "observer", "method")
colnames(tempfin)<-c("ID", "taxa", "vegetation", "observer","method")
colnames(tempsaf)<-c("ID", "taxa", "vegetation", "observer","method")

df_soil <- rbind(tempfin, temprou, tempsaf)


################################################################################
# try plots ----------------------------------------------------------------------
boxplot(soil$time~soil$month) ## cool
# let's now process the number of individuals on time by user.

boxplot(soil$time~soil$observer)


# Morphological diversity in TSBF Rouen
p <- ggplot(tsbf_rou, aes(y=gsmf_taxa, fill=gsmf_taxa))
p + geom_bar(stat="count")+
coord_polar("y", start=0)+
theme_minimal()

# Morphological diversity in TSBF Finlande
x11()
pf <- ggplot(tsbf_fin, aes(y=gsmf_taxa, fill=gsmf_taxa))
pf + geom_bar(stat="count")+
coord_polar("y", start=0)+
theme_minimal()


# Morphological diversity in Safari GLOBAL
x11()
ps <- ggplot(df_soil, aes(y=taxa, fill=taxa))
ps + geom_bar(stat="count")+
facet_wrap(~vegetation)+
theme_minimal()



# and remove outliers / non-macrofauna ------------------------------------------

#soil <- subset(soil, soil$taxa != ('d_acari'))
#soil <- subset(soil, soil$taxa != ('d_collembola'))



#diversity seenn with different methods
div <- ggplot(df_soil, aes(x=method, y=taxa, fill=taxa))
div + geom_col()+
  scale_fill_viridis_d()+
  facet_wrap(~vegetation)+
  theme(axis.text.y=element_blank())


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



###################################################################################################
###################################################################################################
###################################################################################################
# RARE CURVE WITH VEGAN
# ON GSMF TAXA

commtt <- table(df_soil$vegetation, df_soil$taxa)
plotobs <- rarecurve(commtt)


#
# need to make a count of taxa per sample order and transect id for community matrix --------------

# rarecurve TSBF finlande

commTSBfin <- table(tsbf_fin$Field_ID, tsbf_fin$gsmf_taxa)
x11()
par(mfrow=c(1,4))
rarecurve(commTSBfin, ylim=c(1,10))

# SOILFARI

collector1 <- subset(soil, soil$observer=="Collector1")
commucoll1 <- table(collector1$transect_id, collector1$taxa)

rarecurve(commucoll1, step=1, 
  xlab="Rarefaction curves, 2025 Finland LUKE team \n collector1 - Cropfields", ylim=c(1,10))

collector2 <- subset(soil, soil$observer=="Collector2")
commucoll2 <- table(collector2$transect_id, collector2$taxa)
rarecurve(commucoll2, step=1, 
  xlab="Rarefaction curves, 2025 Finland LUKE team \n collector2 - Cropfields", ylim=c(1,10))

collector3 <- subset(soil, soil$observer=="Collector3")
commucoll3 <- table(collector3$transect_id, collector3$taxa)
rarecurve(commucoll3, step=1, 
  xlab="Rarefaction curves, 2025 Finland LUKE team \n collector3 - Cropfields", ylim=c(1,10))


# Whole dataset - vegetation x taxa
commu <- table(soil$vegetation, soil$taxa)
rarecurve(commu, step=1)





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
#  geom_line(data = plotobs, aes(x = Sample, y = Species, group=Site))+

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

# retrieve species guess with SoilFariR function 'getspecies' -----------------------
soil <- getspecies(soil)

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
AFC <- CA(commu) # on vegetation
summary(AFC)

# représentations -------------------------------------------------------------------
barplot(AFC$eig[,2])
transects <- plot(AFC, invisible='col', title='RP des transects')
taxa <- plot(AFC, invisible='row', title='RP des taxa')

x11()
fviz_ca(AFC, title="AFC on the community matrix of taxas per vegetation type", 
col.col = "contrib", arrow = c(FALSE, FALSE))+
 scale_color_gradient2(low = "darkolivegreen2", mid = "indianred2", high = "red", midpoint = 25)


####################################################################################
# on habitats x inaturalist taxa --------------------------------------------------
incommu <- table(soil$vegetation, soil$species_guess)

AFCincomm <- CA(incommu)
summary(AFCincomm)



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






#############################################################
#############################################################
##
## GESTION DU JSON
library(stringr)

# Exemple de chaîne JSON concaténée
json_concatenated <- JASON

# Séparer les objets JSON en utilisant une expression régulière
json_objects <- unlist(str_split(json_concatenated, "(?<=\\])\\[(?=\\{)"))

# Nettoyer chaque objet JSON pour ajouter les crochets manquants si nécessaire
json_objects <- sapply(json_objects, function(x) {
  if (grepl("^\\[", x) && grepl("\\]$", x)) {
    return(x)
  } else if (grepl("^\\[", x)) {
    return(paste0(x, "]"))
  } else if (grepl("\\]$", x)) {
    return(paste0("[", x))
  } else {
    return(paste0("[", x, "]"))
  }
})


library(jsonlite)
library(purrr)

# Parser chaque objet JSON
parsed_objects <- map(json_objects, ~ {
  tryCatch(
    {
      fromJSON(.x)
    },
    error = function(e) {
      message("Erreur de parsing pour : ", substr(.x, 1, 100), "...")
      return(NULL)
    }
  )
})

# Filtrer les objets NULL (ceux qui n'ont pas pu être parsés)
parsed_objects <- parsed_objects[!sapply(parsed_objects, is.null)]
