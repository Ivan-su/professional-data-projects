set search_path = student_db;
--Q1. List all courses that have "Intro to Information Systems" as prerequisite. (HINT: use a subquery)

SELECT *
FROM course
WHERE prerequisite = (
    SELECT course_no
    FROM course
    WHERE description = 'Intro To Information Systems'
);


--Q2. List all courses with above average cost. Display course description, cost, and the average cost of all courses. 
--(HINT: use a subquery)
SELECT 
    description,
    cost,
    (SELECT AVG(cost) FROM course) AS average_cost
FROM course
WHERE cost > (
    SELECT AVG(cost)
    FROM course
);

--Q3. For each zip that has at least one instructor, list the total number of instructors in that zipcode.

SELECT zip, COUNT(*) AS instructor_count
FROM instructor 
WHERE 
    zip IN (
        SELECT DISTINCT zip
        FROM instructor
        WHERE zip IS NOT NULL
    )
GROUP BY 
    zip;


--Q4. For each city in the state of CT, list the total number of students live in that city. Display city, 
--state, number of students in descending order.
SELECT z.city, z.state, COUNT(s.student_id) AS student_count
FROM student s
JOIN zipcode z ON s.zip = z.zip
WHERE z.state = 'Ct'
GROUP BY z.city, z.state
ORDER BY student_count DESC;


-- AGGREGATION OF FULL RESULT SET
--Q5. Find the minimum, maximum, and average grade of final exams in sections taught by Todd Smythe.
SELECT MIN(numeric_grade) AS min_grade,MAX(numeric_grade) AS max_grade,
    AVG(numeric_grade) AS avg_grade
FROM grade
WHERE grade_type_code = 'Fi'
  AND section_id IN (
      SELECT section_id
      FROM section WHERE instructor_id = (
          SELECT instructor_id
          FROM instructor WHERE first_name = 'Todd' AND last_name = 'Smythe'
      )
  );
  
--Q6: For all students who took "Intro to Information Systems", calculate the highest, lowest,
--and average midterm exam grade for each section. Display Section No and calculation results.
SELECT s.section_no, MAX(g.numeric_grade) AS max_midterm,
 MIN(g.numeric_grade) AS min_midterm, AVG(g.numeric_grade) AS avg_midterm
FROM grade g
JOIN section s ON g.section_id = s.section_id
WHERE s.course_no = (
        SELECT course_no
        FROM course WHERE description = 'Intro To Information Systems'
    ) AND g.grade_type_code = 'Mt'
GROUP BY 
    s.section_no;

-- TABLE JOIN WITH HAVING-CLAUSE
--Q7. List the instructor id and name of the instructors that teach fewer than 10 sections regardless of student enrollment.
SELECT i.instructor_id,i.first_name,
    i.last_name, COUNT(s.section_id) AS section_count
FROM instructor i
JOIN section s ON i.instructor_id = s.instructor_id
GROUP BY 
    i.instructor_id, i.first_name, i.last_name
HAVING 
    COUNT(s.section_id) < 10;



--Q8. Show which city has the most students. Display city and state, and number of students.

SELECT z.city, z.state,
    COUNT(s.student_id) AS student_count
FROM student s
JOIN zipcode z ON s.zip = z.zip
GROUP BY z.city, z.state
HAVING 
    COUNT(s.student_id) >= ALL (
        SELECT COUNT(s2.student_id)
        FROM student s2
        JOIN zipcode z2 ON s2.zip = z2.zip
        GROUP BY z2.city, z2.state);



--Q9: List all zipcodes where at least three students AND at least four instructor reside. Show zip, state and city.

SELECT z.zip, z.state, z.city
FROM zipcode z
JOIN student s ON z.zip = s.zip
JOIN instructor i ON z.zip = i.zip
GROUP BY z.zip, z.state, z.city
HAVING 
    COUNT(DISTINCT s.student_id) >= 3
    AND COUNT(DISTINCT i.instructor_id) >= 4;



--Q10: List all cities that have 10 or more students and instructor combined. Show city, state, number of student residents, 
--number of instructor residents, and total student/instructor residents in that city. Sort by total in descending order.
SELECT 
    z.city,
    z.state,
    COUNT(DISTINCT s.student_id) AS student_count,
    COUNT(DISTINCT i.instructor_id) AS instructor_count,
    COUNT(DISTINCT s.student_id) + COUNT(DISTINCT i.instructor_id) AS total_residents
FROM zipcode z
LEFT JOIN student s ON z.zip = s.zip
LEFT JOIN instructor i ON z.zip = i.zip
GROUP BY z.city, z.state
HAVING COUNT(DISTINCT s.student_id) + COUNT(DISTINCT i.instructor_id) >= 10
ORDER BY total_residents DESC;




















