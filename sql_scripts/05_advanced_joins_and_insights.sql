-- ====================================================================
-- Project: Quick Commerce Delivery Operations Analysis
-- File: 05_advanced_joins_and_insights.sql
-- Description: Business Questions 24 to 30 (Advanced Joins, Grouping & Insights)
-- ====================================================================

-- Q24: Identify dark stores that experienced more than 10 cancellations (using HAVING filter).
SELECT 
    d.hub_name,
    d.city,
    COUNT(o.order_id) AS total_cancellations
FROM orders_log AS o
JOIN dark_stores AS d ON o.hub_id = d.hub_id
WHERE o.order_status = 'Cancelled'
GROUP BY d.hub_name, d.city
HAVING COUNT(o.order_id) > 10
ORDER BY total_cancellations DESC;


-- Q25: Which top 3 riders generated the highest cumulative revenue for the platform?
SELECT 
    r.rider_id,
    r.vehicle_type,
    r.rider_rating,
    SUM(o.order_value_inr) AS total_revenue_generated_inr
FROM orders_log AS o
JOIN rider_fleet AS r ON o.rider_id = r.rider_id
WHERE o.order_status = 'Delivered'
GROUP BY r.rider_id, r.vehicle_type, r.rider_rating
ORDER BY total_revenue_generated_inr DESC
LIMIT 3;


-- Q26: In which hour of the day is the order volume highest (peak-hour analysis)?
SELECT 
    EXTRACT(HOUR FROM order_time) AS order_hour,
    COUNT(order_id) AS orders_placed_count
FROM orders_log
GROUP BY order_hour
ORDER BY orders_placed_count DESC;


-- Q27: What is the fleet allocation per hub (number of riders assigned to each dark store)?
SELECT 
    d.hub_name,
    d.city,
    d.max_capacity_per_hr,
    COUNT(r.rider_id) AS total_assigned_riders
FROM dark_stores AS d
LEFT JOIN rider_fleet AS r ON d.hub_id = r.hub_id
GROUP BY d.hub_name, d.city, d.max_capacity_per_hr
ORDER BY total_assigned_riders DESC;


-- Q28: How does the delay percentage compare between high-value orders (> 1000) and budget orders (<= 500)?
SELECT 
    CASE 
        WHEN order_value_inr > 1000 THEN 'High-Value (> 1000)'
        WHEN order_value_inr <= 500 THEN 'Budget (<= 500)'
        ELSE 'Mid-Tier (501 - 1000)'
    END AS order_tier,
    COUNT(*) AS total_orders,
    ROUND(
        100.0 * COUNT(CASE WHEN actual_delivery_min > promised_delivery_min THEN 1 END) / COUNT(*), 
        2
    ) AS delay_percentage
FROM orders_log
WHERE order_status = 'Delivered'
GROUP BY order_tier
ORDER BY delay_percentage DESC;


-- Q29: Identify reliable riders who completed at least 20 deliveries with an average delivery time under 14 minutes.
SELECT 
    r.rider_id,
    r.vehicle_type,
    COUNT(o.order_id) AS deliveries_count,
    ROUND(AVG(o.actual_delivery_min), 2) AS avg_delivery_time_min
FROM orders_log AS o
JOIN rider_fleet AS r ON o.rider_id = r.rider_id
WHERE o.order_status = 'Delivered'
GROUP BY r.rider_id, r.vehicle_type
HAVING COUNT(o.order_id) >= 20 
   AND AVG(o.actual_delivery_min) < 14
ORDER BY avg_delivery_time_min ASC;


-- Q30: What is the top-performing rider (by highest delivered orders count) for each dark store?
SELECT DISTINCT ON (d.hub_name)
    d.hub_name,
    r.rider_id,
    COUNT(o.order_id) AS completed_orders
FROM orders_log AS o
JOIN dark_stores AS d ON o.hub_id = d.hub_id
JOIN rider_fleet AS r ON o.rider_id = r.rider_id
WHERE o.order_status = 'Delivered'
GROUP BY d.hub_name, r.rider_id
ORDER BY d.hub_name, completed_orders DESC;