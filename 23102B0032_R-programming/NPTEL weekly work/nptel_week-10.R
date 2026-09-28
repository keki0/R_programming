# Example 1: Replace first occurrence
y <- "Number of participants: 25"
sub("25", "30", y)

# Example 2: Replace first occurrence in a sentence
y <- "Mr. Singh is the smart one. Mr. Singh is funny, too."

sub("Mr. Singh", "Professor Jha", y)

# Example 3: Replace all occurrences
gsub("Mr. Singh", "Professor Jha", y)

# Compare sub() and gsub()
sub("Mr. Singh", "Professor Jha", y)
gsub("Mr. Singh", "Professor Jha", y)
# Character vector
str <- c("R Course", "exercises",
         "include examples of R language")

# Return matching strings
grep("ex", str, value = TRUE)

# Return indices of matching strings
grep("ex", str, value = FALSE)

# Case-sensitive matching
str <- c("R Course", "exercises",
         "include examples of r language",
         "in R software.")

grep("R", str, ignore.case = FALSE, value = TRUE)

# Case-insensitive matching
grep("R", str, ignore.case = TRUE, value = TRUE)

# Return indices with case ignored
grep("R", str, ignore.case = TRUE, value = FALSE)

# Return indices with case sensitivity
grep("R", str, ignore.case = FALSE, value = FALSE)

# Search in two strings
x <- "R course 24.07.2021"
y <- "Number of participants: 25"

# Combine strings
c(x, y)

# Search for "our"
grep("our", c(x, y))

# Search for "Num"
grep("Num", c(x, y))
# Character vector
str <- c("R Course", "exercises",
         "include examples of R language")

# Search for R
grepl("R", str)

# Search for ex
grepl("ex", str)

# Another example from the lecture
grepl("ex", str, value = TRUE)
# Load MASS package
library(MASS)

# Display painters dataset
painters

# Display row names
rownames(painters)

# Check whether School is numeric
is.numeric(painters$School)

# Check whether Drawing is numeric
is.numeric(painters$Drawing)

# Check whether School is a factor
is.factor(painters$School)

# Check whether Drawing is a factor
is.factor(painters$Drawing)

# Display column names
colnames(painters)

# Summary of all variables
summary(painters)

# Frequency table for School
summary(painters$School)
# Attach the data frame
attach(painters)

# Access variables directly
summary(School)

summary(Composition)

# Detach the data frame
detach(painters)

# Access variables using the $ operator
summary(painters$School)

summary(painters$Composition)
# Select painters belonging to School F
subset(painters, School == "F")

# Equivalent method using indexing
painters[painters[["School"]] == "F", ]

# Select painters with Composition <= 6
subset(painters, Composition <= 6)

# Select School F and eliminate Colour and School columns
subset(painters, School == "F", select = c(-3, -5))
# Split painters dataset according to School
splitted <- split(painters, painters$School)

# Display split data
splitted

# Access individual data frames
splitted$A
splitted$B
splitted$C
splitted$D
splitted$E
splitted$F
splitted$G
splitted$H

# Check whether splitted$A is a data frame
is.data.frame(splitted$A)
# Create first data frame
df1 <- data.frame(
  state = c("UP", "MP", "AP", "JK"),
  popnsize = c(1000, 2000, 3000, 4000)
)

# Create second data frame
df2 <- data.frame(
  state = c("UP", "MP", "AP", "JK"),
  samplesize = c(100, 200, 300, 400),
  surveycompleted = c("Yes", "No", "Yes", "No")
)

# Display data frames
df1
df2

# Combine columns side-by-side
cbind(df1, df2)
# Display data frames
df1
df2

# Merge using common column state
merge(df1, df2, by = "state")
# Create first data frame
df11 <- data.frame(
  state = c("UP", "MP", "AP", "JK"),
  popnsize = c(1000, 2000, 3000, 4000)
)

# Create second data frame
df22 <- data.frame(
  state = c("Bihar", "Delhi", "Punjab"),
  popnsize = c(100, 200, 300)
)

# Display data frames
df11
df22

# Stack data frames vertically
rbind(df11, df22)
