--Q1. Show all students who has a registration date of 1/25/2007. Display salutation, first name inital, and full last name in all upper
--cases in one column labeled "Student List". (HINT: use functions such as UPPER and SUBSTR) Sample Result: Student List Mr. R SHI Ms. H LOPEZ
SET search_path = student_db;
select  salutation || ' '|| SUBSTRING( first_name, 1, 1 ) || ' ' || Upper(last_name) as Student_List
from student
where registration_date = '2007-01-25';

--Q2. Display the number of students who live on the 40th St in Brooklyn, NY. (HINT: use the COUNT function and join table STUDENT with ZIPCODE)
SELECT COUNT(*) AS num_students
FROM student s
JOIN zipcode z ON s.zip = z.zip
WHERE s.street_address ILIKE '%40th%'
  AND z.city ILIKE 'Brooklyn'
  AND z.state ILIKE 'NY';



--Q3. Show section information for all Programming related courses (description has "Programming"), excluding "Intro to Programming" 
--or any Java related programming courses. Dispaly Course_No, course description, Section_No, section location, and section capacity. 
--If a course has no section, then display "N/A" for section location and leave other section related columns blank. (HINT: left join COURSE 
--and SECTION; use the NVL function)

select c.course_no, c.description,  
COALESCE(CAST(s.Section_No AS TEXT), 'N/A') AS Section_No,
COALESCE(s.location, 'N/A'), 
COALESCE(CAST(s.capacity AS TEXT), 'N/A') AS Capacity
from course c left join section s 
on c.course_no = s.course_no
where c.description like '%Programming%'
and c.description != 'Intro To Programming'
and c.description not like '%Java%'


--Q4. Show the address information for all Flushing, NY students who live in an apartment (if address contains "#"). 
--Display student first name, last name, street information (number and street name), and apartment number. 
--(HINT: use string functions such as SUBSTR and INSTR) 
--Sample Result: FIRST_NAME LAST_NAME STREET_INFORMATION APARTMENT_NUMBER Mary Axch 144-70 41st Ave. #4T

select 
	s.first_name, s.last_name,
    TRIM(SUBSTRING(s.street_address FROM 1 FOR POSITION('#' IN s.street_address) - 1)) AS street_information,
    TRIM(SUBSTRING(s.street_address FROM POSITION('#' IN s.street_address))) AS apartment_number
from student s 
left join zipcode z 
	on s.zip = z.zip
where 
	z.city = 'Flushing'
	and z.state = 'Ny'
	and street_address like '%#%';


--Q5. For sections offered for Intro To Programming, calculate and display number of sections offered, 
--total capacity, lowest capacity, highest capacity, and average capacity. (HINT: use functions such as COUNT, SUM, MIN, MAX, and AVG)

select
	   count(s.section_id) count_section, 
	   sum(s.capacity) Total_capacity,
	   min(s.capacity) Lowest_capacity, 
	   max(s.capacity) Highest_capacity, 
	   avg(s.capacity) Average_capacity 
from course c left join section s
on c.course_no = s.course_no
where c.description ='Intro To Programming'


--Q6. List all course sections that have a start date on or after 6/1/1999 and have not been enrolled by any student.
--Display section ID,course No, start_date_time.
--(HINT: use left join and TO_DATE function)

select s.section_id, s.course_no, s.start_date_time
from section s left join enrollment e
on s.section_id = e.section_id
where 
s.start_date_time >= To_DATE('1999-06-01', 'YYYY-MM-DD')
AND e.enroll_date IS NULL;

--Q7. For all Programming related course sections taught by Anita Morris, calculate and list 
--total number of sections and total capacity. 
--(HINT: join INSTRUCTOR, SECTION, and COURSE)

SELECT count(section_id) total_number_section, sum(capacity) total_capacity
FROM instructor ins left join section sec
on ins.instructor_id = sec.instructor_id
left join course c
on c.course_no = sec.course_no
where 
ins.last_name = 'Morris'
and
ins.first_name = 'Anita'
and
c.description like '%Programming%'



--Q8. List all students who took a course from Anita Morris and who enrolled 90 days or more before section start date. 
--Display student first name, last name, enroll date, section start date, and instructor phone number. 
--(HINT: join STUDENT, ENROLLMENT, SECTION, and INSTRUCTOR; use section.start_date_time - enrollment.enroll_date to calculate number 
--of days in between)

select stu.first_name, stu.last_name, e.enroll_date, sec.start_date_time, ins.phone
from student stu left join enrollment e
on stu.student_id = e.student_id
left join section sec
on e.section_id = sec.section_id
left join instructor ins
on sec.instructor_id = ins.instructor_id
where 
ins.last_name = 'Morris'
and
ins.first_name = 'Anita'
and DATE_PART('day', sec.start_date_time - e.enroll_date) >= 90;

--Q9. For all sections taught by Anita Morris, calculate the average of the Final grade 
--(HINT: join INSTRUCTOR, SECTION, ENROLLMENT, and GRADE; use FI as grade_type_code)
SELECT sec. section_id, AVG(g.numeric_grade) AS avg_final_grade
FROM instructor ins
left join section sec on ins.instructor_id = sec.instructor_id
left join enrollment e on sec.section_id = e.section_id
left join grade g on e.student_id = g.student_id
WHERE ins.last_name = 'Morris'
AND ins.first_name = 'Anita'
AND g.grade_type_code = 'Fi'
group by sec. section_id;


--Q10. Find any student/instructor pairs so that the student has taken a course taught by the instructor and they live in the same zipcode. 
--Display student first and last name, instructor first and last name, and their zipcode

SELECT 
    s.first_name AS student_first_name,
    s.last_name AS student_last_name,
    i.first_name AS instructor_first_name,
    i.last_name AS instructor_last_name,
    z.zip AS shared_zipcode
FROM Student s
JOIN Enrollment e ON s.student_id = e.student_id
JOIN Section sec ON e.section_id = sec.section_id
JOIN Instructor i ON sec.instructor_id = i.instructor_id
JOIN Zipcode z ON s.zip = z.zip AND i.zip = z.zip;

