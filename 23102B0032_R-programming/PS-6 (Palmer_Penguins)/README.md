# Statistical Analysis of Palmer Penguins

## Overview

This experiment performs statistical analysis on the Palmer Penguins dataset to investigate differences in physical characteristics among penguin species and between sexes.

The analysis focuses mainly on:

- Body mass
- Flipper length
- Penguin species
- Sex

Statistical methods including descriptive statistics, hypothesis testing, t-test, ANOVA, Tukey HSD, Kruskal-Wallis test, and two-way ANOVA were applied.

## Objectives

- Calculate descriptive statistics for penguin body mass.
- Compare body mass between male and female penguins.
- Test whether body mass differs among penguin species.
- Check assumptions for parametric tests.
- Perform Tukey HSD post-hoc analysis.
- Perform the Kruskal-Wallis test when ANOVA assumptions are violated.
- Investigate the effects of species, sex, and their interaction using two-way ANOVA.
- Analyze differences in flipper length among species.
- Visualize the statistical results.

## Dataset

The Palmer Penguins dataset contains measurements for Adelie, Chinstrap, and Gentoo penguins.

The main variables used in this experiment include:

- `species`
- `sex`
- `body_mass_g`
- `flipper_length_mm`

The analysis uses observations with available values for the respective variables.

## Statistical Methods

The following methods were used:

1. Descriptive statistics
2. Histogram
3. Boxplots
4. Density plots
5. Shapiro-Wilk normality test
6. Q-Q plots
7. Independent-samples t-test
8. 95% confidence interval
9. Cohen's d effect size
10. One-way ANOVA
11. Levene's test
12. Tukey HSD
13. Kruskal-Wallis test
14. Two-way ANOVA
15. Flipper-length analysis

## Key Results

### Body Mass by Sex

Male penguins had a higher mean body mass than female penguins.

- Male mean: 4545.69 g
- Female mean: 3862.27 g
- Mean difference: 683.41 g
- t = 8.555
- p < 0.001
- 95% CI: 526.25 g to 840.58 g
- Cohen's d = 0.936

The difference was statistically significant and had a large effect size.

### Body Mass by Species

The one-way ANOVA showed a significant difference in body mass among species:

- F(2, 339) = 343.6
- p < 0.001

Tukey HSD showed that Gentoo penguins differed significantly from both Adelie and Chinstrap penguins, while the difference between Adelie and Chinstrap was not significant.

Levene's test indicated unequal variances, so the Kruskal-Wallis test was also performed:

- χ²(2) = 217.599
- p < 0.001

The Kruskal-Wallis test confirmed a significant difference among species.

### Two-Way ANOVA

The two-way ANOVA showed significant effects of:

- Species
- Sex
- Species × Sex interaction

Therefore, the relationship between sex and body mass differs across species.

### Flipper Length

Flipper length differed significantly among all three species.

One-way ANOVA:

- F(2, 339) = 594.8
- p < 0.001

Tukey HSD indicated significant differences between every pair of species.

The Kruskal-Wallis test also confirmed a significant difference:

- χ²(2) = 244.89
- p < 0.001

## Project Files

### `penguin_analysis.R`

Main R script containing the complete statistical analysis and visualization code.

### `Palmer_Penguins_Statistical_Analysis.Rmd`

R Markdown source file used to generate the statistical report.

### `Palmer_Penguins_Statistical_Analysis.html`

Rendered HTML report containing the analysis, results, tables, visualizations, and conclusions.

### `data/`

Contains the dataset used for analysis.

### `figures/`

Contains the graphs generated during the analysis.

### `outputs/`

Contains statistical results saved as CSV and TXT files.

## Software and Packages

- R
- RStudio
- `palmerpenguins`
- `dplyr`
- `ggplot2`
- `moments`
- `car`
- `knitr`
- `rmarkdown`

## Conclusion

The analysis demonstrates significant differences in physical characteristics among penguin species. Gentoo penguins generally have greater body mass and longer flippers than Adelie and Chinstrap penguins. Male penguins also have significantly greater body mass than female penguins, and the significant species × sex interaction indicates that sex-related differences vary across species.