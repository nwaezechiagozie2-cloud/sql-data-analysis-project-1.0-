-- =============================================================================
-- CUSTOMER RETENTION DEEP DIVE
-- =============================================================================

-- 1. CHURN BY CUSTOMER VALUE (Are we losing our VIPs?)
-- Insight: Losing low-value customers is normal. Losing VIPs is a disaster.
WITH
    CustomerMetrics AS (
        SELECT
            customer_key,
            SUM(sales_amount) AS total_spent,
            MAX(order_date) AS last_order_date,
            (
                SELECT MAX(order_date)
                FROM gold_fact_sales
            ) AS max_db_date
        FROM gold_fact_sales
        GROUP BY
            customer_key
    ),
    Segments AS (
        SELECT
            customer_key,
            CASE
                WHEN total_spent > 5000 THEN 'VIP (>5k)'
                WHEN total_spent > 1000 THEN 'Regular (1k-5k)'
                ELSE 'Low Value (<1k)'
            END AS value_segment,
            CASE
                WHEN TIMESTAMPDIFF(
                    MONTH,
                    last_order_date,
                    max_db_date
                ) > 12 THEN 'Lapsed'
                ELSE 'Active'
            END AS status
        FROM CustomerMetrics
    )
SELECT
    value_segment,
    status,
    COUNT(*) as customer_count,
    -- Calculate percentage within the segment
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (
            PARTITION BY
                value_segment
        ),
        1
    ) as pct_of_segment
FROM Segments
GROUP BY
    value_segment,
    status
ORDER BY value_segment, status;

-- 2. RETENTION BY FIRST PURCHASE CATEGORY (Which products create loyal fans?)
-- Insight: Do people who start with Accessories come back more often?
WITH
    FirstPurchase AS (
        SELECT s.customer_key, p.category as first_category, s.order_date
        FROM
            gold_fact_sales s
            JOIN gold_dim_products p ON s.product_key = p.product_key
            -- Filter to get only the very first order for each customer
        WHERE (s.customer_key, s.order_date) IN (
                SELECT customer_key, MIN(order_date)
                FROM gold_fact_sales
                GROUP BY
                    customer_key
            )
    ),
    CustomerStatus AS (
        SELECT
            customer_key,
            MAX(order_date) AS last_order_date,
            (
                SELECT MAX(order_date)
                FROM gold_fact_sales
            ) AS max_db_date
        FROM gold_fact_sales
        GROUP BY
            customer_key
    )
SELECT
    fp.first_category,
    CASE
        WHEN TIMESTAMPDIFF(
            MONTH,
            cs.last_order_date,
            cs.max_db_date
        ) > 12 THEN 'Lapsed'
        ELSE 'Active'
    END AS current_status,
    COUNT(DISTINCT fp.customer_key) as customer_count
FROM
    FirstPurchase fp
    JOIN CustomerStatus cs ON fp.customer_key = cs.customer_key
GROUP BY
    fp.first_category,
    current_status
ORDER BY fp.first_category;

-- =============================================================================
-- NEXT STEP: We found a correlation between first purchase and retention.
-- Go to `verify_accessory_behavior.sql` to see if this holds up under scrutiny.
-- =============================================================================