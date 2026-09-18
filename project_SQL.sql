/*
Project: Wages and Food Prices in the Czech Republic

This script creates:
1. t_artem_repin_project_SQL_primary_final
2. t_artem_repin_project_SQL_secondary_final
*/


-- ============================================================
-- PRIMARY FINAL TABLE
-- Czech wages and food prices for comparable years: 2006–2018
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

