--Creating a transient table--
CREATE OR REPLACE TRANSIENT DATABASE SAMPLING_DB;
--Creating a view with sample row and seed--
CREATE OR REPLACE VIEW ADDRESS_SAMPLE
AS 
SELECT * FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF10TCL.CUSTOMER_ADDRESS 
SAMPLE ROW (1) SEED(27);
--Try with a larger table than the above table--
CREATE OR REPLACE VIEW ADDRESS_SAMPLE
AS 
SELECT * FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.CUSTOMER_ADDRESS 
SAMPLE ROW (1) SEED(27);
--Display the table--
SELECT * FROM ADDRESS_SAMPLE;
-- calculates the percentage distribution of each location type--
--(COUNT(*)/500284*100)- divides by the total row count of the full table and multiplies by 100 to get a percentage--
SELECT CA_LOCATION_TYPE, COUNT(*)/500284*100
FROM ADDRESS_SAMPLE
GROUP BY CA_LOCATION_TYPE;
--Now try with different percentage for sample row--
CREATE OR REPLACE VIEW ADDRESS_SAMPLE
AS 
SELECT * FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.CUSTOMER_ADDRESS 
SAMPLE ROW (10) SEED(27);
--Display the table and check the row count--
SELECT * FROM ADDRESS_SAMPLE;
-- tells you the proportion of each location type within the sample.
SELECT CA_LOCATION_TYPE, COUNT(*)/4998600*100
FROM ADDRESS_SAMPLE
GROUP BY CA_LOCATION_TYPE;

--Do it with sample system--
SELECT * FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.CUSTOMER_ADDRESS 
SAMPLE SYSTEM (1) SEED(23);
--Try with a different sample system percentage--
SELECT * FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF100TCL.CUSTOMER_ADDRESS 
SAMPLE SYSTEM (10) SEED(23);