--Creating a normal database--
CREATE OR REPLACE DATABASE TDB;
--Creating a transient table--
CREATE OR REPLACE TRANSIENT TABLE TDB.public.customers_transient (
   id int,
   first_name string,
  last_name string,
  email string,
  gender string,
  Job string,
  Phone string);
--Inserting the values--
--This cross-joins the customers table with itself to multiply the row count and inserts the result into customers_transient.--
INSERT INTO TDB.public.customers_transient
SELECT t1.* FROM MY_FIRST_DB.public.customers t1
CROSS JOIN (SELECT * FROM MY_FIRST_DB.public.customers) t2;
--Show the tables--
SHOW TABLES;
--Query storage(returns storage usage metrics for every table in your account)--
SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.TABLE_STORAGE_METRICS;

SELECT 	ID, 
       	TABLE_NAME, 
		TABLE_SCHEMA,
        TABLE_CATALOG,
		ACTIVE_BYTES,
		TIME_TRAVEL_BYTES / (1024*1024*1024) AS TIME_TRAVEL_STORAGE_USED_GB,
		FAILSAFE_BYTES / (1024*1024*1024) AS FAILSAFE_STORAGE_USED_GB,
        IS_TRANSIENT,
        DELETED,
        TABLE_CREATED,
        TABLE_DROPPED,
        TABLE_ENTERED_FAILSAFE
FROM SNOWFLAKE.ACCOUNT_USAGE.TABLE_STORAGE_METRICS
WHERE TABLE_CATALOG ='TDB'
ORDER BY TABLE_CREATED DESC;
--Set retention time to 0 or 1--
ALTER TABLE TDB.public.customers_transient
SET DATA_RETENTION_TIME_IN_DAYS  = 0;
--Drop the table--
DROP TABLE TDB.public.customers_transient;
--You cannot undrop it because there is no retention period--
UNDROP TABLE TDB.public.customers_transient;
--Display the tables--
SHOW TABLES;
--Creating transient schema and then normal table--
CREATE OR REPLACE TRANSIENT SCHEMA TRANSIENT_SCHEMA;

SHOW SCHEMAS;

CREATE OR REPLACE TABLE TDB.TRANSIENT_SCHEMA.new_table (
   id int,
   first_name string,
  last_name string,
  email string,
  gender string,
  Job string,
  Phone string);
  
--By default retention time for transient table is 0 or 1 day--
ALTER TABLE TDB.TRANSIENT_SCHEMA.new_table
SET DATA_RETENTION_TIME_IN_DAYS  = 2;

SHOW TABLES;
--If the schema is transient then the table also becomes transient by default--
--If the schema is normal there can be transient/normal table--
