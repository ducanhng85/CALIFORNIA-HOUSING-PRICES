SELECT * FROM balanced_tree.sales
ORDER BY txn_id;
SELECT * FROM balanced_tree.product_details;
-- What are the top 3 products by total revenue before discount?
SELECT TOP 3
    s.prod_id ,d.product_name
    , SUM(s.qty*s.price) as 'Total Revenue Before Discount'
FROM balanced_tree.sales s
JOIN balanced_tree.product_details d ON s.prod_id = d.product_id
GROUP BY s.prod_id, d.product_name
ORDER BY 2 DESC;


-- What is the total quantity, revenue and discount for each segment?
SELECT d.segment_id
    , d.segment_name
    , SUM(s.qty) as 'Total Quantity'
    , SUM(s.qty*s.price) as 'Total Revenue'
    , SUM((s.discount*s.qty*s.price)/100) as 'Total Discount'
FROM balanced_tree.sales s
JOIN balanced_tree.product_details d ON s.prod_id = d.product_id
GROUP BY d.segment_id, d.segment_name
ORDER BY 1;


-- What is the top selling product for each segment?
WITH T1 AS (
SELECT d.segment_id
    , d.segment_name
    , d.product_id
    , d.product_name
    , SUM(s.qty) as 'Total Quantity' 
    , RANK() OVER (PARTITION BY d.segment_id ORDER BY SUM(s.qty) DESC) AS Ranking
FROM balanced_tree.sales s
JOIN balanced_tree.product_details d ON s.prod_id = d.product_id
GROUP BY d.segment_id, d.segment_name,d.product_id, d.product_name)
SELECT segment_id
, segment_name
, product_id
, product_name
, [Total Quantity]
FROM T1
WHERE Ranking = 1;

-- What is the total quantity, revenue and discount for each category?
SELECT d.category_id
    , d.category_name
    , SUM(s.qty) as 'Total Quantity'
    , SUM(s.qty*s.price) as 'Total Revenue'
    , SUM((s.discount*s.qty*s.price)/100) as 'Total Discount'
FROM balanced_tree.sales s
JOIN balanced_tree.product_details d ON s.prod_id = d.product_id
GROUP BY d.category_id, d.category_name
ORDER BY 1;

-- What is the top selling product for each category?
WITH T1 AS (
SELECT d.category_id
    , d.category_name
    , d.product_id
    , d.product_name
    , SUM(s.qty) as 'Total Quantity' 
    , RANK() OVER (PARTITION BY d.category_id ORDER BY SUM(s.qty) DESC) AS Ranking
FROM balanced_tree.sales s
JOIN balanced_tree.product_details d ON s.prod_id = d.product_id
GROUP BY d.category_id, d.category_name,d.product_id, d.product_name)
SELECT category_id
, category_name
, product_id
, product_name
, [Total Quantity]
FROM T1
WHERE Ranking = 1;
-- What is the percentage split of revenue by product for each segment?
-- total rev for each seg
-- total rev for each product then total rev by pro/total rev each seg 
WITH T1 AS (
    SELECT segment_id, segment_name, product_id ,product_name, 
        SUM(s.qty*s.price) as 'Total Revenue Before Discount'
    FROM balanced_tree.sales s
    JOIN balanced_tree.product_details d ON s.prod_id = d.product_id
    GROUP BY d.segment_id, d.segment_name,product_id ,product_name)
SELECT *, 
    ROUND(100* [Total Revenue Before Discount] / (SUM([Total Revenue Before Discount]) OVER (PARTITION BY segment_id)), 2) AS revenue_percentage
FROM T1
ORDER BY 1,5 DESC;

-- What is the percentage split of revenue by segment for each category?
WITH T1 AS (
    SELECT category_id, category_name, segment_id, segment_name,
        SUM(s.qty*s.price) as 'Total Revenue Before Discount'
    FROM balanced_tree.sales s
    JOIN balanced_tree.product_details d ON s.prod_id = d.product_id
    GROUP BY category_id, category_name, segment_id, segment_name)
SELECT *, 
    ROUND(100* [Total Revenue Before Discount] / (SUM([Total Revenue Before Discount]) OVER (PARTITION BY category_id)), 2) AS revenue_percentage
FROM T1
ORDER BY 1,2;
-- What is the percentage split of total revenue by category?
WITH T1 AS (
    SELECT category_id, category_name,
            SUM(s.qty*s.price) as 'Total Revenue Before Discount'
    FROM balanced_tree.sales s
    JOIN balanced_tree.product_details d ON s.prod_id = d.product_id
    GROUP BY category_id, category_name)
SELECT *,
    ROUND(100* [Total Revenue Before Discount] / (SELECT SUM([Total Revenue Before Discount]) FROM T1), 2) AS revenue_percentage
FROM T1
ORDER BY 1;
-- What is the total transaction “penetration” for each product? 
-- (hint: penetration = number of transactions where at least 1 quantity of a product was purchased divided by total number of transactions)
WITH T1 AS (
    SELECT s.prod_id, d.product_name
    ,COUNT(DISTINCT(s.txn_id)) as 'number of transactions'
    FROM balanced_tree.sales s
    JOIN balanced_tree.product_details d ON d.product_id = s.prod_id
    GROUP BY prod_id,product_name)
-- SELECT COUNT(DISTINCT(txn_id)) as 'number of transactions' FROM balanced_tree.sales
SELECT *,
ROUND(100* [number of transactions]/(SELECT COUNT(DISTINCT(txn_id)) as 'number of transactions' FROM balanced_tree.sales),2) AS 'penetration percentage'
FROM T1
ORDER BY 4 DESC;

-- What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction?
SELECT s.prod_id, t1.prod_id, t2.prod_id 
FROM balanced_tree.sales s
JOIN balanced_tree.sales t1 ON t1.txn_id = s.txn_id 
AND s.prod_id < t1.prod_id
INNER JOIN balanced_tree.sales t2 ON t2.txn_id = s.txn_id
AND t1.prod_id < t2.prod_id
order by 1,2,3;

SELECT t1.prod_id, d1.product_name
FROM balanced_tree.sales t1
JOIN balanced_tree.product_details d1 ON d1.product_id = t1.prod_id

SELECT s.prod_id, t1.prod_id, t2.prod_id, COUNT(*) AS 'Count'	   
FROM balanced_tree.sales s
JOIN balanced_tree.sales t1 ON t1.txn_id = s.txn_id 
AND s.prod_id < t1.prod_id
JOIN balanced_tree.sales t2 ON t2.txn_id = s.txn_id
AND t1.prod_id < t2.prod_id
GROUP BY s.prod_id, t1.prod_id, t2.prod_id
ORDER BY 4 DESC;
-- JOIN balanced_tree.product_details d ON d.product_id = s.prod_id
SELECT TOP 5 product_name, t1.prod_id, t2.prod_id, COUNT(*) AS 'Count'	   
FROM balanced_tree.sales s
JOIN balanced_tree.sales t1 ON t1.txn_id = s.txn_id 
AND s.prod_id < t1.prod_id
JOIN balanced_tree.sales t2 ON t2.txn_id = s.txn_id
AND t1.prod_id < t2.prod_id
JOIN balanced_tree.product_details d ON d.product_id = s.prod_id
GROUP BY product_name, t1.prod_id, t2.prod_id
ORDER BY 4 DESC;