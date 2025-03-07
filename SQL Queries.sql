--Checking data loading
Select count(*) from inventory_data;
Select * from inventory_data;

Select count(*) from sales_data;
Select * from sales_data;

--SQL Queries for Sales & Orders Analysis
--1. Total sales, total units sold, profit, inventory value, distinct products/categories  
SELECT 
    SUM(sales) AS total_sales, 
    SUM(order_item_quantity) AS total_units_sold,
    SUM(order_profit_per_order) AS total_profit,
    SUM(order_item_product_price * order_item_quantity) AS inventory_value,
    COUNT(DISTINCT product_id) AS distinct_products,
    COUNT(DISTINCT category_name) AS distinct_categories
FROM sales_data;

--2. Order status distribution (number of orders by status) 
SELECT order_status, COUNT(order_id) AS order_count
FROM sales_data
GROUP BY order_status
ORDER BY order_count DESC;

--3. Delivery status distribution (on-time, late, canceled, etc.)  
SELECT delivery_status, COUNT(order_id) AS order_count
FROM sales_data
GROUP BY delivery_status
ORDER BY order_count DESC;

--4. Late Delivery Risk by time (week, month, year, quarter) 
SELECT 
    EXTRACT(YEAR FROM order_date) AS year,
    EXTRACT(QUARTER FROM order_date) AS quarter,
    EXTRACT(MONTH FROM order_date) AS month,
    EXTRACT(WEEK FROM order_date) AS week,
    COUNT(CASE WHEN days_for_shipping_real > days_for_shipment_scheduled THEN order_id END) AS late_orders
FROM sales_data
GROUP BY year, quarter, month, week
ORDER BY year, month;

--5. Order quantity by time (week, month, year, quarter)  
SELECT 
    EXTRACT(YEAR FROM order_date) AS year,
    EXTRACT(QUARTER FROM order_date) AS quarter,
    EXTRACT(MONTH FROM order_date) AS month,
    EXTRACT(WEEK FROM order_date) AS week,
    SUM(order_item_quantity) AS total_order_quantity
FROM sales_data
GROUP BY year, quarter, month, week
ORDER BY year, month;

--6. Sales value & units by time (week, month, year, quarter) 
SELECT 
    EXTRACT(YEAR FROM order_date) AS year,
    EXTRACT(QUARTER FROM order_date) AS quarter,
    EXTRACT(MONTH FROM order_date) AS month,
    EXTRACT(WEEK FROM order_date) AS week,
    SUM(sales) AS total_sales,
    SUM(order_item_quantity) AS total_units_sold
FROM sales_data
GROUP BY year, quarter, month, week
ORDER BY year, month;

--7. Profit value by time (week, month, year, quarter)
SELECT 
    EXTRACT(YEAR FROM order_date) AS year,
    EXTRACT(QUARTER FROM order_date) AS quarter,
    EXTRACT(MONTH FROM order_date) AS month,
    EXTRACT(WEEK FROM order_date) AS week,
    SUM(order_profit_per_order) AS total_profit
FROM sales_data
GROUP BY year, quarter, month, week
ORDER BY year, month;

--8. Order profit per order by time (week, month, year, quarter) 
SELECT 
    EXTRACT(YEAR FROM order_date) AS year,
    EXTRACT(QUARTER FROM order_date) AS quarter,
    EXTRACT(MONTH FROM order_date) AS month,
    EXTRACT(WEEK FROM order_date) AS week,
    AVG(order_profit_per_order) AS avg_profit_per_order
FROM sales_data
GROUP BY year, quarter, month, week
ORDER BY year, month;

--9. Order count by country/state over time
SELECT 
    order_country,
    order_state,
    EXTRACT(YEAR FROM order_date) AS year,
    EXTRACT(MONTH FROM order_date) AS month,
    COUNT(order_id) AS total_orders
FROM sales_data
GROUP BY order_country, order_state, year, month
ORDER BY order_country, order_state, year, month;

-- SQL Queries for Inventory Analysis
-- 10. Inventory units by each product (count of unique products in inventory)
SELECT 
    COUNT(DISTINCT "product id") AS total_inventory_units
FROM inventory_data;



-- 11. Inventory value (total inventory stock value)
SELECT 
    SUM("current stock" * "avg order qty") AS total_inventory_value
FROM inventory_data;


-- 12. Inventory distribution (stock levels per product)
SELECT 
    "product name", 
    "current stock", 
    "reorder point", 
    "safety stock"
FROM inventory_data
ORDER BY "current stock" DESC;


-- 13. Stock Action: Products to be ordered vs. Not required to be ordered
SELECT 
    "order-now", 
    COUNT("product id") AS total_products
FROM inventory_data
GROUP BY "order-now";

-- 14. Product order quantity trend over time (week, month, year, quarter)
SELECT 
    DATE_TRUNC('month', sales_data.order_date) AS month,
    inventory_data."product name",
    SUM(inventory_data."avg order qty") AS total_ordered_quantity
FROM inventory_data 
JOIN sales_data ON inventory_data."product id" = sales_data.product_id
GROUP BY month, inventory_data."product name"
ORDER BY month;


-- Top Analysis & Performance Metrics  
-- 15. Top 10 most ordered products, categories, and cities (by revenue & sales units)  
-- By revenue
SELECT 
    p."product name",
    s.category_name,
    s.order_city,
    SUM(s.sales) AS total_revenue,
    SUM(s.order_item_quantity) AS total_units_sold
FROM sales_data s
JOIN inventory_data p ON s.product_id = p."product id"
GROUP BY p."product name", s.category_name, s.order_city
ORDER BY total_revenue DESC
LIMIT 10;

-- By sales units
SELECT 
    p."product name",
	s.category_name,
    s.order_city,
    SUM(s.order_item_quantity) AS total_units_sold
FROM sales_data s
JOIN inventory_data p ON s.product_id = p."product id"
GROUP BY p."product name", s.category_name, s.order_city
ORDER BY total_units_sold DESC
LIMIT 10;

-- 16. Top payment methods by product category  
SELECT 
    s.category_name,
    s.type,
    COUNT(s.order_id) AS total_orders,
    SUM(s.sales) AS total_revenue
FROM sales_data s
JOIN inventory_data p ON s.product_id = p."product id"
GROUP BY s.category_name, s.type
ORDER BY total_revenue DESC;

-- 17. Most efficient shipping mode (least delays)  
SELECT 
    s.shipping_mode,
    AVG(s.days_for_shipping_real) AS avg_actual_shipping_days,
    AVG(s.days_for_shipment_scheduled) AS avg_scheduled_shipping_days,
    AVG(s.days_for_shipping_real - s.days_for_shipment_scheduled) AS avg_delay
FROM sales_data s
GROUP BY s.shipping_mode
ORDER BY avg_delay ASC;


-- 18. Orders, sales, quantity breakdown by order status  
SELECT 
    s.order_status,
    COUNT(s.order_id) AS total_orders,
    SUM(s.sales) AS total_revenue,
    SUM(s.order_item_quantity) AS total_units_sold
FROM sales_data s
GROUP BY s.order_status
ORDER BY total_orders DESC;


-- 19. Top 5 most profitable product categories  
SELECT 
    s.category_name,
    SUM(s.order_profit_per_order) AS total_profit
FROM sales_data s
JOIN inventory_data p ON s.product_id = p."product id"
GROUP BY s.category_name
ORDER BY total_profit DESC
LIMIT 5;


-- 20. Top 5 categories with the highest average discount 
SELECT 
    s.category_name,
    AVG(s.order_item_discount_rate) AS avg_discount
FROM sales_data s
JOIN inventory_data p ON s.product_id = p."product id"
GROUP BY s.category_name
ORDER BY avg_discount DESC
LIMIT 5;
