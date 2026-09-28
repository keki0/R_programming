# ============================================================
# PS-7: CUSTOMER SEGMENTATION AND PREDICTIVE ANALYTICS
# ============================================================

# 1. SET WORKING DIRECTORY
setwd("C:/Users/KETAKI PATIL/R_programming/23102B0032_R-programming/PS-7 (Customer Segmentation)")

# Create output folder
if (!dir.exists("outputs")) {
  dir.create("outputs")
}

# 2. INSTALL REQUIRED PACKAGES
packages <- c(
  "dplyr",
  "ggplot2",
  "cluster",
  "factoextra",
  "randomForest",
  "e1071",
  "caret",
  "pROC",
  "plotly",
  "htmlwidgets",
  "corrplot",
  "scales"
)

new_packages <- packages[
  !(packages %in% installed.packages()[, "Package"])
]

if (length(new_packages) > 0) {
  install.packages(new_packages, dependencies = TRUE)
}

# 3. LOAD LIBRARIES
library(dplyr)
library(ggplot2)
library(cluster)
library(factoextra)
library(randomForest)
library(e1071)
library(caret)
library(pROC)
library(plotly)
library(htmlwidgets)
library(corrplot)
library(scales)

# 4. FIND AND IMPORT CSV FILE
csv_files <- list.files(
  path = ".",
  pattern = "\\.csv$",
  full.names = TRUE,
  ignore.case = TRUE
)

if (length(csv_files) == 0) {
  stop("No CSV file found. Place the dataset CSV in the PS-7 folder.")
}

# If there is more than one CSV, select the dataset file
print(csv_files)

# Select the first CSV file
file_path <- csv_files[1]

# Read dataset
retail <- read.csv(
  file_path,
  stringsAsFactors = FALSE,
  check.names = FALSE
)

cat("Dataset loaded successfully!\n")
cat("Rows:", nrow(retail), "\n")
cat("Columns:", ncol(retail), "\n")

# Display first six records
head(retail)

# Dataset structure
str(retail)

# Summary statistics
summary(retail)

# Save initial dataset summary
capture.output(
  summary(retail),
  file = "outputs/01_dataset_summary.txt"
)

# Save original column names
print(names(retail))

# ============================================================
# 5. DATA PREPROCESSING
# ============================================================

# Standardize column names
names(retail) <- tolower(
  gsub("[^a-zA-Z0-9]+", "", names(retail))
)

# Rename common variations
if ("invoiceno" %in% names(retail)) {
  names(retail)[names(retail) == "invoiceno"] <- "invoiceno"
}

if ("customerid" %in% names(retail)) {
  names(retail)[names(retail) == "customerid"] <- "customerid"
}

if ("invoicedate" %in% names(retail)) {
  names(retail)[names(retail) == "invoicedate"] <- "invoicedate"
}

if ("unitprice" %in% names(retail)) {
  names(retail)[names(retail) == "unitprice"] <- "unitprice"
}

# Check required columns
required_cols <- c(
  "invoiceno",
  "quantity",
  "invoicedate",
  "unitprice",
  "customerid"
)

missing_cols <- setdiff(required_cols, names(retail))

if (length(missing_cols) > 0) {
  stop(
    paste(
      "Missing required columns:",
      paste(missing_cols, collapse = ", ")
    )
  )
}

# Convert columns to appropriate data types
retail$invoiceno <- as.character(retail$invoiceno)

retail$customerid <- as.character(retail$customerid)

retail$quantity <- suppressWarnings(
  as.numeric(retail$quantity)
)

retail$unitprice <- suppressWarnings(
  as.numeric(retail$unitprice)
)

# Convert invoice date
retail$invoicedate <- as.POSIXct(
  retail$invoicedate,
  format = "%m/%d/%Y %H:%M",
  tz = "UTC"
)

# Handle alternative date formats if the first format fails
if (all(is.na(retail$invoicedate))) {
  retail$invoicedate <- as.POSIXct(
    retail$invoicedate,
    format = "%Y-%m-%d %H:%M:%S",
    tz = "UTC"
  )
}

# Record row count before cleaning
rows_before <- nrow(retail)

# Remove duplicate records
retail <- retail[!duplicated(retail), ]

# Remove missing or invalid customer IDs
retail <- retail[
  !is.na(retail$customerid) &
    trimws(retail$customerid) != "" &
    retail$customerid != "NA",
]

# Remove missing or invalid values
retail <- retail[
  !is.na(retail$quantity) &
    !is.na(retail$unitprice) &
    !is.na(retail$invoicedate),
]

# Remove cancelled invoices
# Cancelled invoices generally begin with "C"
retail <- retail[
  !grepl("^C", retail$invoiceno, ignore.case = TRUE),
]

# Remove non-positive quantities and prices
retail <- retail[
  retail$quantity > 0 &
    retail$unitprice > 0,
]

# Calculate transaction amount
retail$totalamount <- retail$quantity * retail$unitprice

rows_after <- nrow(retail)

cat("Rows before cleaning:", rows_before, "\n")
cat("Rows after cleaning:", rows_after, "\n")
cat("Rows removed:", rows_before - rows_after, "\n")

# Save cleaned dataset
write.csv(
  retail,
  "outputs/02_cleaned_retail_data.csv",
  row.names = FALSE
)

# Check missing values
missing_values <- colSums(is.na(retail))

print(missing_values)

write.csv(
  data.frame(
    Column = names(missing_values),
    Missing_Values = as.numeric(missing_values)
  ),
  "outputs/03_missing_values.csv",
  row.names = FALSE
)

# Summary after preprocessing
summary(retail)
# ============================================================
# 6. EXPLORATORY DATA ANALYSIS
# ============================================================

# Number of unique customers
total_customers <- length(unique(retail$customerid))

# Number of unique invoices
total_invoices <- length(unique(retail$invoiceno))

# Total revenue
total_revenue <- sum(retail$totalamount)

cat("Total customers:", total_customers, "\n")
cat("Total invoices:", total_invoices, "\n")
cat("Total revenue:", round(total_revenue, 2), "\n")

# Revenue by country, if country is available
if ("country" %in% names(retail)) {
  
  country_sales <- retail %>%
    group_by(country) %>%
    summarise(
      Revenue = sum(totalamount),
      Customers = n_distinct(customerid),
      .groups = "drop"
    ) %>%
    arrange(desc(Revenue))
  
  print(head(country_sales, 10))
  
  write.csv(
    country_sales,
    "outputs/04_country_sales.csv",
    row.names = FALSE
  )
  
  p_country <- ggplot(
    head(country_sales, 10),
    aes(
      x = reorder(country, Revenue),
      y = Revenue
    )
  ) +
    geom_col() +
    coord_flip() +
    labs(
      title = "Top 10 Countries by Revenue",
      x = "Country",
      y = "Revenue"
    ) +
    theme_minimal()
  
  print(p_country)
  
  ggsave(
    "outputs/01_top_countries.png",
    p_country,
    width = 9,
    height = 6
  )
}

# Distribution of transaction amounts
p_amount <- ggplot(
  retail,
  aes(x = totalamount)
) +
  geom_histogram(
    bins = 50,
    fill = "steelblue",
    color = "white"
  ) +
  labs(
    title = "Distribution of Transaction Amount",
    x = "Transaction Amount",
    y = "Frequency"
  ) +
  theme_minimal()

print(p_amount)

ggsave(
  "outputs/02_transaction_distribution.png",
  p_amount,
  width = 8,
  height = 5
)

# Distribution of quantity
p_quantity <- ggplot(
  retail,
  aes(x = quantity)
) +
  geom_histogram(
    bins = 50,
    fill = "darkgreen",
    color = "white"
  ) +
  labs(
    title = "Distribution of Quantity Purchased",
    x = "Quantity",
    y = "Frequency"
  ) +
  theme_minimal()

print(p_quantity)

ggsave(
  "outputs/03_quantity_distribution.png",
  p_quantity,
  width = 8,
  height = 5
)
# ============================================================
# 7. CUSTOMER-LEVEL FEATURE ENGINEERING
# ============================================================

# Set reference date one day after the latest transaction
reference_date <- max(retail$invoicedate) + 86400

# Construct RFM and other customer-level features
customer_data <- retail %>%
  group_by(customerid) %>%
  summarise(
    Recency = as.numeric(
      difftime(
        reference_date,
        max(invoicedate),
        units = "days"
      )
    ),
    
    Frequency = n_distinct(invoiceno),
    
    Monetary = sum(totalamount),
    
    Avg_Transaction_Value = mean(
      totalamount
    ),
    
    Total_Quantity = sum(quantity),
    
    Purchase_Frequency = n_distinct(invoiceno) /
      max(
        1,
        as.numeric(
          difftime(
            max(invoicedate),
            min(invoicedate),
            units = "days"
          )
        ) / 30
      ),
    
    .groups = "drop"
  )

# Remove any invalid values
customer_data <- customer_data %>%
  filter(
    is.finite(Recency),
    is.finite(Frequency),
    is.finite(Monetary),
    is.finite(Avg_Transaction_Value),
    is.finite(Total_Quantity),
    is.finite(Purchase_Frequency)
  )

# Save customer-level features
write.csv(
  customer_data,
  "outputs/05_customer_features.csv",
  row.names = FALSE
)

# Display feature summary
summary(customer_data)

head(customer_data)

cat(
  "Number of customers for segmentation:",
  nrow(customer_data),
  "\n"
)
# ============================================================
# 8. OUTLIER TREATMENT AND FEATURE SCALING
# ============================================================

features <- c(
  "Recency",
  "Frequency",
  "Monetary",
  "Avg_Transaction_Value",
  "Total_Quantity",
  "Purchase_Frequency"
)

# Work on a copy of the features
customer_features <- customer_data[, features]

# Log transform non-negative skewed variables
log_features <- c(
  "Frequency",
  "Monetary",
  "Avg_Transaction_Value",
  "Total_Quantity",
  "Purchase_Frequency"
)

for (col in log_features) {
  customer_features[[col]] <- log1p(
    customer_features[[col]]
  )
}

# Cap outliers at the 1st and 99th percentiles
for (col in features) {
  
  lower <- quantile(
    customer_features[[col]],
    0.01,
    na.rm = TRUE
  )
  
  upper <- quantile(
    customer_features[[col]],
    0.99,
    na.rm = TRUE
  )
  
  customer_features[[col]] <- pmin(
    pmax(
      customer_features[[col]],
      lower
    ),
    upper
  )
}

# Replace any remaining non-finite values
for (col in features) {
  
  med <- median(
    customer_features[[col]],
    na.rm = TRUE
  )
  
  customer_features[[col]][
    !is.finite(customer_features[[col]])
  ] <- med
}

# Standardize using Z-score normalization
scaled_features <- scale(customer_features)

scaled_features <- as.matrix(scaled_features)

# Save the scaled data
write.csv(
  data.frame(
    CustomerID = customer_data$customerid,
    scaled_features
  ),
  "outputs/06_scaled_customer_features.csv",
  row.names = FALSE
)

cat("Feature scaling completed.\n")
# ============================================================
# 9. ELBOW METHOD
# ============================================================

set.seed(123)

# Test number of clusters from 1 to 10
wss <- numeric(10)

for (k in 1:10) {
  
  km <- kmeans(
    scaled_features,
    centers = k,
    nstart = 10,
    iter.max = 100
  )
  
  wss[k] <- km$tot.withinss
}

elbow_data <- data.frame(
  Clusters = 1:10,
  WSS = wss
)

print(elbow_data)

p_elbow <- ggplot(
  elbow_data,
  aes(
    x = Clusters,
    y = WSS
  )
) +
  geom_line() +
  geom_point(size = 3) +
  scale_x_continuous(breaks = 1:10) +
  labs(
    title = "Elbow Method for Optimal K",
    x = "Number of Clusters (K)",
    y = "Within-Cluster Sum of Squares"
  ) +
  theme_minimal()

print(p_elbow)

ggsave(
  "outputs/04_elbow_method.png",
  p_elbow,
  width = 8,
  height = 5
)

# Select K after inspecting the Elbow graph
# Start with K = 4; change if the elbow suggests otherwise
optimal_k <- 4

cat("Selected number of clusters:", optimal_k, "\n")
# ============================================================
# 10. K-MEANS CLUSTERING
# ============================================================

set.seed(123)

kmeans_model <- kmeans(
  scaled_features,
  centers = optimal_k,
  nstart = 25,
  iter.max = 100
)

# Assign cluster labels
customer_data$Cluster <- factor(
  kmeans_model$cluster
)

# Cluster sizes
cluster_sizes <- as.data.frame(
  table(customer_data$Cluster)
)

colnames(cluster_sizes) <- c(
  "Cluster",
  "Number_of_Customers"
)

print(cluster_sizes)

write.csv(
  cluster_sizes,
  "outputs/07_cluster_sizes.csv",
  row.names = FALSE
)

# Calculate silhouette score
sil <- silhouette(
  kmeans_model$cluster,
  dist(scaled_features)
)

silhouette_score <- mean(sil[, 3])

cat(
  "Average K-Means Silhouette Score:",
  round(silhouette_score, 4),
  "\n"
)

# Plot silhouette
png(
  "outputs/05_silhouette_plot.png",
  width = 1000,
  height = 700
)

plot(
  sil,
  main = "Silhouette Plot for K-Means Clustering",
  col = 1:optimal_k,
  border = NA
)

dev.off()

# Save silhouette score
write.csv(
  data.frame(
    Method = "K-Means",
    K = optimal_k,
    Silhouette_Score = silhouette_score
  ),
  "outputs/08_kmeans_silhouette.csv",
  row.names = FALSE
)
# ============================================================
# 11. HIERARCHICAL CLUSTERING
# ============================================================

set.seed(123)

# Select sample for computational efficiency
sample_size <- min(
  1500,
  nrow(scaled_features)
)

sample_indices <- sample(
  seq_len(nrow(scaled_features)),
  size = sample_size
)

hier_data <- scaled_features[
  sample_indices,
  ,
  drop = FALSE
]

# Compute Euclidean distance
distance_matrix <- dist(
  hier_data,
  method = "euclidean"
)

# Perform hierarchical clustering
hc_model <- hclust(
  distance_matrix,
  method = "ward.D2"
)

# Plot dendrogram
png(
  "outputs/06_hierarchical_dendrogram.png",
  width = 1200,
  height = 800
)

plot(
  hc_model,
  labels = FALSE,
  hang = -1,
  main = "Hierarchical Clustering Dendrogram",
  xlab = "Customers",
  ylab = "Height"
)

rect.hclust(
  hc_model,
  k = optimal_k,
  border = 2:(optimal_k + 1)
)

dev.off()

# Cut dendrogram into K clusters
hc_clusters <- cutree(
  hc_model,
  k = optimal_k
)

# Calculate hierarchical silhouette score
hc_sil <- silhouette(
  hc_clusters,
  distance_matrix
)

hc_silhouette_score <- mean(
  hc_sil[, 3]
)

cat(
  "Hierarchical Silhouette Score:",
  round(hc_silhouette_score, 4),
  "\n"
)

# Save results
hierarchical_results <- data.frame(
  CustomerID = customer_data$customerid[
    sample_indices
  ],
  KMeans_Cluster = customer_data$Cluster[
    sample_indices
  ],
  Hierarchical_Cluster = factor(
    hc_clusters
  )
)

write.csv(
  hierarchical_results,
  "outputs/09_hierarchical_results.csv",
  row.names = FALSE
)

# Compare silhouette scores
clustering_comparison <- data.frame(
  Method = c(
    "K-Means",
    "Hierarchical"
  ),
  Silhouette_Score = c(
    silhouette_score,
    hc_silhouette_score
  )
)

print(clustering_comparison)

write.csv(
  clustering_comparison,
  "outputs/10_clustering_comparison.csv",
  row.names = FALSE
)

p_comparison <- ggplot(
  clustering_comparison,
  aes(
    x = Method,
    y = Silhouette_Score
  )
) +
  geom_col() +
  labs(
    title = "Clustering Method Comparison",
    x = "Clustering Method",
    y = "Average Silhouette Score"
  ) +
  theme_minimal()

print(p_comparison)

ggsave(
  "outputs/07_clustering_comparison.png",
  p_comparison,
  width = 7,
  height = 5
)
# ============================================================
# 12. PRINCIPAL COMPONENT ANALYSIS (PCA)
# ============================================================

pca_model <- prcomp(
  scaled_features,
  center = FALSE,
  scale. = FALSE
)

# Get PCA coordinates
pca_data <- as.data.frame(
  pca_model$x[, 1:2]
)

colnames(pca_data) <- c(
  "PC1",
  "PC2"
)

pca_data$Cluster <- customer_data$Cluster

# Percentage of variance explained
variance_explained <- (
  pca_model$sdev^2 /
    sum(pca_model$sdev^2)
) * 100

cat(
  "PC1 variance explained:",
  round(variance_explained[1], 2),
  "%\n"
)

cat(
  "PC2 variance explained:",
  round(variance_explained[2], 2),
  "%\n"
)

cat(
  "Total variance explained by PC1 and PC2:",
  round(sum(variance_explained[1:2]), 2),
  "%\n"
)

# PCA scatter plot
p_pca <- ggplot(
  pca_data,
  aes(
    x = PC1,
    y = PC2,
    color = Cluster
  )
) +
  geom_point(
    alpha = 0.6,
    size = 1.5
  ) +
  labs(
    title = "Customer Segments Using PCA",
    x = paste0(
      "PC1 (",
      round(variance_explained[1], 1),
      "%)"
    ),
    y = paste0(
      "PC2 (",
      round(variance_explained[2], 1),
      "%)"
    ),
    color = "Cluster"
  ) +
  theme_minimal()

print(p_pca)

ggsave(
  "outputs/08_pca_2d_clusters.png",
  p_pca,
  width = 9,
  height = 6
)

# Save PCA coordinates
write.csv(
  data.frame(
    CustomerID = customer_data$customerid,
    pca_data
  ),
  "outputs/11_pca_coordinates.csv",
  row.names = FALSE
)

# PCA loading matrix
pca_loadings <- as.data.frame(
  pca_model$rotation
)

pca_loadings$Feature <- rownames(
  pca_loadings
)

print(pca_loadings)

write.csv(
  pca_loadings,
  "outputs/12_pca_loadings.csv",
  row.names = FALSE
)
# ============================================================
# 13. CUSTOMER CLUSTER PROFILING
# ============================================================

cluster_profile <- customer_data %>%
  group_by(Cluster) %>%
  summarise(
    Customers = n(),
    
    Avg_Recency = mean(Recency),
    
    Avg_Frequency = mean(Frequency),
    
    Avg_Monetary = mean(Monetary),
    
    Avg_Transaction_Value = mean(
      Avg_Transaction_Value
    ),
    
    Avg_Quantity = mean(Total_Quantity),
    
    Avg_Purchase_Frequency = mean(
      Purchase_Frequency
    ),
    
    .groups = "drop"
  )

print(cluster_profile)

write.csv(
  cluster_profile,
  "outputs/13_cluster_profiles.csv",
  row.names = FALSE
)

# Bar chart of average monetary value by cluster
p_monetary <- ggplot(
  cluster_profile,
  aes(
    x = Cluster,
    y = Avg_Monetary,
    fill = Cluster
  )
) +
  geom_col() +
  labs(
    title = "Average Monetary Value by Customer Cluster",
    x = "Cluster",
    y = "Average Monetary Value"
  ) +
  theme_minimal() +
  theme(legend.position = "none")

print(p_monetary)

ggsave(
  "outputs/09_cluster_monetary_profile.png",
  p_monetary,
  width = 8,
  height = 5
)

# Bar chart of average recency
p_recency <- ggplot(
  cluster_profile,
  aes(
    x = Cluster,
    y = Avg_Recency,
    fill = Cluster
  )
) +
  geom_col() +
  labs(
    title = "Average Recency by Customer Cluster",
    x = "Cluster",
    y = "Average Recency (Days)"
  ) +
  theme_minimal() +
  theme(legend.position = "none")

print(p_recency)

ggsave(
  "outputs/10_cluster_recency_profile.png",
  p_recency,
  width = 8,
  height = 5
)

# Identify high-value cluster
# Based on high monetary value and frequent purchases,
# with recency used as a secondary consideration.

cluster_profile$Value_Score <- scale(
  cluster_profile$Avg_Monetary
)[, 1] +
  scale(
    cluster_profile$Avg_Frequency
  )[, 1] -
  scale(
    cluster_profile$Avg_Recency
  )[, 1]

high_value_cluster <- as.character(
  cluster_profile$Cluster[
    which.max(cluster_profile$Value_Score)
  ]
)

cat(
  "Identified high-value cluster:",
  high_value_cluster,
  "\n"
)

# Save high-value cluster information
write.csv(
  cluster_profile,
  "outputs/14_high_value_cluster_analysis.csv",
  row.names = FALSE
)
# ============================================================
# 14. CREATE HIGH-VALUE CUSTOMER TARGET
# ============================================================

customer_data$High_Value <- factor(
  ifelse(
    as.character(customer_data$Cluster) ==
      high_value_cluster,
    "Yes",
    "No"
  ),
  levels = c(
    "No",
    "Yes"
  )
)

# Display target distribution
print(
  table(customer_data$High_Value)
)

print(
  prop.table(
    table(customer_data$High_Value)
  )
)

# Save labeled customer data
write.csv(
  customer_data,
  "outputs/15_customer_data_with_target.csv",
  row.names = FALSE
)
# ============================================================
# 15. TRAIN-TEST SPLIT
# ============================================================

set.seed(123)

# Features used for prediction
predictor_cols <- c(
  "Recency",
  "Frequency",
  "Monetary",
  "Avg_Transaction_Value",
  "Total_Quantity",
  "Purchase_Frequency"
)

model_data <- customer_data[
  ,
  c(
    predictor_cols,
    "High_Value"
  )
]

# Stratified split
train_index <- createDataPartition(
  model_data$High_Value,
  p = 0.80,
  list = FALSE
)

train_data <- model_data[
  train_index,
  ,
  drop = FALSE
]

test_data <- model_data[
  -train_index,
  ,
  drop = FALSE
]

cat("Training records:", nrow(train_data), "\n")
cat("Testing records:", nrow(test_data), "\n")

print(
  prop.table(
    table(train_data$High_Value)
  )
)

print(
  prop.table(
    table(test_data$High_Value)
  )
)
# ============================================================
# 16. RANDOM FOREST CLASSIFICATION
# ============================================================

set.seed(123)

rf_model <- randomForest(
  High_Value ~ .,
  data = train_data,
  ntree = 300,
  importance = TRUE
)

print(rf_model)

# Predict class labels
rf_predictions <- predict(
  rf_model,
  newdata = test_data,
  type = "class"
)

# Predict probabilities
rf_probabilities <- predict(
  rf_model,
  newdata = test_data,
  type = "prob"
)[, "Yes"]

# Confusion matrix
rf_cm <- confusionMatrix(
  rf_predictions,
  test_data$High_Value,
  positive = "Yes"
)

print(rf_cm)

# Feature importance
rf_importance <- importance(
  rf_model
)

print(rf_importance)

png(
  "outputs/11_random_forest_importance.png",
  width = 1000,
  height = 700
)

varImpPlot(
  rf_model,
  main = "Random Forest Feature Importance"
)

dev.off()

write.csv(
  rf_importance,
  "outputs/16_random_forest_importance.csv"
)
# ============================================================
# 17. SVM CLASSIFICATION
# ============================================================

# Use standardized predictor variables for SVM
# Standardization parameters are estimated only on training data.

svm_train_x <- train_data[, predictor_cols]
svm_test_x <- test_data[, predictor_cols]

train_means <- sapply(
  svm_train_x,
  mean
)

train_sds <- sapply(
  svm_train_x,
  sd
)

# Avoid division by zero
train_sds[train_sds == 0] <- 1

svm_train_x <- scale(
  svm_train_x,
  center = train_means,
  scale = train_sds
)

svm_test_x <- scale(
  svm_test_x,
  center = train_means,
  scale = train_sds
)

svm_train_df <- as.data.frame(
  svm_train_x
)

svm_train_df$High_Value <- train_data$High_Value

svm_test_df <- as.data.frame(
  svm_test_x
)

# Train SVM
set.seed(123)

svm_model <- svm(
  High_Value ~ .,
  data = svm_train_df,
  kernel = "radial",
  cost = 1,
  gamma = 1 / length(predictor_cols),
  probability = TRUE
)

print(svm_model)

# Predict classes
svm_predictions <- predict(
  svm_model,
  newdata = svm_test_df,
  probability = FALSE
)

# Extract probability estimates
svm_pred_with_prob <- predict(
  svm_model,
  newdata = svm_test_df,
  probability = TRUE
)

svm_prob_matrix <- attr(
  svm_pred_with_prob,
  "probabilities"
)

svm_probabilities <- svm_prob_matrix[
  ,
  "Yes"
]

# Confusion matrix
svm_cm <- confusionMatrix(
  factor(
    svm_predictions,
    levels = c("No", "Yes")
  ),
  test_data$High_Value,
  positive = "Yes"
)

print(svm_cm)

# Save SVM model
saveRDS(
  svm_model,
  "outputs/svm_model.rds"
)
# ============================================================
# 18. MODEL PERFORMANCE EVALUATION
# ============================================================

# Function to calculate classification metrics
calculate_metrics <- function(
    actual,
    predicted,
    probabilities,
    model_name) {
  
  actual <- factor(
    actual,
    levels = c("No", "Yes")
  )
  
  predicted <- factor(
    predicted,
    levels = c("No", "Yes")
  )
  
  cm <- confusionMatrix(
    predicted,
    actual,
    positive = "Yes"
  )
  
  accuracy <- as.numeric(
    cm$overall["Accuracy"]
  )
  
  precision <- as.numeric(
    cm$byClass["Precision"]
  )
  
  recall <- as.numeric(
    cm$byClass["Recall"]
  )
  
  f1 <- as.numeric(
    cm$byClass["F1"]
  )
  
  roc_obj <- roc(
    response = actual,
    predictor = probabilities,
    levels = c("No", "Yes"),
    direction = "<",
    quiet = TRUE
  )
  
  auc_value <- as.numeric(
    auc(roc_obj)
  )
  
  return(
    list(
      metrics = data.frame(
        Model = model_name,
        Accuracy = accuracy,
        Precision = precision,
        Recall = recall,
        F1_Score = f1,
        ROC_AUC = auc_value
      ),
      confusion_matrix = cm$table,
      roc = roc_obj
    )
  )
}

# Evaluate Random Forest
rf_results <- calculate_metrics(
  actual = test_data$High_Value,
  predicted = rf_predictions,
  probabilities = rf_probabilities,
  model_name = "Random Forest"
)

# Evaluate SVM
svm_results <- calculate_metrics(
  actual = test_data$High_Value,
  predicted = svm_predictions,
  probabilities = svm_probabilities,
  model_name = "SVM"
)

# Compare performance
model_comparison <- rbind(
  rf_results$metrics,
  svm_results$metrics
)

print(model_comparison)

write.csv(
  model_comparison,
  "outputs/17_model_performance_comparison.csv",
  row.names = FALSE
)

# Confusion matrices
cat("\nRandom Forest Confusion Matrix:\n")
print(rf_results$confusion_matrix)

cat("\nSVM Confusion Matrix:\n")
print(svm_results$confusion_matrix)

write.csv(
  as.data.frame.matrix(
    rf_results$confusion_matrix
  ),
  "outputs/18_rf_confusion_matrix.csv"
)

write.csv(
  as.data.frame.matrix(
    svm_results$confusion_matrix
  ),
  "outputs/19_svm_confusion_matrix.csv"
)

# ROC curve comparison
png(
  "outputs/12_roc_curve_comparison.png",
  width = 1000,
  height = 700
)

plot(
  rf_results$roc,
  col = "blue",
  lwd = 2,
  main = "ROC Curve: Random Forest vs SVM"
)

plot(
  svm_results$roc,
  col = "red",
  lwd = 2,
  add = TRUE
)

legend(
  "bottomright",
  legend = c(
    paste0(
      "Random Forest AUC = ",
      round(
        rf_results$metrics$ROC_AUC,
        3
      )
    ),
    paste0(
      "SVM AUC = ",
      round(
        svm_results$metrics$ROC_AUC,
        3
      )
    )
  ),
  col = c("blue", "red"),
  lwd = 2
)

dev.off()

# Performance comparison graph
comparison_long <- data.frame(
  Model = rep(
    model_comparison$Model,
    each = 4
  ),
  Metric = rep(
    c(
      "Accuracy",
      "Precision",
      "Recall",
      "F1-Score"
    ),
    times = nrow(model_comparison)
  ),
  Score = c(
    model_comparison$Accuracy,
    model_comparison$Precision,
    model_comparison$Recall,
    model_comparison$F1_Score
  )
)

p_metrics <- ggplot(
  comparison_long,
  aes(
    x = Metric,
    y = Score,
    fill = Model
  )
) +
  geom_col(
    position = "dodge"
  ) +
  labs(
    title = "Random Forest vs SVM Performance",
    x = "Evaluation Metric",
    y = "Score"
  ) +
  theme_minimal()

print(p_metrics)

ggsave(
  "outputs/13_model_metrics_comparison.png",
  p_metrics,
  width = 9,
  height = 6
)
# ============================================================
# 19. INTERACTIVE 3D PCA VISUALIZATION
# ============================================================

# Extract first three principal components
pca_3d <- as.data.frame(
  pca_model$x[, 1:3]
)

colnames(pca_3d) <- c(
  "PC1",
  "PC2",
  "PC3"
)

pca_3d$Cluster <- customer_data$Cluster

pca_3d$CustomerID <- customer_data$customerid

# Interactive 3D scatter plot
plot_3d <- plot_ly(
  data = pca_3d,
  x = ~PC1,
  y = ~PC2,
  z = ~PC3,
  color = ~Cluster,
  colors = "Set1",
  type = "scatter3d",
  mode = "markers",
  text = ~paste(
    "Customer ID:", CustomerID,
    "<br>Cluster:", Cluster,
    "<br>PC1:", round(PC1, 2),
    "<br>PC2:", round(PC2, 2),
    "<br>PC3:", round(PC3, 2)
  ),
  hoverinfo = "text",
  marker = list(
    size = 3,
    opacity = 0.7
  )
) %>%
  layout(
    title = "Interactive 3D PCA Customer Segmentation",
    scene = list(
      xaxis = list(title = "Principal Component 1"),
      yaxis = list(title = "Principal Component 2"),
      zaxis = list(title = "Principal Component 3")
    )
  )

# Display in R Studio Viewer
plot_3d

# Save interactive plot
htmlwidgets::saveWidget(
  plot_3d,
  "outputs/14_interactive_3d_customer_clusters.html",
  selfcontained = TRUE
)

cat("Interactive 3D visualization saved successfully.\n")
# ============================================================
# 20. MARKETING RECOMMENDATIONS
# ============================================================

# Calculate median thresholds
median_recency <- median(
  customer_data$Recency
)

median_frequency <- median(
  customer_data$Frequency
)

median_monetary <- median(
  customer_data$Monetary
)

# Generate recommendations for each cluster
cluster_profile$Marketing_Strategy <- NA_character_

for (i in seq_len(nrow(cluster_profile))) {
  
  r <- cluster_profile$Avg_Recency[i]
  f <- cluster_profile$Avg_Frequency[i]
  m <- cluster_profile$Avg_Monetary[i]
  
  if (
    m >= median_monetary &&
    f >= median_frequency &&
    r <= median_recency
  ) {
    
    cluster_profile$Marketing_Strategy[i] <-
      "Reward loyalty with exclusive offers, VIP benefits, early access, and referral programs."
    
  } else if (
    m >= median_monetary &&
    f < median_frequency
  ) {
    
    cluster_profile$Marketing_Strategy[i] <-
      "Encourage repeat purchases using personalized recommendations, bundles, and loyalty points."
    
  } else if (
    r > median_recency &&
    f >= median_frequency
  ) {
    
    cluster_profile$Marketing_Strategy[i] <-
      "Win back inactive customers using personalized reactivation emails and limited-time offers."
    
  } else {
    
    cluster_profile$Marketing_Strategy[i] <-
      "Increase engagement using welcome offers, product recommendations, and low-cost promotional campaigns."
  }
}

# Display marketing recommendations
print(
  cluster_profile[
    ,
    c(
      "Cluster",
      "Customers",
      "Avg_Recency",
      "Avg_Frequency",
      "Avg_Monetary",
      "Marketing_Strategy"
    )
  ]
)

write.csv(
  cluster_profile,
  "outputs/20_marketing_recommendations.csv",
  row.names = FALSE
)

cat("Marketing recommendations generated.\n")
# ============================================================
# 21. FINAL OUTPUTS AND MODEL SAVING
# ============================================================

# Save complete customer segmentation data
write.csv(
  customer_data,
  "outputs/21_final_customer_segmentation.csv",
  row.names = FALSE
)

# Save trained models
saveRDS(
  rf_model,
  "outputs/random_forest_model.rds"
)

saveRDS(
  svm_model,
  "outputs/svm_model.rds"
)

# Save PCA model
saveRDS(
  pca_model,
  "outputs/pca_model.rds"
)

# Save K-Means model
saveRDS(
  kmeans_model,
  "outputs/kmeans_model.rds"
)

# Save hierarchical model
saveRDS(
  hc_model,
  "outputs/hierarchical_model.rds"
)

# Save a text summary of final results
sink(
  "outputs/22_final_results_summary.txt"
)

cat("CUSTOMER SEGMENTATION RESULTS\n")
cat("============================\n\n")

cat("Total customers:", nrow(customer_data), "\n")
cat("Number of clusters:", optimal_k, "\n")

cat(
  "K-Means Silhouette Score:",
  round(silhouette_score, 4),
  "\n"
)

cat(
  "Hierarchical Silhouette Score:",
  round(hc_silhouette_score, 4),
  "\n"
)

cat(
  "High-value cluster:",
  high_value_cluster,
  "\n\n"
)

cat("CLUSTER PROFILES\n")
print(cluster_profile)

cat("\nMODEL PERFORMANCE\n")
print(model_comparison)

cat("\nEND OF EXPERIMENT\n")

sink()

cat("\nExperiment completed successfully!\n")

cat(
  "All outputs saved in:",
  normalizePath("outputs"),
  "\n"
)

