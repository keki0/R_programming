# Lab 4 – Missing Data Handling in R

## Objective

To identify, handle, and visualize missing data in R using suitable data-cleaning and imputation techniques.

## Dataset

**Adult Census Dataset (2000-row sample)**

The experiment works with variables such as `age`, `workclass`, `hours.per.week`, and other demographic attributes.

## Tasks Performed

- Loaded and inspected the Adult Census dataset.
- Introduced and identified missing and invalid values.
- Calculated missing-value summaries.
- Handled missing values using median imputation.
- Replaced invalid values with `NA`.
- Created reusable functions for data cleaning.
- Used `tryCatch()` for safe error handling.
- Visualized missing values using `naniar`.
- Validated the cleaned dataset using `skimr`.
- Exported the cleaned dataset to CSV.

## Tools Used

- **R**
- **RStudio / Google Colab**
- **naniar**
- **skimr**

## Output

The cleaned dataset is saved as:

`cleaned_adult_data.csv`

## Conclusion

The Adult Census dataset was successfully cleaned by identifying missing and invalid values and applying appropriate imputation techniques. The cleaned data was validated and exported for further analysis.