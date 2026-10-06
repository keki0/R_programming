# Laboratory Assignment 8: High-Performance Big Data Analytics Using R
## 📌 Overview

This project implements a high-performance and scalable data analytics workflow in R using the NYC Yellow Taxi Trip Records dataset.

The experiment demonstrates different approaches for processing and analyzing large-scale transportation data, including:

- Efficient data manipulation using data.table

- Functional programming using apply(), lapply(), and purrr::map()

- Vectorized R operations

- Sequential processing

- Parallel processing using foreach and doParallel

- Performance benchmarking using microbenchmark and system.time()

- Data visualization using ggplot2

The objective is to compare these approaches in terms of execution time, computational efficiency, memory utilization, scalability, readability, and suitability for large datasets.
---

## 🎯 Objectives

The main objectives of this experiment are:

1. Process and analyze large-scale NYC taxi trip data using R.

2. Perform efficient filtering, grouping, aggregation, and joining using data.table.

3. Analyze taxi travel patterns and demand.

4. Implement analytical operations using functional programming techniques.

5. Compare functional programming with vectorized and data.table approaches.

6. Implement sequential and parallel processing.

7. Benchmark different implementations based on execution time.

8. Calculate the speedup achieved through parallel processing.

9. Generate meaningful visualizations using ggplot2.

10. Critically evaluate different R programming approaches for large-scale analytics.

--- 

## 📊 Dataset

The experiment uses the NYC Taxi & Limousine Commission (TLC) Yellow Taxi Trip Records.

Files Used

The project uses two datasets:

1. Yellow Taxi Trip Data
yellow_tripdata_2026-08.parquet


This contains the taxi trip records for August 2026.

The dataset contains information such as:

Pickup date and time

Drop-off date and time

Pickup Location ID

Drop-off Location ID

Passenger count

Trip distance

Fare amount

Tip amount

Tolls

Total amount

Payment type

2. Taxi Zone Lookup
taxi_zone_lookup.csv


This lookup table is used to map taxi LocationID values to their corresponding:

Borough

Zone

Service zone

The assignment requires joining the trip records with the Taxi Zone Lookup Table to obtain meaningful geographic information.
---
## 🛠️ Technologies and Libraries

The project is implemented using R and the following packages:

Package	Purpose
arrow	Reading Parquet datasets
data.table	High-performance data manipulation
ggplot2	Data visualization
foreach	Parallel iteration
doParallel	Parallel backend
microbenchmark	Performance benchmarking
purrr	Functional programming
lubridate	Date and time manipulation
📁 Project Structure
PS-8/
│
├── PS-8.R
├── yellow_tripdata_2026-08.parquet
├── taxi_zone_lookup.csv
│
├── 01_trips_by_hour.png
├── 02_trips_by_day.png
├── 03_monthly_demand.png
├── 04_average_fare_by_hour.png
├── 05_revenue_by_hour.png
├── 06_distance_vs_fare.png
├── 07_payment_type.png
│
├── results_trips_by_hour.csv
├── results_trips_by_day.csv
├── results_trips_by_month.csv
├── results_average_fare.csv
├── results_revenue.csv
├── results_top_routes.csv
├── results_revenue_routes.csv
├── results_payment_analysis.csv
├── results_execution_comparison.csv
└── results_benchmark.csv
---
## 🔬 Experiment Implementation
1. Data Acquisition and Preparation

The Yellow Taxi Trip data is loaded from the Parquet file using the arrow package.

The data is then converted into a data.table object for efficient processing.

The following preprocessing operations are performed:

Dataset structure inspection

Dimension checking

Data type inspection

Missing value analysis

Duplicate record analysis

Data cleaning

Date-time conversion

Extraction of temporal attributes

The following temporal attributes are derived:

Hour

Day

Day of week

Month

The Taxi Zone Lookup Table is then joined with the trip dataset using pickup and drop-off Location IDs.

2. Transportation Data Analytics

The experiment performs several analytical operations using data.table.

Trip Demand

Taxi demand is analyzed according to:

Hour of the day

Day of the week

Month

Fare and Revenue Analysis

The analysis includes:

Average fare by hour

Total revenue by hour

Total revenue by route

Route Analysis

The most frequently travelled pickup-drop-off routes are identified.

The highest-revenue routes are also calculated based on total transaction amount.

Trip Distance and Fare

The relationship between trip distance and fare amount is analyzed using correlation and visualization.

Payment Analysis

Different payment methods are compared based on:

Number of trips

Revenue

Borough
---
## 🧩 Functional Programming

The experiment implements analytical operations using different functional programming approaches.

apply() / sapply()

Used to calculate statistics such as mean values across selected numerical variables.

lapply()

Used to calculate multiple statistics including:

Mean

Median

Standard deviation

purrr::map()

Used to apply analytical functions across selected columns.

These implementations are compared with vectorized and data.table approaches.
---
## ⚡ Vectorized Operations

Vectorized R operations are implemented for computational tasks such as calculating the mean fare.

Vectorized operations avoid explicit iteration over individual records and can provide efficient execution for suitable numerical operations.
---
## 🚀 data.table Implementation

data.table is used extensively for:

- Filtering

- Grouping

- Aggregation

- Joining

- Route analysis

- Revenue calculations

- Demand analysis

The use of data.table provides an efficient and memory-conscious approach for processing large datasets.
---
## 🖥️ Sequential Processing

The dataset is divided into logical partitions based on pickup day.

Each partition is processed sequentially using lapply().

The execution time is measured using:

system.time()


The sequential execution time is stored for comparison with the parallel implementation.
---
## 🔀 Parallel Processing

Parallel processing is implemented using:

foreach

doParallel

The available CPU cores are detected and an appropriate number of cores is selected.

The same partitioned analysis is executed in parallel.

The parallel execution time is then compared with the sequential execution time.
---
## 📈 Speedup Calculation

Parallel performance is evaluated using the following formula:

Speedup = Sequential Execution Time / Parallel Execution Time


A speedup value greater than 1 indicates that the parallel implementation executed faster than the sequential implementation.

The actual speedup obtained during execution is recorded in:

results_execution_comparison.csv
---
## ⏱️ Performance Benchmarking

Performance comparisons are performed using:

system.time()

microbenchmark

The experiment compares different implementation approaches, including:

Vectorized operations

data.table

Functional programming

Sequential processing

Parallel processing

The benchmark results are saved in:

results_benchmark.csv


Execution-time comparisons are saved in:

results_execution_comparison.csv
---
## 📊 Data Visualizations

The experiment generates visualizations using ggplot2.

The following plots are produced:

1. Trips by Hour
01_trips_by_hour.png


Shows the number of taxi trips for each hour of the day.

2. Trips by Day
02_trips_by_day.png


Shows taxi demand across different days of the week.

3. Monthly Demand
03_monthly_demand.png


Shows taxi usage across months represented in the dataset.

4. Average Fare by Hour
04_average_fare_by_hour.png


Shows how average taxi fare varies throughout the day.

5. Revenue by Hour
05_revenue_by_hour.png


Shows total taxi revenue for different hours.

6. Distance vs Fare
06_distance_vs_fare.png


Shows the relationship between trip distance and fare amount.

7. Payment Type Distribution
07_payment_type.png


Shows the distribution of taxi trips across payment types.
---
## 📁 Output Files

The analysis results are exported as CSV files for further analysis and reporting.

Important output files include:

results_trips_by_hour.csv
results_trips_by_day.csv
results_trips_by_month.csv
results_average_fare.csv
results_revenue.csv
results_top_routes.csv
results_revenue_routes.csv
results_payment_analysis.csv
results_execution_comparison.csv
results_benchmark.csv
---
## ▶️ How to Run
Step 1: Open RStudio

Open the project folder in RStudio.

Step 2: Make Sure the Required Files Are Present
PS-8/
├── PS-8.R
├── yellow_tripdata_2026-08.parquet
└── taxi_zone_lookup.csv

Step 3: Install the Required Packages

The R script automatically checks for and installs missing packages.

Step 4: Run the Script

Open:

PS-8.R


Then run the complete script using:

Ctrl + A
Ctrl + Enter


Alternatively, execute the sections sequentially.

Step 5: Check the Generated Results

After execution, the result CSV files and visualization PNG files will be generated in the same directory.
---
## 📌 Key Findings and Interpretation

The experiment demonstrates that different R programming approaches have different computational characteristics.

data.table

data.table is highly suitable for large-scale data manipulation because it provides efficient filtering, grouping, aggregation, joining, and memory-conscious operations.

Vectorized Operations

Vectorized operations are efficient for suitable numerical computations because they avoid unnecessary explicit iteration.

Functional Programming

apply(), lapply(), and purrr::map() provide readable and reusable approaches for repeated analytical operations. They are particularly useful when applying the same function across multiple objects or variables.

Parallel Processing

Parallel processing can reduce execution time when the workload is sufficiently large and can be divided into independent tasks. However, parallel processing introduces overhead associated with creating workers and distributing data.

Therefore, parallel processing does not necessarily provide an advantage for every workload.

Benchmarking

Actual execution times are hardware- and dataset-dependent. The benchmark results generated by the experiment should therefore be used to determine which approach performed best in the current environment.
---
## 🧠 Critical Analysis

Based on the experiment:

data.table is well suited for large-scale data manipulation and aggregation.

Vectorized operations are preferable for simple numerical operations that can be expressed without explicit iteration.

Functional programming improves code organization and allows functions to be applied systematically across multiple variables or partitions.

Parallel processing is beneficial when computational workloads are sufficiently large and independent.

Parallel processing introduces overhead, so it may not always be faster than sequential execution.

Execution speed, memory usage, readability, and scalability must all be considered when selecting an implementation.

Benchmarking provides experimental evidence for comparing alternative implementations rather than assuming that one approach is always superior.
---
## ✅ Conclusion

This experiment demonstrated an end-to-end high-performance analytics workflow using R and the NYC Yellow Taxi Trip dataset.

The experiment covered:

- Data preparation

- Efficient data manipulation using data.table

- Functional programming

- Vectorized operations

- Sequential processing

- Parallel processing

- Performance benchmarking

- Data visualization

The results demonstrate the importance of selecting an appropriate computational approach based on dataset size, workload characteristics, execution time, memory requirements, scalability, and code readability.

For large-scale analytical applications, optimized approaches such as data.table, vectorized operations, and appropriately designed parallel processing can provide significant computational benefits.
---
## 📚 Dataset Source

NYC Taxi & Limousine Commission (TLC) — Trip Record Data

https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page
---
## 🎓 Course Information
	
Laboratory Assignment	8
Subject	R Programming
Topic	High-Performance Big Data Analytics Using R
Dataset	NYC Yellow Taxi Trip Records
Language	R