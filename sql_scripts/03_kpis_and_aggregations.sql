-- ====================================================================
-- Project: Quick Commerce Delivery Operations Analysis
-- File: 03_kpis_and_aggregations.sql
-- Description: Business Questions 7 to 15 (Aggregations & Key Metrics)
-- ====================================================================

-- Q7: What is the total revenue generated from all successfully delivered orders?
SELECT 
    SUM(order_value_inr) AS total_delivered_revenue_inr
FROM orders_log
WHERE order_status = 'Delivered';


-- Q8: What is the overall Average Order Value (AOV) for delivered orders?
SELECT 
    ROUND(AVG(order_value_inr), 2) AS average_order_value_inr
FROM orders_log
WHERE order_status = 'Delivered';


-- Q9: What is the total count of delivered orders handled by each dark store?
SELECT 
    hub_id,
    COUNT(order_id) AS total_delivered_orders
FROM orders_log
WHERE order_status = 'Delivered'
GROUP BY hub_id
ORDER BY total_delivered_orders DESC;


-- Q10: Which dark store generated the highest total revenue?
SELECT 
    d.hub_name,
    d.city,
    SUM(o.order_value_inr) AS total_revenue_inr
FROM orders_log AS o
JOIN dark_stores AS d ON o.hub_id = d.hub_id
WHERE o.order_status = 'Delivered'
GROUP BY d.hub_name, d.city
ORDER BY total_revenue_inr DESC
LIMIT 1;


-- Q11: What is the overall average delivery time (in minutes) across all delivered orders?
SELECT 
    ROUND(AVG(actual_delivery_min), 2) AS overall_avg_delivery_minutes
FROM orders_log
WHERE order_status = 'Delivered';


-- Q12: Which top 5 delivery riders completed the highest number of deliveries?
SELECT 
    rider_id,
    COUNT(order_id) AS total_deliveries_completed
FROM orders_log
WHERE order_status = 'Delivered'
GROUP BY rider_id
ORDER BY total_deliveries_completed DESC
LIMIT 5;


-- Q13: What was the single highest-value order delivered, and which rider completed it?
SELECT 
    order_id,
    rider_id,
    order_value_inr
FROM orders_log
WHERE order_status = 'Delivered'
ORDER BY order_value_inr DESC
LIMIT 1;


-- Q14: What is the total order volume and total revenue generated broken down by city?
SELECT 
    d.city,
    COUNT(o.order_id) AS total_orders,
    SUM(o.order_value_inr) AS city_revenue_inr
FROM orders_log AS o
JOIN dark_stores AS d ON o.hub_id = d.hub_id
WHERE o.order_status = 'Delivered'
GROUP BY d.city
ORDER BY city_revenue_inr DESC;


-- Q15: What is the percentage distribution of orders across each order status?
SELECT 
    order_status,
    COUNT(*) AS order_count,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM orders_log), 2) AS status_percentage
FROM orders_log
GROUP BY order_status
ORDER BY order_count DESC;