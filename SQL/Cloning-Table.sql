--Display the old table--
SELECT * FROM MY_FIRST_DB.PUBLIC.CUSTOMERS;
--Create a cloning table for the original customers table--
CREATE TABLE MY_FIRST_DB.PUBLIC.CUSTOMERS_CLONE
CLONE MY_FIRST_DB.PUBLIC.CUSTOMERS;
--Show the cloned table data--
SELECT * FROM MY_FIRST_DB.PUBLIC.CUSTOMERS_CLONE;
--Update/make a small change in cloned table--
UPDATE MY_FIRST_DB.public.CUSTOMERS_CLONE
SET LAST_NAME = NULL;
--Display the original table and check whether the last name has not been set to null-
SELECT * FROM MY_FIRST_DB.PUBLIC.CUSTOMERS ;
--Display the cloned table and check wether the lastname is set to null--
SELECT * FROM MY_FIRST_DB.PUBLIC.CUSTOMERS_CLONE;
--Cloning a temporary table is not possible--
--Create a temporary table--
CREATE OR REPLACE TEMPORARY TABLE MY_FIRST_DB.PUBLIC.TEMP_TABLE(
  id int);
--Try to create a permanent cloning table for the above temporary table--
CREATE TABLE MY_FIRST_DB.PUBLIC.TABLE_COPY
CLONE MY_FIRST_DB.PUBLIC.TEMP_TABLE;
--Create a temporary cloning table for the above temporary table--
CREATE OR REPLACE TEMPORARY TABLE MY_FIRST_DB.PUBLIC.TABLE_COPY
CLONE MY_FIRST_DB.PUBLIC.TEMP_TABLE;
--Display the table--
SELECT * FROM MY_FIRST_DB.PUBLIC.TABLE_COPY;