--Creating a DB--
CREATE OR REPLACE DATABASE COPY_DB;
--Creating a table--
CREATE OR REPLACE TABLE  COPY_DB.PUBLIC.ORDERS (
    ORDER_ID VARCHAR(30),
    AMOUNT VARCHAR(30),
    PROFIT INT,
    QUANTITY INT,
    CATEGORY VARCHAR(30),
    SUBCATEGORY VARCHAR(30));
--Prepare stage object--
CREATE OR REPLACE STAGE COPY_DB.PUBLIC.aws_stage_copy
    url='s3://snowflakebucket-copyoption/size/';
--List the files in that stage object--
LIST @COPY_DB.PUBLIC.aws_stage_copy;
--Load data using copy command(There was no error in those files)--
--IT just validates the file whether it has error or not. It dosent load the file--
COPY INTO COPY_DB.PUBLIC.ORDERS
    FROM @aws_stage_copy
    file_format= (type = csv field_delimiter=',' skip_header=1)
    pattern='.*Order.*'
    VALIDATION_MODE = RETURN_ERRORS;
--Returns first 5 rows if there is no error in all 4 files--
COPY INTO COPY_DB.PUBLIC.ORDERS
    FROM @aws_stage_copy
    file_format= (type = csv field_delimiter=',' skip_header=1)
    pattern='.*Order.*'
   VALIDATION_MODE = RETURN_5_ROWS;
--So far the above files didnt had the errors
--Now use files with errors--
CREATE OR REPLACE STAGE COPY_DB.PUBLIC.aws_stage_copy
    url='s3://snowflakebucket-copyoption/returnfailed/';
--List the files in that stage--
LIST @COPY_DB.PUBLIC.aws_stage_copy;  
--Checks whether those files has error or not--
--If it has error it displays those errors alone--
COPY INTO COPY_DB.PUBLIC.ORDERS
    FROM @aws_stage_copy
    file_format= (type = csv field_delimiter=',' skip_header=1)
    pattern='.*Order.*'
    VALIDATION_MODE = RETURN_ERRORS;
--Rteruns the first row of errors found in any of these four files--
COPY INTO COPY_DB.PUBLIC.ORDERS
    FROM @aws_stage_copy
    file_format= (type = csv field_delimiter=',' skip_header=1)
    pattern='.*Order.*'
    VALIDATION_MODE = RETURN_1_rows;
--Working with errors--
--Creating a table to store the rejected data
CREATE OR REPLACE TABLE  COPY_DB.PUBLIC.ORDERS (
    ORDER_ID VARCHAR(30),
    AMOUNT VARCHAR(30),
    PROFIT INT,
    QUANTITY INT,
    CATEGORY VARCHAR(30),
    SUBCATEGORY VARCHAR(30));
--Check whether the files has errors using copy command--
COPY INTO COPY_DB.PUBLIC.ORDERS
    FROM @aws_stage_copy
    file_format= (type = csv field_delimiter=',' skip_header=1)
    pattern='.*Order.*'
    VALIDATION_MODE = RETURN_ERRORS;
--Creating a table to store the failed data/results--
CREATE OR REPLACE TABLE rejected AS 
select rejected_record from table(result_scan(last_query_id()));
--Adding additional records(dont run)--
INSERT INTO rejected
select rejected_record from table(result_scan(last_query_id()));
--Show the rejected table--
SELECT * FROM rejected;
--Saving rejected files without validation mode--
COPY INTO COPY_DB.PUBLIC.ORDERS
    FROM @aws_stage_copy
    file_format= (type = csv field_delimiter=',' skip_header=1)
    pattern='.*Order.*'
    ON_ERROR=CONTINUE
--It returns details about rows that failed dueing loading--
select * from table(validate(orders, job_id => '_last'));
--Gives the raw rejected records--
SELECT REJECTED_RECORD FROM rejected;
--It takes the rejected record string and gives us the new structured table--
CREATE OR REPLACE TABLE rejected_values as
SELECT 
SPLIT_PART(rejected_record,',',1) as ORDER_ID, 
SPLIT_PART(rejected_record,',',2) as AMOUNT, 
SPLIT_PART(rejected_record,',',3) as PROFIT, 
SPLIT_PART(rejected_record,',',4) as QUATNTITY, 
SPLIT_PART(rejected_record,',',5) as CATEGORY, 
SPLIT_PART(rejected_record,',',6) as SUBCATEGORY
FROM rejected; 
--Show the new structured table--
SELECT * FROM rejected_values;