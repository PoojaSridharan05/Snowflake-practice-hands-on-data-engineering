CREATE OR REPLACE STAGE STAGING_DB.external_stages.aws_stage_errorex
    url='s3://bucketsnowflakes4'
--List the files in stage area--
LIST @STAGING_DB.external_stages.aws_stage_errorex;
 --Creating a table--
CREATE OR REPLACE TABLE my_first_db.PUBLIC.ORDERS_EX (
    ORDER_ID VARCHAR(30),
    AMOUNT INT,
    PROFIT INT,
    QUANTITY INT,
    CATEGORY VARCHAR(30),
    SUBCATEGORY VARCHAR(30));
 --Demonstrating a error message--
COPY INTO my_first_db.PUBLIC.ORDERS_EX
    FROM @STAGING_DB.external_stages.aws_stage_errorex
    file_format= (type = csv field_delimiter=',' skip_header=1)
    files = ('OrderDetails_error.csv');
--check the table output--
SELECT * FROM my_first_db.PUBLIC.ORDERS_EX;
--On Error option when an error occurs--
COPY INTO my_first_db.PUBLIC.ORDERS_EX
    FROM @STAGING_DB.external_stages.aws_stage_errorex
    file_format= (type = csv field_delimiter=',' skip_header=1)
    files = ('OrderDetails_error.csv')
    ON_ERROR = 'CONTINUE';
--Truncate the previous upload--
--use this for before executing every copy command(to clear the data)--
TRUNCATE TABLE my_first_db.PUBLIC.ORDERS_EX;
--Abort even if one file has error--
COPY INTO my_first_db.PUBLIC.ORDERS_EX
    FROM @STAGING_DB.external_stages.aws_stage_errorex
    file_format= (type = csv field_delimiter=',' skip_header=1)
    files = ('OrderDetails_error.csv','OrderDetails_error2.csv')
    ON_ERROR = 'ABORT_STATEMENT';
--Skip a file that has error and continue to upload--
COPY INTO my_first_db.PUBLIC.ORDERS_EX
    FROM @STAGING_DB.external_stages.aws_stage_errorex
    file_format= (type = csv field_delimiter=',' skip_header=1)
    files = ('OrderDetails_error.csv','OrderDetails_error2.csv')
    ON_ERROR = 'SKIP_FILE';
--Set an error limit for a file--
COPY INTO my_first_db.PUBLIC.ORDERS_EX
    FROM @STAGING_DB.external_stages.aws_stage_errorex
    file_format= (type = csv field_delimiter=',' skip_header=1)
    files = ('OrderDetails_error.csv','OrderDetails_error2.csv')
    ON_ERROR = 'SKIP_FILE_3';  
--Set the error limit in percentage--
COPY INTO my_first_db.PUBLIC.ORDERS_EX
    FROM @STAGING_DB.external_stages.aws_stage_errorex
    file_format= (type = csv field_delimiter=',' skip_header=1)
    files = ('OrderDetails_error.csv','OrderDetails_error2.csv')
    ON_ERROR = 'SKIP_FILE_0.5%'; 
--set the total upload file size  across all files limit to 30Bytes--
COPY INTO my_first_db.PUBLIC.ORDERS_EX
    FROM @STAGING_DB.external_stages.aws_stage_errorex
    file_format= (type = csv field_delimiter=',' skip_header=1)
    files = ('OrderDetails_error.csv','OrderDetails_error2.csv')
    ON_ERROR = SKIP_FILE_3 
    SIZE_LIMIT = 30;
