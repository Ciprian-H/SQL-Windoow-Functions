###############################################################
###############################################################
-- Guided Project: Introduction to SQL Window Functions
###############################################################
###############################################################

#############################
-- Task One: Getting Started
-- In this task, we will get started with the project
-- by retrieving all the data in the project-db database
#############################

-- 1.1: Retrieve all the data in the project-db database
SELECT * FROM employees;
SELECT * FROM departments;
SELECT * FROM regions;
SELECT * FROM customers;
SELECT * FROM sales;

#############################
-- Task Two: ROW_NUMBER() - Part One
-- In this task, we will learn the ROW_NUMBER() 
-- and OVER() to assign numbers to each row
#############################SELECT * FROM employees;
SELECT * FROM departments;
SELECT * FROM regions;
SELECT * FROM customers;
SELECT * FROM sales;

-- 2.1: Assign numbers to each row of the departments table
select *, 
row_number() over() as Row_N 
from departments 
order by Row_N ASC;

-- Exercise 2.1: Assign numbers to each row of 
-- the department for the Entertainment division

SELECT *,
row_number() OVER() AS Row_N
FROM departments
WHERE division = 'Entertainment'
ORDER BY Row_N ASC;

#############################
-- Task Three: ROW_NUMBER() - Part Two
-- In this task, we will continue to learn how to 
-- assign numbers to each row using ROW_NUMBER() and OVER()
#############################

-- 3.1: Retrieve all the data from the employees table
SELECT * FROM employees;

-- Order by inside OVER()
-- 3.2: Retrieve a list of employee_id, first_name, 
-- hire_date, and department of all employees in the sports
-- department ordered by the hire date
select employee_id, first_name, hire_date, department, 
row_number() over(order by hire_date asc) as Row_N 
from employees
where department = 'Sports' order by Row_N

-- 3.3: Order by multiple columns
select employee_id, first_name, hire_date, salary, department, 
row_number() over(order by hire_date asc, salary desc) as Row_N 
from employees
where department = 'Sports' order by Row_N

-- 3.4: Ordering in- and outside the OVER() clause
SELECT employee_id, first_name, hire_date, salary, department,
ROW_NUMBER() OVER(ORDER BY hire_date ASC, salary DESC) AS Row_N
FROM employees
WHERE department = 'Sports'
ORDER BY employee_id;


#############################
-- Task Four: PARTITION BY
-- In this task, we will learn how to use
-- the PARTITION BY clause inside OVER()
#############################

-- 4.1: Retrieve the employee_id, first_name, 
-- hire_date of employees for different departments
select employee_id, first_name, hire_date, department,
row_number() over(partition by department)
from employees
order by department ASC;

-- Exercise 4.1: Order by the hire_date
SELECT employee_id, first_name, department, hire_date,
row_number() over(PARTITION BY department order by hire_date) AS Row_N
FROM employees
ORDER BY department ASC;

#############################
-- Task Five: PARTITION BY with CTE
-- In this task, we will learn how to write a conditional
-- statement using a single CASE clause
#############################

-- 5.1: Retrieve all data from the sales and customers tables
SELECT * FROM sales;
SELECT * FROM customers;

-- 5.2: Create a common table expression to retrieve the
-- customer_id, customer_name, segment and how many 
-- times the customer has purchased from the mall 
WITH customer_purchase AS (
	SELECT s.customer_id, c.customer_name, c.segment,
	COUNT(*) AS purchase_count
	FROM sales s
	JOIN customers c
	ON s.customer_id = c.customer_id
	GROUP BY s.customer_id, c.customer_name, c.segment
	ORDER BY customer_id)

-- 5.3: Number each customer by how many purchases they've made
select customer_id, customer_name, segment, purchase_count,
row_number() over(order by purchase_count desc) as Row_N
from customer_purchase
order by Row_N, purchase_count DESC;

-- Same CTE as 5.2
WITH customer_purchase AS (
	SELECT s.customer_id, c.customer_name, c.segment,
	COUNT(*) AS purchase_count
	FROM sales s
	JOIN customers c
	ON s.customer_id = c.customer_id
	GROUP BY s.customer_id, c.customer_name, c.segment
	ORDER BY customer_id)

-- Exercise 5.1: Number each customer by their customer segment
-- and by how many purchases they've made in descending order
SELECT customer_id, customer_name, segment, purchase_count,
row_number() OVER (PARTITION BY segment order by purchase_count desc) AS Row_N
FROM customer_purchase
ORDER BY segment, purchase_count DESC;

#############################
-- Task Six: Fetching: LEAD() & LAG()
-- In this task, we will learn how to fetch data
-- using the LEAD() and LAG() clauses
#############################

-- 6.1: Retrieve all employees first name, department, salary
-- and the salary after that employee
select first_name, department, salary,
lead(salary) over() next_salary
from employees;

-- 6.2: Retrieve all employees first name, department, salary
-- and the salary before that employee
select first_name, department, salary,
lag(salary) over() previous_salary
from employees;

-- 6.3: Retrieve all employees first name, department, salary
-- and the salary after that employee in order of their salaries
select first_name, department, salary,
lead(salary) over(order by salary desc) next_salary
from employees;

select first_name, department, salary,
lead(salary) over(order by salary desc) next_salary,
salary-lead(salary) over(order by salary desc) salary_difference
from employees;

-- Exercise 6.1: Retrieve all employees first name, department, salary
-- and the salary before that employee in order of their salaries in
-- descending order. Call the new column cloest_higher_salary
SELECT first_name, department, salary,
lag(salary) over (ORDER BY salary desc) cloest_higher_salary
FROM employees;

SELECT first_name, department, salary,
lag(salary) over (ORDER BY salary desc) cloest_higher_salary,
salary-lag(salary) over (ORDER BY salary desc) salary_difference
FROM employees;

-- Exercise 6.2: Retrieve all employees first name, department, salary
-- and the salary after that employee for each department in descending order
-- of their salaries. Call the new column cloest_lowest_salary 
SELECT first_name, department, salary,
lead(salary) OVER (partition by department order by salary desc) cloest_lowest_salary,
FROM employees;

SELECT first_name, department, salary,
lead(salary) OVER (partition by department order by salary desc) cloest_lowest_salary,
salary-lead(salary) OVER (partition by department order by salary desc) salary_difference
FROM employees;

-- What do you think this query will return?
SELECT first_name, department, salary,
LEAD(salary, 1) OVER (ORDER BY salary DESC) closest_salary,
LEAD(salary, 2) OVER (ORDER BY salary DESC) next_cloest_salary
FROM employees
WHERE department = 'Clothing';

#############################
-- Task Seven: FIRST_VALUE() - Part One
-- In this task, we will learn how to use the
-- FIRST_VALUE() clause with the OVER() clause
#############################

-- 7.1: Retrieve the first_name, last_name, department, and 
-- hire_date of all employees. Add a new column called first_emp_date 
-- that returns the hire date of the first hired employee
select first_name, department, hire_date,
first_value(hire_date) over(order by hire_date) first_emp_date
from employees

-- 7.2: Find the difference between the hire date of the first employee
-- hired and every other employees
select *, age(hire_date, first_emp_date) hire_date_diff
from (select first_name, department, hire_date,
first_value(hire_date) over(order by hire_date) first_emp_date
from employees) a
order by hire_date

-- Exercise 7.1: Partition by department
SELECT first_name, last_name, department, hire_date,
first_value(hire_date) OVER (partition by department ORDER BY hire_date) AS first_emp_date
FROM employees;

-- Exercise 7.2: Find the difference between the hire date of the 
-- first employee hired and every other employees partitioned by department
SELECT *, age(hire_date, first_emp_date) hire_date_diff
FROM (
SELECT first_name, department, hire_date,
first_value(hire_date) OVER (partition by department ORDER BY hire_date) AS first_emp_date
FROM employees) a;

#############################
-- Task Eight: FIRST_VALUE() - Part Two
-- In this task, we will continue to learn how to 
-- use the FIRST_VALUE() clause with the OVER() clause
#############################

-- Exercise 8.1: Return the first salary for different departments
-- Order by the salary in descending order
SELECT first_name, email, department, salary,
first_value(salary) OVER(partition by department order by salary desc) first_salary
FROM employees;

-- OR
SELECT first_name, email, department, salary,
MAX(salary) OVER(PARTITION BY department ORDER BY salary DESC) first_salary
FROM employees;

select *, first_salary - salary salary_diff
from (SELECT first_name, email, department, salary,
	first_value(salary) OVER(partition by department order by salary desc) first_salary
	FROM employees) a
	
SELECT first_name, email, department, salary,
first_value(salary) OVER(partition by department order by salary desc) first_salary,
first_value(salary) OVER(partition by department order by salary desc) - salary salary_diff
FROM employees;

-- Exercise 8.2: Return the first salary for different departments
-- Order by the first_name in ascending order
SELECT first_name, email, department, salary,
first_value(salary) OVER(partition by department order by first_name asc)
FROM employees;

-- 8.1: Return the fifth salary for different departments
-- Order by the first_name in ascending order
SELECT first_name, email, department, salary,
nth_value(salary, 4) OVER(partition by department order by first_name asc)
FROM employees;















