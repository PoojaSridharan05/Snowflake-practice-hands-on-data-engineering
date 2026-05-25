-- Query load history within a database --
USE COPY_DB;
/* Click database, click copy_db, click information_schema, click views, click load_history for the below command */
select * from COPY_DB.INFORMATION_SCHEMA.LOAD_HISTORY;
--Query load history gloabally from SNOWFLAKE database--
/* Click databases, click snowflake, click account_usage, click views, click load_history */
select * from SNOWFLAKE.ACCOUNT_USAGE.LOAD_HISTORY;
--Filter on specific table & schema--
--Shows only the tables whose name is orders and schema name in public--
SELECT * FROM snowflake.account_usage.load_history
  where schema_name='PUBLIC' and
  table_name='ORDERS';
  --Filter on specific table & schema where error_count>0-- 
SELECT * FROM snowflake.account_usage.load_history
  where schema_name='PUBLIC' and
  table_name='ORDERS' and
  error_count > 0;
--Filter the history by sorting using previous day history using date and time--
SELECT * FROM snowflake.account_usage.load_history
WHERE DATE(LAST_LOAD_TIME) <= DATEADD(days,-1,CURRENT_DATE);

