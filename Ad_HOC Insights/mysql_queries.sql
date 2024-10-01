1.Provide the list of markets in which customer "Atliq Exclusive" operates its business in the APAC region.*/

Select DISTINCT market 
From gdb023.dim_customer 
Where customer = 'Atliq Exclusive' And region = 'APAC'

2.	What is the percentage of unique product increase in 2021 vs. 2020? The final output contains these fields,
unique_products_2020 unique_products_2021 percentage_chg*/

With unique_product_count as
(	SELECT COUNT(DISTINCT CASE WHEN fiscal_year = 2020 THEN product_code END) AS unique_products_2020,
	COUNT(DISTINCT CASE WHEN fiscal_year = 2021 THEN product_code END) AS unique_products_2021
    FROM fact_sales_monthly)
SELECT unique_products_2020, unique_products_2021, CONCAT(ROUND(((unique_products_2021 - unique_products_2020)*1.0 / unique_products_2020)*100,2),"%") 
AS percentage_chg FROM unique_product_count


3.	Provide a report with all the unique product counts for each segment and sort them in descending order of product counts. The final output contains 2 fields,
segment product_count*/

SELECT count(DISTINCT(product_code)) AS product_count
FROM dim_product
GROUP BY segment
ORDER BY product_count DESC;

4.	Follow-up: Which segment had the most increase in unique products in 2021 vs 2020? The final output contains these fields,
segment product_count_2020 product_count_2021 difference*/

With unique_product as
(  SELECT 
		dp.segment AS SEGMENT,
		COUNT(DISTINCT CASE WHEN fiscal_year = 2020 THEN fsm.product_code END) AS product_count_2020,
		COUNT(DISTINCT CASE WHEN fiscal_year = 2021 THEN fsm.product_code END) AS product_count_2021
        FROM fact_sales_monthly AS fsm
        INNER JOIN dim_product AS dp
        ON fsm.product_code = dp.product_code
        GROUP BY dp.segment
)
SELECT product_count_2020, product_count_2021, 
(product_count_2021 - product_count_2020) AS difference
FROM unique_product
ORDER BY difference DESC;

/*5.	Get the products that have the highest and lowest manufacturing costs. The final output should contain these fields,
product_code product manufacturing_cost*/

SELECT dp.product_code AS product_code, dp.product AS product,
CONCAT('$ ', ROUND(fmc.manufacturing_cost,2)) as manufacturing_cost

FROM dim_product AS dp
INNER JOIN fact_manufacturing_cost AS fmc
ON dp.product_code = fmc.product_code
WHERE fmc.manufacturing_cost = (SELECT MAX(manufacturing_cost) FROM fact_manufacturing_cost)
OR fmc.manufacturing_cost = (SELECT MIN(manufacturing_cost) FROM fact_manufacturing_cost)
ORDER BY fmc.manufacturing_cost DESC;

 /* 6.Generate a report which contains the top 5 customers who received an average high pre_invoice_discount_pct for the fiscal year 2021 and in the Indian market. The final output contains these fields,
customer_code customer
average_discount_percentage*/

SELECT fpid.customer_code, dc.customer,
CONCAT(ROUND(AVG(pre_invoice_discount_pct)*100,2), "%") AS average_discount_percentage
FROM fact_pre_invoice_deductions as fpid
INNER JOIN dim_customer as dc
ON fpid.customer_code = dc.customer_code
WHERE market = 'INDIA' AND fiscal_year = '2021'
GROUP BY customer_code,customer
ORDER BY AVG(pre_invoice_discount_pct) DESC
LIMIT 5;

/* 
7.	Get the complete report of the Gross sales amount for the customer “Atliq Exclusive” for each month. This analysis helps to get an idea of low and high-performing months and take strategic decisions.
The final report contains these columns:
Month Year
Gross sales Amount*/

SELECT 
MONTHNAME(date) AS month,
YEAR(date) AS year,
CONCAT("$ ", ROUND(SUM(fsm.sold_quantity * fgp.gross_price)/1000000,2)) AS gross_sales_amount
FROM fact_sales_monthly as fsm
INNER JOIN fact_gross_price as fgp 
ON fsm.product_code = fgp.product_code
AND fsm.fiscal_year = fgp.fiscal_year
INNER JOIN dim_customer as dc
ON dc.customer_code = fsm.customer_code
WHERE CUSTOMER = "Atliq Exclusive" 
GROUP BY month,year
ORDER BY year;

/* 8. In which quarter of 2020, got the maximum total_sold_quantity? The final output contains these fields sorted by the total_sold_quantity,
Quarter total_sold_quantity*/


SELECT CASE 
	   WHEN MONTH(date) IN (9,10,11) THEN 'Q1'
       WHEN MONTH(date) IN (12,1,2) THEN 'Q2'
       WHEN MONTH(date) IN (3,4,5) THEN 'Q3'
       ELSE 'Q4'
       END AS quarters,
	   SUM(sold_quantity) AS total_sold_quantity
FROM fact_sales_monthly
WHERE fiscal_year = 2020
GROUP BY quarters
ORDER BY total_sold_quantity DESC;

/* Which channel helped to bring more gross sales in the fiscal year 2021 and the percentage of contribution? The final output contains these fields,
channel gross_sales_mln percentage */

WITH gross_sales AS (
		SELECT dc.channel AS channel,
        ROUND(SUM(fgp.gross_price * fsm.sold_quantity)/1000000,2) AS gross_sales_mln
FROM fact_sales_monthly AS fsm
LEFT JOIN fact_gross_price AS fgp
ON fsm.product_code = fgp.product_code
LEFT JOIN dim_customer AS dc
ON fsm.customer_code = dc.customer_code
WHERE fsm.fiscal_year = 2021
GROUP BY dc.channel
)
SELECT channel,
	   CONCAT('$ ', gross_sales_mln) AS gross_sales_mln,
       CONCAT(ROUND(gross_sales_mln / (SELECT SUM(gross_sales_mln) FROM gross_sales) * 100, 2), '%') AS percentage
FROM gross_sales
ORDER BY percentage DESC;

/* 10.Get the Top 3 products in each division that have a high total_sold_quantity in the fiscal_year 2021? The final output contains these fields,
division product_code product total_sold_quantity rank_order*/

WITH top_sold_products AS(
	SELECT dp.division AS division, dp.product_code AS product_code , dp.product AS product, 
    SUM(fsm.sold_quantity) AS total_sold_quantity
FROM fact_sales_monthly AS fsm
INNER JOIN dim_product AS dp
ON fsm.product_code = dp.product_code
WHERE fiscal_year = 2021
GROUP BY dp.division, dp.product_code, dp.product
ORDER BY total_sold_quantity DESC
),
top_sold_per_division AS(
SELECT division,product_code,product,total_sold_quantity,
	   DENSE_RANK() OVER (PARTITION BY division ORDER BY total_sold_quantity DESC) 
       AS rank_order
FROM top_sold_products)
SELECT * FROM top_sold_per_division
WHERE rank_order <= 3;



