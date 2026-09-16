# Analysis of Wages and Food Prices in the Czech Republic

This project analyses the development of average wages and food prices in the Czech Republic. It also compares these developments with selected economic indicators in other European countries.

## Files in this repository

- `project_SQL.sql` – SQL script for creating the final tables and answering the research questions.
- `README.md` – description of the data preparation process, results, and data limitations.

## Final tables

### t_artem_repin_project_SQL_primary_final

This table contains data on average wages and food prices in the Czech Republic for the common period 2006–2018.

Wage data were taken from the `czechia_payroll` table and joined with `czechia_payroll_industry_branch` to obtain industry names.

Only records representing the average gross wage were used (`value_type_code = 5958`). Wage values were aggregated into annual averages for each industry.

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
