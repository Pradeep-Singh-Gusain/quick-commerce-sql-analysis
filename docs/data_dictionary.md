# Quick Commerce Dark Store Operations — Data Dictionary

## Overview
This document provides complete schema definitions, column-level metadata, data types, constraints, and business domain logic for the **Quick Commerce Delivery Operations** database (`quick_commerce_db`) built in PostgreSQL.

---

## 1. Entity-Relationship Summary

| Table Name | Primary Key | Foreign Key Dependencies | Description | Row Count |
| :--- | :--- | :--- | :--- | :--- |
| **`dark_stores`** | `hub_id` | *None* | Master table containing regional fulfillment hubs / dark store locations. | 5 |
| **`rider_fleet`** | `rider_id` | `hub_id` &rarr; `dark_stores(hub_id)` | Delivery partner personnel registry, fleet category, and customer ratings. | 30 |
| **`orders_log`** | `order_id` | `hub_id` &rarr; `dark_stores(hub_id)`, `rider_id` &rarr; `rider_fleet(rider_id)` | Transactional log of delivery dispatches, order financials, SLAs, and order lifecycle states. | 2,000 |

---

## 2. Table: `dark_stores`

* **Business Purpose:** Represents the hyperlocal physical micro-warehouses (dark stores) fulfilling instant grocery deliveries within a 2–3 km radius.

| Column Name | Data Type | Constraints | Nullable | Description / Business Logic | Example |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `hub_id` | `VARCHAR(20)` | `PRIMARY KEY` | No | Unique business identifier assigned to each dark store hub. | `'HUB_BLR_01'` |
| `hub_name` | `VARCHAR(100)` | `NOT NULL` | No | Operational name indicating the physical neighborhood / locality. | `'Koramangala Hub'` |
| `city` | `VARCHAR(50)` | `NOT NULL` | No | Metro city where the fulfillment center operates (`Bengaluru`, `Mumbai`, `Delhi`). | `'Bengaluru'` |
| `max_capacity_per_hr` | `INT` | `CHECK (max_capacity_per_hr > 0)` | No | Maximum order throughput capacity per hour designed for store picking and packing. | `220` |

---

## 3. Table: `rider_fleet`

* **Business Purpose:** Details the active delivery workforce assigned across regional fulfillment centers.

| Column Name | Data Type | Constraints | Nullable | Description / Business Logic | Example |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `rider_id` | `VARCHAR(20)` | `PRIMARY KEY` | No | Unique alphanumeric employee/contractor ID for each delivery partner. | `'R_001'` |
| `hub_id` | `VARCHAR(20)` | `FOREIGN KEY` | No | The specific dark store hub to which the delivery rider is base-assigned. | `'HUB_DEL_01'` |
| `vehicle_type` | `VARCHAR(30)` | `CHECK (vehicle_type IN ('Petrol_Bike', 'EV_Bike', 'Cycle'))` | No | Vehicle asset utilized for order fulfillment trips. | `'Petrol_Bike'` |
| `rider_rating` | `NUMERIC(2, 1)` | `CHECK (rider_rating BETWEEN 1.0 AND 5.0)` | No | Rolling customer satisfaction score (CSAT) ranging from 1.0 to 5.0. | `4.8` |

---

## 4. Table: `orders_log`

* **Business Purpose:** Granular, order-level transactional data capturing consumer spend, order timing, fulfillment partner, and delivery SLA compliance.

| Column Name | Data Type | Constraints | Nullable | Description / Business Logic | Example |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `order_id` | `VARCHAR(20)` | `PRIMARY KEY` | No | Unique transaction tracking ID generated upon order checkout. | `'ORD_00001'` |
| `hub_id` | `VARCHAR(20)` | `FOREIGN KEY` | No | The dark store from which the order inventory was picked and packed. | `'HUB_DEL_01'` |
| `rider_id` | `VARCHAR(20)` | `FOREIGN KEY` | No | The assigned delivery partner executing the last-mile trip. | `'R_005'` |
| `order_time` | `TIMESTAMP` | `NOT NULL` | No | Timestamp when the order was confirmed by the customer. | `'2026-08-15 19:42:10'` |
| `order_value_inr` | `NUMERIC(8, 2)` | `CHECK (order_value_inr > 0)` | No | Total order billing amount in Indian National Rupees (INR), inclusive of taxes and packaging fees. | `811.16` |
| `promised_delivery_min` | `INT` | `DEFAULT 12` | No | Quick-commerce guaranteed delivery SLA window promised to the customer (in minutes). | `12` |
| `actual_delivery_min` | `INT` | `CHECK (actual_delivery_min > 0)` | Yes | Exact time elapsed from order placement to doorstep handover (in minutes). | `14` |
| `order_status` | `VARCHAR(20)` | `CHECK (order_status IN ('Delivered', 'Cancelled'))` | No | Terminal fulfillment status of the order transaction. | `'Delivered'` |

---

## 5. Domain Business Rules & Metrics

1. **SLA Breach Definition:**
   * An order is classified as an **SLA Breach (Delayed)** when:  
     $$\text{actual\_delivery\_min} > \text{promised\_delivery\_min}$$
   * If $\text{actual\_delivery\_min} \le \text{promised\_delivery\_min}$, the order is classified as **On-Time**.

2. **Severe Delay Threshold:**
   * Orders requiring more than **18 minutes** represent extreme operational friction (traffic congestion, dispatch bottlenecks, or weather disruption) requiring incident review.

3. **Customer Spend Cohorts (Order Tiers):**
   * **Budget Tier:** $\le \text{₹}500$
   * **Mid-Tier:** $\text{₹}501 \text{ to ₹}1,000$
   * **High-Value Tier:** $> \text{₹}1,000$

4. **Revenue Calculation:**
   * Revenue is calculated strictly from completed orders ($\text{order\_status} = \text{'Delivered'}$). Cancelled orders represent gross platform revenue leakage.