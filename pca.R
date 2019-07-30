sww = 0

for (i in 1:15) {
  km.out = kmeans(scale(data), centers = i, nstart = 20, )
  sww[i] = km.out$tot.withinss
}

plot(1:15, sww, type = 'b')

sgrid = read_excel('Grid.xlsx')
Jgrid = read_excel('JGrid.xlsx')

subset = sgrid[, c(4:6, 8:33)]
jsubset = Jgrid[, c(2, 4:6, 8:34)]
pd = Jgrid  
sub_pca = subset %>% 
              mutate(Male = ifelse(Gender == 'M', 1, 0), Local = ifelse(Distance == 'Local', 1, 0),
                            Weekend = ifelse(DoW %in% c('Friday', 'Saturday', 'Sunday'), 1, 0), 
                            SlotDom = ifelse(EnrollDominance == 'Slot Dominant', 1, 0), 
                            SlotDom2 = ifelse(`1st Dominant` == 'Slot Dominant', 1, 0)) %>% 
              select(-c(Gender,Distance, DoW, EnrollDominance, `1st Dominant`, `2nd Dominant`, 
                        `3rd Dominant`, `Other Dominant`, Distance_From_Prop, other_free, 
                        other_Earned, `Other TotalActual`, `Other Dominant`, `Other TotalTheo`))
J_pca = jsubset %>% 
              mutate(Male = ifelse(Gender == 'M', 1, 0), Local = ifelse(Distance == 'Local', 1, 0),
                     Weekend = ifelse(DoW %in% c('Friday', 'Saturday', 'Sunday'), 1, 0), 
                     SlotDom = ifelse(EnrollDominance == 'Slot Dominant', 1, 0), 
                     SlotDom2 = ifelse(`1st Dominant` == 'Slot Dominant', 1, 0)) %>% 
              select(-c(Gender,Distance, DoW, EnrollDominance, `1st Dominant`, `2nd Dominant`, 
                        `3rd Dominant`, `Other Dominant`, Distance_From_Prop, other_free, 
                        other_Earned, `Other TotalActual`, `Other Dominant`, `Other TotalTheo`,
                        Property_key))
jsubset %>% 
          mutate(Male = ifelse(Gender == 'M', 1, 0), Local = ifelse(Distance == 'Local', 1, 0),
                 Weekend = ifelse(DoW %in% c('Friday', 'Saturday', 'Sunday'), 1, 0), 
                 SlotDom = ifelse(EnrollDominance == 'Slot Dominant', 1, 0), 
                 SlotDom2 = ifelse(`1st Dominant` == 'Slot Dominant', 1, 0)) %>% 
          filter(Property_key == 25) %>% 
          select(-c(Gender,Distance, DoW, EnrollDominance, `1st Dominant`, `2nd Dominant`, 
                    `3rd Dominant`, `Other Dominant`, Distance_From_Prop, other_free, 
                    other_Earned, `Other TotalActual`, `Other Dominant`, `Other TotalTheo`,
                    Property_key, `1st_free`, `2nd_free`, `3rd_free`)) %>% prcomp(scale. = T) %>% summary()
jsubset %>% group_by(Property_key) %>% summarise_if(is.numeric, sum) %>% select_if(any_vars(. == 0), all_vars())

pca = prcomp(sub_pca, scale. = F)
spca = prcomp(sub_pca, scale. = T)
jpca = prcomp(J_pca, scale. = T, center = T)
jpca2 = prcomp(J_pca2, scale. = T)

summary(spca)
summary(jpca)
biplot(jpca)
biplot(spca)
plot(spca$x[, c(1,2)], col = factor(sub_pca$GridParticipant + 1))

autoplot(spca, loadings = T, loadings.label = T, 
         loadings.colour = 'blue', label.colour = 'green', label.show.legend = T)

autoplot(jpca, loadings = T, loadings.label = T, label.show.legend = T,  label.colour = 'blue') + 
  geom_point(alpha = .2, col = factor(J_pca$GridParticipant + 2))

x = ifelse(sub_pca$EnrollTheo <= 0, 1,sub_pca$EnrollTheo)

as.data.frame.matrix(jpca2$rotation, make.names = T) %>% rownames_to_column() %>% arrange(desc(abs(PC2)))
