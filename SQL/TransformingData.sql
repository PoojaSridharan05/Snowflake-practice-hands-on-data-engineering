--Creating a table1 with only 2 columns for example1--
CREATE OR REPLACE TABLE my_first_db.PUBLIC.ORDERS_EX (
    ORDER_ID VARCHAR(30),
    AMOUNT INT
    )
--Creating a table2 with multiple columns for example2 & example4--
CREATE OR REPLACE TABLE my_first_db.PUBLIC.ORDERS_EX (
    ORDER_ID VARCHAR(30),
    AMOUNT INT,
    PROFIT INT,
    PROFITABLE_FLAG VARCHAR(30)
    )
--Drop a table--
drop table my_first_db.public.orders_ex;
--Showing the contents of the table--
select * from my_first_db.public.orders_ex;
--Transforming using the select statement(selecting only specific columns and showing)--
--For this below example1 the table also should have only 2 columns(s is an alias name)--
COPY INTO my_first_db.PUBLIC.ORDERS_EX
    FROM (select s.$1, s.$2 from @STAGING_DB.external_stages.aws_stage s)
    file_format= (type = csv field_delimiter=',' skip_header=1)
    files=('OrderDetails.csv');
--Copy command example2 using sql function(case)--
COPY INTO my_first_db.PUBLIC.ORDERS_EX
    FROM (select 
            s.$1,
            s.$2, 
            s.$3,
            CASE WHEN CAST(s.$3 as int) < 0 THEN 'not profitable' ELSE 'profitable' END 
          from @STAGING_DB.external_stages.aws_stage s)
    file_format= (type = csv field_delimiter=',' skip_header=1)
    files=('OrderDetails.csv');
--The above same command alternate way of giving the column name as PROFITABLE_FLAG)--
COPY INTO my_first_db.PUBLIC.ORDERS_EX (ORDER_ID, AMOUNT, PROFIT, PROFITABLE_FLAG)
    FROM (select 
            s.$1,
            s.$2, 
            s.$3,
            CASE WHEN CAST(s.$3 as int) < 0 THEN 'not profitable' ELSE 'profitable' END 
          from @STAGING_DB.external_stages.aws_stage s)
    file_format= (type = csv field_delimiter=',' skip_header=1)
    files=('OrderDetails.csv');
--Creating a table3 for example3--
CREATE OR REPLACE TABLE my_first_db.PUBLIC.ORDERS_EX (
    ORDER_ID VARCHAR(30),
    AMOUNT INT,
    PROFIT INT,
    CATEGORY_SUBSTRING VARCHAR(5)
    );
--Copy command for example3 to show only first five characters in a string-- 
COPY INTO my_first_db.PUBLIC.ORDERS_EX
    FROM (select 
            s.$1,
            s.$2, 
            s.$3,
           substring (s.$5, 1, 5)
          from @STAGING_DB.external_stages.aws_stage s)
    file_format= (type = csv field_delimiter=',' skip_header=1)
    files=('OrderDetails.csv');
--Till now the above select columns and table columns were equal--
--Now if we want to select columns which is not equal to table columns--
--Example table2 has been used to select few columns which is not equal to the table columns--
COPY INTO my_first_db.PUBLIC.ORDERS_EX (ORDER_ID,PROFIT)
    FROM (select 
            s.$1,
            s.$3
          from @STAGING_DB.external_stages.aws_stage s)
    file_format= (type = csv field_delimiter=',' skip_header=1)
    files=('OrderDetails.csv');
--Creating a table4 for auto increment in ID column--
CREATE OR REPLACE TABLE my_first_db.PUBLIC.ORDERS_EX (
    ORDER_ID number autoincrement start 1 increment 1,
    AMOUNT INT,
    PROFIT INT,
    PROFITABLE_FLAG VARCHAR(30) 
    );
--To show only specified column along with auto increment ID--    
COPY INTO my_first_db.PUBLIC.ORDERS_EX (PROFIT,AMOUNT)
    FROM (select 
            s.$2,
            s.$3
          from @STAGING_DB.external_stages.aws_stage s)
    file_format= (type = csv field_delimiter=',' skip_header=1)
    files=('OrderDetails.csv');
--showing the output using specific condition--
select * from my_first_db.public.orders_ex;
select * from my_first_db.public.orders_ex where ORDER_ID > 15;



