-- Active: 1764674974722@@127.0.0.1@3306@DataWarehouseAnalytics
-- =============================================================================
-- OFFICIAL COHORT RETENTION MATRIX (STRICT MODE SAFE)
-- =============================================================================
WITH
    CohortBase AS (
        SELECT customer_key, YEAR(MIN(order_date)) as join_year
        FROM gold_fact_sales
        WHERE
            order_date IS NOT NULL
        GROUP BY
            customer_key
    ),
    CohortSize AS (
        SELECT join_year, COUNT(DISTINCT customer_key) as total_customers
        FROM CohortBase
        GROUP BY
            join_year
    ),
    Activity AS (
        SELECT s.customer_key, c.join_year, YEAR(s.order_date) - c.join_year as years_since_join
        FROM
            gold_fact_sales s
            JOIN CohortBase c ON s.customer_key = c.customer_key
        WHERE
            order_date IS NOT NULL
    )
SELECT
    a.join_year,
    cs.total_customers as cohort_size,
    a.years_since_join,
    COUNT(DISTINCT a.customer_key) as active_customers,
    ROUND(
        COUNT(DISTINCT a.customer_key) * 100.0 / cs.total_customers,
        1
    ) as retention_rate_pct
FROM Activity a
    JOIN CohortSize cs ON a.join_year = cs.join_year
GROUP BY
    a.join_year,
    cs.total_customers,
    a.years_since_join
ORDER BY a.join_year, a.years_since_join;

SELECT
    YEAR(order_date) as order_year,
    COUNT(DISTINCT order_number) as total_orders,
    COUNT(DISTINCT customer_key) as unique_customers
FROM gold_fact_sales
GROUP BY
    YEAR(order_date)
ORDER BY order_year;

-- =============================================================================
-- NEXT STEP: Trends are clear.
-- Go to `02_operational_views.sql` to see how we automate this for the business.
-- =============================================================================