-- =============================================================================
-- OPERATIONAL VIEWS: DASHBOARD LAYER
-- =============================================================================
-- view_dashboard_sales: Transactional data with Profit and Margin %
-- view_dashboard_customers: Aggregated data with RFM Segmentation
--
-- RFM SEGMENT DEFINITIONS:
-- 1. Champions: Best customers (Recent, Frequent, High Spend)
-- 2. Loyal Spenders: Consistent high-value repeat customers
-- 3. Loyal Visitors: Frequent buyers with low average spend
-- 4. Whales: Rare buyers who spend very large amounts
-- 5. Potential Loyalist: Recent customers with 2+ purchases
-- 6. New Customers: Recent first-time buyers
-- 7. At Risk: High-value customers who haven't returned recently
-- 8. Hibernating: Low-value, low-frequency, old customers
-- =============================================================================

CREATE OR REPLACE VIEW view_dashboard_sales AS
SELECT
    s.order_number,
    s.order_date,
    YEAR(s.order_date) as order_year,
    MONTH(s.order_date) as order_month,
    c.customer_key,
    CONCAT(
        c.first_name,
        ' ',
        c.last_name
    ) as customer_name,
    c.country,
    p.product_name,
    p.category,
    p.subcategory,
    s.sales_amount,
    s.quantity,
    p.cost as unit_cost,
    (p.cost * s.quantity) as total_cost,
    (
        s.sales_amount - (p.cost * s.quantity)
    ) as profit,
    ROUND(
        (
            s.sales_amount - (p.cost * s.quantity)
        ) / NULLIF(s.sales_amount, 0) * 100,
        2
    ) as margin_pct
FROM
    gold_fact_sales s
    JOIN gold_dim_products p ON s.product_key = p.product_key
    JOIN gold_dim_customers c ON s.customer_key = c.customer_key
WHERE
    s.order_date IS NOT NULL;

CREATE OR REPLACE VIEW view_dashboard_customers AS
WITH
    MaxDate AS (
        SELECT MAX(order_date) as m_date
        FROM gold_fact_sales
    ),
    RFM_Base AS (
        SELECT
            s.customer_key,
            MIN(s.order_date) as first_purchase,
            MAX(s.order_date) as last_purchase,
            TIMESTAMPDIFF(
                DAY,
                MAX(s.order_date),
                (
                    SELECT m_date
                    FROM MaxDate
                )
            ) AS recency_days,
            COUNT(DISTINCT s.order_number) AS frequency,
            SUM(s.sales_amount) AS lifetime_value
        FROM gold_fact_sales s
        WHERE
            s.order_date IS NOT NULL
        GROUP BY
            s.customer_key
    ),
    RFM_Scored AS (
        SELECT
            r.*,
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
                ORDER BY lifetime_value ASC
            ) as m_score
        FROM RFM_Base r
    )
SELECT
    r.customer_key,
    CONCAT(
        c.first_name,
        ' ',
        c.last_name
    ) as customer_name,
    c.country,
    r.first_purchase,
    r.last_purchase,
    r.recency_days,
    r.frequency,
    r.lifetime_value,
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
FROM
    RFM_Scored r
    JOIN gold_dim_customers c ON r.customer_key = c.customer_key;

-- Test the views
SELECT * FROM view_dashboard_customers LIMIT 10;