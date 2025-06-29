-- Create Database 
CREATE DATABASE Pizza_Place_Sales;

-- Use the database
use Pizza_Place_Sales;

-- Table 1: orders
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    date DATE,
    time TIME
);

-- Table 2: order_details
CREATE TABLE order_details (
    order_details_id INT PRIMARY KEY,
    order_id INT,
    pizza_id VARCHAR(255),
    quantity INT,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (pizza_id) REFERENCES pizzas(pizza_id)
);

-- Table 3: pizzas
CREATE TABLE pizzas (
    pizza_id VARCHAR(255) PRIMARY KEY,
    pizza_type_id VARCHAR(255),
    size VARCHAR(255),
    price DECIMAL(5,2),
    FOREIGN KEY (pizza_type_id) REFERENCES pizza_types(pizza_type_id)
);

-- Table 4: pizza_types
CREATE TABLE pizza_types (
    pizza_type_id VARCHAR(255) PRIMARY KEY,
    name VARCHAR(255),
    category VARCHAR(255),
    ingredients TEXT
);


-- Load the data from the csv file to the orders tables
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/orders.csv'
INTO TABLE orders
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"' 
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-- Load the data from the csv file to the pizza_types tables
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/pizza_types.csv'
INTO TABLE pizza_types
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-- Load the data from the csv file to the pizzas tables
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/pizzas.csv'
INTO TABLE pizzas
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-- Load the data from the csv file to the order_details tables
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/order_details.csv'
INTO TABLE order_details
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;


-- Insights from the data

-- 1. Total number of orders
SELECT COUNT(*) AS total_orders FROM orders;

-- 2. Total revenue of the organization
SELECT SUM(od.quantity * p.price) AS total_revenue
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id;

-- 3. Top 5 best selling pizzas i the organization
SELECT pt.name, SUM(od.quantity) AS total_quantity
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY total_quantity DESC
LIMIT 5;

-- 4. Monthly order Trend 
SELECT DATE_FORMAT(date, '%Y-%m') AS month, COUNT(*) AS total_orders
FROM orders
GROUP BY month
ORDER BY month;

-- 5. Peak order hours
SELECT HOUR(time) AS hour, COUNT(*) AS total_orders
FROM orders
GROUP BY hour
ORDER BY total_orders DESC;

-- 6. Daily sales trend
SELECT date, COUNT(*) AS orders_per_day
FROM orders
GROUP BY date
ORDER BY date;

-- 7. Order by category
SELECT pt.category, COUNT(*) AS total_orders
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category;

-- 8. Revenue by categories of Pizzas
SELECT pt.category, ROUND(SUM(od.quantity * p.price), 2) AS revenue
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category
ORDER BY revenue DESC;

-- 9. Most profitable Pizza
SELECT pt.name, SUM(od.quantity * p.price) AS total_revenue
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY total_revenue DESC
LIMIT 1;

-- 10. Average items per order
SELECT ROUND(AVG(item_count), 2) AS avg_items_per_order
FROM (
  SELECT order_id, SUM(quantity) AS item_count
  FROM order_details
  GROUP BY order_id
) AS order_summary;

-- 11. Creating a view for Power bi about monthly revenue
CREATE VIEW monthly_revenue AS
SELECT DATE_FORMAT(o.date, '%Y-%m') AS month,
       ROUND(SUM(od.quantity * p.price), 2) AS revenue
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
JOIN pizzas p ON od.pizza_id = p.pizza_id
GROUP BY month;
select * from monthly_revenue;

-- 12. using CTE's for finding the total sales of different types of pizza
WITH pizza_sales AS (
  SELECT pizza_id, SUM(quantity) AS total_sold
  FROM order_details
  GROUP BY pizza_id
)
SELECT ps.pizza_id, pt.name, ps.total_sold
FROM pizza_sales ps
JOIN pizzas p ON ps.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
ORDER BY ps.total_sold DESC;

-- 13. Window Function for ranking pizzas by their revenue
SELECT pt.name, 
       SUM(od.quantity * p.price) AS revenue,
       RANK() OVER (ORDER BY SUM(od.quantity * p.price) DESC) AS rank_by_revenue
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name;









-- Fix for localhost
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'root';

-- Fix for 127.0.0.1
ALTER USER 'root'@'127.0.0.1' IDENTIFIED WITH mysql_native_password BY 'root';

-- Global root fix
ALTER USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY 'root';

-- Apply changes
FLUSH PRIVILEGES;



SELECT user, host FROM mysql.user;


CREATE USER 'root'@'127.0.0.1' IDENTIFIED WITH mysql_native_password BY 'root';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'127.0.0.1' WITH GRANT OPTION;

CREATE USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY 'root';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;

FLUSH PRIVILEGES;

