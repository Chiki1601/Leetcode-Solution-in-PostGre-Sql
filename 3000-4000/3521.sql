-- Write your PostgreSQL query statement below
WITH filter_first AS (
	SELECT product_id, count(user_id) total_bought
	FROM ProductPurchases
	GROUP BY product_id
	HAVING count(user_id) > 2
), main_proccess AS (
	SELECT P.product_id AS product1_id, P1.product_id AS product2_id, COUNT( DISTINCT P.user_id ) customer_count 
	FROM ProductPurchases P INNER JOIN ProductPurchases P1 ON P.product_id < P1.product_id AND P.user_id = P1.user_id
	AND EXISTS (
		SELECT 1 FROM filter_first C WHERE P.product_id = C.product_id 
	)
	AND EXISTS (
		SELECT 1 FROM filter_first C WHERE P1.product_id = C.product_id
	)
	GROUP BY P.product_id, P1.product_id
	HAVING(COUNT(DISTINCT P.user_id)) > 2
)
SELECT product1_id, product2_id,
(SELECT category FROM ProductInfo P WHERE P.product_id = M.product1_id) AS product1_category,
(SELECT category FROM ProductInfo P WHERE P.product_id = M.product2_id) AS product2_category,
customer_count
FROM main_proccess M
ORDER BY customer_count DESC, product1_id, product2_id
