-- =============================================================================
-- CORRELATION ANALYSIS: BIKE TYPE VS. ACCESSORY ATTACHMENT
-- =============================================================================
-- Question: Does a higher bike margin (Mountain Bikes) lead to lower accessory sales?
-- Purpose: To provide the CEO with the "Trade-off" between high-margin bikes
--          and high-attachment bikes.

WITH
    OrderSummary AS (
        -- For every order, calculate bike revenue and accessory revenue separately
        SELECT
            s.order_number,
            MAX(
                CASE
                    WHEN p.category = 'Bikes' THEN p.subcategory
                END
            ) as bike_type,
            SUM(
                CASE
                    WHEN p.category = 'Bikes' THEN s.sales_amount
                    ELSE 0
                END
            ) as bike_rev,
            SUM(
                CASE
                    WHEN p.category = 'Accessories' THEN s.sales_amount
                    ELSE 0
                END
            ) as acc_rev,
            COUNT(
                CASE
                    WHEN p.category = 'Accessories' THEN 1
                END
            ) as acc_count
        FROM
            gold_fact_sales s
            JOIN gold_dim_products p ON s.product_key = p.product_key
        GROUP BY
            s.order_number
        HAVING
            bike_rev > 0 -- Only look at orders that contain a bike
    )
SELECT
    bike_type,
    COUNT(*) as total_orders,
    -- Attachment Rate: % of bike orders that included at least one accessory
    ROUND(
        SUM(
            CASE
                WHEN acc_count > 0 THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        1
    ) as attachment_rate_pct,
    -- Average Accessory Revenue per Bike Order
    ROUND(AVG(acc_rev), 2) as avg_acc_spend_per_order,
    -- Estimated Total Margin (Bike Margin + Accessory Margin)
    -- Using: Mountain (43%), Road (39%), Touring (41%), Accessories (63%)
    CASE
        WHEN bike_type = 'Mountain Bikes' THEN '43%'
        WHEN bike_type = 'Road Bikes' THEN '39%'
        WHEN bike_type = 'Touring Bikes' THEN '41%'
    END as bike_margin_pct
FROM OrderSummary
GROUP BY
    bike_type
ORDER BY avg_acc_spend_per_order DESC;
SELECT 
    p_bike.subcategory as bike_type,
    p_acc.subcategory as accessory_type,
    COUNT(*) as attachment_count
FROM gold_fact_sales s1
JOIN gold_dim_products p_bike ON s1.product_key = p_bike.product_key
JOIN gold_fact_sales s2 ON s1.order_number = s2.order_number
JOIN gold_dim_products p_acc ON s2.product_key = p_acc.product_key
WHERE p_bike.category = 'Bikes' 
  AND p_acc.category = 'Accessories'
GROUP BY 1, 2
ORDER BY 1, 3 DESC;

WITH BikeOrders AS (
    SELECT 
        s.order_number,
        c.country,
        p.subcategory as bike_type
    FROM gold_fact_sales s
    JOIN gold_dim_products p ON s.product_key = p.product_key
    JOIN gold_dim_customers c ON s.customer_key = c.customer_key
    WHERE p.category = 'Bikes'
),
UniversalAttachments AS (
    SELECT 
        s.order_number,
        SUM(CASE WHEN p.subcategory = 'Bottles and Cages' THEN 1 ELSE 0 END) as has_bottle,
        SUM(CASE WHEN p.subcategory = 'Tires and Tubes' THEN 1 ELSE 0 END) as has_tube,
        SUM(CASE WHEN p.subcategory = 'Helmets' THEN 1 ELSE 0 END) as has_helmet
    FROM gold_fact_sales s
    JOIN gold_dim_products p ON s.product_key = p.product_key
    WHERE p.subcategory IN ('Bottles and Cages', 'Tires and Tubes', 'Helmets')
    GROUP BY s.order_number
)
SELECT 
    b.country,
    COUNT(b.order_number) as total_bikes_sold,
    -- % of bikes sold WITHOUT a helmet
    ROUND(SUM(CASE WHEN a.has_helmet IS NULL OR a.has_helmet = 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(b.order_number), 1) as pct_missed_helmet,
    -- % of bikes sold WITHOUT a bottle
    ROUND(SUM(CASE WHEN a.has_bottle IS NULL OR a.has_bottle = 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(b.order_number), 1) as pct_missed_bottle
FROM BikeOrders b
LEFT JOIN UniversalAttachments a ON b.order_number = a.order_number
GROUP BY b.country
ORDER BY pct_missed_helmet DESC;

WITH CustomerOrders AS (
    SELECT 
        c.country,
        s.customer_key,
        COUNT(DISTINCT s.order_number) as total_orders,
        SUM(CASE WHEN p.category = 'Bikes' THEN 1 ELSE 0 END) as bought_bike,
        SUM(CASE WHEN p.category = 'Accessories' THEN 1 ELSE 0 END) as bought_acc
    FROM gold_fact_sales s
    JOIN gold_dim_products p ON s.product_key = p.product_key
    JOIN gold_dim_customers c ON s.customer_key = c.customer_key
    GROUP BY c.country, s.customer_key
)
SELECT 
    country,
    COUNT(*) as total_customers,
    -- % of customers who bought MORE than once
    ROUND(SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) as repeat_customer_rate,
    -- % of customers who bought a bike AND came back for accessories later
    ROUND(SUM(CASE WHEN bought_bike > 0 AND bought_acc > 0 AND total_orders > 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) as bike_to_acc_conversion
FROM CustomerOrders
GROUP BY country
ORDER BY repeat_customer_rate DESC;

SELECT 
    c.country,
    p.category,
    COUNT(s.order_number) as total_orders,
    SUM(s.sales_amount) as total_revenue,
    ROUND(SUM(s.sales_amount) / COUNT(s.order_number), 2) as avg_spend_per_order
FROM gold_fact_sales s
JOIN gold_dim_products p ON s.product_key = p.product_key
JOIN gold_dim_customers c ON s.customer_key = c.customer_key
WHERE p.category = 'Accessories'
GROUP BY c.country, p.category
ORDER BY avg_spend_per_order DESC;
