# Practical 1 – Air Quality Data Cleaning Using R

## Objective

To clean and preprocess air-quality data using R by handling missing values, invalid values, loops, functions, and error handling.

## Dataset

**Beijing Multi-Site Air Quality Dataset**

Selected file:
`PRSA_Data_Aotizhongxin_20130301-20170228.csv`

## Tasks Performed

- Imported and inspected the dataset.
- Identified missing values.
- Demonstrated `NA`, `NULL`, and `NaN`.
- Created `missing_summary()` to summarize missing values.
- Identified `NaN` and infinite values in `pollution_ratio`.
- Handled missing numerical values using **median imputation**.
- Handled missing categorical values using **mode imputation**.
- Implemented error handling using `tryCatch()`.
- Compared missing values before and after cleaning.
- Generated a bar chart for missing values.
- Exported the cleaned dataset as a CSV file.

## Files

```text
PS_1/
├── 23102B0032_R-prog_PS-1.R
├── PRSA_Data_Aotizhongxin_20130301-20170228.csv
├── cleaned_air_quality_data.csv
└── README.md
```

## Tools Used

- **R**
- **RStudio**
- **Base R functions**

## Output

The cleaned dataset is saved as:

`cleaned_air_quality_data.csv`

## Conclusion

The air-quality dataset was successfully cleaned by identifying and handling missing and invalid values. Loops, user-defined functions, median/mode imputation, and `tryCatch()` were used to create a reusable and robust data-cleaning process.