CREATE EXTERNAL TABLE employees
(
    emp_no     INT,
    birth_date DATE,
    first_name STRING,
    last_name  STRING,
    gender     STRING,
    hire_date  DATE,
    dept_no    STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n' 
STORED AS TEXTFILE
LOCATION '/input/employees';

CREATE EXTERNAL TABLE departments
(
    dept_no STRING,
    dept_name STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
STORED AS TEXTFILE
LOCATION '/input/departments';

SELECT * FROM employees LIMIT 10;
SELECT * FROM departments;

-- employees 테이블에서 성별이 'M'인 사원들 조회, 입사일자 기준으로 정렬
SELECT * FROM employees
WHERE gender = 'M'
ORDER BY hire_date;

-- 생일이 4월인 사원 조회
SELECT * FROM employees
WHERE birth_date LIKE '%-04-%';

SELECT * FROM employees
WHERE MONTH(birth_date) = 4;

-- employees 테이블에서 나이가 가장 많은 사원 조회
SELECT MIN(birth_date) FROM employees;

SELECT * FROM employees
WHERE birth_date = (SELECT MIN(birth_date) FROM employees);

-- employees 테이블에서 부서별 사원 수 조회
-- SELECT COUNT(DISTINCT dept_no) FROM employees; => 부서 개수
SELECT dept_no, COUNT(*) FROM employees
GROUP BY dept_no;

-- Development 부서의 사원 정보 조회 (join)
SELECT *
FROM employees JOIN departments
ON employees.dept_no = departments.dept_no
WHERE departments.dept_name = 'Development';

SELECT * FROM employees e JOIN departments d 
ON e.dept_no = d.dept_no
WHERE d.dept_name = 'Development';

-- 부서별 사원 수 조회 (join)
SELECT d.dept_name, COUNT(e.emp_no)
FROM employees e JOIN departments d 
ON e.dept_no = d.dept_no
GROUP BY d.dept_name;

-- Sales 부서의 남녀 카운트
SELECT e.gender, COUNT(*)
FROM employees e JOIN departments d 
ON e.dept_no = d.dept_no
WHERE d.dept_name = 'Sales'
GROUP BY e.gender;

SELECT
	SUM(CASE WHEN e.gender = 'M' THEN 1 ELSE 0 END) AS M,
	SUM(CASE WHEN e.gender = 'F' THEN 1 ELSE 0 END) AS F
FROM employees e JOIN departments d 
ON e.dept_no = d.dept_no
WHERE d.dept_name = 'Sales';