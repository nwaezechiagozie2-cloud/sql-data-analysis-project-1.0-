-- =============================================================================
-- VERIFICATION: ARE ACCESSORY BUYERS ACTUALLY REPEAT BUYERS?
-- =============================================================================
-- We need to check if people who buy Accessories are "One-and-Done" or "Multi-Buyers".
WITH
    CustomerCategoryStats AS (
        SELECT
            s.customer_key,
            -- Did they buy Accessories?
            MAX(
                CASE
                    WHEN p.category = 'Accessories' THEN 1
                    ELSE 0
                END
            ) as bought_accessories,
            -- Did they buy Bikes?
            MAX(
                CASE
                    WHEN p.category = 'Bikes' THEN 1
                    ELSE 0
                END
            ) as bought_bikes,
            -- Total Orders for this customer
            COUNT(DISTINCT s.order_number) as total_orders
        FROM
            gold_fact_sales s
            JOIN gold_dim_products p ON s.product_key = p.product_key
        GROUP BY
            s.customer_key
    )
SELECT
    'Accessory Buyers' as customer_group,
    COUNT(*) as total_customers,
    SUM(
        CASE
            WHEN total_orders = 1 THEN 1
            ELSE 0
        END
    ) as one_time_buyers,
    SUM(
        CASE
            WHEN total_orders > 1 THEN 1
            ELSE 0
        END
    ) as repeat_buyers,
    ROUND(
        SUM(
            CASE
                WHEN total_orders > 1 THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        1
    ) as pct_repeat_buyers
FROM CustomerCategoryStats
WHERE
    bought_accessories = 1
UNION ALL
SELECT
    'Bike Buyers' as customer_group,
    COUNT(*) as total_customers,
    SUM(
        CASE
            WHEN total_orders = 1 THEN 1
            ELSE 0
        END
    ) as one_time_buyers,
    SUM(
        CASE
            WHEN total_orders > 1 THEN 1
            ELSE 0
        END
    ) as repeat_buyers,
    ROUND(
        SUM(
            CASE
                WHEN total_orders > 1 THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        1
    ) as pct_repeat_buyers
FROM CustomerCategoryStats
WHERE
    bought_bikes = 1;

-- =============================================================================
-- NEXT STEP: The theory was disproven! Bikes are the real loyalty anchor.
-- Go to `official_cohort_retention.sql` to see the long-term trend of this behavior.
-- =============================================================================