##################################################
## Project: Nursing Homes model
## agent_based_COVID_SEIRX
## Script purpose: This scripts plot heatmaps based on calibration
# results
## Date:23.03.2021.
## Author: Elma Hot Dervic
##################################################


library(reshape2)
library(ggplot2)
library( RColorBrewer)
library(svglite)
library(dplyr)


# read the csv file (output from nursing homes model)
# plot heatmaps - calculated distance (model data - empirical data)
# save plots
# and add empirical data

## INPUT:
# nursing_home/Final_calibration_1.csv
# nursing_home/Final_calibration_2.csv
# nursing_home/Final_calibration_3.csv
# nursing_home/Final_calibration_4.csv

## OUTPUT:
# calibration_plots/Calibration_thefirstversion_Mean_Euclidean_Distance.png/pdf

data1 <- read.table("nursing_home/1st run R/1_calibration_1.csv", sep = ",", stringsAsFactors = F, header = T)
str(data1)
head(data1)
summary(data1)

data2 <- read.table("nursing_home/1st run R/1_calibration_2.csv", sep = ",", stringsAsFactors = F, header = T)
str(data2)
head(data2)


data3 <- read.table("nursing_home/1st run R/1_calibration_3.csv", sep = ",", stringsAsFactors = F, header = T)
str(data3)
head(data3)

data4 <- read.table("nursing_home/1st run R/1_calibration_4.csv", sep = ",", stringsAsFactors = F, header = T)
str(data4)
head(data4)




names(data)

data1_final <- NULL
data1_final <- data1 %>% group_by(intermediate_contact_weight, far_contact_weight) %>% summarise(mean_ed = mean(euclidean_distance, na.rm = T), std_ed = sd(euclidean_distance, na.rm = T), 
                                                                                           mean_ed_total= mean(euclidean_distance_total, na.rm = T), std_ed_total = sd(euclidean_distance_total, na.rm = T),
                                                                                           mean_ed_groups = mean(euclidean_distance_groups, na.rm = T), std_end_groups = sd(euclidean_distance_groups, na.rm = T),
                                                                                          )

str(data1_final)


data2_final <- data2 %>% group_by(intermediate_contact_weight, far_contact_weight) %>% summarise(mean_ed = mean(euclidean_distance, na.rm = T), std_ed = sd(euclidean_distance, na.rm = T), 
                                                                                                 mean_ed_total= mean(euclidean_distance_total, na.rm = T), std_ed_total = sd(euclidean_distance_total, na.rm = T),
                                                                                                 mean_ed_groups = mean(euclidean_distance_groups, na.rm = T), std_end_groups = sd(euclidean_distance_groups, na.rm = T),
                                                                                                 )

str(data2_final)

data3_final <- data3 %>% group_by(intermediate_contact_weight, far_contact_weight)%>% summarise(mean_ed = mean(euclidean_distance, na.rm = T), std_ed = sd(euclidean_distance, na.rm = T), 
                                                                                                mean_ed_total= mean(euclidean_distance_total, na.rm = T), std_ed_total = sd(euclidean_distance_total, na.rm = T),
                                                                                                mean_ed_groups = mean(euclidean_distance_groups, na.rm = T), std_end_groups = sd(euclidean_distance_groups, na.rm = T),
                                                                                                )

str(data3_final)

data4_final <- data4 %>% group_by(intermediate_contact_weight, far_contact_weight)%>% summarise(mean_ed = mean(euclidean_distance, na.rm = T), std_ed = sd(euclidean_distance, na.rm = T), 
                                                                                                mean_ed_total= mean(euclidean_distance_total, na.rm = T), std_ed_total = sd(euclidean_distance_total, na.rm = T),
                                                                                                mean_ed_groups = mean(euclidean_distance_groups, na.rm = T), std_end_groups = sd(euclidean_distance_groups, na.rm = T),
)

str(data4_final)

data <- NULL


summary(data2)
summary(data1)
summary(data3)
summary(data4)

data <- data1_final
str(data)
data$mean_ed <- data1_final$mean_ed + data2_final$mean_ed + data3_final$mean_ed + data4_final$mean_ed
data$std_ed <- data1_final$std_ed + data2_final$std_ed + data3_final$std_ed  + data4_final$std_ed 
data$mean_ed_total <-data1_final$mean_ed_total + data2_final$mean_ed_total + data3_final$mean_ed_total + data4_final$mean_ed_total
data$std_ed_total <-  data1_final$std_ed_total +  data2_final$std_ed_total +  data3_final$std_ed_total + data4_final$std_ed_total
data$mean_ed_groups <- data1_final$mean_ed_groups + data2_final$mean_ed_groups + data3_final$mean_ed_groups + data4_final$mean_ed_groups
data$std_end_groups <-  data1_final$std_end_groups +  data2_final$std_end_groups +  data3_final$std_end_groups+  data4_final$std_end_groups


names(data)
str(data)



data1_final[data1_final$mean_ed==min(data1_final$mean_ed),]
data2_final[data2_final$mean_ed==min(data2_final$mean_ed),]
data3_final[data3_final$mean_ed==min(data3_final$mean_ed),]
data4_final[data4_final$mean_ed==min(data4_final$mean_ed),]
data[data$mean_ed==min(data$mean_ed),]


# **************** Mean_Euclidean_Distance ****************
names(data)

df <- data[,c(1,2, 3)]
str(df)
min <- min(df$mean_ed[!is.na(df$mean_ed)])
df2 <- df[(df$mean_ed==min & !is.na(df$mean_ed)),]

x <- df$mean_ed[!is.na(df$mean_ed )]
x <- sum(x==min)


plot <- ggplot(df, aes(far_contact_weight, intermediate_contact_weight,  fill= mean_ed)) + 
  geom_tile() +
  scale_fill_gradient(low="lightgreen", high="red", na.value="darkgrey") +
  guides(fill=guide_legend(title="Mean Euclidean Distance")) + labs(title = "Mean Euclidean Distance", subtitle = paste0("min: ", df2$mean_ed), caption = paste0("intermediate: ", df2$intermediate_contact_weight, " far: ", df2$far_contact_weight))  +
  theme(text = element_text(family = "Helvetica", size = 20)) +
  geom_point(data=df2, aes(x=far_contact_weight, y=intermediate_contact_weight), size = 3) 
plot
name <- "calibration_plots/Calibration_thefirstversion_Mean_Euclidean_Distance.png"
ggsave(plot,  file = name,  width = 20*1.25, height = 15 *1.25, units = "cm", dpi=96) 

name <- "calibration_plots/Calibration_thefirstversion_Mean_Euclidean_Distance.pdf"
ggsave(plot,  file = name,  width = 20*1.25, height = 15 *1.25, units = "cm", dpi=96) 

