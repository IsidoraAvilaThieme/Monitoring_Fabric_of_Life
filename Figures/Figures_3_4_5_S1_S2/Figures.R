# This is the R code for plotting the figures 3, 4, 5, S1 and S2

library(tidyverse)


Data = read.csv('paper_data.csv', header=T) # reading data

############ Plots for the paper ################

scenario.labs2 <- c("Compliance", "Non Compliance")
names(scenario.labs2) <- c("Compliance", "No_compliance_S2")

# Fig. 3. Number of species per trophic group that decreases (black bars), 
# increases (blue bars) or exhibited less than 5% change (grey bars) under 
# a) the scenario of Lessonia harvesting complying with fishing regulations, or
# b) not complying with regulation 4 (Table 1)

spp = Data %>% group_by(scenarios, TL,change) %>% summarize(n=n())

spp$TL = factor(spp$TL, levels=c('Top', 'Predator', 'Omnivore', 'Herbivore', 
                                   'Filterfeeder', 'Producer'))

ggplot(filter(spp, scenarios %in% c('Compliance', 'No_compliance_S2')), aes(x=TL, y=n,label=n, fill=change))+
  geom_col(position = position_dodge2(width = 0.9, preserve = "single"), col="black", ) +
  scale_fill_manual(values=c('black', '#56B4E9', 'darkgray'))+
  facet_grid(.~scenarios,labeller = labeller(scenarios=scenario.labs2))+
  labs(y='Number of species', x= 'Functional group', fill='Change')+
  scale_y_continuous(limits=c(0,26), breaks=c(0,5,10,15,20,25))+
  geom_text(position = position_dodge2(width = 0.9, preserve = "single"),vjust=-1)+
  theme_bw()+
  theme(
    #panel.grid.major  = element_blank(),
    #    panel.grid.minor  = element_blank(),
    legend.position   = c(0.85,0.85),
    axis.title        = element_blank(),
    legend.title      = element_text(size=15),
    legend.title.align = 0.5,
    legend.background = element_rect(colour ='grey'),
    legend.text       = element_text(size=15), 
    axis.text.y       = element_text(size=15),
    axis.text.x       = element_text(size=12.5, angle = 20, vjust = 0.8, hjust = 0.7),
    strip.background  = element_rect(fill = 'white'),
    strip.text        = element_text(size=18))

# Fig. 4. Changes in abundance of the rocky shore functional groups, 
# expressed as the change in biomass with respect to the unfished scenario 
# (no harvesting of Lessonia kelps). a) Effects of fishing under the scenario 
# of compliance to fishing regulations and b) under non-compliance with 
# regulation 4 (see Table 1).

spp2= Data %>% group_by(scenarios, TL,change) %>% summarize(mean=mean(abs_proportion))

spp2_v2 = spp2 %>% pivot_wider( names_from = change,
                                values_from = mean) %>% replace_na(list(Increase=0, Decrease=0)) 

spp2_v2$TL = factor(spp2_v2$TL, levels=c('Top', 'Predator', 'Omnivore', 'Herbivore', 
                                 'Filterfeeder', 'Producer'))

ggplot(filter(spp2_v2, scenarios %in% c('Compliance','No_compliance_S2')), aes(x=TL))+
  geom_bar(aes(y=Increase), width=0.36,col='black', fill='#56B4E9',stat='identity', 
           position = position_nudge(x=-0.2))+
  geom_bar(aes(y=(Decrease*2)), width=0.36,col='black', fill='black',stat='identity', 
           position = position_nudge(x=0.2))+
  facet_grid(.~scenarios,labeller = labeller(scenarios=scenario.labs2))+
  scale_y_continuous(limits = c(0,200),name = 'Increase',sec.axis = sec_axis(~.*0.5, name='Decrease', breaks = c(0,25,50,75,100)))+
  theme_bw()+
  theme(
    #panel.grid.major  = element_blank(),
    panel.grid.minor  = element_blank(),
    legend.position   = 'none',
    axis.title        = element_blank(),
    legend.title      = element_text(size=15),
    legend.title.align = 0.5,
    legend.background = element_rect(colour ='grey'),
    legend.text       = element_text(size=15), 
    axis.text.y       = element_text(size=15),
    axis.text.x       = element_text(size=12.5,angle = 20, vjust = 0.8, hjust = 0.7),
    strip.background  = element_rect(fill = 'white'),
    strip.text        = element_text(size=18))

# Fig. 5. Summary of ATN simulations showing the changes in the species 
# abundances a) after harvesting Lessonia spicata following all fishing  
# recommendations and b) after failing to comply with regulation number 4 from 
# Table 1. Changes in species abundances (diameters and point colors) are given 
# relative to a scenario without any fishing.

ggplot(filter(Data, scenarios %in% c("Compliance", "No_compliance_S2")), aes(x=log10(BodyMass), 
                                                                             y=log10(binit/BodyMass),
                                                                             size=abs_proportion, 
                                                                             #shape=change, 
                                                                             fill=change,label=label))+ 
  geom_point(shape =21,col="black", alpha=0.8, stroke=0.7)+
  #scale_y_continuous(limits=c(-4.5,4.5),
  #                   breaks=c(-4,-2,0,2,4))+
  guides(fill = guide_legend(override.aes = list(size=4)))+
  scale_fill_manual(values=c('black', '#56B4E9', 'darkgray'))+
  scale_x_continuous(limits=c(-3,3))+
  #scale_shape_manual(values=c(25,24,4))+
  scale_size_continuous(range=c(2,10), 
                        breaks=c(5,10,20,50,80,100,150,200),
                        limits=c(0,200))+
  #geom_text(vjust=-1, size=3, data=filter(Data, scenarios %in% c("Compliance", "No_compliance_S2"),
  #                        change %in% c("Increase") & CodeMatrix >40))+
  facet_wrap(vars(scenarios), labeller = labeller(scenarios=scenario.labs2))+
  #labs(x=)+
  theme_bw()+
  xlab(bquote("Log"[10]~"(Body Mass)"))+
  ylab(bquote("Log"[10]~"(Population density)"))+
  theme(
        #legend.title = element_blank(),
        #legend.position = 'none',
        legend.text = element_text(size=15),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank(),
        strip.background = element_rect(fill="white"),
        strip.text       = element_text(size=18),
        axis.title       = element_text(size=17),
        #axis.title       = element_blank(),
        axis.text        = element_text(size=15))

# Fig. S1. Changes in abundance of adult and juvenile Lessonia spicata 
# biomass with respect to the no harvesting (unfished) scenario when 
# a) harvesting under the scenario of compliance to fishing regulations, 
# and b) under non-compliance with regulation 4 (see Table 1).

less_data = Data %>% 
  filter(label %in% c('lessonia nigrescens j','lessonia nigrescens a')) %>% 
  select(label,scenarios, change, abs_proportion) %>% 
  pivot_wider( names_from = change, values_from = abs_proportion) %>% replace_na(list(Increase=0, Decrease=0))

less_data$label = factor(less_data$label, levels=c('lessonia nigrescens j', 'lessonia nigrescens a'))

ggplot(filter(less_data, scenarios %in% c('Compliance', 'No_compliance_S2')), aes(x=label), fill=chage)+
  geom_bar(aes(y=Increase), width=0.36,col='black', fill='#56B4E9',stat='identity', 
           position = position_nudge(x=-0.2))+
  geom_bar(aes(y=(Decrease*2)), width=0.36,col='black', fill='black',stat='identity', 
           position = position_nudge(x=0.2))+
  scale_x_discrete(labels=c('lessonia nigrescens a'='Adult','lessonia nigrescens j'='Juvenile'))+
  scale_y_continuous(limits = c(0,200),name = 'Increase',sec.axis = sec_axis(~.*0.5, name='Decrease', breaks = c(0,25,50,75,100)))+
  theme_bw()+
  facet_grid(.~scenarios,labeller = labeller(scenarios=scenario.labs2))+
  theme(
    #panel.grid.major  = element_blank(),
    panel.grid.minor  = element_blank(),
    legend.position   = 'none',
    axis.title        = element_blank(),
    legend.title      = element_text(size=15),
    legend.title.align = 0.5,
    legend.background = element_rect(colour ='grey'),
    legend.text       = element_text(size=15), 
    axis.text         = element_text(size=15),
    axis.text.x       = element_text(size=18), 
    strip.background  = element_rect(fill = 'white'),
    strip.text        = element_text(size=18))

# Fig. S2. Number of species per trophic group that decreases (black bars), 
# increases (blue bars) or exhibited less than 10% change (grey bars) compared 
# to non-fishing scenario, under a) the scenario of Lessonia harvesting 
# complying with fishing regulations, or b) not complying with regulation 4 
# (Table 1).

head(Data)
trophic_lessthan10 = Data %>% group_by(scenarios, TL,change_v2) %>% summarize(n=n())

trophic_lessthan10$TL = factor(trophic_lessthan10$TL, levels=c('Top', 'Predator', 'Omnivore', 'Herbivore', 
                                 'Filterfeeder', 'Producer'))

ggplot(filter(trophic_lessthan10, scenarios %in% c('Compliance', 'No_compliance_S2')), aes(x=TL, y=n,label=n, fill=change_v2))+
  geom_col(position = position_dodge2(width = 0.9, preserve = "single"), col="black", ) +
  scale_fill_manual(values=c('black', '#56B4E9', 'darkgray'))+
  facet_grid(.~scenarios,labeller = labeller(scenarios=scenario.labs2))+
  labs(y='Number of species', x= 'Functional group', fill='Change')+
  scale_y_continuous(limits=c(0,26), breaks=c(0,5,10,15,20,25))+
  geom_text(position = position_dodge2(width = 0.9, preserve = "single"),vjust=-1)+
  theme_bw()+
  theme(
    #panel.grid.major  = element_blank(),
    #    panel.grid.minor  = element_blank(),
    legend.position   = c(0.85,0.85),
    axis.title        = element_blank(),
    legend.title      = element_text(size=15),
    legend.title.align = 0.5,
    legend.background = element_rect(colour ='grey'),
    legend.text       = element_text(size=15), 
    axis.text.y       = element_text(size=15),
    axis.text.x       = element_text(size=12.5, angle = 20, vjust = 0.8, hjust = 0.7),
    strip.background  = element_rect(fill = 'white'),
    strip.text        = element_text(size=18))