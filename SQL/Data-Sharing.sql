--Create a DB--
CREATE OR REPLACE DATABASE DATA_S;
--Create a stage--
CREATE OR REPLACE STAGE aws_stage
    url='s3://bucketsnowflakes3';
--List files in stage--
LIST @aws_stage;
--Create table--
CREATE OR REPLACE TABLE ORDERS (
ORDER_ID	VARCHAR(30)
,AMOUNT	NUMBER(38,0)
,PROFIT	NUMBER(38,0)
,QUANTITY	NUMBER(38,0)
,CATEGORY	VARCHAR(30)
,SUBCATEGORY	VARCHAR(30));
--Load data using copy command--
COPY INTO ORDERS
    FROM @MANAGE_DB.external_stages.aws_stage
    file_format= (type = csv field_delimiter=',' skip_header=1)
    pattern='.*OrderDetails.*';
--Display the table--    
SELECT * FROM ORDERS;
--Create a share object--
CREATE OR REPLACE SHARE ORDERS_SHARE;
--Setup Grants--
--Grant usage on database--
GRANT USAGE ON DATABASE DATA_S TO SHARE ORDERS_SHARE; 
--Grant usage on schema--
GRANT USAGE ON SCHEMA DATA_S.PUBLIC TO SHARE ORDERS_SHARE; 
--Grant SELECT on table--
GRANT SELECT ON TABLE DATA_S.PUBLIC.ORDERS TO SHARE ORDERS_SHARE; 
--Validate Grants--
SHOW GRANTS TO SHARE ORDERS_SHARE;
--Command to get the organization name and account name if its to the same account--
SELECT CURRENT_ORGANIZATION_NAME() || '.' || CURRENT_ACCOUNT_NAME();
--BZLOQAF.RC57230--
--To create an consumer account set the role to orgadmin--
USE ROLE ORGADMIN;
--Creating a consumer account--
CREATE ACCOUNT my_consumer_account
  ADMIN_NAME = 'admin'
  ADMIN_PASSWORD = 'SecurePassword123!'
  EMAIL = 'poojasridhar7@gmail.com'
  MUST_CHANGE_PASSWORD = false
  EDITION = ENTERPRISE;
--Details of that consumer account--
/* Account Name: MY_CONSUMER_ACCOUNT
Account Locator: BD46956
Full Identifier: BZLOQAF.MY_CONSUMER_ACCOUNT
URL: https://bzloqaf-my_consumer_account.snowflakecomputing.com */

-- Add Consumer Account --
ALTER SHARE ORDERS_SHARE ADD ACCOUNT= BZLOQAF.MY_CONSUMER_ACCOUNT;

--Contents to be written on consumer account--
-- Create database from share --

--Show all shares (consumer & producers)--
SHOW SHARES;
--See details on share--
DESC SHARE BZLOQAF.RC57230.ORDERS_SHARE;
--Create a database in consumer account using the share--
CREATE DATABASE DATA_SHARE_DB FROM SHARE BZLOQAF.RC57230.ORDERS_SHARE;
--Validate table access--
SELECT * FROM  DATA_SHARE_DB.PUBLIC.ORDERS;
--Setup virtual warehouse--
CREATE WAREHOUSE READ_WH WITH
WAREHOUSE_SIZE='X-SMALL'
AUTO_SUSPEND = 180
AUTO_RESUME = TRUE
INITIALLY_SUSPENDED = TRUE;
