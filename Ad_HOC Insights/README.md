# Consumer-Goods-Ad-hoc-Insights

### Data
This dataset is from [CODEBASICS RESUME PROJECT CHALLENGE #7](https://codebasics.io/challenge/codebasics-resume-project-challenge/7) aimed at providing insights to executive management in the Consumer Goods domain. The project analyzes consumer behavior, product sales, and performance metrics using MySQL to generate actionable insights for strategic decision-making.

### Domain: Consumer Goods

### Function: Executive Management

### Problem Statement:

Atliq Hardwares (imaginary company) is one of the leading computer hardware producers in India and well expanded in other countries too. However, the management noticed that they do not get enough insights to make quick and smart data-informed decisions. They want to expand their data analytics team by adding several junior data analysts. Tony Sharma, their data analytics director wanted to hire someone who is good at both tech and soft skills. Hence, he decided to conduct a SQL challenge which will help him understand both the skills.

### Data Dictionary 
## Database Overview: `gdb023` (Atliq Hardware)

This project involves analyzing consumer data from the `gdb023` database, containing information related to product sales, manufacturing costs, and customer data. Below is an overview of the key tables and their descriptions.

| Table Name                    | Description                                                                                           | Key Columns                                                                                             |
|-------------------------------|-------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------|
| `dim_customer`                 | Contains customer-related data such as names, sales platforms, and regions.                          | `customer_code`: Unique customer ID <br> `customer`: Customer names <br> `platform`, `channel`, `region`, `sub_zone` |
| `dim_product`                  | Contains product-related data, categorizing products into divisions, segments, and variants.          | `product_code`: Unique product ID <br> `division`, `segment`, `category`, `product`, `variant`          |
| `fact_gross_price`             | Contains gross price information for each product.                                                    | `product_code`: Unique product ID <br> `fiscal_year`: Fiscal period <br> `gross_price`: Initial product price |
| `fact_manufacturing_cost`      | Contains the production cost data for each product, including direct costs.                          | `product_code`: Unique product ID <br> `cost_year`: Fiscal period <br> `manufacturing_cost`: Production cost |
| `fact_pre_invoice_deductions`  | Contains pre-invoice deduction data, including discount percentages for each product.                | `customer_code`: Unique customer ID <br> `fiscal_year`: Fiscal period <br> `pre_invoice_discount_pct`: Discount percentage |
| `fact_sales_monthly`           | Contains monthly sales data for each product, including sales quantities and dates.                  | `date`: Sale date <br> `product_code`: Unique product ID <br> `customer_code`: Unique customer ID <br> `sold_quantity`, `fiscal_year` |


## Queries for Ad_Hoc Insights

### Request 1: Which markets does customer "Atliq Exclusive" operate in within the APAC region?
```sql
SELECT DISTINCT market 
FROM dim_customer 
WHERE customer = 'Atliq Exclusive' AND region = 'APAC';
```
| Market        |
|---------------|
| India         |
| Indonesia     |
| Japan         |
| Philippines   |
| South Korea   |
| Australia     |
| New Zealand   |
| Bangladesh    |

### Request 2: What is the percentage of unique product increase in 2021 vs. 2020? 
```sql
WITH unique_product_count AS (
    SELECT 
        COUNT(DISTINCT CASE WHEN fiscal_year = 2020 THEN product_code END) AS unique_products_2020,
        COUNT(DISTINCT CASE WHEN fiscal_year = 2021 THEN product_code END) AS unique_products_2021
    FROM fact_sales_monthly
)
SELECT 
    unique_products_2020, 
    unique_products_2021, 
    CONCAT(ROUND(((unique_products_2021 - unique_products_2020) * 1.0 / unique_products_2020) * 100, 2), "%") AS percentage_chg
FROM unique_product_count;
```
| unique_products_2020 | unique_products_2021 | percentage_chg |
|----------------------|----------------------|-----------------|
| 245                  | 334                  | 36.33%          |

### Request 3: Provide a report with all the unique product counts for each segment and sort them in descending order of product counts. 
```sql
SELECT segment, count(DISTINCT(product_code)) AS product_count
FROM dim_product
GROUP BY segment
ORDER BY product_count DESC;
```
| Segment         | Product Count |
|-----------------|---------------|
| Notebook     | 129           |
| Accessories     | 116           |
| Peripherals    | 84            |
| Desktop     | 32            |
| Storage   | 27            |
| Networking     | 9             |


### Request 4: Follow-up: Which segment had the most increase in unique products in 2021 vs 2020? 
```sql
With unique_product AS(
SELECT 
		dp.segment AS SEGMENT,
		COUNT(DISTINCT CASE WHEN fiscal_year = 2020 THEN fsm.product_code END) AS product_count_2020,
		COUNT(DISTINCT CASE WHEN fiscal_year = 2021 THEN fsm.product_code END) AS product_count_2021
FROM fact_sales_monthly AS fsm
INNER JOIN dim_product AS dp
ON fsm.product_code = dp.product_code
GROUP BY dp.segment
)
SELECT segment,product_count_2020, product_count_2021, 
(product_count_2021 - product_count_2020) AS difference
FROM unique_product
ORDER BY difference DESC;
```
| Segment         | product_count_2020 | product_count_2021 | Difference |
|-----------------|---------------------|---------------------|------------|
| Accessories    | 6                   | 9                   | 3          |
| Notebook      | 7                   | 22                  | 15         |
| Peripherals      | 12                  | 17                  | 5          |
| Desktop     | 59                  | 75                  | 16         |
|Storage    | 69                  | 103                 | 34         |
| Networking    | 92                  | 108                 | 16         |


### Request 5: Get the products that have the highest and lowest manufacturing costs. 
```sql
SELECT 
    dp.product_code AS product_code, 
    dp.product AS product,
    CONCAT('$ ', ROUND(fmc.manufacturing_cost, 2)) AS manufacturing_cost
FROM dim_product AS dp
INNER JOIN fact_manufacturing_cost AS fmc
ON dp.product_code = fmc.product_code
WHERE fmc.manufacturing_cost = (SELECT MAX(manufacturing_cost) FROM fact_manufacturing_cost)
   OR fmc.manufacturing_cost = (SELECT MIN(manufacturing_cost) FROM fact_manufacturing_cost)
ORDER BY fmc.manufacturing_cost DESC;
```
| product_code     | product                         | manufacturing_cost |
|------------------|---------------------------------|--------------------|
| A6120110206      | AQ HOME Allin1 Gen 2           | $ 240.54           |
| A2118150101      | AQ Master wired x1 Ms          | $ 0.89             |

### Request 6: Generate a report which contains the top 5 customers who received an average high pre_invoice_discount_pct for the fiscal year 2021 and in the Indian market.
```sql
SELECT 
    fpid.customer_code, 
    dc.customer,
    CONCAT(ROUND(AVG(pre_invoice_discount_pct) * 100, 2), "%") AS average_discount_percentage
FROM fact_pre_invoice_deductions AS fpid
INNER JOIN dim_customer AS dc ON fpid.customer_code = dc.customer_code
WHERE market = 'INDIA' AND fiscal_year = '2021'
GROUP BY customer_code, customer
ORDER BY AVG(pre_invoice_discount_pct) DESC
LIMIT 5;
```
| customer_code | customer  | average_discount_percentage |
|---------------|-----------|-----------------------------|
| 90002009      | Flipkart  | 30.83%                      |
| 90002006      | Viveks    | 30.38%                      |
| 90002003      | Ezone     | 30.28%                      |
| 90002002      | Croma     | 30.25%                      |
| 90002016      | Amazon    | 29.33%                      |

### Request 7: Get the complete report of the Gross sales amount for the customer “Atliq Exclusive” for each month. This analysis helps to get an idea of low and high-performing months and take strategic decisions.
```sql
SELECT 
    MONTHNAME(date) AS month,
    YEAR(date) AS year,
    CONCAT("$ ", ROUND(SUM(fsm.sold_quantity * fgp.gross_price) / 1000000, 2)) AS gross_sales_amount
FROM fact_sales_monthly AS fsm
INNER JOIN fact_gross_price AS fgp 
ON fsm.product_code = fgp.product_code
INNER JOIN dim_customer AS dc 
ON dc.customer_code = fsm.customer_code
WHERE dc.customer = 'Atliq Exclusive'
GROUP BY month, year
ORDER BY year;
```
| Month      | Year | Gross Sales Amount |
|------------|------|--------------------|
| September  | 2019 | $ 4.50             |
| October    | 2019 | $ 5.14             |
| November   | 2019 | $ 7.52             |
| December   | 2019 | $ 4.83             |
| January    | 2020 | $ 4.74             |
| February   | 2020 | $ 4.00             |
| March      | 2020 | $ 0.38             |
| April      | 2020 | $ 0.40             |
| May        | 2020 | $ 0.78             |
| June       | 2020 | $ 1.70             |
| July       | 2020 | $ 2.55             |
| August     | 2020 | $ 2.79             |
| September  | 2020 | $ 12.35            |
| October    | 2020 | $ 13.22            |
| November   | 2020 | $ 20.46            |
| December   | 2020 | $ 12.94            |
| January    | 2021 | $ 12.40            |
| February   | 2021 | $ 10.13            |
| March      | 2021 | $ 12.14            |
| April      | 2021 | $ 7.31             |
| May        | 2021 | $ 12.15            |
| June       | 2021 | $ 9.82             |
| July       | 2021 | $ 12.09            |
| August     | 2021 | $ 7.18             |

### Request 8: In which quarter of 2020, got the maximum total_sold_quantity?
```sql
SELECT 
    CASE 
        WHEN MONTH(date) IN (9, 10, 11) THEN 'Q1'
        WHEN MONTH(date) IN (12, 1, 2) THEN 'Q2'
        WHEN MONTH(date) IN (3, 4, 5) THEN 'Q3'
        ELSE 'Q4'
    END AS quarters,
    SUM(sold_quantity) AS total_sold_quantity
FROM fact_sales_monthly
WHERE fiscal_year = 2020
GROUP BY quarters
ORDER BY total_sold_quantity DESC;
```
| Quarter | total_sold_quantity |
|---------|---------------------|
| Q1      | 7005619             |
| Q2      | 6649642             |
| Q4      | 5042541             |
| Q3      | 2075087             |

### Request 9: Which channel helped to bring more gross sales in the fiscal year 2021 and the percentage of contribution?
```sql
SELECT 
    sales_channel, 
    CONCAT(ROUND(SUM(fsm.sold_quantity * fgp.gross_price) / 1000000, 2), "$") AS gross_sales_contribution
FROM fact_sales_monthly AS fsm
INNER JOIN fact_gross_price AS fgp 
ON fsm.product_code = fgp.product_code
WHERE fiscal_year = 2021
GROUP BY sales_channel;
```
| Channel      | gross_sales_mln | percentage |
|--------------|------------------|------------|
| Retailer     | $ 1924.17        | 73.22%     |
| Direct       | $ 406.69         | 15.48%     |
| Distributor   | $ 297.18         | 11.31%     |

### Request 10: Get the Top 3 products in each division that have a high total_sold_quantity in the fiscal_year 2021?
```sql
WITH ranked_products AS (
    SELECT 
        division, 
        dp.product,
        fsm.sold_quantity,
        ROW_NUMBER() OVER (PARTITION BY division ORDER BY fsm.sold_quantity DESC) AS rank
    FROM fact_sales_monthly AS fsm
    INNER JOIN dim_product AS dp 
    ON fsm.product_code = dp.product_code
    WHERE fiscal_year = 2021
)
SELECT 
    division, 
    product, 
    sold_quantity
FROM ranked_products
WHERE rank <= 3;
```
| Division | product_code   | product                  | total_sold_quantity | rank_order |
|----------|----------------|--------------------------|---------------------|------------|
| N & S    | A6720160103    | Pen Drive 2 IN 1        | 701373              | 1          |
| N & S    | A6818160202    | Pen Drive DRC            | 688003              | 2          |
| N & S    | A6819160203    | Pen Drive DRC            | 676245              | 3          |
| P & A    | A2319150302    | Gamers Ms               | 428498              | 1          |
| P & A    | A2520150501    | Maxima Ms               | 419865              | 2          |
| P & A    | A2520150504    | Maxima Ms               | 419471              | 3          |
| PC       | A4218110202    | Digit                    | 17434               | 1          |
| PC       | A4319110306    | Velocity                 | 17280               | 2          |
| PC       | A4218110208    | Digit                    | 17275               | 3          |

