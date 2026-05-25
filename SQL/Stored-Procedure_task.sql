USE TASK_DB;
--Display the customers table and check the row count--
SELECT * FROM CUSTOMERS;
--Creating a procedure to add a timestamp to the current date column in customers table--
CREATE OR REPLACE PROCEDURE CUSTOMERS_INSERT_PROCEDURE (CREATE_DATE varchar)
    RETURNS STRING NOT NULL
    LANGUAGE JAVASCRIPT
    AS
        $$
        var sql_command = 'INSERT INTO CUSTOMERS(CREATE_DATE) VALUES(:1);'
        snowflake.execute(
            {
            sqlText: sql_command,
            binds: [CREATE_DATE]
            });
        return "Successfully executed.";
        $$;
--Creating the task to run the procedure--    
CREATE OR REPLACE TASK CUSTOMER_TAKS_PROCEDURE
WAREHOUSE = COMPUTE_WH
SCHEDULE = '1 MINUTE'
AS CALL  CUSTOMERS_INSERT_PROCEDURE (CURRENT_TIMESTAMP);
--Show the tasks--
SHOW TASKS;
--Resume the stored procedure task-- 
ALTER TASK CUSTOMER_TAKS_PROCEDURE RESUME;
--Displays the customers table--
SELECT * FROM CUSTOMERS;