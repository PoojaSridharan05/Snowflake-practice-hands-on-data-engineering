
--Creates a transient DB--
CREATE OR REPLACE TRANSIENT DATABASE STREAMS_DB;
-- Create table1 
create or replace table sales_raw_staging(
  id varchar,
  product varchar,
  price varchar,
  amount varchar,
  store_id varchar);
-- insert values into table1 
insert into sales_raw_staging 
    values
        (1,'Banana',1.99,1,1),
        (2,'Lemon',0.99,1,1),
        (3,'Apple',1.79,1,2),
        (4,'Orange Juice',1.89,1,2),
        (5,'Cereals',5.98,2,1);  
--Create table2--
create or replace table store_table(
  store_id number,
  location varchar,
  employees number);
--Insert values into table2--
INSERT INTO STORE_TABLE VALUES(1,'Chicago',33);
INSERT INTO STORE_TABLE VALUES(2,'London',12);
--create table3--
create or replace table sales_final_table(
  id int,
  product varchar,
  price number,
  amount int,
  store_id int,
  location varchar,
  employees int);
--Join tbale1 and table2 values into table3--
INSERT INTO sales_final_table 
    SELECT 
    SA.id,
    SA.product,
    SA.price,
    SA.amount,
    ST.STORE_ID,
    ST.LOCATION, 
    ST.EMPLOYEES 
    FROM SALES_RAW_STAGING SA
    JOIN STORE_TABLE ST ON ST.STORE_ID=SA.STORE_ID ;
--Display all the tables--
select * from store_table;
select * from sales_raw_staging;
select * from sales_final_table;   
--Create a stream object--
create or replace stream sales_stream on table sales_raw_staging;
--Show the stream--
SHOW STREAMS;
DESC STREAM sales_stream;
select * from sales_stream;                                      
--If we add any changes in the raw table it should be reflected on the final table--
-- insert values into table1--
insert into sales_raw_staging  
    values
        (6,'Mango',1.99,1,2),
        (7,'Garlic',0.99,1,1);
--Check the tables and stream object--
select * from sales_stream;
select * from sales_raw_staging;              
select * from sales_final_table;        
--Now the data in stream object/table will be copied and stored in final table3--
--Using join combine the data from stream table to final table3--
INSERT INTO sales_final_table 
    SELECT 
    SA.id,
    SA.product,
    SA.price,
    SA.amount,
    ST.STORE_ID,
    ST.LOCATION, 
    ST.EMPLOYEES 
    FROM SALES_STREAM SA
    JOIN STORE_TABLE ST ON ST.STORE_ID=SA.STORE_ID ;
--Display the tables--
select * from sales_stream;
select * from sales_final_table;
-- insert values into table1 again-- 
insert into sales_raw_staging  
    values
        (8,'Paprika',4.99,1,2),
        (9,'Tomato',3.99,1,2);     
 -- Consume stream object--
INSERT INTO sales_final_table 
    SELECT 
    SA.id,
    SA.product,
    SA.price,
    SA.amount,
    ST.STORE_ID,
    ST.LOCATION, 
    ST.EMPLOYEES 
    FROM SALES_STREAM SA
    JOIN STORE_TABLE ST ON ST.STORE_ID=SA.STORE_ID ;
--Display the tables--
SELECT * FROM SALES_FINAL_TABLE;        
SELECT * FROM SALES_RAW_STAGING;     
SELECT * FROM SALES_STREAM;
