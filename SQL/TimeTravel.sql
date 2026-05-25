--Creating a table--
CREATE OR REPLACE TABLE MY_FIRST_DB.public.test (
   id int,
   first_name string,
  last_name string,
  email string,
  gender string,
  Job string,
  Phone string);
--Creating a file format--
CREATE OR REPLACE FILE FORMAT STAGING_DB.file_formats.csv_file
    type = csv
    field_delimiter = ','
    skip_header = 1;
--Creating a stage--    
CREATE OR REPLACE STAGE STAGING_DB.external_stages.time_travel_stage
    URL = 's3://data-snowflake-fundamentals/time-travel/'
    file_format = STAGING_DB.file_formats.csv_file;
--List the files in that stage--
LIST @STAGING_DB.external_stages.time_travel_stage;
--Copy the data/file into the table--
COPY INTO my_first_db.public.test
from @STAGING_DB.external_stages.time_travel_stage
files = ('customers.csv');
--Display the table--
SELECT * FROM my_first_db.public.test;
--Use-case: Update data by changing the first name to 'joyen' for the whole table (by mistake)--
UPDATE my_first_db.public.test
SET FIRST_NAME = 'Joyen';
--Using time travel: Method 1 is to use the offset function by 2 minutes back--
--This method is not frequently used but useful for small minutes rollback--
SELECT * FROM my_first_db.public.test at (OFFSET => -60*1.5);
--Copy command--
COPY INTO my_first_db.public.test
from @STAGING_DB.external_stages.time_travel_stage
files = ('customers.csv');
--Displaying the table--
SELECT * FROM my_first_db.public.test;
-- Setting up UTC time for convenience--
-- 2026-05-09 19:22:58.055 +0000 --
ALTER SESSION SET TIMEZONE ='UTC';
--Shows the current date and time(Timestamp)--
SELECT DATEADD(DAY, 1, CURRENT_TIMESTAMP);
--Make an update by mistake--
--Set the job title to data analyst for all the users--
UPDATE my_first_db.public.test
SET Job = 'Data Scientist';
--Display the table which was made by mistake--
SELECT * FROM my_first_db.public.test;
--Display the table with the correct data using timestamp--
SELECT * FROM my_first_db.public.test before (timestamp => '2026-05-08 19:22:58.055'::timestamp_tz);
--Using time travel: Method 3 - by Query ID--
--Preparing table--
CREATE OR REPLACE TABLE my_first_db.public.test (
   id int,
   first_name string,
  last_name string,
  email string,
  gender string,
  Phone string,
  Job string);
--Copy command--
COPY INTO my_FIRST_DB.public.test
from @STAGING_DB.external_stages.time_travel_stage
files = ('customers.csv');
--Displaying the table--
SELECT * FROM my_FIRST_DB.public.test;
--Altering table (by mistake) by setting the email address to null for all the id--
-- 01c43cc1-0005-6d70-000d-77de000cf32a --
UPDATE my_FIRST_DB.public.test
SET EMAIL = null;
--Display the mistake table--
SELECT * FROM my_FIRST_DB.public.test;
--Display the correct table by using query id--
SELECT * FROM my_FIRST_DB.public.test before (statement => '01c43cc1-0005-6d70-000d-77de000cf32a');


