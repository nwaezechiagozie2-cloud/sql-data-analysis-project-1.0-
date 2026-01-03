-- Active: 1764674974722@@127.0.0.1@3306@DataWarehouseAnalytics
-- =============================================================================
-- BUSINESS INSIGHTS ANALYSIS
-- =============================================================================
-- This file contains queries designed to answer key business questions:
-- 1. Which product categories are driving the most profit?
-- 2. Are we retaining our customers?
-- 3. Which countries have the highest growth potential?
-- =============================================================================
-- 1. PROFITABILITY ANALYSIS
-- Calculate Revenue, Cost, and Profit Margin by Category
-- Insight: Helps identify high-margin categories to promote and low-margin ones to optimize.
SELECT
    p.category,
    SUM(s.sales_amount) AS total_revenue,
    SUM(p.cost * s.quantity) AS total_cost,
    SUM(s.sales_amount) - SUM(p.cost * s.quantity) AS total_profit,
    ROUND(
        (
            SUM(s.sales_amount) - SUM(p.cost * s.quantity)
        ) / SUM(s.sales_amount) * 100,
        2
    ) AS profit_margin_pct
FROM
    gold_fact_sales s
    JOIN gold_dim_products p ON s.product_key = p.product_key
GROUP BY
    p.category
ORDER BY total_profit DESC;

-- 2. CUSTOMER RETENTION ANALYSIS
-- Identify Active vs Lapsed Customers (Lapsed = No purchase in last 12 months)
-- Insight: High lapsed percentage indicates a need for re-engagement campaigns.
WITH
    CustomerLastOrder AS (
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
    CASE
        WHEN TIMESTAMPDIFF(
            MONTH,
            last_order_date,
            max_db_date
        ) > 12 THEN 'Lapsed (>12 months)'
        ELSE 'Active (<12 months)'
    END AS customer_status,
    COUNT(*) AS customer_count,
    ROUND(
        COUNT(*) * 100.0 / (
            SELECT COUNT(*)
            FROM CustomerLastOrder
        ),
        1
    ) AS pct_of_base
FROM CustomerLastOrder
GROUP BY
    1;

-- 3. REGIONAL PERFORMANCE
-- Sales by Country
-- Insight: Identifies top performing markets.
SELECT
    c.country,
    SUM(s.sales_amount) AS total_revenue,
    SUM(s.sales_amount) - SUM(p.cost * s.quantity) AS total_profit,
    CONCAT(
        ROUND(
            (
                SUM(s.sales_amount) - SUM(p.cost * s.quantity)
            ) / SUM(s.sales_amount) * 100,
            2
        ),
        '%'
    ) AS profit_margin,
    COUNT(DISTINCT s.order_number) AS total_orders,
    ROUND(
        SUM(s.sales_amount) / COUNT(DISTINCT s.order_number),
        2
    ) AS avg_order_value
FROM
    gold_fact_sales s
    JOIN
        gold_dim_customers c ON s.customer_key = c.customer_key
    JOIN
        gold_dim_products p ON s.product_key = p.product_key
GROUP BY
    c.country
ORDER BY total_revenue DESC;

-- 4. PRODUCT PERFORMANCE (Top 10 Products by Revenue)
-- Insight: Focus inventory and marketing on these top performers.
SELECT
    p.product_name,
    p.category,
    SUM(s.sales_amount) AS total_revenue,
    SUM(s.quantity) AS total_units_sold
FROM
    gold_fact_sales s
    JOIN gold_dim_products p ON s.product_key = p.product_key
GROUP BY
    p.product_name,
    p.category
ORDER BY total_revenue DESC
LIMIT 10;
-- =============================================================================
-- NEXT STEP: High-level metrics found a margin gap.
-- Go to `business_deep_dive.sql` to find the root cause of these low margins.
-- =============================================================================