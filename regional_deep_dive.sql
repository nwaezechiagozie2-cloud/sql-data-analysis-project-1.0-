-- =============================================================================
-- REGIONAL DEEP DIVE: PROFITABILITY & OPPORTUNITY
-- =============================================================================

-- 1. CATEGORY MIX BY COUNTRY
-- Purpose: Identify which countries are "Bike Heavy" vs "Accessory Healthy"
SELECT c.country, p.category, ROUND(
        SUM(s.sales_amount) / SUM(SUM(s.sales_amount)) OVER (
            PARTITION BY
                c.country
        ) * 100, 2
    ) AS pct_of_revenue
FROM
    gold_fact_sales s
    JOIN gold_dim_customers c ON s.customer_key = c.customer_key
    JOIN gold_dim_products p ON s.product_key = p.product_key
GROUP BY
    c.country,
    p.category
ORDER BY p.category, pct_of_revenue DESC;

-- 2. THE "GLOBAL ATTACHMENT" PROFIT OPPORTUNITY
-- Purpose: Calculate the exact dollar value of matching Canada's accessory rate in the USA and Australia.
WITH
    RegionalMetrics AS (
        SELECT c.country, SUM(
                CASE
                    WHEN p.category = 'Bikes' THEN s.sales_amount
                    ELSE 0
                END
            ) as bike_rev, SUM(
                CASE
                    WHEN p.category = 'Accessories' THEN s.sales_amount
                    ELSE 0
                END
            ) as acc_rev
        FROM
            gold_fact_sales s
            JOIN gold_dim_customers c ON s.customer_key = c.customer_key
            JOIN gold_dim_products p ON s.product_key = p.product_key
        WHERE
            c.country IN (
                'Australia',
                'Canada',
                'United States'
            )
        GROUP BY
            c.country
    ),
    AttachmentRates AS (
        SELECT
            country,
            bike_rev,
            acc_rev,
            -- Canada's Benchmark Ratio (Accessories per $1 of Bikes)
            (
                SELECT acc_rev / bike_rev
                FROM RegionalMetrics
                WHERE
                    country = 'Canada'
            ) as benchmark_ratio
        FROM RegionalMetrics
        WHERE
            country != 'Canada'
    )
SELECT
    country,
    ROUND(bike_rev, 0) as current_bike_sales,
    ROUND(acc_rev, 0) as current_acc_sales,
    ROUND(bike_rev * benchmark_ratio, 0) as target_acc_sales,
    ROUND(
        (bike_rev * benchmark_ratio) - acc_rev,
        0
    ) as revenue_gap,
    -- Potential Profit = Revenue Gap * Accessory Margin (63%)
    ROUND(
        (
            (bike_rev * benchmark_ratio) - acc_rev
        ) * 0.63,
        0
    ) as potential_profit_gain
FROM AttachmentRates
ORDER BY potential_profit_gain DESC;

--3 What exactly is Canada doing?

WITH CountryTopProducts AS (
    SELECT 
        c.country,
        p.product_name,
        SUM(s.quantity) as units_sold,
        RANK() OVER (PARTITION BY c.country ORDER BY SUM(s.quantity) DESC) as product_rank
    FROM gold_fact_sales s
    JOIN gold_dim_customers c ON s.customer_key = c.customer_key
    JOIN gold_dim_products p ON s.product_key = p.product_key
    WHERE c.country IN ('Australia', 'Canada')
      AND p.category = 'Accessories'
    GROUP BY c.country, p.product_name
)
SELECT * FROM CountryTopProducts WHERE product_rank <= 5;

--4 Product analysis for regions
SELECT 
    p.product_name,
    p.category,
    SUM(s.sales_amount - (p.cost * s.quantity)) AS total_profit,
    ROUND((SUM(s.sales_amount) - SUM(p.cost * s.quantity)) / SUM(s.sales_amount) * 100, 2) AS margin_pct
FROM gold_fact_sales s
JOIN gold_dim_products p ON s.product_key = p.product_key
GROUP BY p.product_name, p.category
ORDER BY total_profit DESC
LIMIT 10;