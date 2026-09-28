
# ============================================================
# NPTEL_week-11
# Foundations of R Software - Lecture Notes Code Collection
# ============================================================


# ------------------------------------------------------------
# LECTURE 43: DATA FRAMES - MORE OPERATIONS
# ------------------------------------------------------------

# Load MASS package and view the painters dataset
install.packages("MASS")   # Run once if not already installed
library(MASS)

painters
head(painters)
summary(painters)

# Frequency table for a categorical variable
summary(painters$School)

# Summary statistics for a numeric variable
summary(painters$Composition)

# Attach data frame to access columns by name
attach(painters)

summary(School)
summary(Composition)

# Detach data frame
detach(painters)

# After detaching, use painters$School
summary(painters$School)

# Subset rows where School is F
subset(painters, School == "F")

# Equivalent subsetting using square brackets
painters[painters[["School"]] == "F", ]

# Subset rows where Composition is at most 6
subset(painters, Composition <= 6)

# Select School F and remove columns 3 and 5
subset(painters, School == "F", select = c(-3, -5))

# Split the data frame by School
splitted <- split(painters, painters$School)
splitted

# Access each split
splitted$A
splitted$B
splitted$C
splitted$D
splitted$E
splitted$F
splitted$G
splitted$H

# Check whether a split is a data frame
is.data.frame(splitted$A)


# ------------------------------------------------------------
# LECTURE 46: IMPORTING AND READING EXCEL / OTHER DATA FILES
# ------------------------------------------------------------

# Set working directory (edit this path for your computer)
# setwd("C:/RCourse/")

# Install and load readxl
install.packages("readxl")   # Run once
library(readxl)

# Read the first sheet of an Excel file
# dataspexcel <- read_excel("spexcel.xlsx")

# Read a particular sheet by position
# dataspexcel <- read_excel("spexcel.xlsx", sheet = 1)
# dataspexcel2 <- read_excel("spexcel.xlsx", sheet = 2)

# Read a particular sheet by name
# dataspexcel <- read_excel("spexcel.xlsx", sheet = "sheet_name")

# View imported Excel data and extract columns
# dataspexcel
# dataspexcel$`Variable 1`
# dataspexcel$`Variable 2`
# mean(dataspexcel$`Variable 1`)

# Access columns containing spaces using backticks
# dataspexcel2$`Variable 4`
# dataspexcel2$`Variable 5`
# dataspexcel2$`Variable 6`
# mean(dataspexcel2$`Variable 6`)

# Read only the first 3 data rows
# dataspexcel4 <- read_excel("spexcel.xlsx", n_max = 3)
# dataspexcel4

# Read a range using Excel A1 notation
# dataspexcel_range <- read_excel("spexcel.xlsx", range = "C1:E7")

# Read a range using R1C1 notation
# dataspexcel_range2 <- read_excel("spexcel.xlsx", range = "R1C2:R2C5")

# Read SPSS data
install.packages("foreign")   # Run once
library(foreign)
# spss_data <- read.spss("datafile.sav")

# Read HTML tables
install.packages("XML")       # Run once
library(XML)
# html_data <- readHTMLTable("filename.html")

# Other foreign-format readers (examples)
# read.octave("file")
# read.systat("file")
# read.xport("file")
# read.dta("file")


# ------------------------------------------------------------
# LECTURE 47: SAVING AND WRITING DATA FILES
# ------------------------------------------------------------

# Create a vector from 1 to 100
x <- c(1:100)
x

# Write vector to a text file
write(x, file = "shalabh")

# Write data to a CSV file
# write.csv(data, file = "data.csv", row.names = FALSE)

# General write.csv syntax examples
# write.csv(x, file = "", append = FALSE)
# write.csv(x, file = "data.csv", append = FALSE,
#           quote = TRUE, na = "NA", row.names = TRUE,
#           col.names = TRUE, fileEncoding = "")

# Write data as a table
# write.table(data, file = "data.txt", sep = "\t",
#             row.names = FALSE, col.names = TRUE)

# Write a matrix or data frame to a tab-delimited file
# write.table(data, file = "data.tsv", sep = "\t",
#             append = FALSE, quote = TRUE,
#             na = "NA", row.names = FALSE)


# ------------------------------------------------------------
# LECTURE 48: STATISTICAL FUNCTIONS
# FREQUENCIES AND PARTITION VALUES
# ------------------------------------------------------------

# Absolute and relative frequencies: gender example
gender <- c(1, 2, 1, 2, 1, 1, 1, 2, 1, 1)
gender

# Absolute frequencies
table(gender)

# Relative frequencies
table(gender) / length(gender)

# Pizza delivery direction example
direction <- c(
  1,1,2,1,2,3,2,2,3,3,3,1,2,3,2,2,3,1,1,3,3,1,2,
  1,3,3,3,2,2,2,2,1,2,2,1,1,1,3,2,2,1,2,3,2,2,1,
  2,3,3,2,1,2,2,3,1,1,2,1,2,3,2,3,2,2,3,1,2,3,3,3,
  2,1,1,1,2,1,1,2,1,2,3,3,1,2,3,3,2,1,2,3,2,1,3,
  2,2,2,2,3,2,2
)

# Absolute frequencies
table(direction)

# Relative frequencies
table(direction) / length(direction)

# Marks of 15 students
marks <- c(68, 82, 63, 86, 34, 96, 41, 89, 29, 51,
           75, 77, 56, 59, 42)

# Default quartiles (0%, 25%, 50%, 75%, 100%)
quantile(marks)

# Specify quartile probabilities explicitly
quantile(marks, probs = c(0, 0.25, 0.5, 0.75, 1))

# Specify other partition values
quantile(marks, probs = c(0, 0.20, 0.4, 0.6, 0.8, 1))


# ------------------------------------------------------------
# LECTURE 49: GRAPHICS - SCATTER PLOTS AND BAR PLOTS
# ------------------------------------------------------------

# Heights of 50 persons
height <- c(
  166,125,130,142,147,159,159,147,165,156,149,164,137,166,135,142,
  133,136,127,143,165,121,142,148,158,146,154,157,124,125,158,159,
  164,143,154,152,141,164,131,152,152,161,143,143,139,131,125,145,
  140,163
)

# Scatter plot / index plot
plot(height)

# Scatter plot with red points
plot(height, col = "red")

# Bar plots for categorical data
# Bar plot of raw codes (usually not meaningful)
barplot(gender)

# Bar plot of absolute frequencies
barplot(table(gender))

# Bar plot of relative frequencies
barplot(table(gender) / length(gender))

# Bar plot of direction codes (raw values)
barplot(direction)

# Bar plot of absolute frequencies for directions
barplot(table(direction))

# Bar plot of relative frequencies for directions
barplot(table(direction) / length(direction))

# Add colors
barplot(table(direction), col = c("red", "green", "blue"))

# Add title
barplot(
  table(direction),
  col = c("red", "green", "blue"),
  main = "Directions of food delivery"
)

# Add legend
barplot(
  table(direction),
  col = c("red", "green", "blue"),
  main = "Directions of food delivery",
  legend.text = c("dir1", "dir2", "dir3")
)

# Add subtitle and axis label
barplot(
  table(direction),
  col = c("red", "green", "blue"),
  main = "Directions of food delivery",
  legend.text = c("dir1", "dir2", "dir3"),
  sub = "Three directions",
  xlab = "Food Delivery"
)

# End of compiled code examples