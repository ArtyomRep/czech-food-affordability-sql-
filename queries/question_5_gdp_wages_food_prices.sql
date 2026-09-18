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
