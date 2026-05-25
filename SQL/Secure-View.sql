
-- Create database & table --
CREATE OR REPLACE DATABASE CUSTOMER_DB;
--Create a table--
CREATE OR REPLACE TABLE CUSTOMER_DB.public.customers (
   id int,
   first_name string,
  last_name string,
  email string,
  gender string,
  Job string,
  Phone string);
--File format--
CREATE OR REPLACE FILE FORMAT MANAGE_DB.file_formats.csv_file
    type = csv
    field_delimiter = ','
    skip_header = 1;
--Creating a stage--
CREATE OR REPLACE STAGE MANAGE_DB.external_stages.time_travel_stage
    URL = 's3://data-snowflake-fundamentals/time-travel/'
    file_format = MANAGE_DB.file_formats.csv_file;
--List the files--   
LIST  @MANAGE_DB.external_stages.time_travel_stage;
--Copy data and insert in table--
COPY INTO CUSTOMER_DB.public.customers
FROM @MANAGE_DB.external_stages.time_travel_stage
files = ('customers.csv');
--Display the table--
SELECT * FROM  CUSTOMER_DB.PUBLIC.CUSTOMERS;

-- Create general VIEW -- 
CREATE OR REPLACE VIEW CUSTOMER_DB.PUBLIC.CUSTOMER_VIEW AS
SELECT 
FIRST_NAME,
LAST_NAME,
EMAIL
FROM CUSTOMER_DB.PUBLIC.CUSTOMERS
WHERE JOB != 'DATA SCIENTIST'; 
-- Grant usage & SELECT --
GRANT USAGE ON DATABASE CUSTOMER_DB TO ROLE PUBLIC;
GRANT USAGE ON SCHEMA CUSTOMER_DB.PUBLIC TO ROLE PUBLIC;
GRANT SELECT ON TABLE CUSTOMER_DB.PUBLIC.CUSTOMERS TO ROLE PUBLIC;
GRANT SELECT ON VIEW CUSTOMER_DB.PUBLIC.CUSTOMER_VIEW TO ROLE PUBLIC;
--Try this command in new window in public role mode--
SHOW VIEWS LIKE '%CUSTOMER%';

-- Create SECURE VIEW -- 
CREATE OR REPLACE SECURE VIEW CUSTOMER_DB.PUBLIC.CUSTOMER_VIEW_SECURE AS
SELECT 
FIRST_NAME,
LAST_NAME,
EMAIL
FROM CUSTOMER_DB.PUBLIC.CUSTOMERS
WHERE JOB != 'DATA SCIENTIST';
--Grant permission--
GRANT SELECT ON VIEW CUSTOMER_DB.PUBLIC.CUSTOMER_VIEW_SECURE TO ROLE PUBLIC;
--Try this command in new window in public role mode--
SHOW VIEWS LIKE '%CUSTOMER%';
