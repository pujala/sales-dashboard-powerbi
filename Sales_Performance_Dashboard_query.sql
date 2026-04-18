--1. Total Sales, Profit, Quantity
SELECT 
	SUM(sales) AS total_sales,
	SUM(profit) AS total_profit,
	SUM(quantity) AS total_quantity	
FROM superstore_sales;

--2. Sales by Region
SELECT region, SUM(sales) AS total_sales
FROM superstore_sales
GROUP BY region
ORDER BY total_sales DESC;

--3. Top 5 Customers 
WITH total_sales_customer AS (
	SELECT customer_name, SUM(sales) AS total_sales
	FROM superstore_sales
	GROUP BY customer_name
),
ranked_customer AS (
	SELECT customer_name, total_sales,
		DENSE_RANK() OVER (ORDER BY total_sales DESC) AS rnk
	FROM total_sales_customer
)
SELECT customer_name, total_sales
FROM ranked_customer
WHERE rnk <= 5;

--4. Monthly Sales Trend 
SELECT YEAR(order_date) AS year,
	MONTH(order_date) AS month,
	SUM(sales) AS total_sales
FROM superstore_sales
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY year, month;

--5. Profit Ratio 
SELECT
	SUM(profit) * 1.0 / SUM(sales) AS profit_ratio
FROM superstore_sales;

--alternative 
SELECT
	CAST(SUM(profit) AS float)/ SUM(sales) AS profit_ratio
FROM superstore_sales;

--6. Top Product per Category (WINDOW FUNCTION) = 1
SELECT *
FROM (
	SELECT category,
		sub_category,
		SUM(sales) AS total_sales,
		ROW_NUMBER() OVER (PARTITION BY category ORDER BY SUM(sales) DESC) AS rn
	FROM superstore_sales
	GROUP BY category, sub_category
) t
WHERE rn = 1;

-- Top N
SELECT *
FROM (
	SELECT category,
		sub_category,
		SUM(sales) AS total_sales,
		DENSE_RANK() OVER (PARTITION BY category ORDER BY SUM(sales) DESC) AS rn
	FROM superstore_sales
	GROUP BY category, sub_category
) t
WHERE rn <= 3;

--7. Running Total (TREND ANALYSIS)
SELECT 
    order_date,
    daily_sales,
    SUM(daily_sales) OVER (ORDER BY order_date) AS running_sales
FROM (
    SELECT 
        order_date,
        SUM(sales) AS daily_sales
    FROM superstore_sales
    GROUP BY order_date
) t
ORDER BY order_date;

--8. Identify Loss-Making Products
SELECT sub_category,
	SUM(profit) AS total_profit
FROM superstore_sales
GROUP BY sub_category
HAVING SUM(profit) < 0;
