##################################################
## Project: Nursing Homes model
## agent_based_COVID_SEIRX
## Script purpose: This scripts plot total number of infected (and groups)
##   based on model data
## Date:23.03.2021.
## Author: Elma Hot Dervic
##################################################

library(reshape2)
library(ggplot2)
library( RColorBrewer)
library(svglite)

# read the CSV file (output from nursing homes model)
# plot mean value of infected total and standard deviation
# save plots
# and add empirical data

# plot 1 : infected total
# plot 2 : infected employees and infected residents
## INPUT:
# nursing_home/Final_0ed-0.4-0.2 _Outbreak_sizes.csv

## OUTPUT:
# calibration_plots/1_Final_0ed-0.4-0.2 _infected_total.png/pdf
# calibration_plots/1_Final_0ed-0.4-0.2_infected_groups.png/pdf

name0 <- "0ed-0.4-0.2"

data1 <- read.table(paste0("nursing_home/Final_", name0, "_Outbreak_sizes.csv"), sep = ",", stringsAsFactors = F, header = T)
str(data1)
head(data1)

data1$I_employee <- data1$E_employee + data1$I_employee + data1$R_employee
data1$I_resident <- data1$E_resident + data1$I_resident + data1$R_resident 

data1$R_employee <- NULL
data1$E_employee <- NULL


data1$R_resident <- NULL
data1$E_resident <- NULL
names(data1) <- c("run", "i", "infected_employee", "infected_resident")
data1[data1$run==1,]


data1$infected_total <- data1$infected_employee + data1$infected_resident

data_final <- data1 %>% group_by(i ) %>% summarise(mean_total = mean(infected_total), sd_total = sd(infected_total),
                                                                  mean_employee = mean(infected_employee), sd_employee = sd(infected_employee),
                                                                  mean_resident = mean(infected_resident), sd_resident = sd(infected_resident))
# plot only the first 30 days
data_final <- data_final[data_final$i < 30,]


# read the empirical data 
real_outbreak1 <- read.table("data/nursing_home/oubreak_1.csv", sep = ",", stringsAsFactors = F, header = T)
str(real_outbreak1)
real_outbreak1$cumulative_total <- real_outbreak1$cumulative_I_resident + real_outbreak1$cumulative_I_employee


real_outbreak2 <- read.table("data/nursing_home/oubreak_2.csv", sep = ",", stringsAsFactors = F, header = T)
str(real_outbreak2)
real_outbreak2$cumulative_total <- real_outbreak2$cumulative_I_resident + real_outbreak2$cumulative_I_employee


real_outbreak3 <- read.table("data/nursing_home/oubreak_3.csv", sep = ",", stringsAsFactors = F, header = T)
str(real_outbreak3)
real_outbreak3$cumulative_total <- real_outbreak3$cumulative_I_resident + real_outbreak3$cumulative_I_employee


real_outbreak4 <- read.table("data/nursing_home/oubreak_4.csv", sep = ",", stringsAsFactors = F, header = T)
str(real_outbreak4)
real_outbreak4$cumulative_total <- real_outbreak4$cumulative_I_resident + real_outbreak4$cumulative_I_employee
str(real_outbreak4)

real_outbreak1$outbreak <- "1st outbreak"
real_outbreak2$outbreak <- "2nd outbreak"
real_outbreak3$outbreak <- "3rd outbreak"
real_outbreak4$outbreak <- "4th outbreak"

real_outbreak <- rbind(real_outbreak1, real_outbreak2)
real_outbreak <- rbind(real_outbreak, real_outbreak3)
real_outbreak <- rbind(real_outbreak, real_outbreak4)

names(data_final)
str(real_outbreak)

plot <- ggplot(data = data_final, aes(x = i)) +
  geom_line(aes(y = mean_total), size = 2) +
  geom_ribbon(aes(y = mean_total, ymin = mean_total - sd_total, ymax = mean_total + sd_total, fill = "red"), alpha = .2) +
  xlab("Days") + ylab("Infected total") +  ylim(0, 50) +  xlim(0, 15) +
  theme(axis.text.x = element_text( hjust = 1, face = "bold", size = 15),
        axis.text.y = element_text(size = 15, face = "bold"),
        text = element_text(family = "Helvetica", size = 15))  +
  guides(fill=guide_legend(title="Standard deviation"))  + labs(title = "Calibration") +
  geom_point(data=real_outbreak, aes(x=t, y=cumulative_total,col = outbreak), size = 2) 
plot

name <- paste0("calibration_plots/1_Final_", name0, "_infected_total.png")
ggsave(plot,  file = name,  width = 20*1.25, height = 15 *1.25, units = "cm", dpi=96)



real_outbreak <- real_outbreak1[,c(1,2,5)]
real_outbreak$type <- rep("Employee", nrow(real_outbreak))

type <- rep("Employee", nrow(real_outbreak2))
real_outbreak <- rbind(real_outbreak,cbind(real_outbreak2[,c(1,2,5)],type))

type <- rep("Employee", nrow(real_outbreak3))
real_outbreak <- rbind(real_outbreak,cbind(real_outbreak3[,c(1,2,5)],type))

type <- rep("Employee", nrow(real_outbreak4))
real_outbreak <- rbind(real_outbreak,cbind(real_outbreak4[,c(1,2,5)],type))


names(real_outbreak) <- c("t", "Infected", "outbreak", "type")

names(real_outbreak1)[3] <- "Infected"
names(real_outbreak2)[3] <- "Infected"
names(real_outbreak3)[3] <- "Infected"
names(real_outbreak4)[3] <- "Infected"

type <- rep("Resident", nrow(real_outbreak1))
real_outbreak <- rbind(real_outbreak,cbind(real_outbreak1[,c(1,3,5)],type))

type <- rep("Resident", nrow(real_outbreak2))
real_outbreak <- rbind(real_outbreak,cbind(real_outbreak2[,c(1,3,5)],type))

type <- rep("Resident", nrow(real_outbreak3))
real_outbreak <- rbind(real_outbreak,cbind(real_outbreak3[,c(1,3,5)],type))

type <- rep("Resident", nrow(real_outbreak4))
real_outbreak <- rbind(real_outbreak,cbind(real_outbreak4[,c(1,3,5)],type))




data_final$mean_employee_min  <-  data_final$mean_employee - data_final$sd_employee
data_final$mean_employee_min[data_final$mean_employee_min<0] <- 0

data_final$mean_resident_min  <-  data_final$mean_resident - data_final$sd_resident
data_final$mean_resident_min[data_final$mean_resident_min<0] <- 0

# plot only the first 15 days
data_final <- data_final[data_final$i<16,]
plot <- ggplot(data = data_final, aes(x = i)) + 
  geom_line(aes(y = mean_resident), size = 2, colour = "#CC6666") + 
  geom_ribbon(aes(y = mean_resident, ymin = mean_resident_min, ymax = mean_resident + sd_resident), alpha = .2, fill = "red") +
  geom_line(aes(y = mean_employee), size = 2, colour =  "#9999CC") + 
  geom_ribbon(aes(y = mean_employee, ymin =mean_employee_min, ymax = mean_employee + sd_employee), alpha = .2, fill = "blue") +
  xlab("Days") + ylab("Infected") + ylim(0, 25) +  xlim(0, 15) +
  theme(axis.text.x = element_text( hjust = 1, face = "bold", size = 15), 
        axis.text.y = element_text(size = 15, face = "bold"),
        text = element_text(family = "Helvetica", size = 15))  +
  guides(fill=guide_legend(title="Standard deviation"))  + labs(title = "Calibration") +
  guides(fill=guide_legend(title="Standard deviation"))  + labs(title = "Calibration") +
  geom_point(data=real_outbreak, aes(x=t, y=Infected ,col = outbreak, shape = type), size = 2) 

plot


name <- paste0("calibration_plots/1_Final_", name0, "_infected_groups.png")
ggsave(plot,  file = name,  width = 20*1.25, height = 15 *1.25, units = "cm", dpi=96) 

name <- paste0("calibration_plots/1_Final_", name0, "_infected_groups.pdf")
ggsave(plot,  file = name,  width = 20*1.25, height = 15 *1.25, units = "cm", dpi=96) 

