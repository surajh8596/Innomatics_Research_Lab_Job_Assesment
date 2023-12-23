USE ZYWA;

SELECT * FROM TRANSACTIONS;
SELECT COUNT(*) FROM TRANSACTIONS;

# Extract month_name and month from Transaction_timestamp
ALTER TABLE TRANSACTIONS ADD COLUMN MONTH_NAME VARCHAR(20);
UPDATE TRANSACTIONS
SET MONTH_NAME = MONTHNAME(STR_TO_DATE(TRANSACTION_TIMESTAMP, '%m/%d/%y %H:%i'));

ALTER TABLE TRANSACTIONS ADD COLUMN MONTH_NUMBER VARCHAR(20);
UPDATE TRANSACTIONS
SET MONTH_NUMBER = MONTH(STR_TO_DATE(TRANSACTION_TIMESTAMP, '%m/%d/%y %H:%i'));


# 1. Monthly Transactions
-- Need how much amount we have processed each month commutative and every month.
SELECT MONTH_NAME, ROUND(SUM(BILLING_AMOUNT), 2) TOTAL_AMOUNT FROM TRANSACTIONS
GROUP BY MONTH_NAME;


# 2. Most Popular Products/Services
-- Design a SQL query to identify the top 5 most popular products or services based on transaction counts.
	-- In this table we dont have any field which is define products/services
	-- To answer this question I used "MERCHANT_TYPE" column.
SELECT COUNT(DISTINCT MERCHANT_TYPE) AS TOTAL_MERCHANTS FROM TRANSACTIONS;

SELECT MERCHANT_TYPE AS PRODUCT_OR_SERVICE, COUNT(*) AS TOTAL_TRANSACTIONS FROM TRANSACTIONS
GROUP BY PRODUCT_OR_SERVICE
ORDER BY TOTAL_TRANSACTIONS 
LIMIT 5;

# 3. Daily Revenue Trend
-- Formulate a SQL query to visualize the daily revenue trend over time.
SELECT DATE(STR_TO_DATE(TRANSACTION_TIMESTAMP, '%m/%d/%y %H:%i')) AS TRANSACTION_DAY,
       ROUND(SUM(BILLING_AMOUNT),2) AS DAILY_REVENUE FROM TRANSACTIONS
GROUP BY TRANSACTION_DAY
ORDER BY TRANSACTION_DAY;

# 4. Average Transaction Amount by Product Category
-- Formulate a SQL query to find the average transaction amount for each product category
	-- In 'TRANSACTIONS' table there is no column related to product category.
	-- To answer this question I used 'MERCHANT_TYPE' column.
SELECT MERCHANT_TYPE, ROUND(AVG(TRANSACTION_AMOUNT), 2) AS AVERAGE_TRANSACTION_AMOUNT FROM TRANSACTIONS
GROUP BY MERCHANT_TYPE
order by AVERAGE_TRANSACTION_AMOUNT desc
limit 10;

# 5. Transaction Funnel Analysis
-- Create a SQL query to analyze the transaction funnel, including completed, pending, and cancelled transactions.
SELECT TRANSACTION_TYPE, COUNT(*) AS TOTAL_TRANSACTIONS FROM TRANSACTIONS
GROUP BY TRANSACTION_TYPE
ORDER BY TOTAL_TRANSACTIONS DESC;

### 6. Monthly Retention Rate
-- Design a SQL query to calculate the Monthly Retention Rate, grouping users into monthly cohorts.
SELECT MONTH_NAME, MONTH_NUMBER, COUNT(DISTINCT user_id) AS COHORT_SIZE,
    COUNT(DISTINCT CASE WHEN MONTH_NUMBER = MONTH_NUMBER THEN user_id END) AS RETAINED_USERS,
    COUNT(DISTINCT CASE WHEN MONTH_NUMBER = MONTH_NUMBER + 1 THEN user_id END) AS NEXT_MONTH_USERS,
    IFNULL(COUNT(CASE WHEN MONTH_NUMBER = (MONTH_NUMBER + 1) THEN user_id END) /
           COUNT(DISTINCT user_id) * 100, 2) AS RETENTION_RATE
FROM TRANSACTIONS
GROUP BY MONTH_NUMBER, MONTH_NAME
HAVING MONTH_NUMBER < (SELECT MAX(MONTH_NUMBER) FROM TRANSACTIONS);
