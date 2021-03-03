-- Extract a list containing information about all managers’ employee number, first and last name, department number, and hire date. 

SELECT 
    e.emp_no, e.first_name, e.last_name, dm.dept_no, e.hire_date
FROM
    employees AS e
        LEFT JOIN
    dept_manager AS dm ON e.emp_no = dm.emp_no
WHERE e.first_name = 'Margareta'
ORDER BY dm.dept_no DESC, e.emp_no;
    
-------------------------------------------------------------------------------------------------------------------------------------

-- EUse a CROSS JOIN to return a list with all possible combinations between managers from the dept_manager table and department number 9.

SELECT 
    dm.*, d.*
FROM
    departments AS d
        CROSS JOIN
    dept_manager AS dm 
WHERE d.dept_no = 'd009'
ORDER BY dm.dept_no;

-- Return a list with the first 10 employees with all the departments they can be assigned to.

SELECT 
    e.*, d.*
FROM
    employees e
        CROSS JOIN
    departments d
WHERE
    e.emp_no < '10011'
ORDER BY e.emp_no , d.dept_name;

-- Select all managers’ first and last name, hire date, job title, start date, and department name.

SELECT
	e.emp_no, e.first_name, e.last_name, e.hire_date, t.title, m.from_date, d.dept_name
FROM
	employees e
        JOIN
    dept_manager m ON e.emp_no = m.emp_no
        JOIN
    departments d ON m.dept_no = d.dept_no
        JOIN
    titles t ON e.emp_no = t.emp_no
WHERE t.title = 'Manager'
ORDER BY e.emp_no;
    
-- How many male and how many female managers do we have in the ‘employees’ database?

SELECT
    e.gender, COUNT(dm.emp_no)
FROM
    employees e
        JOIN
    dept_manager dm ON e.emp_no = dm.emp_no
GROUP BY gender;

-- Go forward to the solution and execute the query.
-- What do you think is the meaning of the minus sign before subset A in the last row (ORDER BY -a.emp_no DESC)? 

SELECT
    *
FROM
    (SELECT e.emp_no, e.first_name, e.last_name,
            NULL AS dept_no,
            NULL AS from_date
    FROM
        employees e
    WHERE
        last_name = 'Denis' UNION SELECT
        NULL AS emp_no,
            NULL AS first_name,
            NULL AS last_name,
            dm.dept_no,
            dm.from_date
    FROM
        dept_manager dm) as a
ORDER BY -a.emp_no DESC;

-- Extract the information about all department managers who were hired between the 1st of January 1990 and the 1st of January 1995.

SELECT *
FROM
    dept_manager
WHERE
    emp_no IN (SELECT
            emp_no
        FROM
            employees
        WHERE
            hire_date BETWEEN '1990-01-01' AND '1995-01-01');
            
-- Select the entire information for all employees whose job title is “Assistant Engineer”. 
-- Hint: To solve this exercise, use the 'employees' table.

SELECT 
    *
FROM
    employees e
WHERE
    EXISTS( SELECT 
            *
        FROM
            titles t
        WHERE
            t.emp_no = e.emp_no
                AND title = 'Assistant Engineer')
ORDER BY emp_no;

-- Create a view that will extract the average salary of all managers registered in the database. Round this value to the nearest cent.
-- If you have worked correctly, after executing the view from the “Schemas” section in Workbench, you should obtain the value of 66924.27.

CREATE OR REPLACE VIEW v_manager_avg_salary AS
    SELECT
        ROUND(AVG(salary), 2)
    FROM
        salaries s
            JOIN
        dept_manager m ON s.emp_no = m.emp_no;
        
-- Create a procedure that will provide the average salary of all employees.
-- Then, call the procedure.

DELIMITER $$
CREATE PROCEDURE avg_salary()
BEGIN
	SELECT round(avg(salary),2)
    FROM salaries;
END$$
DELIMITER ; 

CALL employees.avg_salary();

-- Create a procedure called ‘emp_info’ that uses as parameters the first and the last name of an individual, and returns their employee number.
DROP PROCEDURE emp_info;
DELIMITER $$
CREATE PROCEDURE emp_info(IN p_first_name VARCHAR(255), IN p_last_name VARCHAR(255), OUT p_emp_no INTEGER)
BEGIN
	SELECT e.emp_no
    INTO p_emp_no FROM employees e
    WHERE e.first_name = p_first_name AND e.last_name = p_last_name;
END$$
DELIMITER ;

set @p_emp_no = 0;
call employees.emp_info('Aruna', 'Journel', @p_emp_no);
select @p_emp_no;

-- Create a function called ‘emp_info’ that takes for parameters the first and last name of an employee, and returns the salary from the newest contract of that employee.
-- Hint: In the BEGIN-END block of this program, you need to declare and use two variables – v_max_from_date that will be of the DATE type, and v_salary, that will be of the DECIMAL (10,2) type.
-- Finally, select this function.

DELIMITER $$
CREATE FUNCTION emp_info(p_first_name varchar(255), p_last_name varchar(255)) RETURNS decimal(10,2)
DETERMINISTIC NO SQL READS SQL DATA
BEGIN
	DECLARE v_max_from_date date;
    DECLARE v_salary decimal(10,2);
SELECT
    MAX(from_date)
INTO v_max_from_date FROM
    employees e
        JOIN
    salaries s ON e.emp_no = s.emp_no
WHERE
    e.first_name = p_first_name
        AND e.last_name = p_last_name;
SELECT
    s.salary
INTO v_salary FROM
    employees e
        JOIN
    salaries s ON e.emp_no = s.emp_no
WHERE
    e.first_name = p_first_name
        AND e.last_name = p_last_name
        AND s.from_date = v_max_from_date;
                RETURN v_salary;
END$$
DELIMITER ;

SELECT EMP_INFO('Aruna', 'Journel');

-- Select all records from the ‘salaries’ table of people whose salary is higher than $89,000 per annum.
-- Then, create an index on the ‘salary’ column of that table, and check if it has sped up the search of the same SELECT statement.
ALTER TABLE salaries
DROP INDEX i_salary;

SELECT
    *
FROM
    salaries
WHERE
    salary > 89000;

CREATE INDEX i_salary ON salaries(salary);

SELECT
    *
FROM
    salaries
WHERE
    salary > 89000;
    
-- Similar to the exercises done in the lecture, obtain a result set containing the employee number, first name, and last name of 
-- all employees with a number higher than 109990. Create a fourth column in the query, indicating whether this employee is also a 
-- manager, according to the data provided in the dept_manager table, or a regular employee. 

SELECT
    e.emp_no, e.first_name, e.last_name,
    CASE
        WHEN dm.emp_no IS NOT NULL THEN 'Manager'
        ELSE 'Employee'
    END AS is_manager
FROM
	employees e
	LEFT JOIN
    dept_manager dm ON dm.emp_no = e.emp_no
WHERE
    e.emp_no > 109990;