CREATE EXTERNAL TABLE books
(
	isbn		STRING,
	book_title	STRING,
	book_author	STRING,
	year_of_publication	STRING,
	publisher	STRING,
	image_url_s	STRING,
	image_url_m	STRING,
	image_url_l	STRING
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
    "separatorChar" = ";",
    "quoteChar"     = "\""
)
STORED AS TEXTFILE
LOCATION '/input/book/books'
TBLPROPERTIES ("skip.header.line.count"="1");

CREATE TABLE books2 AS
SELECT
  isbn,
  book_title,
  book_author,
  CASE 
    WHEN year_of_publication RLIKE '^[0-9]{4}$' THEN CAST(year_of_publication AS INT)
    ELSE NULL
  END AS year_of_publication,
  publisher,
  image_url_s,
  image_url_m,
  image_url_l
FROM books;


CREATE EXTERNAL TABLE book_ratings
(
	user_id		INT,
	isbn		STRING,
	book_rating	INT
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
    "separatorChar" = ";",
    "quoteChar"     = "\""
)
STORED AS TEXTFILE
LOCATION '/input/book/book_ratings'
TBLPROPERTIES ("skip.header.line.count"="1");

CREATE TABLE book_ratings2 AS
SELECT
  user_id,
  isbn,
  CASE 
    WHEN book_rating RLIKE '^[0-9]{4}$' THEN CAST(book_rating AS INT)
    ELSE NULL
  END AS book_rating
FROM book_ratings;

CREATE EXTERNAL TABLE users
(
	user_id		INT,
	location	STRING,
	age			INT
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
    "separatorChar" = ";",
    "quoteChar"     = "\""
)
STORED AS TEXTFILE
LOCATION '/input/book/users'
TBLPROPERTIES ("skip.header.line.count"="1");

CREATE TABLE users2 AS
SELECT
	CAST(user_id AS INT) AS user_id,
	CASE 
    	WHEN location = '' OR location = 'NULL' THEN NULL 
    	ELSE location 
	END AS location,
	CASE 
    	WHEN age RLIKE '^[0-9]+$' THEN CAST(age AS INT) 
	    ELSE NULL 
	END AS age
FROM users;
	

SELECT * FROM books LIMIT 10;
SELECT * FROM book_ratings LIMIT 10;
SELECT * FROM users LIMIT 10;

DROP TABLE users;

-- Books 테이블에서 중복된 ISBN 확인
SELECT isbn, COUNT(*) FROM books
GROUP BY isbn
HAVING COUNT(*) > 1;

-- Users 테이블에서 Age의 결측값 확인
SELECT age, COUNT(*) FROM users2
WHERE age IS NULL
GROUP BY age;

-- 사용자 연령의 기초 통계(최소, 최대, 평균)를 확인합니다.
SELECT MIN(age), MAX(age), AVG(age) FROM users2;

-- 책의 출판 연도에 대한 기초 통계(최소, 최대, 평균)를 확인합니다.
SELECT MIN(year_of_publication), MAX(year_of_publication), AVG(year_of_publication) FROM books2;

-- 평점의 분포 확인
SELECT book_rating, COUNT(book_rating) FROM book_ratings
GROUP BY book_rating;

-- 출판사별로 얼마나 많은 책이 있는지, 그리고 그 책들의 평균 평점이 어떤지 확인합니다.
