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

setwd('/Users/alexpretat/Documents')

# import dataset and process the first time

soil <- read.csv2('soil.csv', h = TRUE, sep = ',', stringsAsFactor = TRUE)
laur <- read.csv2('alex.csv', h=TRUE, sep = ',', stringsAsFactor =TRUE)

colnames(laur)
colnames(soil)

soil$observed_on_string <- ymd_hms(soil$time_observed_at)
laur$observed_on_string<-ymd_hms(laur$time_observed_at)
soil <- rbind(soil, laur)


soil1 <- subset(soil, grepl('^2023-04', time_observed_at))
soil2 <- subset(soil, grepl('^2025-05', time_observed_at))

#soil <- rbind(soil1, soil2)

write.csv2(soil, '/Users/alexpretat/Documents/soilsforqgis.csv')



################################################################################
# Now import the version with CORINE LC

setwd('/Users/alexpretat/AI4SH')
source('safari_func.r')

# soil <- read.csv2('soil_lu.csv', h = TRUE, sep = ',', stringsAsFactor = FALSE)

soil <- getuser(soil)
soil <- getday(soil)

soil$session<-as.factor(soil$session)
soil$time <- as_hms(soil$observed_on_string)
soil$hour <- hour(soil$time)
soil$hour <- as.factor(soil$hour)
# try out some plots

plot(soil$time~soil$observed_on_string) ## cool


################################################################################

# let's now process the number of individuals on time by user.
class(soil$user)


boxplot(soil$time~soil$observer)

day1 <- subset(soil, soil$day=='day1')
day1 <- day1[order(day1$time),]

day2 <- subset(soil, soil$day=='day2')
day2 <- day2[order(day2$time),]

day3 <- subset(soil, soil$day=='day3')
day3 <- day3[order(day3$time),]


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

soil <- soil %>%
  arrange(observed_on_string, day, observer, milieux) %>%
  group_by(observer, day, hour, milieux) %>%
  mutate(obs_id = row_number()) %>%
  mutate(cum_taxa = sapply(1:n(), function(i) n_distinct(ident_taxon_ids[1:i])),
         cum_indiv = 1:n())



library(ggplot2)

ggplot(soil, aes(x = time, y = cum_indiv, color = observer)) +
  geom_line(linewidth = 1.2) +
  facet_wrap(~ milieux) +
  labs(
    title = "Courbe d'accumulation de la biodiversité",
    subtitle = "Taxa en fonction du nombre d'individus par jour et observateur",
    x = "Nombre cumulé d'individus observés",
    y = "Richesse spécifique (taxa uniques)") +
  theme_minimal()


##################################################################################
# TEST PIVOT LONGER to have taxa and number cum

library(tidyr)

soil_long <- soil %>%
  pivot_longer(cols = c(cum_indiv, cum_taxa),
               names_to = "type",
               values_to = "cumulative_count")

soil_long$type <- as.factor(soil_long$type)



library(ggplot2)

ggplot(soil_long, aes(x = time, y = cumulative_count, color = observer, group = type)) +
  geom_point(size = 1, aes(shape=type)) +
  facet_wrap(~ day) +
  labs(
    title = "Accumulation de la biodiversité",
    subtitle = "Comparaison entre nombre d'individus et richesse taxonomique",
    x = "Heure",
    y = "Valeur cumulée",
    color = "Observateur",
    linetype = "Type de mesure"
  ) +
  theme_minimal()


##################################################################################
# Let's get interesting

#  vegan package example
data(BCI)
SAC <- specaccum(BCI, "random")
plot(SAC, ci.type = "poly", lwd = 2, ci.lty = 0, ci.col = "lightgray")





