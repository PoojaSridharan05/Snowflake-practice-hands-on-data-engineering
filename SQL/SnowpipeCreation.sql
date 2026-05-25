--Create table first--
CREATE OR REPLACE TABLE my_first_db.PUBLIC.employees (
  id INT,
  first_name STRING,
  last_name STRING,
  email STRING,
  location STRING,
  department STRING
  );
--Create file format object--
CREATE OR REPLACE file format STAGING_DB.file_formats.csv_fileformat
    type = csv
    field_delimiter = ','
    skip_header = 1
    null_if = ('NULL','null')
    empty_field_as_null = TRUE;
--Create stage object with integration object & file format object--
CREATE OR REPLACE stage STAGING_DB.external_stages.csv_folder
    URL = 's3://snowflakebucketarg2909/csv/snowpipe'
    STORAGE_INTEGRATION = s3_int
    FILE_FORMAT = STAGING_DB.file_formats.csv_fileformat;
--Create stage object with integration object & file format object--
LIST @STAGING_DB.external_stages.csv_folder;
--Create schema to keep things organized--
CREATE OR REPLACE SCHEMA STAGING_DB.pipes;
--Define pipe--
CREATE OR REPLACE pipe STAGING_DB.pipes.employee_pipe
auto_ingest = TRUE
AS
COPY INTO my_first_db.PUBLIC.employees
FROM @STAGING_DB.external_stages.csv_folder;
--Describe pipe--
DESC pipe employee_pipe;
--List the files--
SELECT * FROM my_first_db.PUBLIC.employees;   
--Handling errors--
--Create file format object--
CREATE OR REPLACE file format STAGING_DB.file_formats.csv_fileformat
    type = csv
    field_delimiter = '|'
    skip_header = 1
    null_if = ('NULL','null')
    empty_field_as_null = TRUE;
SELECT * FROM my_first_db.PUBLIC.employees;
ALTER PIPE employee_pipe refresh;
--Validate pipe is actually working--
SELECT SYSTEM$PIPE_STATUS('employee_pipe');
--Snowpipe error message--
SELECT * FROM TABLE(VALIDATE_PIPE_LOAD(
    PIPE_NAME => 'STAGING_DB.pipes.employee_pipe',
    START_TIME => DATEADD(HOUR,-2,CURRENT_TIMESTAMP())));
--COPY command history from table to see error massage--
SELECT * FROM TABLE (INFORMATION_SCHEMA.COPY_HISTORY(
   table_name  =>  'my_first_db.PUBLIC.EMPLOYEES',
   START_TIME =>DATEADD(HOUR,-2,CURRENT_TIMESTAMP())));
--Correct way of table creation without error--
CREATE OR REPLACE file format STAGING_DB.file_formats.csv_fileformat
    type = csv
    field_delimiter = ','
    skip_header = 1
    null_if = ('NULL','null')
    empty_field_as_null = TRUE;
SELECT * FROM my_first_db.PUBLIC.employees;
--Displaying of pipes in different ways--
DESC pipe STAGING_DB.pipes.employee_pipe;
SHOW PIPES;
SHOW PIPES like '%employee%';
SHOW PIPES in database STAGING_DB;
SHOW PIPES in schema STAGING_DB.pipes;
SHOW PIPES like '%employee%' in Database STAGING_DB;
-- Changing pipe (alter stage or file format) --
--Preparation table first--
CREATE OR REPLACE TABLE my_first_db.PUBLIC.employees2 (
  id INT,
  first_name STRING,
  last_name STRING,
  email STRING,
  location STRING,
  department STRING
  );
--Pause pipe--
ALTER PIPE STAGING_DB.pipes.employee_pipe SET PIPE_EXECUTION_PAUSED = true;
--Verify pipe  execution state is paused and has pendingFileCount 0--
SELECT SYSTEM$PIPE_STATUS('STAGING_DB.pipes.employee_pipe');
