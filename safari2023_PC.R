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

# work day time part process
soil$time <- as_hms(soil$observed_on_string)
soil$hour <- hour(soil$time)
soil$day <- day(soil$observed_on_string)
soil$month <- month(soil$observed_on_string)
soil$year <- year(soil$observed_on_string)

# convert to factor
soil$day <- as.factor(soil$day)
soil$month <- as.factor(soil$month)
soil$year <- as.factor(soil$year)
soil$hour <- as.factor(soil$hour


# try plots
boxplot(soil$time~soil$month) ## cool

#lets rewwork the DF

View(soil)

soil$ident_taxon_ids



################################################################################

# let's now process the number of individuals on time by user.

boxplot(soil$time~soil$observer)



##################################################################################
# okay let's build a loop
soil$milieux<-NA
for (i in 1:length(soil$description)) {
    if (grepl("meadow", soil$description[i], ignore.case = TRUE)) {
      soil$milieux[i] <- "meadow"
    } else if (grepl("forest", soil$description[i], ignore.case = TRUE)) {
      soil$milieux[i] <- "forest"
    }
  }

##################################################################################
#taxa as seen on inaturalist
soil <- soil %>%
  arrange(observed_on_string, observer, milieux, transect_id) %>%
  group_by(observer, hour, milieux) %>%
  mutate(obs_id = row_number()) %>%
  mutate(cum_taxa_true = sapply(1:n(), function(i) n_distinct(ident_taxon_ids[1:i])),
         cum_indiv = 1:n())

# taxa as proposed on GSMF dataset
soil <- soil %>%
  arrange(observed_on_string, observer, milieux, transect_id) %>%
  group_by(observer, hour, milieux) %>%
  mutate(obs_id = row_number()) %>%
  mutate(cum_taxa = sapply(1:n(), function(i) n_distinct(taxa[1:i])),
         cum_indiv = 1:n())


# plots :)
library(ggplot2)

ggplot(soil, aes(x = cum_indiv, y = cum_taxa, color = milieux, group = description)) +
  geom_line(linewidth = 1.2) +
  facet_wrap(~ transect_id) +
  labs(
    title = "Courbe d'accumulation de la biodiversité",
    subtitle = "Taxa en fonction du nombre d'individus par jour et observateur",
    x = "Nombre cumulé d'individus observés",
    y = "Richesse spécifique (taxa uniques)") +
  theme_minimal()


#second plot
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

data <- as.data.frame(soil[,c(71,82)])

commu<-data %>% 
pivot_longer(cols = c(transect_id, taxa),
  names_to='transect_id',
  taxas_to='taxa')


rarecurve(data, step=1)
min(rowSums(data))
##################################################################################
# TEST PIVOT LONGER to have taxa and number cum

library(tidyr)

soil_long <- soil %>%
  pivot_longer(cols = c(cum_indiv, cum_taxa),
               names_to = "type",
               taxas_to = "cumulative_count")

soil_long$type <- as.factor(soil_long$type)



library(ggplot2)

ggplot(soil_long, aes(x = time, y = cumulative_count, color = transect_id, group = transect_id)) +
  geom_line() +
  facet_wrap(~ observer) +
  labs(
    title = "Accumulation of biodiversity",
    subtitle = "Number of found individuals per taxa over time",
    x = "Heure",
    y = "Valeur cumulée",
    color = "Day of sessions",
    linetype = "Type de mesure"
  ) +
  theme_minimal()


##################################################################################
# Let's get interesting

#  vegan package example
data(BCI)
SAC <- specaccum(BCI, "random")
plot(SAC, ci.type = "poly", lwd = 2, ci.lty = 0, ci.col = "lightgray")





