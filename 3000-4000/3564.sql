-- Write your PostgreSQL query statement below
WITH Declare_Mth AS(
	SELECT 'Winter' AS Season, S.* FROM sales S WHERE EXTRACT(MONTH FROM  S.sale_date) IN (12,1,2) 
	UNION ALL
	SELECT 'Spring' AS Season, S.* FROM sales S WHERE  EXTRACT(MONTH FROM  S.sale_date) IN ('3','4','5') 
	UNION ALL
	SELECT 'Summer' AS Season, S.* FROM sales S WHERE  EXTRACT(MONTH FROM  S.sale_date) IN ('6','7','8') 
	UNION ALL
	SELECT 'Fall' AS Season, S.* FROM sales S WHERE  EXTRACT(MONTH FROM  S.sale_date) IN ('9','10','11') 
),Delare_Lg AS (
SELECT
	 Season,category,SUM(quantity) total_quantity ,SUM(quantity*price) total_revenue ,RANK() OVER(PARTITION BY Season ORDER BY SUM(quantity) DESC ,SUM(quantity * price) DESC) rnk
FROM 
	Declare_Mth D
INNER JOIN
	products P ON D.product_id = P.product_id
GROUP BY  Season,category
)
SELECT
	Season,category,total_quantity,total_revenue
FROM 
	Delare_Lg
WHERE rnk = 1
ORDER BY Season ASC
