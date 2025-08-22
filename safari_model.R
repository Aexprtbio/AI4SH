# CREATED 21/08/2025
# PRETAT A.

setwd('D:/GitHub/AI4SH')

soil <- read.csv('soil_for_mod.csv', h=TRUE, stringsAsFactor=TRUE)
summary(soil)



# PACKAGES

library(car)
library(ggplot2)
library(MASS)
library(MuMIn)
library(RVAideMemoire)
library(vegan)
library(glmmTMB)



# DATA TYPES

class(soil$cum_taxa)

# GRAPHIC DATA

p <- ggplot(soil, aes(x=observer, y=lapsed_time))
p+geom_violin()

#######################################################################
#######################################################################
# MODELISATION

set.seed(7)

formula <- ((cum_taxa) ~ (lapsed_time*observer))

mod1 <- glm(formula, data=soil, family=poisson(link="sqrt"))


#---------------------------------------------------------------------#
summary(mod1) 										

# AIC: 2031.5


# Graphics -----------------------------------------------------------#
plotresid(mod1)




######################################################################
# Analysis

Anova(mod1)

r.squaredGLMM(mod1)


# predictions --------------------------------------------------------#

newdata <- as.data.frame(matrix(ncol=2, nrow=1000))
colnames(newdata) <- c('lapsed_time', 'observer')

newdata$lapsed_time <- floor(runif(1000, min=0, max=3600))
newdata$observer <- rep(c('Alex','Jerome', 'Collector1', 'Collector2', 'Collector3'), times=200)


newdata$predictions<-predict(mod1, newdata=newdata, type='response')

p <- ggplot(newdata, aes(x = lapsed_time, y = predictions, color=observer))
p + geom_line(linewidth = 1.1)