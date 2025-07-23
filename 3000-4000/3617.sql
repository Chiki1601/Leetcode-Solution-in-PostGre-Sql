-- Write your PostgreSQL query statement below
WITH process_1 AS (
	SELECT student_id, COUNT(DISTINCT subject) total_subject, SUM(hours_studied) total_study_hours FROM study_sessions GROUP BY student_id
), process_2 AS (
	SELECT student_id, session_date, 
	LEAD(session_date) OVER(PARTITION BY student_id ORDER BY session_date) - session_date diff_date
	FROM study_sessions
)
SELECT p.student_id, s.student_name, s.major, COUNT(DISTINCT p.subject) cycle_length, MAX(pro.total_study_hours) total_study_hours
FROM study_sessions p 
INNER JOIN process_1 pro ON p.student_id = pro.student_id
INNER JOIN students s ON p.student_id = s.student_id
INNER JOIN study_sessions p1 ON p.student_id = p1.student_id AND p.subject = p1.subject AND p.session_date < p1.session_date 
	AND p1.session_date - p.session_date BETWEEN pro.total_subject AND pro.total_subject * 2
WHERE EXISTS (SELECT 1 FROM process_2 pp WHERE p.student_id = pp.student_id AND p.session_date = pp.session_date AND diff_date < 3)
GROUP BY p.student_id, s.student_name, s.major
HAVING COUNT(DISTINCT p.subject) > 2
ORDER BY cycle_length DESC, total_study_hours DESC
