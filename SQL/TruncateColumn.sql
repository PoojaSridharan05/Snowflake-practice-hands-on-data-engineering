--Creating a table--
CREATE OR REPLACE TABLE  COPY_DB.PUBLIC.ORDERS (
    ORDER_ID VARCHAR(30),
    AMOUNT VARCHAR(30),
    PROFIT INT,
    QUANTITY INT,
    CATEGORY VARCHAR(10),
    SUBCATEGORY VARCHAR(30));
--Creating a stage to store the files--
CREATE OR REPLACE STAGE COPY_DB.PUBLIC.aws_stage_copy
    url='s3://snowflakebucket-copyoption/size/';
--List the files that is in stage--
LIST @COPY_DB.PUBLIC.aws_stage_copy;
--Since we have character limit to 10 one column is exceeding that limit--
--While loading the file one column exceeding limit error shows--
COPY INTO COPY_DB.PUBLIC.ORDERS
    FROM @aws_stage_copy
    file_format= (type = csv field_delimiter=',' skip_header=1)
    pattern='.*Order.*';
--If any column exceeding the limit delete that exceeding characters alone--
--Print only the characters within the limit--
COPY INTO COPY_DB.PUBLIC.ORDERS
    FROM @aws_stage_copy
    file_format= (type = csv field_delimiter=',' skip_header=1)
    pattern='.*Order.*'
    TRUNCATECOLUMNS = true; 
--Prints the table--
SELECT * FROM ORDERS;  
--Gives us the error if the column exceeds the limit--
COPY INTO COPY_DB.PUBLIC.ORDERS
    FROM @aws_stage_copy
    file_format= (type = csv field_delimiter=',' skip_header=1)
    pattern='.*Order.*'
    TRUNCATECOLUMNS = false; 
/* Value	Behavior
TRUE - Truncates strings that exceed the column's max length and loads the data (no error)
FALSE (default) - Throws an error and rejects the row if a string exceeds the column's max length
 */
    