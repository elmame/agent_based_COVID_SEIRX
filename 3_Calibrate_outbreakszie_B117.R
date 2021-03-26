##################################################
## Project: Nursing Homes model
## agent_based_COVID_SEIRX
## Script purpose: This scripts plots calculated 
##   probability that your model have the same size outbreak as empirical data
## Date:23.03.2021.
## Author: Elma Hot Dervic
##################################################
library(reshape2)
library(ggplot2)
library( RColorBrewer)
library(svglite)
library(dplyr)

## INPUT:
# nursing_home/Final_B117_Total_number_result_calibration.csv
## OUTPUT:
# Calibration_probability_B117.png/pdf


# from empirical data
total_infected_from_empirical_data1 <- 27
total_infected_from_empirical_data2 <- 28
# total number of days in empirical data
final_day <- 13


data1 <- read.table("nursing_home/Final_B117_Total_number_result_calibration.csv", sep = ",", stringsAsFactors = F, header = T)
str(data1)
head(data1)
tail(data1)
data1$R_resident <- NULL
data1$E_resident <- NULL

str(data1)
names(data1) <- c("run", "i", "infected_employee", "infected_resident", "base_risk", "exposure_duration" )
table(data1$exposure_duration)


data1$infected_total <- data1$infected_employee + data1$infected_resident

# select only the one day (the last day of empirical data)
data2 <- data1[data1$i == final_day,]
sum(data2$infected_resident>total_infected_from_empirical_data)

# print all base risk values
base_risk_all <- unique(data2$base_risk)
x <- unique(data2[,c(5,6)])
rownames(x) <- NULL
x


real_data1 <- NULL
real_data1$compare_result <- rep(NA, length(base_risk_all))
real_data1$outbreak <-  rep("Outbreak 1", length(base_risk_all))
real_data1$base_risk_multiplier <- base_risk_all
real_data1 <- as.data.frame(real_data1)


for (i in 1: length(base_risk_all)){
  
  data3 <- data2[data2$base_risk==base_risk_all[i],]
  real_data1$compare_result[i] <- sum(data3$infected_resident>=total_infected_from_empirical_data1)/nrow(data3)
}


real_data2 <- NULL
real_data2$compare_result <- rep(NA, length(base_risk_all))
real_data2$outbreak <-  rep("Outbreak 2", length(base_risk_all))
real_data2$base_risk_multiplier <- base_risk_all
real_data2 <- as.data.frame(real_data2)
for (i in 1: length(base_risk_all)){
  
  data3 <- data2[data2$base_risk==base_risk_all[i],]
  real_data2$compare_result[i] <- sum(data3$infected_resident>=total_infected_from_empirical_data2)/nrow(data3)
}

real_data <- rbind(real_data1, real_data2)
real_data$outbreak <- as.character(real_data$outbreak)
str(real_data)

plot <- ggplot(data = real_data, aes(x = base_risk_multiplier, y = compare_result, colour = outbreak)) +
  geom_line( size = 2) +
  xlab("Base risk multiplier") + ylab("Probability") +  ylim(0, 0.85) +  xlim(1, 6.9) +
  theme(axis.text.x = element_text( hjust = 1, face = "bold", size = 15),
        axis.text.y = element_text(size = 15, face = "bold"),
        text = element_text(family = "Helvetica", size = 15),
        panel.background = element_rect(fill = NA),
        panel.grid = element_line(colour = "lightgrey", size=0.2),
        panel.ontop = FALSE,
        panel.border = element_blank())  +
  guides(colour=guide_legend(title="Outbreaks"))   
plot


name <-  "calibration_plots/Calibration_probability_B117.png"
ggsave(plot,  file = name,  width = 25*1.25, height = 15 *1.25, units = "cm", dpi=96)

name <-  "calibration_plots/Calibration_probability_B117.pdf"
ggsave(plot,  file = name,  width = 25*1.25, height = 15 *1.25, units = "cm", dpi=96)
