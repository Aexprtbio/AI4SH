# CREATED 21/08/2025
# PRETAT A.

setwd('D:/GitHub/AI4SH')

soil <- read.csv('soil_for_mod.csv', h=TRUE, stringsAsFactor=TRUE)
summary(soil)



# PACKAGES

library(car)
library(dplyr)
library(emmeans)
library(ggplot2)
library(MASS)
library(multcomp)
library(MuMIn)
library(RVAideMemoire)
library(vegan)
library(glmmTMB)



# DATA TYPES

class(soil$cum_taxa)

soil_count <- soil %>%
   group_by(taxa, observer) %>%
   summarise(n=n())


# GRAPHIC DATA

p <- ggplot(soil, aes(x=observer, y=lapsed_time))
p+geom_violin()

bar <- ggplot(soil, aes(observer))
bar+geom_bar(aes(fill=taxa))


#######################################################################
#######################################################################
# MODELISATION WITH GSMF TAXA

set.seed(7)

formula <- ((cum_taxa) ~ ((lapsed_time)*observer))

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


EMM <- emmeans(mod1, ~observer, type="response")
cld(EMM, details=TRUE)

# predictions --------------------------------------------------------#

newdata <- as.data.frame(matrix(ncol=2, nrow=1000))
colnames(newdata) <- c('lapsed_time', 'observer')

newdata$lapsed_time <- floor(runif(1000, min=0, max=3800))
newdata$observer <- rep(c('Alex','Jerome', 'Collector1', 'Collector2', 'Collector3'), times=200)


newdata$predictions<-predict(mod1, newdata=newdata, type='response')

x11()
p <- ggplot(newdata, aes(x = lapsed_time, y = predictions, color=observer))
p + geom_line(linewidth = 1) +
scale_y_continuous(breaks=seq(1, 20, 1), labels=seq(1, 20, 1)) +
geom_vline(xintercept=3600)






#######################################################################
#######################################################################
# MODELISATION WITH INATURALIST TAXA

formulat <- ((cum_taxa_true) ~ ((lapsed_time)*observer))

mod2 <- glm(formulat, data=soil, family=poisson(link="sqrt"))

#----------------------------------------------------------------------#

summary(mod2)

# AIC: 2592.3 


# Graphics -----------------------------------------------------------#
plotresid(mod2)




######################################################################
# Analysis

Anova(mod2)


# predictions --------------------------------------------------------#

newdata$predictionsT<-predict(mod2, newdata=newdata, type='response')


x11()
p <- ggplot(newdata, aes(x = lapsed_time, y = predictionsT, color=observer))
p + geom_line(linewidth = 1) +
scale_y_continuous(breaks=seq(1, 50, 5), labels=seq(1, 50, 5)) +
geom_vline(xintercept=3600)
