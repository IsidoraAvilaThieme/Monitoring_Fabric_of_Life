library(tidyr)
library(tidyverse)

# Data uploading

change_Fmax <- read.csv('change_Fmax.csv', header=T)                 # Fmax output
change_Pja <- read.csv('change_Pja.csv', header=T)                   # Pja output
change_ralgae <- read.csv('change_ralgae.csv', header=T)             # r_i output
change_rmodificator <- read.csv('change_rmodificator.csv', header=T) # r modificator output

########## Plot F_max #####################

ggplot(change_Fmax, aes(y=sp, x= value_Fmax, fill=qual_change))+
  geom_tile()+
  geom_vline(xintercept = c(0.009), linetype='dashed')+ #parameter = 0.009
  geom_vline(xintercept = c(0.0025, 0.0075, 0.01), linetype='dashed', colour='lightgray')+ #  0.001,0.003, 0.006, 0.01
  theme_minimal()+
  scale_x_continuous(breaks = c(0,0.0025,0.005, 0.0075,0.01))+
  #scale_y_discrete(expand = c(0, 0))+
  scale_fill_manual(values=c('black', '#56B4E9', 'white'))+
  labs(y='Species', x= bquote(F['max']), fill='Change')+
  theme(axis.title  = element_text(size=20),
        axis.text.x = element_text(size=18),
        axis.text.y = element_text(size = 18),
        legend.position = 'none')

######### PLot P_j->a    ########################

ggplot(filter(change_Pja, qual_change %in% c('Decrease', 'Increase', 'Less than 5% change')), aes(y=sp, x= value_Pja, fill=qual_change))+
  geom_tile()+
  theme_minimal()+
  scale_x_continuous(breaks=c(0, 0.1, 0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9, 1), limits = c(0,1))+
  geom_vline(xintercept = c(0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9), linetype='dashed', colour='lightgray')+
  geom_vline(xintercept = c(0.1), linetype='dashed', colour='black')+ # parameter value for simulation in paper
  scale_fill_manual(values=c('black', '#56B4E9', 'white'))+
  labs(y='Species', x= bquote(P['J-a']), fill='Change')+
  theme(axis.title  = element_text(size=20),
        axis.text.x = element_text(size=18),
        axis.text.y = element_text(size = 18),
        legend.position = 'none')

######## Plot r_i ####################### 

ggplot(filter(change_ralgae, qual_change %in% c('Decrease', 'Increase', 'Less than 5% change')), aes(y=sp, x= value_ralgae, fill=qual_change))+
  geom_tile()+
  theme_minimal()+
  geom_vline(xintercept = c(0.01,0.02,0.03,0.04), linetype='dashed', colour='lightgray')+
  geom_vline(xintercept = c(0.0180), linetype='dashed', colour='black')+ # parameter value for simulation in paper
  scale_fill_manual(values=c('black', '#56B4E9', 'white'))+
  labs(y='Species', x= bquote(r['i']), fill='Change')+
  theme(axis.title  = element_text(size=20),
        axis.text.x = element_text(size=18),
        axis.text.y = element_text(size = 18),
        legend.position = 'none')

########### Plot r modificator ################

ggplot(filter(change_rmodificator, qual_change %in% c('Decrease', 'Increase', 'Less than 5% change') &
                value_rmodificator < 0.01), 
       aes(y=sp, x= value_rmodificator, fill=qual_change))+
  geom_tile()+
  theme_minimal()+
  #scale_x_continuous(breaks=c(0,0.01, 0.02, 0.03,0.04, 0.05, 0.06))+
  geom_vline(xintercept = c(0,0.0025, 0.0050, 0.0075, 0.01), linetype='dashed', colour='lightgray')+
  geom_vline(xintercept = c(0.001), linetype='dashed', colour='black')+ # parameter value for simulation in paper
  scale_fill_manual(values=c('black', '#56B4E9', 'white'))+
  labs(y='Species', x= bquote(r['modificator']), fill='Change')+
  theme(axis.title  = element_text(size=20),
        axis.text.x = element_text(size=18),
        axis.text.y = element_text(size = 18),
        legend.position = 'none')
