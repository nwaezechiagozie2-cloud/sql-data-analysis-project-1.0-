-- Active: 1764674974722@@127.0.0.1@3306@DataWarehouseAnalytics
-- =============================================================================
-- CUSTOMER CHURN AUDIT (RFM + REVENUE AT RISK)
-- =============================================================================
-- This file completes the "other half" of the job:
-- 1. Segmenting customers (RFM)
-- 2. Quantifying the actual dollar value we are losing (Revenue at Risk)

WITH
    RFM_Base AS (
        SELECT
            customer_key,
            TIMESTAMPDIFF(
                DAY,
                MAX(order_date),
                (
                    SELECT MAX(order_date)
                    FROM gold_fact_sales
                )
            ) AS recency_days,
            COUNT(DISTINCT order_number) AS frequency,
            SUM(sales_amount) AS monetary
        FROM gold_fact_sales
        GROUP BY
            customer_key
    ),
    RFM_Scored AS (
        SELECT
            customer_key,
            recency_days,
            frequency,
            monetary,
            NTILE(4) OVER (
                ORDER BY recency_days DESC
            ) as r_score,
            CASE
                WHEN frequency >= 4 THEN 4
                WHEN frequency = 3 THEN 3
                WHEN frequency = 2 THEN 2
                ELSE 1
            END as f_score,
            NTILE(4) OVER (
                ORDER BY monetary ASC
            ) as m_score
        FROM RFM_Base
    ),
    RFM_Final AS (
        SELECT
            customer_key,
            r_score,
            f_score,
            m_score,
            monetary,
            CASE
                WHEN (
                    r_score = 4
                    AND f_score = 4
                    AND m_score = 4
                ) THEN 'Champions'
                WHEN (
                    f_score >= 3
                    AND m_score >= 3
                ) THEN 'Loyal Spenders'
                WHEN (
                    f_score >= 3
                    AND m_score < 3
                ) THEN 'Loyal Visitors'
                WHEN (
                    f_score <= 2
                    AND m_score = 4
                ) THEN 'Whales'
                WHEN (
                    r_score >= 3
                    AND f_score = 2
                ) THEN 'Potential Loyalist'
                WHEN (
                    r_score >= 3
                    AND f_score = 1
                ) THEN 'New Customers'
                WHEN (
                    r_score <= 2
                    AND (
                        f_score >= 3
                        OR m_score >= 3
                    )
                ) THEN 'At Risk'
                ELSE 'Hibernating'
            END as customer_segment
        FROM RFM_Scored
    )
    -- FINAL AUDIT: QUANTIFYING THE LOSS
SELECT
    customer_segment,
    COUNT(*) as customer_count,
    SUM(monetary) as total_historical_revenue,
    ROUND(AVG(monetary), 0) as avg_customer_value,
    -- This is the "Other Half": What % of our total revenue is in each bucket?
    ROUND(
        SUM(monetary) * 100.0 / (
            SELECT SUM(sales_amount)
            FROM gold_fact_sales
        ),
        1
    ) as pct_of_total_revenue
FROM RFM_Final
GROUP BY
    customer_segment
ORDER BY total_historical_revenue DESC;

-- =============================================================================
-- THE "HIT LIST": TOP 10 AT-RISK CUSTOMERS
-- =============================================================================
-- This is the actionable output for the Marketing Team.
/*
SELECT 
f.customer_key,
c.first_name,
c.last_name,
f.monetary as total_spent,
f.r_score,
f.f_score
FROM RFM_Final f
JOIN gold_dim_customers c ON f.customer_key = c.customer_key
WHERE f.customer_segment = 'At Risk'
ORDER BY f.monetary DESC
LIMIT 10;
*/

-- =============================================================================
-- NEXT STEP: We have the segments.
-- Go to `retention_deep_dive.sql` to see which products create these loyal fans.
-- =============================================================================