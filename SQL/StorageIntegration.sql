--Create storage integration object--
create or replace storage integration s3_int
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = S3
  ENABLED = TRUE 
  STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::445160884483:role/snowflake-access-role'
  STORAGE_ALLOWED_LOCATIONS = ('s3://snowflakebucketarg2909/csv/', 's3://snowflakebucketarg2909/json/')
   COMMENT = 'This an optional comment';
--See storage integration properties to fetch external_id so we can update it in S3--
DESC integration s3_int;
--Create table first--
CREATE OR REPLACE TABLE my_first_db.PUBLIC.movie_titles (
  show_id STRING,
  type STRING,
  title STRING,
  director STRING,
  cast STRING,
  country STRING,
  date_added STRING,
  release_year STRING,
  rating STRING,
  duration STRING,
  listed_in STRING,
  description STRING );
--Create file format object--
CREATE OR REPLACE file format STAGING_DB.file_formats.csv_fileformat
    type = csv
    field_delimiter = ','
    skip_header = 1
    null_if = ('NULL','null')
    empty_field_as_null = TRUE;
--Create stage object with integration object & file format object--
CREATE OR REPLACE stage STAGING_DB.external_stages.csv_folder
    URL = 's3://snowflakebucketarg2909/csv/'
    STORAGE_INTEGRATION = s3_int
    FILE_FORMAT = STAGING_DB.file_formats.csv_fileformat;
--Use Copy command--       
COPY INTO my_first_db.PUBLIC.movie_titles
    FROM @STAGING_DB.external_stages.csv_folder;
--Create file format object--
CREATE OR REPLACE file format STAGING_DB.file_formats.csv_fileformat
    type = csv
    field_delimiter = ','
    skip_header = 1
    null_if = ('NULL','null')
    empty_field_as_null = TRUE    
    FIELD_OPTIONALLY_ENCLOSED_BY = '"';  
--display the table contents--
SELECT * FROM my_first_db.PUBLIC.movie_titles;
--Taming the JSON file--
CREATE OR REPLACE file format STAGING_DB.file_formats.json_fileformat
    type = json;
--Create stage object with integration object & file format object--
CREATE OR REPLACE stage STAGING_DB.external_stages.json_folder
    URL = 's3://snowflakebucketarg2909/json/'
    STORAGE_INTEGRATION = s3_int
    FILE_FORMAT = STAGING_DB.file_formats.json_fileformat;
--First query from S3 Bucket-- 
SELECT * FROM @STAGING_DB.external_stages.json_folder;
--Introduce columns--
SELECT 
$1:asin,
$1:helpful,
$1:overall,
$1:reviewText,
$1:reviewTime,
$1:reviewerID,
$1:reviewTime,
$1:reviewerName,
$1:summary,
$1:unixReviewTime
FROM @STAGING_DB.external_stages.json_folder;
--Format columns & use DATE function--
SELECT 
$1:asin::STRING as ASIN,
$1:helpful as helpful,
$1:overall as overall,
$1:reviewText::STRING as reviewtext,
$1:reviewTime::STRING,
$1:reviewerID::STRING,
$1:reviewTime::STRING,
$1:reviewerName::STRING,
$1:summary::STRING,
DATE($1:unixReviewTime::int) as Revewtime
FROM @STAGING_DB.external_stages.json_folder;
--Format columns & handle custom date--
SELECT 
$1:asin::STRING as ASIN,
$1:helpful as helpful,
$1:overall as overall,
$1:reviewText::STRING as reviewtext,
DATE_FROM_PARTS( <year>, <month>, <day> )
$1:reviewTime::STRING,
$1:reviewerID::STRING,
$1:reviewTime::STRING,
$1:reviewerName::STRING,
$1:summary::STRING,
DATE($1:unixReviewTime::int) as Revewtime
FROM @STAGING_DB.external_stages.json_folder;
--Use DATE_FROM_PARTS and see another difficulty--
SELECT 
$1:asin::STRING as ASIN,
$1:helpful as helpful,
$1:overall as overall,
$1:reviewText::STRING as reviewtext,
DATE_FROM_PARTS( RIGHT($1:reviewTime::STRING,4), LEFT($1:reviewTime::STRING,2), SUBSTRING($1:reviewTime::STRING,4,2) ),
$1:reviewerID::STRING,
$1:reviewTime::STRING,
$1:reviewerName::STRING,
$1:summary::STRING,
DATE($1:unixReviewTime::int) as unixRevewtime
FROM @STAGING_DB.external_stages.json_folder;
--Use DATE_FROM_PARTS and handle the case difficulty--
SELECT 
$1:asin::STRING as ASIN,
$1:helpful as helpful,
$1:overall as overall,
$1:reviewText::STRING as reviewtext,
DATE_FROM_PARTS( 
  RIGHT($1:reviewTime::STRING,4), 
  LEFT($1:reviewTime::STRING,2), 
  CASE WHEN SUBSTRING($1:reviewTime::STRING,5,1)=',' 
        THEN SUBSTRING($1:reviewTime::STRING,4,1) ELSE SUBSTRING($1:reviewTime::STRING,4,2) END),
$1:reviewerID::STRING,
$1:reviewTime::STRING,
$1:reviewerName::STRING,
$1:summary::STRING,
DATE($1:unixReviewTime::int) as UnixRevewtime
FROM @STAGING_DB.external_stages.json_folder;
--Create destination table--
CREATE OR REPLACE TABLE OUR_FIRST_DB.PUBLIC.reviews (
asin STRING,
helpful STRING,
overall STRING,
reviewtext STRING,
reviewtime DATE,
reviewerid STRING,
reviewername STRING,
summary STRING,
unixreviewtime DATE
);
--Copy transformed data into destination table--
COPY INTO OUR_FIRST_DB.PUBLIC.reviews
    FROM (SELECT 
$1:asin::STRING as ASIN,
$1:helpful as helpful,
$1:overall as overall,
$1:reviewText::STRING as reviewtext,
DATE_FROM_PARTS( 
  RIGHT($1:reviewTime::STRING,4), 
  LEFT($1:reviewTime::STRING,2), 
  CASE WHEN SUBSTRING($1:reviewTime::STRING,5,1)=',' 
        THEN SUBSTRING($1:reviewTime::STRING,4,1) ELSE SUBSTRING($1:reviewTime::STRING,4,2) END),
$1:reviewerID::STRING,
$1:reviewerName::STRING,
$1:summary::STRING,
DATE($1:unixReviewTime::int) Revewtime
FROM @STAGING_DB.external_stages.json_folder);
--Validate results--
SELECT * FROM OUR_FIRST_DB.PUBLIC.reviews;   