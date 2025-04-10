## 서버 실행
- 하둡 실행
    - `~/hadoop-3.3.6/sbin/start-all.sh `
- 하이브 서버 실행
- beeline 실행

## 데이터 업로드
- `hdfs dfs -mkdir /input/employees`
- `hdfs dfs -put ~/damf2/data/employees /input/employees`

## 테이블 삭제 확인
- `SHOW TABLES;`