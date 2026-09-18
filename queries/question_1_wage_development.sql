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
