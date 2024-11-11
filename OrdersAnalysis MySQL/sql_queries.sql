
-- find top 10 highest revenue generating products --
SELECT product_id, SUM(sales_price * quantity) AS revenue
FROM df_orders
GROUP BY product_id
ORDER BY 2 DESC
LIMIT 10;

-- find top 5 highest selling products in each region

WITH 
product_sales AS(
SELECT region, product_id, sum(sales_price*quantity) sales
FROM df_orders
GROUP BY region, product_id
),
sales_rnk AS(
	SELECT *, 
    DENSE_RANK() OVER(PARTITION BY region ORDER BY sales DESC) AS rnk
    FROM product_sales)
SELECT * FROM sales_rnk
WHERE rnk <= 5;

-- find month over month growth comparision for 2022 and 2023 sales e.g jan 2022 vs jan 2023

WITH cte1 AS(
SELECT year(order_date) year,
month(order_date) month, sum(sales_price * quantity) sales
FROM df_orders
GROUP BY 1,2
),
cte2 AS(
SELECT month,
 CASE WHEN year =2022 THEN sales ELSE 0 END AS sales_2022,
 CASE WHEN year=2023 THEN sales else 0 END AS sales_2023
 FROM cte1)
 SELECT month, SUM(sales_2022) sales_2022, SUM(sales_2023) sales_2023
 FROM cte2
 GROUP BY 1
 ORDER BY 1;
 
 -- for each category which month had the highest sales
 
With cte1 AS(
SELECT 
category,
DATE_FORMAT(order_date, "%Y-%m") AS order_year_month,
SUM(sales_price * quantity) AS sales
FROM df_orders
GROUP BY 1,2),
cte2 AS(
SELECT *,
RANK() OVER  (PARTITION BY category ORDER BY sales DESC) AS rnk
FROM cte1
)
SELECT category, order_year_month, sales, rnk
FROM cte2
WHERE rnk = 1;

-- Which sub category has the highest growth by profit in 2023 compared to 2022

WITH 
cte1 AS(
SELECT sub_category, YEAR(order_date) year, SUM(profit*quantity) profit
FROM df_orders
GROUP By 1,2),
cte2 AS(
SELECT sub_category,
CASE WHEN year = 2022 THEN profit ELSE 0 END AS profit_2022,
CASE WHEN year = 2023 THEN profit ELSE 0 END AS profit_2023
FROM cte1)
SELECT sub_category, SUM(profit_2023)- SUM(profit_2022)  AS growth_by_profit
FROM cte2
GROUP BY 1
ORDER BY 2 DESC LIMIT 1;


