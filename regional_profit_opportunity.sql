-- =============================================================================
-- PROOF: THE "GLOBAL ATTACHMENT" PROFIT OPPORTUNITY
-- =============================================================================
-- Logic:
-- 1. Use Canada (5.23%) as the benchmark for Accessory Attachment.
-- 2. Calculate the "Profit Gap" for the USA and Australia.

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
            -- Canada's Benchmark Ratio
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