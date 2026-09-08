# Lab 3 – Multi-Source Retail Sales Data Integration and Analysis

## Objective

To integrate retail data from multiple sources, clean and transform the data, perform sales and customer analysis, and store the processed data using SQLite.

## Datasets

The experiment uses three data sources:

- `transactions.csv`
- `products.json`
- `customers.xlsx`

## Tasks Performed

- Imported data from CSV, JSON, and Excel files.
- Inspected and cleaned the datasets.
- Removed duplicate and invalid records.
- Integrated transactions with product and customer data.
- Calculated revenue using quantity and unit price.
- Performed sales and customer analysis.
- Identified top products, countries, and customers by revenue.
- Performed customer value segmentation.
- Compared high-performing and underperforming markets.
- Stored the final integrated data in an SQLite database.
- Retrieved data using SQL queries.

## Tools Used

- **R**
- **RStudio / Google Colab**
- **dplyr**
- **readr**
- **jsonlite**
- **readxl**
- **RSQLite**
- **DBI**

## Output

The integrated retail data is stored in:

`output/retail_sales.db`

## Conclusion

The retail datasets were successfully integrated, cleaned, and analyzed using R. Revenue, customer, product, and country-level insights were obtained, and the processed data was stored and retrieved using SQLite and SQL queries.