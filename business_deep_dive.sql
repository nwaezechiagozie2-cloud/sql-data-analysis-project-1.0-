-- Active: 1764674974722@@127.0.0.1@3306@DataWarehouseAnalytics
-- =============================================================================
-- DEEP DIVE: ROOT CAUSE ANALYSIS
-- =============================================================================

-- 1. SUBCATEGORY DRILL-DOWN
-- Question: Within "Bikes", are Road Bikes dragging down margins?
-- Question: Within "Accessories", what are the actual high-margin items we should push?
SELECT
    p.category,
    p.subcategory,
    COUNT(DISTINCT s.order_number) as total_orders,
    SUM(s.sales_amount) as revenue,
    SUM(p.cost * s.quantity) as total_cost,
    ROUND(
        (
            SUM(s.sales_amount) - SUM(p.cost * s.quantity)
        ) / SUM(s.sales_amount) * 100,
        2
    ) as margin_pct
FROM
    gold_fact_sales s
    JOIN gold_dim_products p ON s.product_key = p.product_key
GROUP BY
    p.category,
    p.subcategory
ORDER BY p.category, margin_pct DESC;

-- 2. REGIONAL CATEGORY MIX
-- Question: Is the low Accessory sales volume a global problem, or specific to one region?
-- Insight: If one country has a 50/50 split and another is 90/10, we know it's a sales execution issue.
SELECT
    c.country,
    p.category,
    SUM(s.sales_amount) as revenue,
    -- Calculate the % contribution of this category to the country's total sales
    ROUND(
        SUM(s.sales_amount) / SUM(SUM(s.sales_amount)) OVER (
            PARTITION BY
                c.country
        ) * 100,
        2
    ) as pct_of_country_sales,
    ROUND(
        (
            SUM(s.sales_amount) - SUM(p.cost * s.quantity)
        ) / SUM(s.sales_amount) * 100,
        2
    ) as margin_pct
FROM
    gold_fact_sales s
    JOIN gold_dim_products p ON s.product_key = p.product_key
    JOIN gold_dim_customers c ON s.customer_key = c.customer_key
WHERE
    c.country IS NOT NULL
GROUP BY
    c.country,
    p.category
ORDER BY c.country, revenue DESC;

-- =============================================================================
-- NEXT STEP: We found the "Australia Anomaly" and "Jersey Trap."
-- Go to `customer_segmentation_rfm.sql` to see if these customers are worth saving.
-- =============================================================================