-- Create Reader Account --
CREATE MANAGED ACCOUNT tech_joy_account
ADMIN_NAME = tech_joy_admin,
ADMIN_PASSWORD = 'Gulab$@12345678',
TYPE = READER;
--Make sure to have selected the role of accountadmin--
--Show accounts--
SHOW MANAGED ACCOUNTS;
-- Share the data -- 
ALTER SHARE ORDERS_SHARE 
ADD ACCOUNT = DF48575;
--No restriction should be given--
ALTER SHARE ORDERS_SHARE 
ADD ACCOUNT =  <reader-account-id>
SHARE_RESTRICTIONS=false;


--Commands to be given on consumer account--
-- Create database from share --
--Show all shares (consumer & producers)--
SHOW SHARES;
--See details on share--
DESC SHARE QNA46172.ORDERS_SHARE;
--Create a database in consumer account using the share--
CREATE DATABASE DATA_SHARE_DB FROM SHARE <account_name_producer>.ORDERS_SHARE;
--Validate table access--
SELECT * FROM  DATA_SHARE_DB.PUBLIC.ORDERS;
--Setup virtual warehouse--
CREATE WAREHOUSE READ_WH WITH
WAREHOUSE_SIZE='X-SMALL'
AUTO_SUSPEND = 180
AUTO_RESUME = TRUE
INITIALLY_SUSPENDED = TRUE;
--Create and setup users--
--Create user--
CREATE USER Myriam PASSWORD = 'difficult-password=123';
--Grant usage on warehouse--
GRANT USAGE ON WAREHOUSE READ_WH TO ROLE PUBLIC;
--Granting privileges on a shared database for other users--
GRANT IMPORTED PRIVILEGES ON DATABASE DATA_SHARE_DB TO ROLE PUBLIC;
--Commands to be written on Myriam account--
select * from DATA_SHARE_DB.PUBLIC.ORDERS;

--Commands on this main account--
SHOW SHARES;
--Create share object--
CREATE OR REPLACE SHARE COMEPLETE_SCHEMA_SHARE;
--Grant usage on dabase & schema--
GRANT USAGE ON DATABASE OUR_FIRST_DB TO SHARE COMEPLETE_SCHEMA_SHARE;
GRANT USAGE ON SCHEMA OUR_FIRST_DB.PUBLIC TO SHARE COMEPLETE_SCHEMA_SHARE;
--Grant select on all tables--
GRANT SELECT ON ALL TABLES IN SCHEMA OUR_FIRST_DB.PUBLIC TO SHARE COMEPLETE_SCHEMA_SHARE;
GRANT SELECT ON ALL TABLES IN DATABASE OUR_FIRST_DB TO SHARE COMEPLETE_SCHEMA_SHARE;
--Add account to share--
ALTER SHARE COMEPLETE_SCHEMA_SHARE
ADD ACCOUNT=KAA74702;
