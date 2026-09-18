/*
Project: Wages and Food Prices in the Czech Republic

This script creates:
1. t_artem_repin_project_SQL_primary_final
2. t_artem_repin_project_SQL_secondary_final
*/


-- ============================================================
-- PRIMARY FINAL TABLE
-- Czech wages and food prices for comparable years: 2006–2018
-- One row = year + industry + food category
-- ============================================================

CREATE TABLE t_artem_repin_project_SQL_primary_final AS
WITH annual_wages AS (
    SELECT
        cp.payroll_year AS year,
        cp.industry_branch_code,
        cpib.name AS industry_name,
        ROUND(AVG(cp.value)::NUMERIC, 2) AS average_wage
    FROM czechia_payroll AS cp
    JOIN czechia_payroll_industry_branch AS cpib
        ON cp.industry_branch_code = cpib.code
    WHERE cp.value_type_code = 5958
        AND cp.calculation_code = 100
        AND cp.unit_code = 200
        AND cp.industry_branch_code IS NOT NULL
        AND cp.payroll_year BETWEEN 2006 AND 2018
    GROUP BY
        cp.payroll_year,
        cp.industry_branch_code,
        cpib.name
),
annual_food_prices AS (
    SELECT
        EXTRACT(YEAR FROM cp.date_from)::INT AS year,
        cp.category_code,
        cpc.name AS food_name,
        cpc.price_value AS food_quantity,
        cpc.price_unit AS food_unit,
        ROUND(AVG(cp.value)::NUMERIC, 2) AS average_food_price
    FROM czechia_price AS cp
    JOIN czechia_price_category AS cpc
        ON cp.category_code = cpc.code
    WHERE EXTRACT(YEAR FROM cp.date_from)::INT BETWEEN 2006 AND 2018
    GROUP BY
        EXTRACT(YEAR FROM cp.date_from)::INT,
        cp.category_code,
        cpc.name,
        cpc.price_value,
        cpc.price_unit
)
SELECT
    aw.year,
    aw.industry_branch_code,
    aw.industry_name,
    aw.average_wage,
    afp.category_code,
    afp.food_name,
    afp.food_quantity,
    afp.food_unit,
    afp.average_food_price
FROM annual_wages AS aw
JOIN annual_food_prices AS afp
    ON aw.year = afp.year
ORDER BY
    aw.year,
    aw.industry_branch_code,
    afp.category_code;


-- ============================================================
-- SECONDARY FINAL TABLE
-- Additional economic data for European countries
-- One row = country + year
-- ============================================================

CREATE TABLE t_artem_repin_project_SQL_secondary_final AS
SELECT
    c.country,
    c.continent,
    e.year,
    e.gdp,
    e.gini,
    e.population
FROM countries AS c
JOIN economies AS e
    ON c.country = e.country
WHERE c.continent = 'Europe'
    AND e.year BETWEEN 2006 AND 2018
ORDER BY
    c.country,
    e.year;

-- ============================================================
-- QUESTION 1
-- Do wages increase in all industries during the observed period?
-- ============================================================

WITH unique_wages AS (
    SELECT DISTINCT
        year,
        industry_branch_code,
        industry_name,
        average_wage
    FROM t_artem_repin_project_SQL_primary_final
),
wage_comparison AS (
    SELECT
        industry_branch_code,
        industry_name,
        MAX(average_wage) FILTER (WHERE year = 2006) AS wage_2006,
        MAX(average_wage) FILTER (WHERE year = 2018) AS wage_2018
    FROM unique_wages
    GROUP BY
        industry_branch_code,
        industry_name
)
SELECT
    industry_name,
    wage_2006,
    wage_2018,
    ROUND(
        ((wage_2018 - wage_2006) / wage_2006) * 100,
        2
    ) AS wage_growth_percent,
    CASE
        WHEN wage_2018 > wage_2006 THEN 'Increased'
        WHEN wage_2018 < wage_2006 THEN 'Decreased'
        ELSE 'No change'
    END AS result
FROM wage_comparison
ORDER BY wage_growth_percent;


-- ============================================================
-- QUESTION 2
-- How much bread and milk can an average wage buy in the first and final comparable years?
-- ============================================================

WITH annual_average_wages AS (
    SELECT
        year,
        ROUND(AVG(average_wage), 2) AS overall_average_wage
    FROM (
        SELECT DISTINCT
            year,
            industry_branch_code,
            average_wage
        FROM t_artem_repin_project_SQL_primary_final
    ) AS unique_wages
    WHERE year IN (2006, 2018)
    GROUP BY
        year
),
bread_and_milk_prices AS (
    SELECT DISTINCT
        year,
        food_category,
        average_food_price
    FROM t_artem_repin_project_SQL_primary_final
    WHERE year IN (2006, 2018)
        AND (
            LOWER(food_category) LIKE '%chléb%'
            OR LOWER(food_category) LIKE '%mléko%'
        )
)
SELECT
    aw.year,
    bmp.food_category,
    aw.overall_average_wage,
    bmp.average_food_price,
    ROUND(
        aw.overall_average_wage / bmp.average_food_price,
        2
    ) AS affordable_quantity,
    CASE
        WHEN LOWER(bmp.food_category) LIKE '%chléb%' THEN 'kg'
        WHEN LOWER(bmp.food_category) LIKE '%mléko%' THEN 'l'
    END AS unit
FROM annual_average_wages AS aw
JOIN bread_and_milk_prices AS bmp
    ON aw.year = bmp.year
ORDER BY
    aw.year,
    bmp.food_category;



-- ============================================================
-- QUESTION 3
-- Which food category has the slowest year-over-year price growth?
-- ============================================================

WITH unique_food_prices AS (
    SELECT DISTINCT
        year,
        category_code,
        food_category,
        average_food_price
    FROM t_artem_repin_project_SQL_primary_final
),
prices_with_previous_year AS (
    SELECT
        year,
        category_code,
        food_category,
        average_food_price,
        LAG(average_food_price) OVER (
            PARTITION BY category_code
            ORDER BY year
        ) AS previous_year_price
    FROM unique_food_prices
),
yearly_price_growth AS (
    SELECT
        category_code,
        food_category,
        year,
        ROUND(
            (
                (average_food_price - previous_year_price)
                / NULLIF(previous_year_price, 0)
            ) * 100,
            2
        ) AS year_on_year_growth_percent
    FROM prices_with_previous_year
    WHERE previous_year_price IS NOT NULL
)
SELECT
    category_code,
    food_category,
    ROUND(
        AVG(year_on_year_growth_percent),
        2
    ) AS average_year_on_year_growth_percent,
    COUNT(*) AS compared_years
FROM yearly_price_growth
GROUP BY
    category_code,
    food_category
ORDER BY
    average_year_on_year_growth_percent,
    food_category;



-- ============================================================
-- QUESTION 4
-- Was there a year when food-price growth exceeded wage growth by more than 10 percentage points?
-- ============================================================

 WITH unique_wages AS (
    SELECT DISTINCT
        year,
        industry_branch_code,
        average_wage
    FROM t_artem_repin_project_SQL_primary_final
),
annual_wages AS (
    SELECT
        year,
        AVG(average_wage) AS average_wage
    FROM unique_wages
    GROUP BY year
),
unique_food_prices AS (
    SELECT DISTINCT
        year,
        category_code,
        average_food_price
    FROM t_artem_repin_project_SQL_primary_final
),
annual_food_prices AS (
    SELECT
        year,
        AVG(average_food_price) AS average_food_price
    FROM unique_food_prices
    GROUP BY year
),
annual_data AS (
    SELECT
        aw.year,
        aw.average_wage,
        afp.average_food_price,
        LAG(aw.average_wage) OVER (
            ORDER BY aw.year
        ) AS previous_wage,
        LAG(afp.average_food_price) OVER (
            ORDER BY afp.year
        ) AS previous_food_price
    FROM annual_wages AS aw
    JOIN annual_food_prices AS afp
        ON aw.year = afp.year
),
growth_comparison AS (
    SELECT
        year,
        ROUND(
            (
                (average_wage - previous_wage)
                / NULLIF(previous_wage, 0)
            ) * 100,
            2
        ) AS wage_growth_percent,
        ROUND(
            (
                (average_food_price - previous_food_price)
                / NULLIF(previous_food_price, 0)
            ) * 100,
            2
        ) AS food_price_growth_percent
    FROM annual_data
    WHERE previous_wage IS NOT NULL
)
SELECT
    year,
    wage_growth_percent,
    food_price_growth_percent,
    ROUND(
        food_price_growth_percent - wage_growth_percent,
        2
    ) AS difference_percentage_points,
    CASE
        WHEN food_price_growth_percent - wage_growth_percent > 10
            THEN 'Yes'
        ELSE 'No'
    END AS exceeded_by_more_than_10_points
FROM growth_comparison
ORDER BY year;


-- ============================================================
-- QUESTION 5
--  Does GDP affect changes in wages and food prices? In other words, if GDP rises more strongly in one year, does it lead to stronger wage or food-price growth in the same year
--  or in the following year?
-- ============================================================

WITH unique_wages AS (
    SELECT DISTINCT
        year,
        industry_branch_code,
        average_wage
    FROM t_artem_repin_project_SQL_primary_final
),
annual_wages AS (
    SELECT
        year,
        AVG(average_wage) AS average_wage
    FROM unique_wages
    GROUP BY
        year
),
unique_food_prices AS (
    SELECT DISTINCT
        year,
        category_code,
        average_food_price
    FROM t_artem_repin_project_SQL_primary_final
),
annual_food_prices AS (
    SELECT
        year,
        AVG(average_food_price) AS average_food_price
    FROM unique_food_prices
    GROUP BY
        year
),
czech_gdp AS (
    SELECT
        year,
        gdp
    FROM t_artem_repin_project_SQL_secondary_final
    WHERE country = 'Czech Republic'
),
annual_values AS (
    SELECT
        aw.year,
        aw.average_wage,
        afp.average_food_price,
        cg.gdp,
        LAG(aw.average_wage) OVER (ORDER BY aw.year) AS previous_wage,
        LAG(afp.average_food_price) OVER (ORDER BY afp.year) AS previous_food_price,
        LAG(cg.gdp) OVER (ORDER BY cg.year) AS previous_gdp
    FROM annual_wages AS aw
    JOIN annual_food_prices AS afp
        ON aw.year = afp.year
    JOIN czech_gdp AS cg
        ON aw.year = cg.year
),
annual_growth AS (
    SELECT
        year,
        ROUND(
            (
                ((gdp - previous_gdp) / NULLIF(previous_gdp, 0)) * 100
            )::NUMERIC,
            2
        ) AS gdp_growth_percent,
        ROUND(
            (
                ((average_wage - previous_wage)
                / NULLIF(previous_wage, 0)) * 100
            )::NUMERIC,
            2
        ) AS wage_growth_percent,
        ROUND(
            (
                ((average_food_price - previous_food_price)
                / NULLIF(previous_food_price, 0)) * 100
            )::NUMERIC,
            2
        ) AS food_price_growth_percent
    FROM annual_values
    WHERE previous_gdp IS NOT NULL
        AND previous_wage IS NOT NULL
        AND previous_food_price IS NOT NULL
)
SELECT
    year,
    gdp_growth_percent,
    wage_growth_percent,
    food_price_growth_percent,
    LEAD(wage_growth_percent) OVER (
        ORDER BY year
    ) AS next_year_wage_growth_percent,
    LEAD(food_price_growth_percent) OVER (
        ORDER BY year
    ) AS next_year_food_price_growth_percent
FROM annual_growth
ORDER BY year;
