--TASK1
SELECT DISTINCT name_program 
FROM program INNER JOIN program_subject USING(program_id) 
INNER JOIN (
	SELECT program_id, MIN(min_result) AS "min_total" 
	FROM program_subject 
	GROUP BY program_id 
	HAVING min_total>=40
	) AS query USING (program_id) 
ORDER BY name_program;

--TASK2
SELECT name_enrollee, IF(SUM(bonus) IS NOT NULL, SUM(bonus), 0) AS "Бонус"
FROM enrollee LEFT JOIN enrollee_achievement AS ea USING (enrollee_id) 
LEFT JOIN achievement USING(achievement_id) 
GROUP BY name_enrollee 
ORDER BY name_enrollee;

--TASK3
SELECT 
    name_department,
    name_program,
    plan,
    IF(COUNT(enrollee_id) IS NOT NULL, COUNT(enrollee_id), 0) AS "Количество",
    IF(COUNT(enrollee_id) IS NOT NULL, ROUND(COUNT(enrollee_id)/plan, 2), 0) AS "Конкурс"
FROM department INNER JOIN program USING(department_id) LEFT JOIN program_enrollee USING (program_id)
GROUP BY name_department, name_program, plan ORDER BY Конкурс DESC;

--TASK4
SELECT name_program FROM (
	SELECT DISTINCT name_program, COUNT(subject_id) AS "num" 
	FROM program INNER JOIN program_subject USING(program_id) 
	INNER JOIN subject USING(subject_id)
	WHERE name_subject IN ('Информатика','Математика'
	) GROUP BY name_program)
AS q WHERE num=2 ORDER BY name_program;

--TASK5
SELECT name_program, name_enrollee, SUM(es.result) AS itog
FROM enrollee AS e 
INNER JOIN program_enrollee AS pe USING(enrollee_id)
INNER JOIN program AS p USING(program_id)
INNER JOIN program_subject AS ps ON pe.program_id = ps.program_id
INNER JOIN subject AS s USING(subject_id)
INNER JOIN enrollee_subject AS es ON s.subject_id = es.subject_id AND e.enrollee_id = es.enrollee_id
GROUP BY name_program, name_enrollee ORDER BY name_program, itog DESC;

--TASK6
SELECT name_program, name_enrollee 
FROM enrollee 
INNER JOIN program_enrollee USING(enrollee_id)
INNER JOIN program USING(program_id)
INNER JOIN program_subject AS ps USING(program_id)
INNER JOIN subject USING(subject_id)
INNER JOIN enrollee_subject AS es USING(subject_id, enrollee_id)

WHERE es.result<ps.min_result GROUP BY name_program, name_enrollee
ORDER BY name_program, name_enrollee;

--TASK7
CREATE TABLE applicant AS SELECT p.program_id AS "program_id", e.enrollee_id AS "enrollee_id", SUM(es.result) AS itog
FROM enrollee AS e 
INNER JOIN program_enrollee AS pe USING(enrollee_id)
INNER JOIN program AS p USING(program_id)
INNER JOIN program_subject AS ps ON pe.program_id = ps.program_id
INNER JOIN subject AS s USING(subject_id)
INNER JOIN enrollee_subject AS es ON s.subject_id = es.subject_id AND e.enrollee_id = es.enrollee_id
GROUP BY program_id, enrollee_id
ORDER BY program_id, itog DESC;

--TASK8
DELETE FROM applicant WHERE(enrollee_id, program_id) IN (SELECT enrollee_id,program_id 
FROM enrollee 
INNER JOIN program_enrollee USING(enrollee_id)
INNER JOIN program USING(program_id)
INNER JOIN program_subject AS ps USING(program_id)
INNER JOIN subject USING(subject_id)
INNER JOIN enrollee_subject AS es USING(subject_id, enrollee_id)

WHERE es.result<ps.min_result GROUP BY name_program, name_enrollee
ORDER BY name_program, name_enrollee);

--TASK9
UPDATE applicant INNER JOIN (
    SELECT enrollee_id, name_enrollee, IF(SUM(bonus) IS NOT NULL, SUM(bonus), 0) AS "Бонус" FROM enrollee LEFT JOIN
    enrollee_achievement AS ea USING (enrollee_id) LEFT JOIN achievement USING(achievement_id) GROUP BY
    name_enrollee, enrollee_id ORDER BY name_enrollee) AS query USING (enrollee_id)
SET itog = itog+Бонус;

--TASK10
SET @prev :=0;
SET @step :=1;

UPDATE applicant_order SET str_id = 
	IF (program_id = @prev, (@step := @step + 1), @step :=1 AND @prev :=program_id);
SELECT* FROM applicant_order;