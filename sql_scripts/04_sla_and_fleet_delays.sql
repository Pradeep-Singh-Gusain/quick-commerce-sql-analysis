-- ====================================================================
-- Project: Quick Commerce Delivery Operations Analysis
-- File: 04_sla_and_fleet_delays.sql
-- Description: Business Questions 16 to 23 (SLA & Fleet Performance)
-- ====================================================================

-- Q16: How many delivered orders breached the promised delivery time (SLA)?
SELECT 
    COUNT(*) AS total_sla_breached_orders
FROM orders_log
WHERE order_status = 'Delivered' 
  AND actual_delivery_min > promised_delivery_min;


-- Q17: What is the overall percentage of SLA-delayed orders on the platform?[cite: 1]
SELECT 
    COUNT(*) AS total_delivered_orders,
    COUNT(CASE WHEN actual_delivery_min > promised_delivery_min THEN 1 END) AS delayed_orders,
    ROUND(
        100.0 * COUNT(CASE WHEN actual_delivery_min > promised_delivery_min THEN 1 END) / COUNT(*), 
        2
    ) AS delay_percentage
FROM orders_log
WHERE order_status = 'Delivered';


-- Q18: What is the average delivery time (in minutes) broken down by vehicle category?[cite: 1]
SELECT 
    r.vehicle_type,
    COUNT(o.order_id) AS total_trips,
    ROUND(AVG(o.actual_delivery_min), 2) AS avg_delivery_minutes
FROM orders_log AS o
JOIN rider_fleet AS r ON o.rider_id = r.rider_id
WHERE o.order_status = 'Delivered'
GROUP BY r.vehicle_type
ORDER BY avg_delivery_minutes ASC;


-- Q19: Which dark store hub recorded the highest number of delayed orders?
SELECT 
    d.hub_name,
    d.city,
    COUNT(o.order_id) AS delayed_order_count
FROM orders_log AS o
JOIN dark_stores AS d ON o.hub_id = d.hub_id
WHERE o.order_status = 'Delivered' 
  AND o.actual_delivery_min > o.promised_delivery_min
GROUP BY d.hub_name, d.city
ORDER BY delayed_order_count DESC
LIMIT 1;


-- Q20: Identify orders that suffered severe delays (taking longer than 18 minutes).
SELECT 
    order_id,
    hub_id,
    rider_id,
    actual_delivery_min,
    order_value_inr
FROM orders_log
WHERE order_status = 'Delivered' 
  AND actual_delivery_min > 18
ORDER BY actual_delivery_min DESC;


-- Q21: Do highly rated riders (rating >= 4.7) maintain a faster average delivery time?
SELECT 
    CASE 
        WHEN r.rider_rating >= 4.7 THEN 'High Rated (>= 4.7)'
        ELSE 'Standard Rated (< 4.7)'
    END AS rating_cohort,
    COUNT(o.order_id) AS total_orders,
    ROUND(AVG(o.actual_delivery_min), 2) AS avg_delivery_minutes
FROM orders_log AS o
JOIN rider_fleet AS r ON o.rider_id = r.rider_id
WHERE o.order_status = 'Delivered'
GROUP BY rating_cohort;


-- Q22: What is the breakdown of on-time versus delayed orders for each dark store?
SELECT 
    d.hub_name,
    COUNT(CASE WHEN o.actual_delivery_min <= o.promised_delivery_min THEN 1 END) AS on_time_count,
    COUNT(CASE WHEN o.actual_delivery_min > o.promised_delivery_min THEN 1 END) AS delayed_count
FROM orders_log AS o
JOIN dark_stores AS d ON o.hub_id = d.hub_id
WHERE o.order_status = 'Delivered'
GROUP BY d.hub_name
ORDER BY delayed_count DESC;


-- Q23: What is the total revenue loss caused by order cancellations broken down by hub?[cite: 1]
SELECT 
    d.hub_name,
    COUNT(o.order_id) AS cancelled_orders_count,
    SUM(o.order_value_inr) AS lost_revenue_inr
FROM orders_log AS o
JOIN dark_stores AS d ON o.hub_id = d.hub_id
WHERE o.order_status = 'Cancelled'
GROUP BY d.hub_name
ORDER BY lost_revenue_inr DESC;