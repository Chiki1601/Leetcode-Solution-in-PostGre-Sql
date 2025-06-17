-- Write your PostgreSQL query statement below
WITH process_1 AS (
SELECT DISTINCT p.employee_id, sub.review_date, sub.rating
FROM performance_reviews p 
JOIN LATERAL (
	SELECT p1.review_date, p1.rating FROM performance_reviews p1
	WHERE p.employee_id = p1.employee_id
	ORDER BY review_date DESC LIMIT 3
)sub ON 1 = 1)
,process_2 AS (
SELECT p.employee_id, p.rating, sub.rating rating_1, sub.review_date
FROM process_1 p
LEFT JOIN LATERAL (
	SELECT p1.rating, p1.review_date FROM process_1 p1
	WHERE p.employee_id = p1.employee_id AND p1.rating > p.rating
	LIMIT 1
)sub ON 1 = 1
WHERE p.rating < sub.rating
)
SELECT p.employee_id, 
(SELECT DISTINCT name FROM employees e WHERE e.employee_id = p.employee_id),
MAX(rating_1) - MIN(rating) improvement_score
FROM process_2 p
GROUP BY p.employee_id, name
HAVING COUNT(DISTINCT review_date) > 1
ORDER BY improvement_score DESC, name;
