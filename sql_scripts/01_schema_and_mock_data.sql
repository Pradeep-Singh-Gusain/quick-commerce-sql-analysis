-- 1. Purani tables drop karna (Fresh start)
DROP TABLE IF EXISTS orders_log;
DROP TABLE IF EXISTS rider_fleet;
DROP TABLE IF EXISTS dark_stores;

-- 2. dark_stores Table: Hubs details
CREATE TABLE dark_stores (
    hub_id VARCHAR(10) PRIMARY KEY,
    hub_name VARCHAR(50) NOT NULL,
    city VARCHAR(30) NOT NULL,
    max_capacity_per_hr INT
);

-- 3. rider_fleet Table: Delivery partners
CREATE TABLE rider_fleet (
    rider_id VARCHAR(10) PRIMARY KEY,
    hub_id VARCHAR(10) REFERENCES dark_stores(hub_id),
    vehicle_type VARCHAR(20),
    rider_rating NUMERIC(2, 1)
);

-- 4. orders_log Table: Granular delivery orders
CREATE TABLE orders_log (
    order_id VARCHAR(15) PRIMARY KEY,
    hub_id VARCHAR(10) REFERENCES dark_stores(hub_id),
    rider_id VARCHAR(10) REFERENCES rider_fleet(rider_id),
    order_time TIMESTAMP,
    promised_delivery_min INT,
    actual_delivery_min INT,
    order_value_inr NUMERIC(8, 2),
    order_status VARCHAR(20)
);

-- 5. Hubs Data Insert (5 Fulfillment Centers)
INSERT INTO dark_stores (hub_id, hub_name, city, max_capacity_per_hr) VALUES
('HUB_DEL_01', 'South Ext Hub', 'Delhi', 180),
('HUB_DEL_02', 'Rohini Hub', 'Delhi', 140),
('HUB_BLR_01', 'Koramangala Hub', 'Bengaluru', 220),
('HUB_BLR_02', 'Indiranagar Hub', 'Bengaluru', 200),
('HUB_MUM_01', 'Andheri West Hub', 'Mumbai', 190);

-- 6. Rider Fleet Data Insert (30 Riders)
INSERT INTO rider_fleet (rider_id, hub_id, vehicle_type, rider_rating)
SELECT 
    'R_' || LPAD(i::TEXT, 3, '0') AS rider_id,
    (ARRAY['HUB_DEL_01', 'HUB_DEL_02', 'HUB_BLR_01', 'HUB_BLR_02', 'HUB_MUM_01'])[1 + MOD(i, 5)] AS hub_id,
    (ARRAY['EV_Bike', 'Petrol_Bike', 'Petrol_Bike', 'Cycle'])[1 + MOD(i, 4)] AS vehicle_type,
    ROUND((3.8 + (RANDOM() * 1.2))::NUMERIC, 1) AS rider_rating
FROM generate_series(1, 30) AS i;

-- 7. Orders Data Insert (Exact 2,000 Orders)
INSERT INTO orders_log (order_id, hub_id, rider_id, order_time, promised_delivery_min, actual_delivery_min, order_value_inr, order_status)
SELECT 
    'ORD_' || LPAD(i::TEXT, 5, '0') AS order_id,
    r.hub_id,
    r.rider_id,
    TIMESTAMP '2026-08-01 08:00:00' + (RANDOM() * INTERVAL '15 days') AS order_time,
    12 AS promised_delivery_min,
    CASE 
        WHEN s.status = 'Cancelled' THEN NULL
        ELSE FLOOR(7 + (RANDOM() * 15))::INT
    END AS actual_delivery_min,
    ROUND((120 + (RANDOM() * 1380))::NUMERIC, 2) AS order_value_inr,
    s.status AS order_status
FROM generate_series(1, 2000) AS i
CROSS JOIN LATERAL (
    SELECT rider_id, hub_id 
    FROM rider_fleet 
    WHERE rider_id = 'R_' || LPAD((1 + FLOOR(RANDOM() * 30))::TEXT, 3, '0')
) AS r
CROSS JOIN LATERAL (
    SELECT 
        CASE 
            WHEN RANDOM() < 0.88 THEN 'Delivered'
            WHEN RANDOM() < 0.95 THEN 'Returned'
            ELSE 'Cancelled'
        END AS status
) AS s;