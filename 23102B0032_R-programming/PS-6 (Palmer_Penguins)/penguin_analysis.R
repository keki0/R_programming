# Lab Problem Statement 6: Statistical Analysis of Physical Characteristics of Palmer Penguins
# Student: YOUR NAME | Roll No.: YOUR ROLL NUMBER

pkgs <- c('palmerpenguins','dplyr','ggplot2','moments','car')
miss <- pkgs[!pkgs %in% rownames(installed.packages())]
if(length(miss)) install.packages(miss, repos='https://cloud.r-project.org')
lapply(pkgs, library, character.only=TRUE)

dir.create('data', showWarnings=FALSE); dir.create('outputs', showWarnings=FALSE); dir.create('figures', showWarnings=FALSE)
penguins <- palmerpenguins::penguins
write.csv(penguins, 'data/penguins.csv', row.names=FALSE, na='')

# 1. Descriptive statistics -------------------------------------------------
desc <- function(x){x<-x[!is.na(x)]; c(N=length(x),Mean=mean(x),Median=median(x),Min=min(x),Max=max(x),Variance=var(x),SD=sd(x),Q1=quantile(x,.25,names=FALSE),Q3=quantile(x,.75,names=FALSE),IQR=IQR(x),Skewness=moments::skewness(x),Kurtosis=moments::kurtosis(x))}
overall <- desc(penguins$body_mass_g)
species_desc <- penguins %>% group_by(species) %>% summarise(N=sum(!is.na(body_mass_g)),Mean=mean(body_mass_g,na.rm=T),Median=median(body_mass_g,na.rm=T),Min=min(body_mass_g,na.rm=T),Max=max(body_mass_g,na.rm=T),Variance=var(body_mass_g,na.rm=T),SD=sd(body_mass_g,na.rm=T),Q1=quantile(body_mass_g,.25,na.rm=T,names=F),Q3=quantile(body_mass_g,.75,na.rm=T,names=F),IQR=IQR(body_mass_g,na.rm=T),Skewness=moments::skewness(body_mass_g,na.rm=T),Kurtosis=moments::kurtosis(body_mass_g,na.rm=T),.groups='drop')
write.csv(as.data.frame(t(overall)),'outputs/overall_descriptive_statistics.csv'); write.csv(species_desc,'outputs/species_descriptive_statistics.csv',row.names=F)

# 2. Required plots ---------------------------------------------------------
ggsave('figures/01_histogram_body_mass.png', ggplot(penguins,aes(body_mass_g))+geom_histogram(binwidth=250,na.rm=T)+labs(title='Distribution of Penguin Body Mass',x='Body Mass (g)',y='Frequency')+theme_minimal(), width=8,height=5,dpi=300)
ggsave('figures/02_boxplot_body_mass_species.png', ggplot(penguins,aes(species,body_mass_g,fill=species))+geom_boxplot(na.rm=T)+labs(title='Body Mass by Penguin Species',x='Species',y='Body Mass (g)')+theme_minimal()+theme(legend.position='none'),width=8,height=5,dpi=300)
ggsave('figures/03_boxplot_body_mass_sex.png', ggplot(penguins,aes(sex,body_mass_g,fill=sex))+geom_boxplot(na.rm=T)+labs(title='Body Mass by Sex',x='Sex',y='Body Mass (g)')+theme_minimal()+theme(legend.position='none'),width=8,height=5,dpi=300)
ggsave('figures/04_density_body_mass_species.png', ggplot(penguins,aes(body_mass_g,fill=species))+geom_density(alpha=.35,na.rm=T)+labs(title='Density Plot of Body Mass by Species',x='Body Mass (g)',y='Density',fill='Species')+theme_minimal(),width=8,height=5,dpi=300)

# 3. Male vs female: normality, Welch t-test, CI, Cohen's d ----------------
sexdat <- penguins %>% filter(!is.na(body_mass_g),!is.na(sex)) %>% droplevels()
male <- sexdat$body_mass_g[sexdat$sex=='male']; female <- sexdat$body_mass_g[sexdat$sex=='female']
shapiro_male <- shapiro.test(male); shapiro_female <- shapiro.test(female)
tt <- t.test(male,female,var.equal=FALSE,conf.level=.95)
pooled_sd <- sqrt(((length(male)-1)*var(male)+(length(female)-1)*var(female))/(length(male)+length(female)-2))
d <- (mean(male)-mean(female))/pooled_sd
tt_summary <- data.frame(male_mean=mean(male),female_mean=mean(female),difference=mean(male)-mean(female),t=unname(tt$statistic),df=unname(tt$parameter),p=tt$p.value,CI_low=tt$conf.int[1],CI_high=tt$conf.int[2],Cohens_d=d)
write.csv(tt_summary,'outputs/male_female_t_test.csv',row.names=F); capture.output(shapiro_male,shapiro_female,tt,tt_summary,file='outputs/male_female_tests.txt')
ggsave('figures/05_qq_male_body_mass.png',ggplot(data.frame(x=male),aes(sample=x))+stat_qq()+stat_qq_line()+labs(title='QQ Plot: Male Body Mass')+theme_minimal(),width=7,height=5,dpi=300)
ggsave('figures/06_qq_female_body_mass.png',ggplot(data.frame(x=female),aes(sample=x))+stat_qq()+stat_qq_line()+labs(title='QQ Plot: Female Body Mass')+theme_minimal(),width=7,height=5,dpi=300)

# 4. One-way ANOVA + assumptions + Tukey ------------------------------------
anova_dat <- penguins %>% filter(!is.na(body_mass_g),!is.na(species)) %>% droplevels()
shapiro_species <- anova_dat %>% group_by(species) %>% summarise(W=unname(shapiro.test(body_mass_g)$statistic),p=shapiro.test(body_mass_g)$p.value,.groups='drop')
model1 <- aov(body_mass_g~species,data=anova_dat); anova1 <- summary(model1); levene1 <- car::leveneTest(body_mass_g~species,data=anova_dat)
write.csv(shapiro_species,'outputs/anova_species_shapiro.csv',row.names=F); write.csv(as.data.frame(levene1),'outputs/levene_test.csv'); capture.output(anova1,levene1,file='outputs/one_way_anova_and_levene.txt')
if(anova1[[1]][['Pr(>F)']][1]<.05) capture.output(TukeyHSD(model1),file='outputs/tukey_hsd.txt') else writeLines('ANOVA not significant; Tukey HSD not required.','outputs/tukey_hsd.txt')
ggsave('figures/07_qq_body_mass_by_species.png',ggplot(anova_dat,aes(sample=body_mass_g))+stat_qq()+stat_qq_line()+facet_wrap(~species)+labs(title='QQ Plots of Body Mass Within Species')+theme_minimal(),width=9,height=5,dpi=300)

# 5. Kruskal-Wallis ----------------------------------------------------------
kw <- kruskal.test(body_mass_g~species,data=anova_dat); write.csv(data.frame(chi_squared=unname(kw$statistic),df=unname(kw$parameter),p=kw$p.value),'outputs/kruskal_wallis.csv',row.names=F)

# 6. Two-way ANOVA -----------------------------------------------------------
two_dat <- penguins %>% filter(!is.na(body_mass_g),!is.na(species),!is.na(sex)) %>% droplevels()
model2 <- aov(body_mass_g~species*sex,data=two_dat); anova2 <- summary(model2); lev2 <- car::leveneTest(body_mass_g~interaction(species,sex),data=two_dat); res_shapiro <- shapiro.test(residuals(model2))
write.csv(as.data.frame(anova2[[1]]),'outputs/two_way_anova.csv'); write.csv(as.data.frame(lev2),'outputs/two_way_levene.csv'); capture.output(anova2,res_shapiro,lev2,file='outputs/two_way_anova_assumptions.txt')
ggsave('figures/08_two_way_species_sex_means.png',ggplot(two_dat,aes(species,body_mass_g,color=sex,group=sex))+stat_summary(fun=mean,geom='point',size=3)+stat_summary(fun=mean,geom='line')+stat_summary(fun.data=mean_cl_normal,geom='errorbar',width=.15)+labs(title='Mean Body Mass by Species and Sex',x='Species',y='Mean Body Mass (g)',color='Sex')+theme_minimal(),width=8,height=5,dpi=300)

# 7. Additional analysis: flipper length -----------------------------------
flip <- penguins %>% filter(!is.na(flipper_length_mm),!is.na(species)) %>% droplevels()
fm <- aov(flipper_length_mm~species,data=flip); fkw <- kruskal.test(flipper_length_mm~species,data=flip)
capture.output(summary(fm),TukeyHSD(fm),fkw,file='outputs/flipper_analysis.txt')
ggsave('figures/09_flipper_length_species.png',ggplot(flip,aes(species,flipper_length_mm,fill=species))+geom_boxplot()+labs(title='Flipper Length by Penguin Species',x='Species',y='Flipper Length (mm)')+theme_minimal()+theme(legend.position='none'),width=8,height=5,dpi=300)
ggsave('figures/10_species_mean_comparison.png',ggplot(anova_dat,aes(species,body_mass_g,fill=species))+stat_summary(fun=mean,geom='col')+stat_summary(fun.data=mean_cl_normal,geom='errorbar',width=.2)+labs(title='Mean Body Mass Comparison Across Species',x='Species',y='Mean Body Mass (g)')+theme_minimal()+theme(legend.position='none'),width=8,height=5,dpi=300)

cat('\n=== FINAL SUMMARY ===\n'); cat('Male mean:',round(mean(male),2),'g\n'); cat('Female mean:',round(mean(female),2),'g\n'); cat('Male vs female p:',format.pval(tt$p.value),'\n'); cat("Cohen's d:",round(d,3),'\n'); cat('One-way ANOVA p:',format.pval(anova1[[1]][['Pr(>F)']][1]),'\n'); cat('Kruskal-Wallis p:',format.pval(kw$p.value),'\n'); cat('All tables and figures saved.\n')
