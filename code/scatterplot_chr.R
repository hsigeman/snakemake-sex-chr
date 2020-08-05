library(doBy)
library(data.table)
library(plot3D)
library(ggplot2)
require(scales)
library(cowplot)

# Reads in files ending with '.chr.out' produced by calculate_gencov_windows.R 
# and calculate_heterozygosityDiff_windows.R
# Makes scatterplots for genome coverage vs difference in heterozygosity and
# chromosomes/scaffolds length. Two values are plotted against each other and
# the third is shown through coloring of the points. 
# Makes a 3D scatterplot of all three variables and colors after length.

source("code/functions.R")
set.seed(999)

args <- commandArgs(trailingOnly = TRUE)

file00 = args[1]
file02 = args[2]
file04 = args[3]
filesnp = args[4]
scatter2D_out = args[5]
scatter3D_out = args[6]

################################################################################
################################# READ FILES ###################################
################################################################################

cov_00_table <- read.table(file00, header=TRUE,fill=TRUE,stringsAsFactor=FALSE)
cov_00 <- gen_data_4plotting(cov_00_table, c("chr", "length", "ratio"))
cov.select.00 <- cov_00$df
max.cov.00 <- cov_00$max
min.cov.00 <- cov_00$min
median.cov.00 <- cov_00$median

cov_02_table <- read.table(file02, header=TRUE,fill=TRUE,stringsAsFactor=FALSE)
cov_02 <- gen_data_4plotting(cov_02_table, c("chr", "length", "ratio"))
cov.select.02 <- cov_02$df
max.cov.02 <- cov_02$max
min.cov.02 <- cov_02$min
median.cov.02 <- cov_02$median

cov_04_table <- read.table(file04, header=TRUE,fill=TRUE,stringsAsFactor=FALSE)
cov_04 <- gen_data_4plotting(cov_04_table, c("chr", "length", "ratio"))
cov.select.04 <- cov_04$df
max.cov.04 <- cov_04$max
min.cov.04 <- cov_04$min
median.cov.04 <- cov_04$median

snp_table <- read.table(filesnp, header=TRUE,fill=TRUE,stringsAsFactor=FALSE)
snp <- gen_data_4plotting(snp_table, c("chr", "length", "diff"))
snp.select <- snp$df
max.snp <- snp$max
min.snp <- snp$min
median.snp <- snp$median

################################################################################
################################# MERGE DATA ###################################
################################################################################

cov.select <- merge(cov.select.00, cov.select.02, by = c("factor", "x"))
cov.select <- merge(cov.select, cov.select.04, by = c("factor", "x"))
cov.select <- merge(cov.select, snp.select, by = c("factor"))

cov.select <- cov.select[,-6]
colnames(cov.select) <- c("scaffold", "length", "cov00", "cov02", "cov04", "hetDiff")

################################################################################
############################# SCATTER PLOT LENGTH ##############################
################################################################################

cov.select <- cov.select[order(cov.select$length),]

l0 <- ggplot(cov.select, aes(x = cov00, y = hetDiff)) + 
  labs(title = "", x = "", y = "difference in heterozygosity") + 
  theme_bw() + 
  scale_x_log10(breaks = trans_breaks("log10", function(x) 10^x), 
                labels = trans_format("log10", math_format(10^.x))) + 
  annotation_logticks(sides="b") + 
  geom_point(aes(color = length)) + 
  scale_color_gradient(low = "blue", high = "red") + 
  theme(legend.position="none")

l2 <- ggplot(cov.select, aes(x = cov02, y = hetDiff)) + 
  labs(title = "", x = "genome coverage", y = "") + 
  theme_bw() + 
  scale_x_log10(breaks = trans_breaks("log10", function(x) 10^x), 
                labels = trans_format("log10", math_format(10^.x))) + 
  annotation_logticks(sides="b") +
  geom_point(aes(color = length)) + 
  scale_color_gradient(low = "blue", high = "red") + 
  theme(legend.position="none")

l4 <- ggplot(cov.select, aes(x = cov04, y = hetDiff)) + 
  labs(title = "", x = "", color = "length", y = "") + 
  theme_bw() + 
  scale_x_log10(breaks = trans_breaks("log10", function(x) 10^x), 
                labels = trans_format("log10", math_format(10^.x))) + 
  annotation_logticks(sides="b") +
  geom_point(aes(color = length)) + 
  scale_color_gradient(low = "blue", high = "red")

legend <- get_legend(l4)

l4 <- l4 + theme(legend.position="none")

l <- plot_grid(l0, l2, l4, legend, ncol = 4, rel_widths = c(3,3,3,1), 
                labels = c("nm = 0", "nm = 2", "nm = 4", ""))

################################################################################
############################ SCATTER PLOT COVERAGE #############################
################################################################################

cov.select <- cov.select[order(cov.select$cov00),]

c0 <- ggplot(cov.select, aes(y = length, x = hetDiff)) + 
  labs(title = "", y = "chromosome/scaffold length", x = "") + 
  theme_bw() + 
  scale_y_log10(breaks = trans_breaks("log10", function(x) 10^x), 
                labels = trans_format("log10", math_format(10^.x))) + 
  annotation_logticks(sides="l") +
  geom_point(aes(color = cov00)) + 
  scale_color_gradient(low = "blue", high = "red") + 
  theme(legend.position="none")

cov.select <- cov.select[order(cov.select$cov02),]

c2 <- ggplot(cov.select, aes(y = length, x = hetDiff)) + 
  labs(title = "", y = "", x = "difference in heterozygosity") + 
  theme_bw() + 
  scale_y_log10(breaks = trans_breaks("log10", function(x) 10^x), 
                labels = trans_format("log10", math_format(10^.x))) + 
  annotation_logticks(sides="l") +
  geom_point(aes(color = cov02)) + 
  scale_color_gradient(low = "blue", high = "red") + 
  theme(legend.position="none")

cov.select <- cov.select[order(cov.select$cov04),]

c4 <- ggplot(cov.select, aes(y = length, x = hetDiff)) + 
  labs(title = "", x = "", color = "coverage", y = "") + 
  theme_bw() + 
  scale_y_log10(breaks = trans_breaks("log10", function(x) 10^x), 
                labels = trans_format("log10", math_format(10^.x))) + 
  annotation_logticks(sides="l") +
  geom_point(aes(color = cov04)) + 
  scale_color_gradient(low = "blue", high = "red")

legend <- get_legend(c4)

c4 <- c4 + theme(legend.position="none")

c <- plot_grid(c0, c2, c4, legend, ncol = 4, rel_widths = c(3,3,3,1))

################################################################################
############################ SCATTER PLOT HETDIFF ##############################
################################################################################

cov.select <- cov.select[order(cov.select$hetDiff),]

h0 <- ggplot(cov.select, aes(y = length, x = cov00)) + 
  labs(title = "", y = "chromosome/scaffold length", x = "") + 
  theme_bw() + 
  scale_y_log10(breaks = trans_breaks("log10", function(x) 10^x), 
                labels = trans_format("log10", math_format(10^.x))) + 
  scale_x_log10(breaks = trans_breaks("log10", function(x) 10^x), 
                labels = trans_format("log10", math_format(10^.x))) +
  annotation_logticks(sides="lb") +
  geom_point(aes(color = hetDiff)) + 
  scale_color_gradient(low = "blue", high = "red") + 
  theme(legend.position="none")

h2 <- ggplot(cov.select, aes(y = length, x = cov02)) + 
  labs(title = "", y = "", x = "genome coverage") + 
  theme_bw() + 
  scale_y_log10(breaks = trans_breaks("log10", function(x) 10^x), 
                labels = trans_format("log10", math_format(10^.x))) + 
  scale_x_log10(breaks = trans_breaks("log10", function(x) 10^x), 
                labels = trans_format("log10", math_format(10^.x))) +
  annotation_logticks(sides="bl") +
  geom_point(aes(color = hetDiff)) + 
  scale_color_gradient(low = "blue", high = "red") + 
  theme(legend.position="none")

h4 <- ggplot(cov.select, aes(y = length, x = cov04)) + 
  labs(title = "", x = "", color = "hetDiff", y = "") + 
  theme_bw() + 
  scale_y_log10(breaks = trans_breaks("log10", function(x) 10^x), 
                labels = trans_format("log10", math_format(10^.x))) + 
  scale_x_log10(breaks = trans_breaks("log10", function(x) 10^x), 
                labels = trans_format("log10", math_format(10^.x))) +
  annotation_logticks(sides="bl") +
  geom_point(aes(color = hetDiff)) + 
  scale_color_gradient(low = "blue", high = "red")

legend <- get_legend(h4)

h4 <- h4 + theme(legend.position="none")

h <- plot_grid(h0, h2, h4, legend, ncol = 4, rel_widths = c(3,3,3,1))



pg <- plot_grid(l,c,h, ncol = 1)

ggsave(scatter2D_out, plot = pg, device = pdf(), width = 14, height = 10)

################################################################################
############################### SCATTER PLOT 3D ################################
################################################################################

pdf(file=scatter3D_out, width = 14, height = 5)

par(mfrow=c(1,3), mar=c(2,1,2,0), oma=c(0,0,0,0), xpd=TRUE)

scatter3D(cov.select$length, log(cov.select$cov00), cov.select$hetDiff,
          colvar = cov.select$length, pch = 19, xlab = "Scaffold length", 
          ylab = "log of normalized genome coverage", main = "nm = 0",
          zlab = "difference in heterozygosity", bty = "b2",
          colkey = FALSE)

scatter3D(cov.select$length, log(cov.select$cov02), cov.select$hetDiff,
          colvar = cov.select$length, pch = 19, xlab = "Scaffold length", 
          ylab = "log of normalized genome coverage", main = "nm = 2",
          zlab = "difference in heterozygosity", bty = "b2",
          colkey = FALSE)

scatter3D(cov.select$length, log(cov.select$cov04), cov.select$hetDiff,
          colvar = cov.select$length, pch = 19, xlab = "Scaffold length", 
          ylab = "log of normalized genome coverage", main = "nm = 4",
          zlab = "difference in heterozygosity", bty = "b2",
          colkey = FALSE)

dev.off()
