CREATE EXTERNAL TABLE users
(
	user_id INT,
	location STRING,
	age INT
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
   "separatorChar" = ";",
   "quoteChar"     = "\""
)  
STORED AS TEXTFILE
LOCATION '/input/book/users';

CREATE VIEW users_view AS
SELECT
	CAST(user_id AS INT) AS user_id,
	location,
	CAST(age AS INT) AS age
FROM users;

CREATE VIEW books_view2 AS
SELECT
	isbn,
	book_title,
	book_author,
	CAST(year_of_publication AS INT) AS year_of_publication,
	publisher,
	image_url_s,
	image_url_m,
	image_url_l
FROM books;

DROP TABLE books_view;

CREATE VIEW book_ratings_view AS
SELECT
  CAST(user_id AS INT) AS user_id,
  isbn,
  CAST(book_rating AS INT) AS book_rating
FROM book_ratings;

SELECT * FROM users_view;
SELECT * FROM books_view;
SELECT * FROM book_ratings_view;

-- Books 테이블에서 중복된 ISBN 확인
SELECT isbn, COUNT(*) FROM books_view
GROUP BY isbn
HAVING COUNT(*) > 1;

-- Users 테이블에서 Age의 결측값 확인
SELECT age, COUNT(*) FROM users_view
WHERE age IS NULL
GROUP BY age;

-- 사용자 연령의 기초 통계(최소, 최대, 평균)를 확인합니다.
SELECT MIN(age), MAX(age), AVG(age) FROM users_view;

-- 책의 출판 연도에 대한 기초 통계(최소, 최대, 평균)를 확인합니다.
SELECT MIN(year_of_publication), MAX(year_of_publication), AVG(year_of_publication) FROM books_view;

-- 평점의 분포 확인
SELECT book_rating, COUNT(book_rating) FROM book_ratings
GROUP BY book_rating;

-- 출판사별로 얼마나 많은 책이 있는지, 그리고 그 책들의 평균 평점이 어떤지 확인합니다.
SELECT books_view.publisher, COUNT(books_view.isbn), AVG(book_ratings_view.book_rating)
FROM books_view JOIN book_ratings_view 
ON books_view.isbn = book_ratings_view.isbn
GROUP BY books_view.publisher
ORDER BY COUNT(books_view.isbn) DESC
LIMIT 10;

-- 가장 많이 평가된 책이 무엇인지 확인합니다.
SELECT books_view.book_title, COUNT(book_ratings_view.book_rating), AVG(book_ratings_view.book_rating)
FROM books_view JOIN book_ratings_view
ON books_view.isbn = book_ratings_view.isbn
GROUP BY books_view.book_title
ORDER BY COUNT(book_ratings_view.book_rating) DESC
LIMIT 10;

-- 책의 출판 연도와 평점 간의 관계를 확인합니다.
SELECT books_view.year_of_publication, AVG(book_ratings_view.book_rating)
FROM books_view JOIN book_ratings_view
ON books_view.isbn = book_ratings_view.isbn
GROUP BY books_view.year_of_publication;

-- 위치(location)에 따라 평균 평점을 출력합니다. 적어도 10개 이상의 평가를 한 경우만 출력합니다.
SELECT u.location, AVG(r.book_rating), COUNT(r.book_rating)
FROM users_view u JOIN book_ratings_view r
ON u.user_id = r.user_id
GROUP BY u.location
HAVING COUNT(r.book_rating) >= 10
ORDER BY AVG(r.book_rating) DESC
LIMIT 10;

-- 각 저자별로 평균 평점이 어떻게 다른지 확인합니다. 적어도 10개 이상의 평가를 한 경우만 출력합니다.
SELECT b.book_author, AVG(r.book_rating), COUNT(r.book_rating)
FROM books_view2 b JOIN book_ratings_view r
ON b.isbn = r.isbn
GROUP BY b.book_author
HAVING COUNT(r.book_rating) > 10
ORDER BY AVG(r.book_rating) DESC
LIMIT 10;