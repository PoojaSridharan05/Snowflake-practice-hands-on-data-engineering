--Setting a stage--
CREATE OR REPLACE STAGE STAGING_DB.external_stages.time_travel_stage
    URL = 's3://data-snowflake-fundamentals/time-travel/'
    file_format = STAGING_DB.file_formats.csv_file;
--Creating a table--
CREATE OR REPLACE TABLE MY_FIRST_DB.public.customers (
   id int,
   first_name string,
  last_name string,
  email string,
  gender string,
  Job string,
  Phone string);
--Copy command--
COPY INTO MY_FIRST_DB.public.customers
from @STAGING_DB.external_stages.time_travel_stage
files = ('customers.csv');
--Displaying the table--
SELECT * FROM MY_FIRST_DB.public.customers;
--UNDROP command - Tables--
DROP TABLE MY_FIRST_DB.public.customers;
SELECT * FROM MY_FIRST_DB.public.customers;
UNDROP TABLE MY_FIRST_DB.public.customers;
--UNDROP command - Schemas--
DROP SCHEMA MY_FIRST_DB.public;
SELECT * FROM MY_FIRST_DB.public.customers;
UNDROP SCHEMA MY_FIRST_DB.public;
--UNDROP command - Database--
DROP DATABASE MY_FIRST_DB;
SELECT * FROM MY_FIRST_DB.public.customers;
UNDROP DATABASE MY_FIRST_DB;
--Restore replaced table--
--Change the data in two columns to check--
UPDATE MY_FIRST_DB.public.customers
SET LAST_NAME = 'Tyson';

UPDATE MY_FIRST_DB.public.customers
SET JOB = 'Data Analyst';

--Undroping a with a name that already exists--
--Changing the job title for the table--
CREATE OR REPLACE TABLE MY_FIRST_DB.public.customers as
SELECT * FROM MY_FIRST_DB.public.customers before (statement => '01c43db2-0005-74f7-000d-77de000ee26e');

SELECT * FROM MY_FIRST_DB.public.customers;

UNDROP table MY_FIRST_DB.public.customers;

ALTER TABLE MY_FIRST_DB.public.customers
RENAME TO MY_FIRST_DB.public.customers_wrong;

UNDROP table MY_FIRST_DB.public.customers;

DESC table OUR_FIRST_DB.public.customers;
--Key concept: UNDROP fails if a table with the same name already exists. The workaround is to rename the existing table first, then UNDROP.--

--Change the Lastname for the table--
CREATE OR REPLACE TABLE MY_FIRST_DB.public.customers as
SELECT * FROM MY_FIRST_DB.public.customers before (statement => '01c43db2-0005-6792-000d-77de000c3c62');

SELECT * FROM MY_FIRST_DB.public.customers;

UNDROP table MY_FIRST_DB.public.customers;

ALTER TABLE MY_FIRST_DB.public.customers
RENAME TO MY_FIRST_DB.public.customers_wrongg;

UNDROP table MY_FIRST_DB.public.customers;

DESC table OUR_FIRST_DB.public.customers;