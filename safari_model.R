# CREATED 21/08/2025
# PRETAT A.

setwd('D:/GitHub/AI4SH')

soil <- read.csv('soil_for_mod.csv', h=TRUE)
summary(soil)



# PACKAGES

library(vegan)
library(glmmTMB)



# DATA TYPES

class(soil$cum_taxa)

#######################################################################
#######################################################################
# MODELISATION

formula <- (cum_taxa ~ lapsed_time + month + transect_id)

mod1 <- glmmTMB(formula, data=soil)