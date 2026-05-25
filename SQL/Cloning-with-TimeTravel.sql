--Setting up table--
CREATE OR REPLACE TABLE MY_FIRST_DB.public.time_travel (
   id int,
   first_name string,
  last_name string,
  email string,
  gender string,
  Job string,
  Phone string);

CREATE OR REPLACE FILE FORMAT STAGING_DB.file_formats.csv_file
    type = csv
    field_delimiter = ','
    skip_header = 1;
    
CREATE OR REPLACE STAGE STAGING_DB.external_stages.time_travel_stage
    URL = 's3://data-snowflake-fundamentals/time-travel/'
    file_format = STAGING_DB.file_formats.csv_file;

LIST @STAGING_DB.external_stages.time_travel_stage;

COPY INTO MY_FIRST_DB.public.time_travel
from @STAGING_DB.external_stages.time_travel_stage
files = ('customers.csv');
--Display the table--
SELECT * FROM MY_FIRST_DB.public.time_travel;
--Update/change the data by setting firstname to frank-- 
UPDATE MY_FIRST_DB.public.time_travel
SET FIRST_NAME = 'Frank';
--Display the updated table--
SELECT * FROM MY_FIRST_DB.public.time_travel;

--Method 1 : Using time travel set an offset value--
SELECT * FROM MY_FIRST_DB.public.time_travel at (OFFSET => -60*1);
--Creating a clone of time travel--
CREATE OR REPLACE TABLE MY_FIRST_DB.PUBLIC.time_travel_clone
CLONE MY_FIRST_DB.public.time_travel at (OFFSET => -60*1);
--Displaying the cloned table--
SELECT * FROM MY_FIRST_DB.PUBLIC.time_travel_clone;

--Method 2 : Using time travel : by query ID--
--Update/change the data by setting the job to snowflake analyst--
UPDATE MY_FIRST_DB.public.time_travel_clone
SET JOB = 'Snowflake Analyst';
--Display the udated table--
SELECT * FROM MY_FIRST_DB.public.time_travel_clone;
--Use the query id to go back to the previous state--
SELECT * FROM MY_FIRST_DB.public.time_travel_clone before (statement => '01c45a35-0005-85b0-000d-77de001363de');
--Creating a clone of time travel using query id--
CREATE OR REPLACE TABLE MY_FIRST_DB.PUBLIC.time_travel_clone_of_clone
CLONE MY_FIRST_DB.public.time_travel_clone before (statement => '01c45a35-0005-85b0-000d-77de001363de');
--Displaying the cloned table--
SELECT * FROM MY_FIRST_DB.public.time_travel_clone_of_clone;