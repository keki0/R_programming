
# Customer Segmentation and Predictive Analytics Using Machine Learning

## R Programming Lab – Lab 7

An end-to-end machine learning project that uses customer transaction data to perform customer segmentation, identify high-value customer groups, predict customer categories, and generate targeted marketing recommendations using R.

---

## 1. Project Overview

E-commerce businesses generate large volumes of transactional data. Analyzing this data helps businesses understand customer purchasing patterns, identify valuable customer groups, and design personalized marketing strategies.

This project uses the UCI Online Retail dataset to develop a customer analytics solution using unsupervised and supervised machine learning techniques.

The project applies K-Means clustering, Hierarchical Clustering, Principal Component Analysis (PCA), Random Forest, and Support Vector Machine (SVM) to analyze customer behavior and predict whether a customer belongs to a high-value segment.

### Objectives

- Preprocess and clean online retail transaction data.
- Perform customer-level feature engineering using RFM and purchasing behavior metrics.
- Identify customer segments using K-Means clustering.
- Determine the number of clusters using the Elbow Method.
- Compare K-Means and Hierarchical Clustering using Silhouette Scores.
- Visualize customer segments using PCA in 2D and 3D.
- Build customer profiles and identify a high-value segment.
- Develop Random Forest and SVM classification models.
- Evaluate predictive performance using standard classification metrics.
- Generate segment-wise marketing recommendations.

---

## 2. Dataset Description

**Dataset:** UCI Online Retail Dataset

**Source:** [UCI Machine Learning Repository – Online Retail](https://archive.ics.uci.edu/dataset/352/online+retail)

The dataset contains 541,909 transaction records from a UK-based online retailer.

### Dataset Attributes

| Attribute | Description |
|---|---|
| InvoiceNo | Unique invoice number for each transaction |
| StockCode | Product identification code |
| Description | Product description |
| Quantity | Number of units purchased |
| InvoiceDate | Date and time of transaction |
| UnitPrice | Price per unit |
| CustomerID | Unique customer identifier |
| Country | Customer's country |

The dataset is suitable for customer segmentation because it contains transaction history, customer identifiers, purchase quantities, and transaction values.

---

## 3. Technologies and Libraries Used

### Programming Language
- R

### Development Environment
- RStudio

### Libraries

| Library | Purpose |
|---|---|
| dplyr | Data manipulation and aggregation |
| ggplot2 | Data visualization |
| cluster | Silhouette analysis and clustering evaluation |
| randomForest | Random Forest classification |
| e1071 | Support Vector Machine |
| caret | Data partitioning and model evaluation |
| pROC | ROC curve and AUC calculation |
| plotly | Interactive 3D visualization |
| htmlwidgets | Exporting interactive visualizations |
| scales | Plot formatting |

---

## 4. Methodology

The project follows an end-to-end customer analytics workflow.

### Step 1: Data Preprocessing

The original dataset contained 541,909 transaction records.

The following preprocessing operations were performed:

1. Standardized column names.
2. Converted invoice numbers and customer IDs to character data types.
3. Converted quantity and unit price to numeric values.
4. Parsed invoice dates into date-time format.
5. Removed duplicate records.
6. Removed records with missing or invalid customer IDs.
7. Removed records with missing dates, quantities, or unit prices.
8. Removed cancelled invoices, identified by invoice numbers beginning with "C".
9. Removed transactions with non-positive quantities or prices.
10. Calculated transaction amount as:

   Transaction Amount = Quantity × Unit Price

#### Preprocessing Results

| Metric | Result |
|---|---:|
| Original transaction records | 541,909 |
| Records after cleaning | 392,692 |
| Records removed | 149,217 |
| Missing values after cleaning | 0 |
| Unique customers | 4,338 |
| Unique invoices | 18,532 |
| Total revenue | 8,887,209 |

The cleaned dataset was saved as `outputs/02_cleaned_retail_data.csv`.

### Step 2: Exploratory Data Analysis

Exploratory Data Analysis was performed to understand the transaction data and purchasing patterns.

The analysis included:

- Number of unique customers and invoices.
- Total revenue generated.
- Revenue by country.
- Distribution of transaction amounts.
- Distribution of purchased quantities.

The United Kingdom contributed the largest revenue in the cleaned dataset, with approximately 7,285,025 in transaction value.

The following visualizations were generated:

- Top 10 countries by revenue.
- Transaction amount distribution.
- Quantity purchased distribution.

### Step 3: Customer-Level Feature Engineering

Transaction records were aggregated to customer-level records.

Six features were constructed for customer segmentation.

| Feature | Description |
|---|---|
| Recency | Number of days since the customer's latest purchase |
| Frequency | Number of distinct invoices associated with the customer |
| Monetary | Total transaction amount spent by the customer |
| Avg_Transaction_Value | Average transaction-line amount for the customer |
| Total_Quantity | Total quantity purchased by the customer |
| Purchase_Frequency | Number of invoices relative to the customer's observed active period |

The reference date was set to one day after the latest transaction date.

A total of 4,338 customer records were generated.

The customer-level dataset was saved as `outputs/05_customer_features.csv`.

### Step 4: Outlier Treatment and Feature Scaling

Customer purchasing features exhibit skewed distributions and extreme values.

The following techniques were applied:

- Log transformation using `log1p()` for selected non-negative purchasing variables.
- Outlier capping at the 1st and 99th percentiles.
- Replacement of remaining non-finite values with feature medians.
- Z-score standardization using `scale()`.

The resulting scaled customer features were used for clustering and PCA.

### Step 5: Elbow Method

The Elbow Method was used to examine the relationship between the number of clusters and the Within-Cluster Sum of Squares (WSS).

K-Means was evaluated for cluster counts from 1 to 10.

The analysis was used to select four clusters for the subsequent segmentation experiments.

**Selected number of clusters: K = 4**

The Elbow Method graph was saved as `outputs/04_elbow_method.png`.

### Step 6: K-Means Clustering

K-Means clustering was performed using the scaled customer features.

Parameters:

- Number of clusters: 4
- Number of random initializations: 25
- Maximum iterations: 100
- Random seed: 123

#### Cluster Distribution

| Cluster | Number of Customers | Percentage |
|---|---:|---:|
| Cluster 1 | 917 | 21.14% |
| Cluster 2 | 1,190 | 27.43% |
| Cluster 3 | 714 | 16.46% |
| Cluster 4 | 1,517 | 34.97% |
| **Total** | **4,338** | **100%** |

The average K-Means Silhouette Score was:

**0.2566**

The silhouette score measures how well customers fit within their assigned clusters compared with neighboring clusters.

The result indicates that the customer segments have some separation, although overlap between customer groups remains.

### Step 7: Hierarchical Clustering

Hierarchical clustering was performed using Euclidean distance and Ward's D2 linkage method.

A random sample of 1,500 customers was used to reduce computational cost.

The dendrogram was generated and cut into four clusters for comparison.

| Clustering Method | Number of Clusters | Silhouette Score |
|---|---:|---:|
| K-Means | 4 | 0.2566 |
| Hierarchical Clustering | 4 | 0.2106 |

The K-Means silhouette score was 0.2566, while the Hierarchical Clustering silhouette score was 0.2106.

Both methods were evaluated using their respective clustering assignments. The hierarchical result was calculated on the sampled customer records.

### Step 8: Principal Component Analysis (PCA)

PCA was applied to reduce the six standardized customer features into principal components for visualization.

The first two principal components explained:

| Component | Variance Explained |
|---|---:|
| PC1 | 50.59% |
| PC2 | 18.95% |
| **Combined** | **69.54%** |

The first two principal components retain 69.54% of the total variance in the standardized features.

A 2D scatter plot was generated to visualize customer segments.

A 3D PCA visualization was also created using the first three principal components and Plotly.

The interactive visualization allows users to rotate the plot, zoom, and inspect customer details through hover information.

### Step 9: Customer Cluster Profiling

Each cluster was analyzed using average recency, frequency, monetary value, transaction value, quantity, and purchase frequency.

#### Cluster Profiles

| Cluster | Customers | Avg. Recency (Days) | Avg. Frequency | Avg. Monetary | Avg. Transaction Value | Avg. Quantity |
|---|---:|---:|---:|---:|---:|---:|
| 1 | 917 | 260.0 | 1.32 | 352 | 37.3 | 185 |
| 2 | 1,190 | 56.3 | 1.55 | 407 | 21.5 | 251 |
| 3 | 714 | 27.2 | 13.60 | 8,488 | 272.0 | 4,860 |
| 4 | 1,517 | 52.2 | 3.82 | 1,332 | 27.9 | 800 |

#### Cluster Interpretation

**Cluster 1 – Inactive or At-Risk Customers**

Customers in this cluster have high recency and relatively low purchase frequency and monetary value. They may require re-engagement campaigns.

**Cluster 2 – Occasional Customers**

Customers have relatively low purchase frequency and moderate recency. They may respond to personalized offers and incentives to encourage repeat purchases.

**Cluster 3 – High-Value Customers**

This segment has the lowest average recency, highest average purchase frequency, highest monetary value, and highest total quantity purchased. It was identified as the high-value customer segment.

**Cluster 4 – Regular Customers**

This segment contains the largest number of customers and has moderate recency, frequency, and monetary value. It represents customers who purchase regularly and may be encouraged to increase spending.

### Step 10: High-Value Customer Identification

The high-value cluster was identified using a score based on standardized cluster-level monetary value, frequency, and recency.

The scoring formula was:

Value Score = Z(Monetary) + Z(Frequency) − Z(Recency)

Cluster 3 received the highest value score and was selected as the high-value customer segment.

#### High-Value Customer Distribution

| Category | Customers | Percentage |
|---|---:|---:|
| High-Value (Yes) | 714 | 16.46% |
| Not High-Value (No) | 3,624 | 83.54% |
| **Total** | **4,338** | **100%** |

A binary target variable named `High_Value` was created using the cluster assignments.

### Step 11: Random Forest Classification

A Random Forest classification model was trained to predict whether a customer belongs to the high-value segment.

Model parameters:

- Number of trees: 300
- Training split: 80%
- Testing split: 20%
- Random seed: 123

The stratified split resulted in 3,472 training records and 866 testing records.

#### Random Forest Results

| Metric | Score |
|---|---:|
| Accuracy | 98.27% |
| Precision | 97.74% |
| Recall | 91.55% |
| F1-Score | 94.55% |
| ROC-AUC | 99.84% |

#### Confusion Matrix

| | Actual No | Actual Yes |
|---|---:|---:|
| Predicted No | 721 | 12 |
| Predicted Yes | 3 | 130 |

The Random Forest model correctly classified 721 non-high-value customers and 130 high-value customers in the test set.

### Step 12: Support Vector Machine (SVM)

An SVM classifier with a radial basis function (RBF) kernel was trained to predict high-value customer membership.

The predictor variables were standardized using training-set means and standard deviations.

Model parameters:

- Kernel: Radial
- Cost: 1
- Gamma: 1/6
- Probability estimation: Enabled

#### SVM Results

| Metric | Score |
|---|---:|
| Accuracy | 97.58% |
| Precision | 100.00% |
| Recall | 85.21% |
| F1-Score | 92.02% |
| ROC-AUC | 99.70% |

#### Confusion Matrix

| | Actual No | Actual Yes |
|---|---:|---:|
| Predicted No | 724 | 21 |
| Predicted Yes | 0 | 121 |

The SVM correctly classified 724 non-high-value customers and 121 high-value customers in the test set.

### Step 13: Model Performance Comparison

The two classification models were evaluated using Accuracy, Precision, Recall, F1-Score, ROC-AUC, and Confusion Matrix.

| Metric | Random Forest | SVM |
|---|---:|---:|
| Accuracy | 98.27% | 97.58% |
| Precision | 97.74% | 100.00% |
| Recall | 91.55% | 85.21% |
| F1-Score | 94.55% | 92.02% |
| ROC-AUC | 99.84% | 99.70% |

The results show that both models achieved high classification scores on the test set.

The Random Forest model had higher accuracy, recall, F1-score, and ROC-AUC in this experiment. The SVM had higher precision.

The ROC curves were plotted to compare the models' ability to distinguish between the two customer categories across classification thresholds.

### Step 14: Feature Importance Analysis

Random Forest feature importance was calculated to examine the contribution of customer features to classification.

The Mean Decrease in Gini values were:

| Feature | Mean Decrease in Gini |
|---|---:|
| Monetary | 296.70 |
| Frequency | 247.69 |
| Total_Quantity | 173.80 |
| Purchase_Frequency | 163.67 |
| Recency | 39.57 |
| Avg_Transaction_Value | 30.36 |

Monetary value, frequency, total quantity, and purchase frequency contributed substantially to the Random Forest's classification splits.

A feature importance plot was generated to visualize these values.

### Step 15: Interactive 3D PCA Visualization

An interactive 3D scatter plot was created using Plotly.

The plot uses PC1, PC2, and PC3 as the three axes, with customer clusters represented by different colors.

The visualization includes hover information containing:

- Customer ID
- Cluster assignment
- PC1 coordinate
- PC2 coordinate
- PC3 coordinate

The interactive plot was exported as a self-contained HTML file:

`outputs/14_interactive_3d_customer_clusters.html`

The file can be opened in a web browser to explore the customer clusters interactively.

### Step 16: Marketing Recommendations

Based on the purchasing behavior of the identified customer segments, the following marketing strategies were developed.

| Cluster | Customer Segment | Suggested Marketing Strategy |
|---|---|---|
| 1 | Inactive or At-Risk Customers | Send re-engagement emails, personalized discounts, and win-back offers. |
| 2 | Occasional Customers | Provide limited-time offers, product recommendations, and repeat-purchase incentives. |
| 3 | High-Value Customers | Offer loyalty rewards, exclusive promotions, early access to products, and personalized services. |
| 4 | Regular Customers | Encourage repeat purchases through loyalty programs, bundles, and cross-selling campaigns. |

These recommendations are based on the observed customer purchasing characteristics and are intended to support customer retention and engagement.

---

## 5. Project Structure

The project generates the following outputs:

```text
PS-7 (Customer Segmentation)/
│
├── README.md
├── customer_segmentation.R
├── Online_Retail.csv
│
└── outputs/
    ├── 01_top_countries.png
    ├── 02_transaction_distribution.png
    ├── 03_quantity_distribution.png
    ├── 02_cleaned_retail_data.csv
    ├── 03_missing_values.csv
    ├── 04_country_sales.csv
    ├── 04_elbow_method.png
    ├── 05_customer_features.csv
    ├── 05_silhouette_plot.png
    ├── 06_scaled_customer_features.csv
    ├── 06_hierarchical_dendrogram.png
    ├── 07_cluster_sizes.csv
    ├── 07_clustering_comparison.png
    ├── 08_kmeans_silhouette.csv
    ├── 08_pca_2d_clusters.png
    ├── 09_hierarchical_results.csv
    ├── 09_cluster_monetary_profile.png
    ├── 10_clustering_comparison.csv
    ├── 10_cluster_recency_profile.png
    ├── 11_pca_coordinates.csv
    ├── 11_random_forest_importance.png
    ├── 12_pca_loadings.csv
    ├── 12_roc_curve_comparison.png
    ├── 13_cluster_profiles.csv
    ├── 13_model_metrics_comparison.png
    ├── 14_high_value_cluster_analysis.csv
    ├── 14_interactive_3d_customer_clusters.html
    ├── 15_customer_data_with_target.csv
    ├── 16_random_forest_importance.csv
    ├── 17_model_performance_comparison.csv
    ├── 18_rf_confusion_matrix.csv
    ├── 19_svm_confusion_matrix.csv
    └── svm_model.rds
```

*Note: The structure lists the main outputs generated by the experiment. The R script and dataset should be placed in the project root, and the output directory should exist before running the script.*

---

## 6. How to Run the Project

### Prerequisites

- R installed on the system.
- RStudio installed.
- Online Retail CSV dataset downloaded from the UCI repository.
- Required R libraries installed.

### Execution Steps

1. Clone or download the project repository.
2. Place the Online Retail CSV dataset in the project directory.
3. Open the R script in RStudio.
4. Set the working directory to the project folder.
5. Install any missing R packages.
6. Execute the script sequentially from the beginning.
7. Check the generated files in the `outputs/` directory.
8. Open the interactive 3D PCA HTML file in a web browser.

The script uses a relative `outputs/` directory for saving the generated files.

---

## 7. Limitations

- The clustering results depend on feature selection, preprocessing, scaling, and the selected number of clusters.
- Hierarchical clustering was performed on a sample of 1,500 customers for computational efficiency.
- The high-value label was derived from the K-Means cluster assignment using the same customer features that were subsequently used for classification. Therefore, the Random Forest and SVM results measure how well the models reproduce the cluster-derived labels, rather than independently predicting future customer spending or future high-value status.
- The evaluation uses a random stratified train-test split and does not represent a time-based future-purchase validation.
- Marketing recommendations are derived from descriptive cluster profiles and have not been validated through real-world marketing campaigns.

---

## 8. Conclusion

This project demonstrates an end-to-end customer segmentation and predictive analytics workflow using R and machine learning.

The Online Retail dataset was cleaned and transformed into customer-level features using RFM metrics and purchasing behavior. K-Means and Hierarchical Clustering were applied to identify customer segments, and PCA was used to visualize their structure.

Four customer segments were identified, with Cluster 3 classified as the high-value segment based on its monetary value, purchase frequency, and recency characteristics.

Random Forest and SVM classification models were developed to predict membership in the cluster-derived high-value category. Both models achieved high test-set classification scores, and feature importance analysis identified monetary value and frequency as important variables in the Random Forest model.

Finally, segment-wise marketing recommendations were developed to support customer retention, engagement, loyalty, and personalized marketing.

The experiment provides practical exposure to data preprocessing, feature engineering, unsupervised learning, supervised classification, model evaluation, dimensionality reduction, and interactive visualization.

---

## 9. Author

**Student:** Ketaki Patil

**Program:** Computer Engineering 

**Experiment:** R Programming Lab – Lab 7

**Project:** Customer Segmentation and Predictive Analytics Using Machine Learning
```
