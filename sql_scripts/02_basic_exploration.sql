-- ====================================================================
-- Project: Quick Commerce Delivery Operations Analysis
-- File: 02_basic_exploration.sql
-- Description: Business Questions 1 to 6 (Exploration & Filtering)
-- ====================================================================

-- Q1: What is the total count of unique delivery riders registered in the fleet?
SELECT 
    COUNT(DISTINCT rider_id) AS total_unique_riders
FROM rider_fleet;


-- Q2: Retrieve the top 10 highest-value orders that were successfully 'Delivered'.
SELECT 
    order_id,
    hub_id,
    rider_id,
    order_value_inr,
    actual_delivery_min
FROM orders_log
WHERE order_status = 'Delivered'
ORDER BY order_value_inr DESC
LIMIT 10;


-- Q3: Fetch the list of dark stores located in Bengaluru and Mumbai along with their operational capacity.
SELECT 
    hub_id,
    hub_name,
    city,
    max_capacity_per_hr
FROM dark_stores
WHERE city IN ('Bengaluru', 'Mumbai')
ORDER BY max_capacity_per_hr DESC;


-- Q4: What is the total number of orders cancelled on the platform?
SELECT 
    COUNT(*) AS total_cancelled_orders
FROM orders_log
WHERE order_status = 'Cancelled';


-- Q5: What are the distinct vehicle categories currently utilized by the delivery fleet?
SELECT DISTINCT 
    vehicle_type
FROM rider_fleet;


-- Q6: Identify all riders who maintain a customer rating of 4.5 or higher.
SELECT 
    rider_id,
    hub_id,
    vehicle_type,
    rider_rating
FROM rider_fleet
WHERE rider_rating >= 4.5
ORDER BY rider_rating DESC;