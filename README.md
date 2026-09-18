# Analysis of Wages and Food Prices in the Czech Republic

This project analyses the development of average wages and food prices in the Czech Republic. It also compares these developments with selected economic indicators in other European countries.

## Files in this repository

- `project_SQL.sql` – SQL script for creating the final tables.
- `README.md` – description of the data preparation process, results, and data limitations.
- `queries` - contains SQL analyses answering the five project research questions:
  - `question_1_wage_development.sql` — Compares average wages in industries between 2006 and 2018.
  - `question_2_bread_milk_affordability.sql` - Calculates how much bread and milk an average wage could buy in the first and final comparable years.
  - `question_3_slowest_price_increase.sql` - Identifies the food category with the slowest average year-to-year price increase.
  - `question_4_food_prices_vs_wages.sql` - Compares food-price growth with wage growth.
  - `question_5_gdp_wages_food_prices.sql` - Compares GDP development with wage and food-price development.

## Final tables

### t_artem_repin_project_SQL_primary_final

This table contains data on average wages and food prices in the Czech Republic for the common period 2006–2018.

Wage data were taken from the `czechia_payroll` table and joined with `czechia_payroll_industry_branch` to obtain industry names.

Food-price data were taken from the `czechia_price` table and joined with `czechia_price_category`. Prices were aggregated into annual average prices for each food category.

The wage and food-price datasets were joined by year. Each row represents one year, one industry, and one food category.

### t_artem_repin_project_SQL_secondary_final

This table contains additional data for European countries, including GDP, population, and the GINI coefficient. It is used mainly for comparing the Czech Republic with other European countries and for answering the fifth research question.

## Data notes

- The common period for wage and food-price data is 2006–2018.
- The primary table contains 6,498 rows.
- It includes 19 industry branches and 27 food categories.
- Some food categories are not available in every year.
- Because the table joins industries with food categories, the same annual wage is repeated for each food category within an industry and year.
- Queries focused only on wages use `DISTINCT` or aggregation to avoid counting repeated wages more than once.
- The results show relationships in the available data but do not prove that one variable causes another.

## Research question results

### 1. Do wages increase in all industries during the observed period?

Average wages increased in all 19 analysed industry branches between 2006 and 2018. No industry showed an overall decrease during this period.

### 2. How much bread and milk can an average wage buy in the first and final comparable years?

Purchasing power increased for both bread and milk between 2006 and 2018. The increase was modest for bread, while milk became noticeably more affordable relative to the average wage.

### 3. Which food category has the slowest year-over-year price growth?
The lowest average year-on-year price growth was recorded for granulated sugar (Cukr krystalový), at -1.92% 

### 4.  Was there a year when food-price growth exceeded wage growth by more than 10 percentage points?

Food-price growth did not exceed wage growth by more than 10 percentage points in any year between 2007 and 2018.

### 5. Does GDP affect changes in wages and food prices? In other words, if GDP rises more strongly in one year, does it lead to stronger wage or food-price growth in the same year or in the following year?

The data do not show a clear pattern that higher GDP growth automatically leads to faster wage growth or higher food prices. In some years, wages or food prices increased after GDP grew, but this was not consistent across the whole period. Therefore, GDP growth alone does not appear to be a reliable indicator of how wages and food prices will change in the same year or the following year.

## Data limitations

- The final primary table covers only the common period from 2006 to 2018.
- Some food categories are not available in every year, so the number of year-to-year comparisons may differ between categories.
- Wage and food-price figures are annual averages. They do not represent individual employees, Czech regions, specific shops, or individual product brands.
- Wages are repeated across food categories in the primary table because each row combines one year, one industry, and one food category. The analytical queries remove these duplicates before calculating average wages.
- The secondary table contains European countries, while the GDP analysis for Question 5 uses only the Czech Republic.
