# ================================================================
# R PROGRAMMING LAB - ASSIGNMENT 8
# High-Performance Big Data Analytics Using R
# NYC Yellow Taxi Trip Records
# ================================================================


# ================================================================
# TASK 0: INSTALL AND LOAD REQUIRED PACKAGES
# ================================================================

# Run this installation section ONLY ONCE if packages are not
# already installed.

required_packages <- c(
  "arrow",
  "data.table",
  "ggplot2",
  "foreach",
  "doParallel",
  "microbenchmark",
  "purrr",
  "lubridate"
)

installed <- rownames(installed.packages())

for (pkg in required_packages) {
  if (!(pkg %in% installed)) {
    install.packages(pkg)
  }
}

# Load packages
library(arrow)
library(data.table)
library(ggplot2)
library(foreach)
library(doParallel)
library(microbenchmark)
library(purrr)
library(lubridate)


# ================================================================
# TASK 1: SET WORKING DIRECTORY
# ================================================================

setwd("C:/Users/KETAKI PATIL/R_programming/23102B0032_R-programming/PS-8")

cat("Working Directory:\n")
print(getwd())


# ================================================================
# TASK 1.1: CHECK FILES
# ================================================================

cat("\nFiles available in the folder:\n")
print(list.files())


# ================================================================
# TASK 1.2: IMPORT NYC YELLOW TAXI PARQUET DATA
# ================================================================

cat("\nReading Yellow Taxi Trip data...\n")

taxi <- read_parquet("yellow_tripdata_2026-08.parquet")

# Convert to data.table
taxi <- as.data.table(taxi)

cat("Taxi data loaded successfully.\n")


# ================================================================
# TASK 1.3: IMPORT TAXI ZONE LOOKUP
# ================================================================

zone_lookup <- fread("taxi_zone_lookup.csv")

cat("\nTaxi Zone Lookup loaded successfully.\n")


# ================================================================
# TASK 1.4: BASIC DATA INSPECTION
# ================================================================

cat("\n================ DATA DIMENSIONS ================\n")
print(dim(taxi))

cat("\nNumber of rows:\n")
print(nrow(taxi))

cat("\nNumber of columns:\n")
print(ncol(taxi))

cat("\nColumn names:\n")
print(names(taxi))

cat("\nStructure:\n")
str(taxi)

cat("\nSummary:\n")
print(summary(taxi))


# ================================================================
# TASK 1.5: LOOK AT FIRST FEW RECORDS
# ================================================================

cat("\nFirst 10 taxi records:\n")
print(head(taxi, 10))

cat("\nTaxi Zone Lookup:\n")
print(head(zone_lookup, 10))


# ================================================================
# TASK 1.6: MISSING VALUE ANALYSIS
# ================================================================

cat("\n================ MISSING VALUES ================\n")

missing_values <- sapply(taxi, function(x) sum(is.na(x)))

missing_table <- data.table(
  Column = names(missing_values),
  Missing_Count = as.numeric(missing_values)
)

missing_table <- missing_table[order(-Missing_Count)]

print(missing_table)


# ================================================================
# TASK 1.7: DUPLICATE ANALYSIS
# ================================================================

cat("\n================ DUPLICATE ANALYSIS ================\n")

duplicate_count <- sum(duplicated(taxi))

cat("Number of duplicate rows:", duplicate_count, "\n")


# ================================================================
# TASK 1.8: CHECK DATA TYPES
# ================================================================

cat("\n================ DATA TYPES ================\n")

print(sapply(taxi, class))


# ================================================================
# TASK 1.9: IDENTIFY DATE COLUMNS
# ================================================================

# NYC TLC files normally use tpep_pickup_datetime and
# tpep_dropoff_datetime for Yellow Taxi data.

cat("\nDate columns:\n")

print(
  names(taxi)[
    grepl(
      "pickup|dropoff",
      names(taxi),
      ignore.case = TRUE
    )
  ]
)


# ================================================================
# TASK 1.10: CONVERT DATE-TIME COLUMNS
# ================================================================

if ("tpep_pickup_datetime" %in% names(taxi)) {
  
  taxi[, tpep_pickup_datetime :=
         as.POSIXct(
           tpep_pickup_datetime,
           tz = "America/New_York"
         )]
  
}

if ("tpep_dropoff_datetime" %in% names(taxi)) {
  
  taxi[, tpep_dropoff_datetime :=
         as.POSIXct(
           tpep_dropoff_datetime,
           tz = "America/New_York"
         )]
  
}


# ================================================================
# TASK 1.11: CREATE TEMPORAL ATTRIBUTES
# ================================================================

if ("tpep_pickup_datetime" %in% names(taxi)) {
  
  taxi[, pickup_hour :=
         hour(tpep_pickup_datetime)]
  
  taxi[, pickup_day :=
         day(tpep_pickup_datetime)]
  
  taxi[, pickup_day_of_week :=
         wday(
           tpep_pickup_datetime,
           label = TRUE,
           abbr = FALSE
         )]
  
  taxi[, pickup_month :=
         month(
           tpep_pickup_datetime,
           label = TRUE,
           abbr = FALSE
         )]
  
}


# ================================================================
# TASK 1.12: DATA CLEANING
# ================================================================

cat("\n================ DATA CLEANING ================\n")

rows_before <- nrow(taxi)

# Remove invalid records
# Keep reasonable positive trip distances and fares.
# Passenger count can be zero/NA in TLC data, so we do not
# require passenger_count > 0.

if ("trip_distance" %in% names(taxi)) {
  taxi <- taxi[
    is.na(trip_distance) |
      trip_distance >= 0
  ]
}

if ("fare_amount" %in% names(taxi)) {
  taxi <- taxi[
    is.na(fare_amount) |
      fare_amount >= 0
  ]
}

if ("total_amount" %in% names(taxi)) {
  taxi <- taxi[
    is.na(total_amount) |
      total_amount >= 0
  ]
}

rows_after <- nrow(taxi)

cat("Rows before cleaning:", rows_before, "\n")
cat("Rows after cleaning :", rows_after, "\n")
cat("Rows removed        :", rows_before - rows_after, "\n")


# ================================================================
# TASK 1.13: TAXI ZONE LOOKUP PREPARATION
# ================================================================

cat("\n================ ZONE LOOKUP ================\n")

print(names(zone_lookup))

# Convert LocationID to integer
if ("LocationID" %in% names(zone_lookup)) {
  zone_lookup[, LocationID := as.integer(LocationID)]
}


# ================================================================
# TASK 1.14: JOIN PICKUP ZONE INFORMATION
# ================================================================

if ("PULocationID" %in% names(taxi)) {
  
  pickup_lookup <- copy(zone_lookup)
  
  setnames(
    pickup_lookup,
    old = c("LocationID", "Borough", "Zone"),
    new = c(
      "PULocationID",
      "PU_Borough",
      "PU_Zone"
    ),
    skip_absent = TRUE
  )
  
  taxi <- pickup_lookup[
    taxi,
    on = "PULocationID"
  ]
  
}


# ================================================================
# TASK 1.15: JOIN DROP-OFF ZONE INFORMATION
# ================================================================

if ("DOLocationID" %in% names(taxi)) {
  
  dropoff_lookup <- copy(zone_lookup)
  
  setnames(
    dropoff_lookup,
    old = c("LocationID", "Borough", "Zone"),
    new = c(
      "DOLocationID",
      "DO_Borough",
      "DO_Zone"
    ),
    skip_absent = TRUE
  )
  
  taxi <- dropoff_lookup[
    taxi,
    on = "DOLocationID"
  ]
  
}


cat("\nZone information joined successfully.\n")


# ================================================================
# TASK 2: TRANSPORTATION DATA ANALYTICS
# ================================================================


# ================================================================
# 2.1 NUMBER OF TRIPS BY HOUR
# ================================================================

cat("\n================ TRIPS BY HOUR ================\n")

trips_by_hour <- taxi[
  !is.na(pickup_hour),
  .(Number_of_Trips = .N),
  by = pickup_hour
]

setorder(trips_by_hour, pickup_hour)

print(trips_by_hour)


# ================================================================
# 2.2 TAXI DEMAND BY DAY OF WEEK
# ================================================================

cat("\n================ TRIPS BY DAY ================\n")

trips_by_day <- taxi[
  !is.na(pickup_day_of_week),
  .(Number_of_Trips = .N),
  by = pickup_day_of_week
]

print(trips_by_day)


# ================================================================
# 2.3 MONTHLY TAXI DEMAND
# ================================================================

cat("\n================ MONTHLY DEMAND ================\n")

trips_by_month <- taxi[
  !is.na(pickup_month),
  .(Number_of_Trips = .N),
  by = pickup_month
]

print(trips_by_month)


# ================================================================
# 2.4 AVERAGE FARE BY HOUR
# ================================================================

cat("\n================ AVERAGE FARE BY HOUR ================\n")

if ("fare_amount" %in% names(taxi)) {
  
  avg_fare_by_hour <- taxi[
    !is.na(pickup_hour) &
      !is.na(fare_amount),
    .(
      Average_Fare = mean(
        fare_amount,
        na.rm = TRUE
      ),
      Number_of_Trips = .N
    ),
    by = pickup_hour
  ]
  
  setorder(avg_fare_by_hour, pickup_hour)
  
  print(avg_fare_by_hour)
  
}


# ================================================================
# 2.5 TOTAL REVENUE BY HOUR
# ================================================================

cat("\n================ TOTAL REVENUE BY HOUR ================\n")

if ("total_amount" %in% names(taxi)) {
  
  revenue_by_hour <- taxi[
    !is.na(pickup_hour) &
      !is.na(total_amount),
    .(
      Total_Revenue = sum(
        total_amount,
        na.rm = TRUE
      )
    ),
    by = pickup_hour
  ]
  
  setorder(revenue_by_hour, pickup_hour)
  
  print(revenue_by_hour)
  
}


# ================================================================
# 2.6 MOST FREQUENTLY TRAVELLED ROUTES
# ================================================================

cat("\n================ TOP ROUTES ================\n")

if (
  "PU_Zone" %in% names(taxi) &
  "DO_Zone" %in% names(taxi)
) {
  
  top_routes <- taxi[
    !is.na(PU_Zone) &
      !is.na(DO_Zone),
    .(Number_of_Trips = .N),
    by = .(
      Pickup_Zone = PU_Zone,
      Dropoff_Zone = DO_Zone
    )
  ]
  
  setorder(
    top_routes,
    -Number_of_Trips
  )
  
  top_routes <- head(top_routes, 10)
  
  print(top_routes)
  
}


# ================================================================
# 2.7 HIGHEST-REVENUE ROUTES
# ================================================================

cat("\n================ HIGHEST REVENUE ROUTES ================\n")

if (
  "PU_Zone" %in% names(taxi) &
  "DO_Zone" %in% names(taxi) &
  "total_amount" %in% names(taxi)
) {
  
  revenue_routes <- taxi[
    !is.na(PU_Zone) &
      !is.na(DO_Zone) &
      !is.na(total_amount),
    .(
      Total_Revenue = sum(
        total_amount,
        na.rm = TRUE
      ),
      Number_of_Trips = .N
    ),
    by = .(
      Pickup_Zone = PU_Zone,
      Dropoff_Zone = DO_Zone
    )
  ]
  
  setorder(
    revenue_routes,
    -Total_Revenue
  )
  
  revenue_routes <- head(
    revenue_routes,
    10
  )
  
  print(revenue_routes)
  
}


# ================================================================
# 2.8 TRIP DISTANCE VS FARE
# ================================================================

cat("\n================ DISTANCE VS FARE ================\n")

if (
  "trip_distance" %in% names(taxi) &
  "fare_amount" %in% names(taxi)
) {
  
  distance_fare <- taxi[
    !is.na(trip_distance) &
      !is.na(fare_amount) &
      trip_distance > 0 &
      fare_amount > 0
  ]
  
  correlation <- cor(
    distance_fare$trip_distance,
    distance_fare$fare_amount,
    use = "complete.obs"
  )
  
  cat(
    "Correlation between trip distance and fare:",
    round(correlation, 4),
    "\n"
  )
  
}


# ================================================================
# 2.9 PAYMENT TYPE ANALYSIS
# ================================================================

cat("\n================ PAYMENT TYPE ================\n")

if ("payment_type" %in% names(taxi)) {
  
  payment_analysis <- taxi[
    !is.na(payment_type),
    .(
      Number_of_Trips = .N,
      Total_Revenue =
        if ("total_amount" %in% names(taxi))
          sum(total_amount, na.rm = TRUE)
      else
        NA_real_
    ),
    by = payment_type
  ]
  
  setorder(
    payment_analysis,
    -Number_of_Trips
  )
  
  print(payment_analysis)
  
}


# ================================================================
# 2.10 PAYMENT TYPE BY BOROUGH
# ================================================================

cat("\n================ PAYMENT BY BOROUGH ================\n")

if (
  "payment_type" %in% names(taxi) &
  "PU_Borough" %in% names(taxi)
) {
  
  payment_borough <- taxi[
    !is.na(payment_type) &
      !is.na(PU_Borough),
    .(
      Number_of_Trips = .N
    ),
    by = .(
      Borough = PU_Borough,
      Payment_Type = payment_type
    )
  ]
  
  setorder(
    payment_borough,
    Borough,
    -Number_of_Trips
  )
  
  print(payment_borough)
  
}


# ================================================================
# TASK 3: FUNCTIONAL PROGRAMMING
# ================================================================


# ================================================================
# 3.1 APPLY()
# Calculate summary statistics for selected numeric columns
# ================================================================

cat("\n================ APPLY() ================\n")

numeric_columns <- c(
  "trip_distance",
  "fare_amount",
  "total_amount"
)

numeric_columns <- numeric_columns[
  numeric_columns %in% names(taxi)
]

apply_result <- sapply(
  taxi[, ..numeric_columns],
  function(x) {
    mean(x, na.rm = TRUE)
  }
)

print(apply_result)


# ================================================================
# 3.2 Lapply()
# ================================================================

cat("\n================ LAPPLY() ================\n")

lapply_result <- lapply(
  taxi[, ..numeric_columns],
  function(x) {
    c(
      Mean = mean(x, na.rm = TRUE),
      Median = median(x, na.rm = TRUE),
      SD = sd(x, na.rm = TRUE)
    )
  }
)

print(lapply_result)


# ================================================================
# 3.3 PURRR::MAP()
# ================================================================

cat("\n================ PURRR::MAP() ================\n")

map_result <- map(
  taxi[, ..numeric_columns],
  ~ mean(.x, na.rm = TRUE)
)

print(map_result)


# ================================================================
# TASK 3.4: VECTORIZED IMPLEMENTATION
# ================================================================

cat("\n================ VECTORIZED ================\n")

if ("fare_amount" %in% names(taxi)) {
  
  vectorized_mean_fare <-
    mean(
      taxi$fare_amount,
      na.rm = TRUE
    )
  
  cat(
    "Vectorized mean fare:",
    vectorized_mean_fare,
    "\n"
  )
  
}


# ================================================================
# TASK 3.5: DATA.TABLE IMPLEMENTATION
# ================================================================

cat("\n================ DATA.TABLE ================\n")

if ("fare_amount" %in% names(taxi)) {
  
  data_table_mean_fare <- taxi[
    ,
    mean(
      fare_amount,
      na.rm = TRUE
    )
  ]
  
  cat(
    "data.table mean fare:",
    data_table_mean_fare,
    "\n"
  )
  
}


# ================================================================
# TASK 4: SEQUENTIAL PROCESSING
# ================================================================

cat("\n================ SEQUENTIAL PROCESSING ================\n")


# Divide data month-wise.
# Since this dataset is one month, we create partitions based
# on pickup day to demonstrate partitioned processing.

if ("pickup_day" %in% names(taxi)) {
  
  partitions <- split(
    taxi,
    taxi$pickup_day
  )
  
} else {
  
  partitions <- split(
    taxi,
    seq_len(nrow(taxi)) %% 4
  )
  
}


# Function for computational operation
calculate_partition <- function(data) {
  
  if (
    "fare_amount" %in% names(data) &
    "trip_distance" %in% names(data)
  ) {
    
    data[
      ,
      .(
        Trips = .N,
        Average_Fare =
          mean(
            fare_amount,
            na.rm = TRUE
          ),
        Average_Distance =
          mean(
            trip_distance,
            na.rm = TRUE
          ),
        Total_Revenue =
          if ("total_amount" %in% names(data))
            sum(
              total_amount,
              na.rm = TRUE
            )
        else
          NA_real_
      )
    ]
    
  } else {
    
    data.table(
      Trips = nrow(data)
    )
    
  }
  
}


# Sequential execution
sequential_time <- system.time({
  
  sequential_results <- lapply(
    partitions,
    calculate_partition
  )
  
})


cat("\nSequential execution time:\n")
print(sequential_time)


# Combine sequential results
sequential_table <- rbindlist(
  sequential_results,
  fill = TRUE
)

cat("\nSequential results:\n")
print(sequential_table)


# ================================================================
# TASK 4.1: PARALLEL PROCESSING
# ================================================================

cat("\n================ PARALLEL PROCESSING ================\n")


# Determine number of cores
available_cores <- parallel::detectCores()

cat(
  "Available CPU cores:",
  available_cores,
  "\n"
)


# Use at most 4 cores
cores_to_use <- min(
  4,
  max(1, available_cores - 1)
)

cat(
  "Cores used for parallel processing:",
  cores_to_use,
  "\n"
)


# Create cluster
cl <- makeCluster(
  cores_to_use
)

registerDoParallel(cl)


# Parallel execution
parallel_time <- system.time({
  
  parallel_results <- foreach(
    partition = partitions,
    .combine = rbind,
    .packages = "data.table"
  ) %dopar% {
    
    calculate_partition(partition)
    
  }
  
})


# Stop cluster
stopCluster(cl)

registerDoSEQ()


cat("\nParallel execution time:\n")
print(parallel_time)


cat("\nParallel results:\n")
print(parallel_results)


# ================================================================
# TASK 4.2: SPEEDUP
# ================================================================

sequential_seconds <-
  as.numeric(
    sequential_time["elapsed"]
  )

parallel_seconds <-
  as.numeric(
    parallel_time["elapsed"]
  )


if (parallel_seconds > 0) {
  
  speedup <-
    sequential_seconds /
    parallel_seconds
  
} else {
  
  speedup <- NA
  
}


cat("\n================ SPEEDUP ================\n")

cat(
  "Sequential time:",
  sequential_seconds,
  "seconds\n"
)

cat(
  "Parallel time:",
  parallel_seconds,
  "seconds\n"
)

cat(
  "Speedup:",
  round(speedup, 4),
  "\n"
)


# ================================================================
# TASK 5: PERFORMANCE BENCHMARKING
# ================================================================


# ================================================================
# 5.1 BASE R / VECTORIZED VS DATA.TABLE
# ================================================================

cat("\n================ MICROBENCHMARK ================\n")


# Use a smaller representative vector if dataset is very large
# to keep benchmarking practical.

if ("fare_amount" %in% names(taxi)) {
  
  fare_vector <- taxi$fare_amount
  
  benchmark_result <- microbenchmark(
    
    Vectorized_Mean = {
      mean(
        fare_vector,
        na.rm = TRUE
      )
    },
    
    DataTable_Mean = {
      taxi[
        ,
        mean(
          fare_amount,
          na.rm = TRUE
        )
      ]
    },
    
    Apply_Mean = {
      sapply(
        list(fare_vector),
        function(x)
          mean(
            x,
            na.rm = TRUE
          )
      )
    },
    
    times = 10
    
  )
  
  print(benchmark_result)
  
  cat("\nBenchmark summary:\n")
  
  benchmark_summary <- summary(
    benchmark_result
  )
  
  print(benchmark_summary)
  
}


# ================================================================
# TASK 5.2: CREATE EXECUTION-TIME COMPARISON TABLE
# ================================================================

comparison_table <- data.table(
  
  Method = c(
    "Sequential",
    "Parallel"
  ),
  
  Execution_Time_Seconds = c(
    sequential_seconds,
    parallel_seconds
  )
  
)

comparison_table[
  ,
  Speedup := sequential_seconds /
    Execution_Time_Seconds
]

cat("\n================ EXECUTION COMPARISON ================\n")

print(comparison_table)


# ================================================================
# TASK 6: DATA VISUALIZATION
# ================================================================


# ================================================================
# 6.1 NUMBER OF TRIPS BY HOUR
# ================================================================

if (exists("trips_by_hour")) {
  
  p1 <- ggplot(
    trips_by_hour,
    aes(
      x = pickup_hour,
      y = Number_of_Trips
    )
  ) +
    
    geom_col() +
    
    labs(
      title = "Number of Taxi Trips by Hour",
      x = "Hour of Day",
      y = "Number of Trips"
    ) +
    
    theme_minimal()
  
  print(p1)
  
  ggsave(
    "01_trips_by_hour.png",
    p1,
    width = 8,
    height = 5
  )
  
}


# ================================================================
# 6.2 TAXI DEMAND BY DAY
# ================================================================

if (exists("trips_by_day")) {
  
  p2 <- ggplot(
    trips_by_day,
    aes(
      x = pickup_day_of_week,
      y = Number_of_Trips
    )
  ) +
    
    geom_col() +
    
    labs(
      title = "Taxi Demand by Day of Week",
      x = "Day of Week",
      y = "Number of Trips"
    ) +
    
    theme_minimal()
  
  print(p2)
  
  ggsave(
    "02_trips_by_day.png",
    p2,
    width = 8,
    height = 5
  )
  
}


# ================================================================
# 6.3 MONTHLY TAXI DEMAND
# ================================================================

if (exists("trips_by_month")) {
  
  p3 <- ggplot(
    trips_by_month,
    aes(
      x = pickup_month,
      y = Number_of_Trips
    )
  ) +
    
    geom_col() +
    
    labs(
      title = "Monthly Taxi Demand",
      x = "Month",
      y = "Number of Trips"
    ) +
    
    theme_minimal()
  
  print(p3)
  
  ggsave(
    "03_monthly_demand.png",
    p3,
    width = 8,
    height = 5
  )
  
}


# ================================================================
# 6.4 AVERAGE FARE BY HOUR
# ================================================================

if (exists("avg_fare_by_hour")) {
  
  p4 <- ggplot(
    avg_fare_by_hour,
    aes(
      x = pickup_hour,
      y = Average_Fare
    )
  ) +
    
    geom_line() +
    
    geom_point() +
    
    labs(
      title = "Average Fare by Hour",
      x = "Hour of Day",
      y = "Average Fare ($)"
    ) +
    
    theme_minimal()
  
  print(p4)
  
  ggsave(
    "04_average_fare_by_hour.png",
    p4,
    width = 8,
    height = 5
  )
  
}


# ================================================================
# 6.5 REVENUE BY HOUR
# ================================================================

if (exists("revenue_by_hour")) {
  
  p5 <- ggplot(
    revenue_by_hour,
    aes(
      x = pickup_hour,
      y = Total_Revenue
    )
  ) +
    
    geom_col() +
    
    labs(
      title = "Total Taxi Revenue by Hour",
      x = "Hour of Day",
      y = "Total Revenue ($)"
    ) +
    
    theme_minimal()
  
  print(p5)
  
  ggsave(
    "05_revenue_by_hour.png",
    p5,
    width = 8,
    height = 5
  )
  
}


# ================================================================
# 6.6 TRIP DISTANCE VS FARE
# ================================================================

if (
  exists("distance_fare") &&
  nrow(distance_fare) > 0
) {
  
  # Sample for visualization so the plot remains manageable.
  set.seed(123)
  
  plot_data <- distance_fare[
    sample(
      .N,
      min(.N, 10000)
    )
  ]
  
  p6 <- ggplot(
    plot_data,
    aes(
      x = trip_distance,
      y = fare_amount
    )
  ) +
    
    geom_point(
      alpha = 0.3
    ) +
    
    labs(
      title = "Trip Distance vs Fare Amount",
      x = "Trip Distance (miles)",
      y = "Fare Amount ($)"
    ) +
    
    theme_minimal()
  
  print(p6)
  
  ggsave(
    "06_distance_vs_fare.png",
    p6,
    width = 8,
    height = 5
  )
  
}


# ================================================================
# 6.7 PAYMENT TYPE DISTRIBUTION
# ================================================================

if (exists("payment_analysis")) {
  
  payment_plot_data <- payment_analysis
  
  p7 <- ggplot(
    payment_plot_data,
    aes(
      x = factor(payment_type),
      y = Number_of_Trips
    )
  ) +
    
    geom_col() +
    
    labs(
      title = "Taxi Trips by Payment Type",
      x = "Payment Type",
      y = "Number of Trips"
    ) +
    
    theme_minimal()
  
  print(p7)
  
  ggsave(
    "07_payment_type.png",
    p7,
    width = 8,
    height = 5
  )
  
}


# ================================================================
# TASK 7: SAVE IMPORTANT RESULTS
# ================================================================


fwrite(
  trips_by_hour,
  "results_trips_by_hour.csv"
)

fwrite(
  trips_by_day,
  "results_trips_by_day.csv"
)

fwrite(
  trips_by_month,
  "results_trips_by_month.csv"
)

if (exists("avg_fare_by_hour")) {
  
  fwrite(
    avg_fare_by_hour,
    "results_average_fare.csv"
  )
  
}

if (exists("revenue_by_hour")) {
  
  fwrite(
    revenue_by_hour,
    "results_revenue.csv"
  )
  
}

if (exists("top_routes")) {
  
  fwrite(
    top_routes,
    "results_top_routes.csv"
  )
  
}

if (exists("revenue_routes")) {
  
  fwrite(
    revenue_routes,
    "results_revenue_routes.csv"
  )
  
}

if (exists("payment_analysis")) {
  
  fwrite(
    payment_analysis,
    "results_payment_analysis.csv"
  )
  
}

fwrite(
  comparison_table,
  "results_execution_comparison.csv"
)


# ================================================================
# TASK 7.1: SAVE BENCHMARK RESULTS
# ================================================================

if (exists("benchmark_summary")) {
  
  fwrite(
    as.data.table(benchmark_summary),
    "results_benchmark.csv"
  )
  
}


# ================================================================
# FINAL SUMMARY
# ================================================================

cat("\n\n")
cat("====================================================\n")
cat("              EXPERIMENT COMPLETED\n")
cat("====================================================\n")

cat("\nDataset rows processed:", nrow(taxi), "\n")
cat("Dataset columns:", ncol(taxi), "\n")

cat(
  "\nSequential execution time:",
  sequential_seconds,
  "seconds\n"
)

cat(
  "Parallel execution time:",
  parallel_seconds,
  "seconds\n"
)

cat(
  "Parallel speedup:",
  round(speedup, 4),
  "\n"
)

cat("\nResults and plots have been saved in:\n")
cat(getwd(), "\n")

cat("\nGenerated output files include:\n")

print(
  list.files(
    pattern = "^(results_|0[1-7]_).*"
  )
)

cat("\n====================================================\n")
cat("                 END OF EXPERIMENT\n")
cat("====================================================\n")