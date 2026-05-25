--Creating a table to copy the data--
CREATE or replace table MY_FIRST_DB.PUBLIC.orders
(
    ORDER_ID VARCHAR(30),
    AMOUNT INT,
    PROFIT INT,
    QUANTITY INT,
    CATEGORY VARCHAR(30),
    SUBCATEGORY VARCHAR(30)
);
--Print the contents of the table--
select * from my_first_db.public.orders;
--Copy command with fully qualified stage command(copies all the files from stage)--
copy into my_first_db.public.orders
 from @STAGING_DB.external_stages.aws_stage
 file_format = (type = csv field_delimiter = ',' skip_header = 1);
--List the files in stage--
LIST @STAGING_DB.external_stages.aws_stage
--We have to specify which file should be loaded using copy command--
copy into my_first_db.public.orders
 from @STAGING_DB.external_stages.aws_stage
 file_format = (type = csv field_delimiter = ',' skip_header = 1)
 files = ('OrderDetails.csv');
--Copy command with pattern for file names--
copy into my_first_db.public.orders
 from @STAGING_DB.external_stages.aws_stage
 file_format = (type = csv field_delimiter = ',' skip_header = 1)
 pattern = '.*Oder.*';
