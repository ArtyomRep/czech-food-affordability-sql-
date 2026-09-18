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
