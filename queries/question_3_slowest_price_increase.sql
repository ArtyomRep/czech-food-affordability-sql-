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
