# CREATED ON 09 MAY 2025
# PRÉTAT

rm(list=ls())

library(ade4)
library(car)
library(dplyr)
library(hms)
library(lubridate)
library(tidyr)
library(vegan)

setwd('D:/GitHub/POLLSOL-AIFSH/AIFSH/4-SAFARI-method/')

# import dataset and process the first time

soil <- read.csv2('merged_dataxa.csv', h = TRUE, sep = ';', stringsAsFactor = TRUE, na=c('', 'NA', 'na'))
#soil2 <- read.csv2('soil.csv', h = TRUE, sep = ',', stringsAsFactor = TRUE)

colnames(soil)
length(soil$observed_on_string)
soil$observed_on_string <- ymd_hms(soil$time_observed_at)

################################################################################
# use the safari func script

setwd('D:/GitHub/AI4SH')
source('safari_func.r')


# soil <- read.csv2('soil_lu.csv', h = TRUE, sep = ',', stringsAsFactor = FALSE)
soil <- subset(soil, is.na(soil$transect_id)==FALSE)
soil <- getuser(soil)
#soil <- getday(soil)
soil <- gettaxa(soil)

# work day time part process ----------------------------------------------------
soil$time <- as_hms(soil$observed_on_string)
soil$hour <- hour(soil$time)
soil$day <- day(soil$observed_on_string)
soil$month <- month(soil$observed_on_string)
soil$year <- year(soil$observed_on_string)

# convert to factor -------------------------------------------------------------
soil$day <- as.factor(soil$day)
soil$month <- as.factor(soil$month)
soil$year <- as.factor(soil$year)
soil$hour <- as.factor(soil$hour


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
# okay let's build a loop
soil$milieux<-NA
for (i in 1:length(soil$description)) {
    if (grepl("meadow", soil$description[i], ignore.case = TRUE)) {
      soil$milieux[i] <- "meadow"
    } else if (grepl("forest", soil$description[i], ignore.case = TRUE)) {
      soil$milieux[i] <- "forest"
    }
    else {
      soil$milieux[i] <- "forest"
    }
  }

##################################################################################
#taxa as seen on inaturalist
soil <- soil %>%
  arrange(observed_on_string, observer, milieux, transect_id) %>%
  group_by(observer, hour, milieux, transect_id) %>%
  mutate(obs_id = row_number()) %>%
  mutate(cum_taxa_true = sapply(1:n(), function(i) n_distinct(ident_taxon_ids[1:i])),
         cum_indiv = 1:n())

# taxa as proposed on GSMF dataset
soil <- soil %>%
  arrange(observed_on_string, observer, milieux, transect_id) %>%
  group_by(observer, hour, milieux, transect_id) %>%
  mutate(obs_id = row_number()) %>%
  mutate(cum_taxa = sapply(1:n(), function(i) n_distinct(taxa[1:i])),
         cum_indiv = 1:n())


# plots :) ------------------------------------------------------------------------
library(ggplot2)

x11()
ggplot(soil, aes(x = cum_indiv, y = cum_taxa, color = observer, group = description)) +
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
ggplot(soil, aes(x = time, y = cum_taxa, color = milieux, group = transect_id)) +
  geom_line(linewidth = 1.2) +
  facet_wrap(~ observer) +
  labs(
    title = "Courbe d'accumulation de la biodiversité",
    subtitle = "Taxa en fonction du temps d'observation",
    x = "Nombre cumulé d'individus observés",
    y = "Richesse spécifique (taxa uniques)") +
  theme_minimal()


##################################################################################
# RARE CURVE WITH VEGAN

# ON GSMF TAXA
# need to make a count of taxa per transect id for community matrix --------------

commu <- table(soil$transect_id, soil$taxa)
x11()
rarecurve(commu, step=1, 
  xlab="Courbe d'accumulation de la diversité de taxas par transects")

# community matrix per observer --------------------------------------------------
obs <- table(soil$observer, soil$taxa)
x11()
rarecurve(obs, step=1,
  xlab="Courbe d'accumulation, diversité de taxas par observateur")


# rarecurve per habitat, Alex observations --------------------------------------- 
tab2025 <- subset(soil, soil$observer=='Alex')
veg <- table(tab2025$milieux, tab2025$taxa)
x11()
rarecurve(veg, step=1,
  xlab="Courbe d'accumulation, diversité de taxas par milieux")

##################################################################################
# Let's get interesting

#  work on ACP now : LIBS -----------------------------------------------------------
library(FactoMineR)
library(factoextra)
library(seriation)
library(clustertend)
library(cluster)

# on transects ----------------------------------------------------------------------
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
