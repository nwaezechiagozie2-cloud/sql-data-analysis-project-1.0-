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