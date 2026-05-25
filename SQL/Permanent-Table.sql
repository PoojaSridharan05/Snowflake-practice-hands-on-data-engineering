CREATE OR REPLACE DATABASE PDB;
--Creating a table--
CREATE OR REPLACE TABLE PDB.public.customers (
   id int,
   first_name string,
  last_name string,
  email string,
  gender string,
  Job string,
  Phone string);
  
CREATE OR REPLACE TABLE PDB.public.helper (
   id int,
   first_name string,
  last_name string,
  email string,
  gender string,
  Job string,
  Phone string);
--Stage and file format--
CREATE OR REPLACE FILE FORMAT STAGING_DB.file_formats.csv_file
    type = csv
    field_delimiter = ','
    skip_header = 1;
    
CREATE OR REPLACE STAGE STAGING_DB.external_stages.time_travel_stage
    URL = 's3://data-snowflake-fundamentals/time-travel/'
    file_format = STAGING_DB.file_formats.csv_file;
--List the files--
LIST  @STAGING_DB.external_stages.time_travel_stage;
--Copy data and insert in table--
COPY INTO PDB.public.helper
FROM @STAGING_DB.external_stages.time_travel_stage
files = ('customers.csv');

SELECT * FROM PDB.public.helper;

INSERT INTO PDB.public.customers
SELECT
t1.ID
,t1.FIRST_NAME	
,t1.LAST_NAME	
,t1.EMAIL	
,t1.GENDER	
,t1.JOB
,t1.PHONE
 FROM PDB.public.helper t1
CROSS JOIN (SELECT * FROM PDB.public.helper) t2
CROSS JOIN (SELECT TOP 100 * FROM PDB.public.helper) t3;

--Show table and validate--
SHOW TABLES;
--Permanent tables--
USE OUR_FIRST_DB;
--Create a table--
CREATE OR REPLACE TABLE customers (
   id int,
   first_name string,
  last_name string,
  email string,
  gender string,
  Job string,
  Phone string);
--Create a database;
CREATE OR REPLACE DATABASE PDB;

SHOW DATABASES;

SHOW TABLES;
--View table metrics (takes a bit to appear)--
SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.TABLE_STORAGE_METRICS;
--This query analyzes storage consumption of dropped tables in your Snowflake account.--
SELECT 	ID, 
       	TABLE_NAME, 
		TABLE_SCHEMA,
        TABLE_CATALOG,
		ACTIVE_BYTES / (1024*1024*1024) AS ACTIVE_STORAGE_USED_GB,
		TIME_TRAVEL_BYTES / (1024*1024*1024) AS TIME_TRAVEL_STORAGE_USED_GB,
		FAILSAFE_BYTES / (1024*1024*1024) AS FAILSAFE_STORAGE_USED_GB,
        IS_TRANSIENT,
        DELETED,
        TABLE_CREATED,
        TABLE_DROPPED,
        TABLE_ENTERED_FAILSAFE
FROM SNOWFLAKE.ACCOUNT_USAGE.TABLE_STORAGE_METRICS
--WHERE TABLE_CATALOG ='PDB'
WHERE TABLE_DROPPED is not null
ORDER BY FAILSAFE_BYTES DESC;
--Why this matters: Dropped tables don't immediately free storage. They continue consuming space during Time Travel and Failsafe periods. This query helps identify which dropped tables are still costing you the most in storage, useful for cost optimization and understanding your storage bill.--

/* Setup — Creates database PDB, two tables (customers, helper), a CSV file format, and an S3 external stage.

Load Data — Copies customers.csv from the S3 stage into the helper table.

Generate Large Dataset — Cross-joins helper with itself to insert millions of rows into customers for storage testing.

Drop Tables Implicitly — Runs CREATE OR REPLACE DATABASE PDB, which drops and recreates the database, effectively deleting all tables including the large customers table.

Analyze Dropped Table Storage — Queries SNOWFLAKE.ACCOUNT_USAGE.TABLE_STORAGE_METRICS to show that dropped permanent tables still consume Time Travel and Failsafe storage, demonstrating the hidden cost of dropped tables. */