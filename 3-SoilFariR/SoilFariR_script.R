# CREATED ON 09 MAY 2025
# PRÉTAT

# Last update : 24/02/2026

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

tsbf_rou <- read.csv2('L3EBO_macrofaune.csv', h=TRUE, stringsAsFactor=TRUE, na.strings=c('', 'na'))
tsbf_env <- read.csv2('L3EBO_environnement.csv', h=TRUE, stringsAsFactor=TRUE, dec='.')
tsbf_fin <- read.csv2('tsbf_finland2025.csv', h=TRUE, stringsAsFactor=TRUE, na.strings=c('', 'na'))

safa_esol <- read.csv2('ESOL-observations.csv', h=TRUE, stringsAsFactor=TRUE, na.strings=c('', 'na'))  # observations des étudiant.es
safa_fin <-read.csv2('finland_2025_safari.csv', h=TRUE, stringsAsFactor=, na.strings=c('', 'na'))  # observations de Finlande
soil <- read.csv2('uptodate_DataFrame.csv', h=TRUE, stringsAsFactor=TRUE, na.strings=c('', 'na')) # mine

summary(tsbf_rou)
summary(tsbf_fin)
summary(soil)
summary(safa_esol)
summary(safa_fin)


#####################################################################################
#####################################################################################
# processing safa_esol to make it corresponds w soil --------------------------------
safa_esol <- gettaxa(safa_esol)
safa_esol <- milieu(safa_esol)
safa_esol$vegetation="forest"
safa_esol <- getmethod(safa_esol) 

location<-data.frame(safa_esol$location)
latlong <- location %>%
  separate(safa_esol.location,
    sep=",", into=c("latitude", "longitude"), remove=TRUE)
safa_esol$latitude <- latlong$latitude
safa_esol$longitude <- latlong$longitude

safa_esol <- subset(safa_esol, is.na(safa_esol$place_ids)!=TRUE)

# processing safa_fin to make it corresponds w soil --------------------------------
safa_fin <- gettaxa(safa_fin)
safa_fin <- milieu(safa_fin)
safa_fin <- getmethod(safa_fin) 

location<-data.frame(safa_fin$location)
latlong <- location %>%
  separate(safa_fin.location,
    sep=",", into=c("latitude", "longitude"), remove=TRUE)
safa_fin$latitude <- latlong$latitude
safa_fin$longitude <- latlong$longitude


# processing soil df to be sure -----------------------------------------------------
soil <- gettaxa(soil)
soil <- milieu(soil)
soil <- getmethod(soil) 
#soil <- subset(soil, is.na(soil$transect_id)==FALSE)
soil <- subset(soil, is.na(soil$taxa)==FALSE)

location<-data.frame(soil$location)
latlong <- location %>%
  separate(soil.location,
    sep=",", into=c("latitude", "longitude"), remove=TRUE)
soil$latitude <- latlong$latitude
soil$longitude <- latlong$longitude


a <- names(soil)
b <- names(safa_esol)
c <- names(safa_fin)
setdiff(b, a)
setdiff(b, c)

safari <- rbind(soil, safa_fin)

safari$time_observed_at <- as.character(safari$time_observed_at)
safari$observed_on_lub <- dmy(safari$observed_on)
safari$day <- day(safari$observed_on_lub)
safari$month <- month(safari$observed_on_lub)
safari$year <- year(safari$observed_on_lub)

safari <- getuser(safari)
safari <- gettransect(safari)

safari$month <- as.factor(safari$month)
safari$year <- as.factor(safari$year)
safari$transect_id <- as.factor(safari$transect_id)
safari$taxa <- as.factor(safari$taxa)
safari$observer <- as.factor(safari$observer)
safari$saf_method <- as.factor(safari$saf_method)

safari <- subset(safari, is.na(safari$taxa)!=TRUE)
safari <- subset(safari, is.na(safari$observer)!=TRUE)
safari$latitude <- as.numeric(safari$latitude)
safari$longitude <- as.numeric(safari$longitude)
summary(safari)


write.csv(safari, 'safari_all_projects_dataframe.csv')


tsbf_rou$vegetation="forest"

# TEMPORARY CONCATENATION OF DFS ------------------------------------------------------

temprou <- data.frame(tsbf_rou$groupe_tp, tsbf_rou$gsmf_taxa, tsbf_rou$vegetation, tsbf_rou$etudiant)
tempfin <- data.frame(tsbf_fin$Field_ID, tsbf_fin$gsmf_taxa, tsbf_fin$vegetation, tsbf_fin$observer)
tempsaf <- data.frame(safari$transect_id, safari$taxa, safari$vegetation, safari$observer)
tempesol <- data.frame(safa_esol$transect_id, safa_esol$taxa, safa_esol$vegetation, safa_esol$observer)

temprou$method <- "TSBF"
tempfin$method <- "TSBF"
tempsaf$method <- "SAFARI"
tempesol$method <- "SAFARI"

colnames(temprou)<-c("ID", "taxa", "vegetation", "observer", "method")
colnames(tempfin)<-c("ID", "taxa", "vegetation", "observer","method")
colnames(tempsaf)<-c("ID", "taxa", "vegetation", "observer","method")
colnames(tempesol)<-c("ID", "taxa", "vegetation", "observer","method")

df_soil <- rbind(tempfin, temprou, tempsaf, tempesol)


################################################################################
################################################################################
# try plots ----------------------------------------------------------------------
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


#diversity seenn with different methods
div <- ggplot(df_soil, aes(x=vegetation, y=taxa, fill=taxa))
div + geom_col()+
  scale_fill_viridis_d()+
  facet_wrap(~method)+
  theme(axis.text.y=element_blank())


# and remove outliers / non-macrofauna ------------------------------------------

#soil <- subset(soil, soil$taxa != ('d_acari'))
#soil <- subset(soil, soil$taxa != ('d_collembola'))




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

# ON GSMF TAXA -----------------------------------------------------------------------------------

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


# Whole dataset - method x taxa -----------------------------------------------------------------
commu <- table(safari$saf_method, safari$taxa)
rarecurve(commu, step=1)


# need to make a count of taxa per transect id for community matrix --------------

safari$taxa <- as.factor(safari$taxa)
safari$transect_id <- as.factor(safari$transect_id)
safari$observer <- as.factor(safari$observer)


# community matrix per observer --------------------------------------------------

# Créer une variable combinée
safari$obs_transect <- paste(safari$observer, safari$transect_id, sep = "_")

# Table de contingence avec la variable combinée
safcon <- table(safari$obs_transect, safari$taxa)


# Working with vegan::decostand --------------------------------------------------
safcon.hell <- decostand(safcon, method='hellinger')



# Metadata avec les informations séparées
metadata <- data.frame(
  "Site" = rownames(safcon),
  "observer" = sapply(strsplit(rownames(safcon), "_"), `[`, 1),
  "transect_id" = sapply(strsplit(rownames(safcon), "_"), `[`, 2)
)

# Courbes de raréfaction
plotobs <- rarecurve(safcon.hell, step=2, tidy=TRUE,
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

safari$taxon_id <- as.factor(safari$ident_taxon_ids)


obs_trans <- table(safari$obs_transect, safari$taxon_id)

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
# Let's get interesting : MULTIVARIATE ANALYSIS
# Table de contingence avec la variable combinée
safcon <- table(safari$obs_transect, safari$taxa)


# Working with vegan::decostand --------------------------------------------------
safcon.hell <- decostand(safcon, method='hellinger') # transformation

safcon.hell <- scale(safcon.hell) # centrer / réduire values



# firs look at quantitative variables we may be interested in :
df_soil$method <- as.factor(df_soil$method)

df_soil <- droplevels(df_soil)
summary(df_soil)


# Multiple Correspondance Analysis on simplified df -------------------------------

ACM <- dudi.acm(df_soil, scannf=FALSE, nf=10)

MVA.synt(ACM)  # percentages
MVA.plot(ACM, byfac=TRUE, fac=df_soil$vegetation) # graphs








# Mixed Analysis with SAFARI sampling and quantitative data -----------------------

safari <- droplevels(safari)

Amix <- dudi.mix(safari, scannf=FALSE, nf=10)


























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
