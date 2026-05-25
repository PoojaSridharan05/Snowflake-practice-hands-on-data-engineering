--Show the tables that starts with customers--
SHOW TABLES like '%CUSTOMERS%';
--Set the table retention period for 2 days--
ALTER TABLE MY_FIRST_DB.PUBLIC.CUSTOMERS
SET DATA_RETENTION_TIME_IN_DAYS = 2;
--Set the retention period while creating the table itself--
CREATE OR REPLACE TABLE MY_FIRST_DB.public.ret_example (
    id int,
    first_name string,
    last_name string,
    email string,
    gender string,
    Job string,
    Phone string)
DATA_RETENTION_TIME_IN_DAYS = 3;
--Show tables that has filename with EX--
SHOW TABLES like '%EX%';
--Now drop and undrop the table to check the result--
DROP TABLE MY_FIRST_DB.public.ret_example;
UNDROP TABLE MY_FIRST_DB.public.ret_example;
--Now set the rentention period to 0 days--
ALTER TABLE MY_FIRST_DB.public.ret_example
SET DATA_RETENTION_TIME_IN_DAYS = 0;
--You cannot undrop the table because retention period is set to 0 days--
--So we cannot use time travel here because of 0 retention days--
DROP TABLE MY_FIRST_DB.public.ret_example;
UNDROP TABLE MY_FIRST_DB.public.ret_example;