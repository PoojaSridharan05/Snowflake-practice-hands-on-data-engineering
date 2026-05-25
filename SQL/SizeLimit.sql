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
--Creating a stage for s3 bucket--
CREATE OR REPLACE STAGE COPY_DB.PUBLIC.aws_stage_copy
    url='s3://snowflakebucket-copyoption/size/';
--List the files which is in S3--
LIST @aws_stage_copy;
--Load the data using size limit--
--The limit will be considered for all the files--
/*Even though the first file exceeds the 20,000-byte limit, Snowflake's SIZE_LIMIT behavior is:
It checks the limit before starting to load a file
If no data has been loaded yet, it will always load at least one file regardless of that file's size
It only stops queuing additional files once the cumulative threshold is reached
So the first file always gets loaded completely, even if it's larger than the SIZE_LIMIT. The limit only prevents subsequent files from being added to the load operation.*/
COPY INTO COPY_DB.PUBLIC.ORDERS
    FROM @aws_stage_copy
    file_format= (type = csv field_delimiter=',' skip_header=1)
    pattern='.*Order.*'
    SIZE_LIMIT=20000;
--Loading with another size limit--
COPY INTO COPY_DB.PUBLIC.ORDERS
    FROM @aws_stage_copy
    file_format= (type = csv field_delimiter=',' skip_header=1)
    pattern='.*Order.*'
    SIZE_LIMIT=60000;
--Now both the files loaded--
/* First it checks the first file and it loaded. It is yet to exceed the limit. So it loaded the second file.
It exceeded the limit and now it will not go for next file*/