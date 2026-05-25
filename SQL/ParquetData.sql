--Option1 : Declaring a file format while creating the stage--
--Creating a file format--
CREATE OR REPLACE FILE FORMAT STAGING_DB.FILE_FORMATS.PARQUET_FORMAT
    TYPE = 'parquet';
--Create a stage to upload a file--    
CREATE OR REPLACE STAGE STAGING_DB.EXTERNAL_STAGES.PARQUETSTAGE
    url = 's3://snowflakeparquetdemo'   
    FILE_FORMAT = STAGING_DB.FILE_FORMATS.PARQUET_FORMAT;
--List the files in staging db--
LIST  @STAGING_DB.EXTERNAL_STAGES.PARQUETSTAGE;   
--Show the contents of a file--    
SELECT * FROM @STAGING_DB.EXTERNAL_STAGES.PARQUETSTAGE;
/* Above commands - The file format is attached to the stage at creation time (FILE_FORMAT = ... in CREATE STAGE)
You can query with just SELECT * FROM @stage; — no need to specify format */
/* Below commands - The stage is created without a file format
You must specify the format at query time using (file_format => ...) every time you query */
--Option2 : Declaring the file format for every time you query--
--Creating a stage--
CREATE OR REPLACE STAGE STAGING_DB.EXTERNAL_STAGES.PARQUETSTAGE
    url = 's3://snowflakeparquetdemo';
--This queries Parquet data directly from the stage, specifying the file format inline at query time--
--This is useful when the stage doesn't have a file format attached to it, so you provide it per-query instead--
SELECT * 
FROM @STAGING_DB.EXTERNAL_STAGES.PARQUETSTAGE
(file_format => 'STAGING_DB.FILE_FORMATS.PARQUET_FORMAT');
--Quotes can be omitted in case of the current namespace(if the db and table name specified on top right corner)--
USE STAGING_DB.FILE_FORMATS;
--This queries Parquet data from the stage, with the file format specified without quotes--
SELECT * 
FROM @STAGING_DB.EXTERNAL_STAGES.PARQUETSTAGE
(file_format => STAGING_DB.FILE_FORMATS.PARQUET_FORMAT);
--Quotes = safe fallback. No quotes = cleaner but depends on namespace or full path.--
--Creating a stage--
CREATE OR REPLACE STAGE STAGING_DB.EXTERNAL_STAGES.PARQUETSTAGE
    url = 's3://snowflakeparquetdemo'   
    FILE_FORMAT = STAGING_DB.FILE_FORMATS.PARQUET_FORMAT;
--Returns each Parquet column (index, cat_id, date, dept_id, item_id, state_id, store_id, value) as separate columns instead of one blob of VARIANT data--
SELECT 
$1:__index_level_0__,
$1:cat_id,
$1:date,
$1:"__index_level_0__",
$1:"cat_id",
$1:"d",
$1:"date",
$1:"dept_id",
$1:"id",
$1:"item_id",
$1:"state_id",
$1:"store_id",
$1:"value"
FROM @STAGING_DB.EXTERNAL_STAGES.PARQUETSTAGE;
/* Syntax	            When needed
$1:cat_id	            Simple names (works without quotes)
$1:"__index_level_0__"	Names with special characters or case-sensitivity */
--Date conversion--   
SELECT DATE(365*60*60*24);
--Querying with conversions and aliases-- 
SELECT 
$1:__index_level_0__::int as index_level,
$1:cat_id::VARCHAR(50) as category,
DATE($1:date::int ) as Date,
$1:"dept_id"::VARCHAR(50) as Dept_ID,
$1:"id"::VARCHAR(50) as ID,
$1:"item_id"::VARCHAR(50) as Item_ID,
$1:"state_id"::VARCHAR(50) as State_ID,
$1:"store_id"::VARCHAR(50) as Store_ID,
$1:"value"::int as value
FROM @STAGING_DB.EXTERNAL_STAGES.PARQUETSTAGE;
/* Summary:
Option 1 — Attach file format to stage → query simply with SELECT * FROM @stage
Option 2 — Create stage without format → specify format each query with (file_format => ...)
Column extraction — Use $1:column_name to pull individual fields from the VARIANT blob
Final query — Properly converts each column to the right data type (::int, ::VARCHAR, DATE()) with aliases for clean output */
--Adding metadata details like filename, timestamp, rownumber--
SELECT 
$1:__index_level_0__::int as index_level,
$1:cat_id::VARCHAR(50) as category,
DATE($1:date::int ) as Date,
$1:"dept_id"::VARCHAR(50) as Dept_ID,
$1:"id"::VARCHAR(50) as ID,
$1:"item_id"::VARCHAR(50) as Item_ID,
$1:"state_id"::VARCHAR(50) as State_ID,
$1:"store_id"::VARCHAR(50) as Store_ID,
$1:"value"::int as value,
METADATA$FILENAME as FILENAME,
METADATA$FILE_ROW_NUMBER as ROWNUMBER,
TO_TIMESTAMP_NTZ(current_timestamp) as LOAD_DATE
FROM @STAGING_DB.EXTERNAL_STAGES.PARQUETSTAGE;
--Command to display the time without timezone--
SELECT TO_TIMESTAMP_NTZ(current_timestamp);
--Creating a destination table--
CREATE OR REPLACE TABLE my_first_db.PUBLIC.PARQUET_DATA (
    ROW_NUMBER int,
    index_level int,
    cat_id VARCHAR(50),
    date date,
    dept_id VARCHAR(50),
    id VARCHAR(50),
    item_id VARCHAR(50),
    state_id VARCHAR(50),
    store_id VARCHAR(50),
    value int,
    Load_date timestamp default TO_TIMESTAMP_NTZ(current_timestamp));
--Load the data into the table--
COPY INTO  my_first_db.PUBLIC.PARQUET_DATA
    FROM (SELECT 
            METADATA$FILE_ROW_NUMBER,
            $1:__index_level_0__::int,
            $1:cat_id::VARCHAR(50),
            DATE($1:date::int ),
            $1:"dept_id"::VARCHAR(50),
            $1:"id"::VARCHAR(50),
            $1:"item_id"::VARCHAR(50),
            $1:"state_id"::VARCHAR(50),
            $1:"store_id"::VARCHAR(50),
            $1:"value"::int,
            TO_TIMESTAMP_NTZ(current_timestamp)
        FROM @STAGING_DB.EXTERNAL_STAGES.PARQUETSTAGE);

select * from my_first_db.PUBLIC.PARQUET_DATA;