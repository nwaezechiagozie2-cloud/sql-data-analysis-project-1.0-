-- =============================================================================
-- PROOF: THE "TRUE ATTACHMENT" PROFIT CALCULATION
-- =============================================================================
-- Logic:
-- 1. Calculate the "Attachment Ratio" (Accessory Revenue per $1 of Bike Revenue).
-- 2. Apply Canada's high ratio to Australia's existing Bike volume.
-- 3. Calculate the PURE PROFIT GAIN from these additional sales.

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
            c.country IN ('Australia', 'Canada')
        GROUP BY
            c.country
    ),
    AttachmentRates AS (
        SELECT
            -- Canada's Benchmark: How many cents of accessories per $1 of bikes?
            (
                SELECT acc_rev / bike_rev
                FROM RegionalMetrics
                WHERE
                    country = 'Canada'
            ) as canada_ratio,
            -- Australia's Current State
            (
                SELECT bike_rev
                FROM RegionalMetrics
                WHERE
                    country = 'Australia'
            ) as aus_bike_rev,
            (
                SELECT acc_rev
                FROM RegionalMetrics
                WHERE
                    country = 'Australia'
            ) as aus_current_acc_rev
    )
SELECT
    ROUND(aus_bike_rev, 0) as current_bike_sales,
    ROUND(aus_current_acc_rev, 0) as current_accessory_sales,
    -- If Australia matched Canada's attachment rate:
    ROUND(
        aus_bike_rev * canada_ratio,
        0
    ) as target_accessory_sales,
    -- The "New" money we are leaving on the table
    ROUND(
        (aus_bike_rev * canada_ratio) - aus_current_acc_rev,
        0
    ) as additional_revenue_opportunity,
    -- Profit = Additional Revenue * Accessory Margin (63%)
    -- We use 63% because these are NEW sales, not shifted sales.
    ROUND(
        (
            (aus_bike_rev * canada_ratio) - aus_current_acc_rev
        ) * 0.63,
        0
    ) as potential_profit_boost
FROM AttachmentRates;