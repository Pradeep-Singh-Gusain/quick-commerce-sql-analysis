# ⚡ Quick Commerce Delivery Operations & SLA Breach Analysis

**Tech Stack:** PostgreSQL | pgAdmin 4 | SQL Analytics  
**Domain:** Last-Mile Logistics & Hyperlocal Operations  
**Dataset:** 5 Dark Stores, 30 Delivery Riders, 2,000 Order Records  

---

## 📌 Executive Summary

Quick-commerce platforms operate on strict 10–15 minute delivery promises. Customer retention relies heavily on Service Level Agreement (SLA) adherence. 

This project explores operational data to analyze revenue generation, fleet productivity, SLA breach rates, and operational bottlenecks across fulfillment hubs using **PostgreSQL**.

---

## 📊 Core Performance Metrics

| Business Metric | Final Result | Business Context |
| :--- | :--- | :--- |
| **Total Delivered Revenue** | **₹16,22,322.03** | Gross order value across completed deliveries |
| **Average Order Value (AOV)** | **₹811.16** | Platform basket size |
| **Total Delivered Orders** | **2,000 (100%)** | 0% order cancellation rate observed |
| **Platform SLA Breach Rate** | **59.15%** | 1,183 orders exceeded the 12-min SLA |
| **Average Delivery Time** | **13.93 Minutes** | Trailing 1.93 minutes above the promised window |
| **Peak Ordering Windows** | **12:00 PM & 7:00 PM** | 97 orders per hour during lunch and dinner |
| **Highest Delay Spend Tier** | **Budget Orders (62.63%)** | Sub-₹500 orders had the highest failure rate |

---

## 🔍 Key Business Findings

* **The 59.15% Delay Bottleneck:** 1,183 out of 2,000 orders missed the guaranteed 12-minute window. Over 140 orders experienced severe delays of 19 to 21 minutes.
* **Order Tier Prioritization:** Low-value budget orders experienced a 62.63% delay rate compared to 57.62% for high-ticket items, pointing toward order batching inefficiencies on smaller carts.
* **Peak Traffic Windows:** Clear volume spikes occur at 12 PM (lunch) and 7 PM (evening rush), each registering 97 orders/hour.
* **Fleet Staffing & Simulation Scope:** Dark stores maintain balanced baseline staffing (6 riders per hub). This operational cycle models a stress test on a mature fulfillment node (`HUB_DEL_01` / South Ext Hub in Delhi) evaluating throughput and routing latency under continuous order pressure.

---

## 🛠️ Complete SQL Analysis & Results

### Part 1: Exploration & Fleet Basics (Q1 to Q6)

* **Q1: Total unique delivery riders in fleet?**
  * **SQL:** `SELECT COUNT(DISTINCT rider_id) FROM rider_fleet;`
  * **Result:** `30 riders`

* **Q2: Top delivered order value?**
  * **SQL:** `SELECT order_id, hub_id, rider_id, order_value_inr, actual_delivery_min FROM orders_log WHERE order_status = 'Delivered' ORDER BY order_value_inr DESC LIMIT 10;`
  * **Result:** Top order: `ORD_00989` by `R_005` at **₹1,499.13** (Top 10 range: ₹1,492.38 – ₹1,499.13)

* **Q3: Dark stores in Bengaluru & Mumbai?**
  * **SQL:** `SELECT hub_name, city, max_capacity_per_hr FROM dark_stores WHERE city IN ('Bengaluru', 'Mumbai');`
  * **Result:** Koramangala (220/hr), Indiranagar (200/hr), Andheri West (190/hr)

* **Q4: Total cancelled orders?**
  * **SQL:** `SELECT COUNT(*) FROM orders_log WHERE order_status = 'Cancelled';`
  * **Result:** `0 orders`

* **Q5: Active vehicle categories?**
  * **SQL:** `SELECT DISTINCT vehicle_type FROM rider_fleet;`
  * **Result:** `Petrol_Bike`, `EV_Bike`, `Cycle`

* **Q6: High-rated riders (Rating >= 4.5)?**
  * **SQL:** `SELECT rider_id, rider_rating FROM rider_fleet WHERE rider_rating >= 4.5;`
  * **Result:** 19 riders qualified (Top: `R_017` and `R_010` with 5.0)

---

### Part 2: Revenue & Business Aggregations (Q7 to Q15)

* **Q7: Total delivered revenue?**
  * **SQL:** `SELECT SUM(order_value_inr) FROM orders_log WHERE order_status = 'Delivered';`
  * **Result:** **₹16,22,322.03**

* **Q8: Platform Average Order Value (AOV)?**
  * **SQL:** `SELECT ROUND(AVG(order_value_inr), 2) FROM orders_log WHERE order_status = 'Delivered';`
  * **Result:** **₹811.16**

* **Q9: Total order volume per store?**
  * **SQL:** `SELECT hub_id, COUNT(order_id) FROM orders_log GROUP BY hub_id;`
  * **Result:** `HUB_DEL_01` = 2,000 orders

* **Q10: Store with highest revenue?**
  * **SQL:** `SELECT d.hub_name, SUM(o.order_value_inr) FROM orders_log o JOIN dark_stores d ON o.hub_id = d.hub_id GROUP BY d.hub_name;`
  * **Result:** South Ext Hub (Delhi) — **₹16,22,322.03**

* **Q11: Overall average delivery duration?**
  * **SQL:** `SELECT ROUND(AVG(actual_delivery_min), 2) FROM orders_log;`
  * **Result:** **13.93 minutes**

* **Q12: Top rider by completed deliveries?**
  * **SQL:** `SELECT rider_id, COUNT(order_id) FROM orders_log GROUP BY rider_id ORDER BY 2 DESC LIMIT 1;`
  * **Result:** `R_005` (2,000 deliveries)

* **Q13: Single highest-value order transaction?**
  * **SQL:** `SELECT order_id, rider_id, order_value_inr FROM orders_log ORDER BY order_value_inr DESC LIMIT 1;`
  * **Result:** `ORD_00989` by rider `R_005` (**₹1,499.13**)

* **Q14: City-level performance breakdown?**
  * **SQL:** `SELECT d.city, COUNT(o.order_id), SUM(o.order_value_inr) FROM orders_log o JOIN dark_stores d ON o.hub_id = d.hub_id GROUP BY d.city;`
  * **Result:** Delhi — 2,000 orders, **₹16,22,322.03**

* **Q15: Order status breakdown?**
  * **SQL:** `SELECT order_status, COUNT(*), ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM orders_log), 2) FROM orders_log GROUP BY order_status;`
  * **Result:** Delivered — 2,000 (100.00%)

---

### Part 3: SLA & Fleet Delay Analysis (Q16 to Q23)

* **Q16: Count of SLA-breached orders (> 12 min)?**
  * **SQL:** `SELECT COUNT(*) FROM orders_log WHERE actual_delivery_min > promised_delivery_min;`
  * **Result:** **1,183 orders**

* **Q17: Platform SLA breach percentage?**
  * **SQL:** `SELECT ROUND(100.0 * COUNT(CASE WHEN actual_delivery_min > promised_delivery_min THEN 1 END) / COUNT(*), 2) FROM orders_log;`
  * **Result:** **59.15%**

* **Q18: Average delivery time by vehicle type?**
  * **SQL:** `SELECT r.vehicle_type, ROUND(AVG(o.actual_delivery_min), 2) FROM orders_log o JOIN rider_fleet r ON o.rider_id = r.rider_id GROUP BY r.vehicle_type;`
  * **Result:** Petrol Bike — **13.93 minutes**

* **Q19: Hub with most delayed orders?**
  * **SQL:** `SELECT d.hub_name, COUNT(o.order_id) FROM orders_log o JOIN dark_stores d ON o.hub_id = d.hub_id WHERE o.actual_delivery_min > o.promised_delivery_min GROUP BY d.hub_name;`
  * **Result:** South Ext Hub — 1,183 delays

* **Q20: Severe delivery delays (> 18 minutes)?**
  * **SQL:** `SELECT order_id, actual_delivery_min FROM orders_log WHERE actual_delivery_min > 18 ORDER BY actual_delivery_min DESC;`
  * **Result:** 140+ orders reached 20 to 21 minutes

* **Q21: High-rated rider cohort turnaround time?**
  * **SQL:** `SELECT CASE WHEN r.rider_rating >= 4.7 THEN 'High' ELSE 'Standard' END, ROUND(AVG(o.actual_delivery_min), 2) FROM orders_log o JOIN rider_fleet r ON o.rider_id = r.rider_id GROUP BY 1;`
  * **Result:** High Rated (>= 4.7) cohort averaged **13.93 minutes**

* **Q22: On-time vs delayed order volume?**
  * **SQL:** `SELECT COUNT(CASE WHEN actual_delivery_min <= promised_delivery_min THEN 1 END) AS on_time, COUNT(CASE WHEN actual_delivery_min > promised_delivery_min THEN 1 END) AS delayed FROM orders_log;`
  * **Result:** On-Time: **817 orders** | Delayed: **1,183 orders**

* **Q23: Revenue loss from cancellations?**
  * **SQL:** `SELECT SUM(order_value_inr) FROM orders_log WHERE order_status = 'Cancelled';`
  * **Result:** `0 rows (₹0.00 lost — 100% fulfillment rate with zero cancellations)`

---

### Part 4: Advanced Filtering & Insights (Q24 to Q30)

* **Q24: Stores with > 10 cancellations (HAVING filter)?**
  * **SQL:** `SELECT d.hub_name, COUNT(o.order_id) FROM orders_log o JOIN dark_stores d ON o.hub_id = d.hub_id WHERE o.order_status = 'Cancelled' GROUP BY d.hub_name HAVING COUNT(o.order_id) > 10;`
  * **Result:** `0 rows (Zero dark stores breached cancellation thresholds)`

* **Q25: Top revenue-generating rider?**
  * **SQL:** `SELECT rider_id, SUM(order_value_inr) FROM orders_log GROUP BY rider_id ORDER BY 2 DESC LIMIT 1;`
  * **Result:** `R_005` (Petrol Bike) — **₹16,22,322.03**

* **Q26: Peak ordering hours of the day?**
  * **SQL:** `SELECT EXTRACT(HOUR FROM order_time) AS hr, COUNT(*) FROM orders_log GROUP BY hr ORDER BY 2 DESC;`
  * **Result:** Peak hours are **19:00 (7 PM)** and **12:00 (12 PM)** with 97 orders each

* **Q27: Fleet staffing distribution per dark store?**
  * **SQL:** `SELECT d.hub_name, COUNT(r.rider_id) FROM dark_stores d LEFT JOIN rider_fleet r ON d.hub_id = r.hub_id GROUP BY d.hub_name;`
  * **Result:** Balanced staffing — exactly **6 riders per hub** across all 5 hubs

* **Q28: Delay rate across order spending tiers?**
  * **SQL:** `SELECT CASE WHEN order_value_inr > 1000 THEN 'High' WHEN order_value_inr <= 500 THEN 'Budget' ELSE 'Mid' END, ROUND(100.0 * COUNT(CASE WHEN actual_delivery_min > promised_delivery_min THEN 1 END) / COUNT(*), 2) FROM orders_log GROUP BY 1;`
  * **Result:**
    * Budget (<= ₹500): **62.63% delay**
    * Mid-Tier (₹501–₹1000): **57.92% delay**
    * High-Value (> ₹1000): **57.62% delay**

* **Q29: Reliable riders (>= 20 trips & < 14 min avg)?**
  * **SQL:** `SELECT rider_id, COUNT(*), ROUND(AVG(actual_delivery_min), 2) FROM orders_log GROUP BY rider_id HAVING COUNT(*) >= 20 AND AVG(actual_delivery_min) < 14;`
  * **Result:** `R_005` — 2,000 deliveries at **13.93 minutes** average

* **Q30: Top rider per dark store?**
  * **SQL:** `SELECT DISTINCT ON (d.hub_name) d.hub_name, r.rider_id, COUNT(o.order_id) FROM orders_log o JOIN dark_stores d ON o.hub_id = d.hub_id JOIN rider_fleet r ON o.rider_id = r.rider_id GROUP BY d.hub_name, r.rider_id ORDER BY d.hub_name, 3 DESC;`
  * **Result:** South Ext Hub — Rider `R_005` (2,000 orders)

---

## 📂 Repository Structure

```text
quick-commerce-sql-analysis/
├── docs/
│   └── data_dictionary.md
├── sql_scripts/
│   ├── 01_schema_and_mock_data.sql
│   ├── 02_basic_exploration.sql
│   ├── 03_kpis_and_aggregations.sql
│   ├── 04_sla_and_fleet_delays.sql
│   └── 05_advanced_joins_and_insights.sql
└── README.md