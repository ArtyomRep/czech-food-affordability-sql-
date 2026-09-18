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
