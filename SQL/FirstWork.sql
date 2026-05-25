select * from snowflake_sample_data.tpch_sf1.customer limit 100;
--Creating a Warehouse--
use role sysadmin;
create or replace warehouse First_WH with 
  warehouse_size = 'XSmall'
  Min_cluster_count = 1
  Max_cluster_count = 3
  Auto_Suspend = 600
  Auto_resume = TRUE
  Comment = "This is my First Warehouse";

--Alter an existing warehouse--
alter warehouse FIRST_WH set Auto_suspend = 300;
--Drop an existing warehouse--
DROP warehouse FIRST_WH;
--Creating a DB--
Create or Replace database My_First_DB;
--Creating a table--
CREATE  or replace TABLE MY_FIRST_DB.PUBLIC.LOAN_PAYMENT (
  "Loan_ID" STRING,
  "loan_status" STRING,
  "Principal" STRING,
  "terms" STRING,
  "effective_date" STRING,
  "due_date" STRING,
  "paid_off_time" STRING,
  "past_due_days" STRING,
  "age" STRING,
  "education" STRING,
  "Gender" STRING);
use database My_First_DB;
select * from MY_FIRST_DB.PUBLIC.LOAN_PAYMENT;
--Load the data to table through s3 bucket--
 COPY INTO LOAN_PAYMENT
    FROM s3://bucketsnowflakes3/Loan_payments_data.csv
    file_format = (type = csv 
                   field_delimiter = ',' 
                   skip_header=1);
    