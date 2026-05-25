--1st step: Load Raw JSON--
CREATE OR REPLACE stage STAGING_DB.EXTERNAL_STAGES.JSONSTAGE
     url='s3://bucketsnowflake-jsondemo';
CREATE OR REPLACE file format STAGING_DB.FILE_FORMATS.JSONFORMAT
    TYPE = JSON;
CREATE OR REPLACE table my_first_db.PUBLIC.JSON_RAW (
    raw_file variant);
COPY INTO my_first_db.PUBLIC.JSON_RAW
    FROM @STAGING_DB.EXTERNAL_STAGES.JSONSTAGE
    file_format= STAGING_DB.FILE_FORMATS.JSONFORMAT
    files = ('HR_data.json');
SELECT * FROM my_first_db.PUBLIC.JSON_RAW;
--2nd step: Parse & Analyse Raw JSON--
--Selecting attribute/for a single column without any proper format--
SELECT RAW_FILE:city FROM my_first_db.PUBLIC.JSON_RAW;
--Another way of selecting single column/attribute--
SELECT $1:first_name FROM my_first_db.PUBLIC.JSON_RAW;
--Selecting attribute/single column - string formattted way--
SELECT RAW_FILE:first_name::string as first_name  FROM my_first_db.PUBLIC.JSON_RAW;
--Selecting attribute/single column - int formattted way--
SELECT RAW_FILE:id::int as id  FROM my_first_db.PUBLIC.JSON_RAW;
--Professional way of formatting the whole table for multiple columns--
SELECT 
    RAW_FILE:id::int as id,  
    RAW_FILE:first_name::STRING as first_name,
    RAW_FILE:last_name::STRING as last_name,
    RAW_FILE:gender::STRING as gender
FROM my_first_db.PUBLIC.JSON_RAW;
--3rd step : Handling nested data--
--Check if the table has nested data--
SELECT RAW_FILE:job as job  FROM my_first_db.PUBLIC.JSON_RAW;
--Selecting a specific column--
SELECT 
      RAW_FILE:job.salary::INT as salary
FROM my_first_db.PUBLIC.JSON_RAW;
--Selecting multiple columns along with nested data--
SELECT 
    RAW_FILE:first_name::STRING as first_name,
    RAW_FILE:job.salary::INT as salary,
    RAW_FILE:job.title::STRING as title
FROM my_first_db.PUBLIC.JSON_RAW;
--4th step : Handling arreys--
--Listing the previous company names in key value pair--
SELECT
    RAW_FILE:prev_company as prev_company
FROM my_first_db.PUBLIC.JSON_RAW;
--This selects the 2nd element from the previous company--
SELECT
    RAW_FILE:prev_company[1]::STRING as prev_company
FROM my_first_db.PUBLIC.JSON_RAW;
--This returns the number of elements in previous company array--
SELECT
    ARRAY_SIZE(RAW_FILE:prev_company) as prev_company
FROM my_first_db.PUBLIC.JSON_RAW;
--MANUALLY flatterns the previous company array by using union all to combine the 1st and 2nd elements into separate rows--
--ORDER BY id - sorts so each person's companies appear together--
SELECT 
    RAW_FILE:id::int as id,  
    RAW_FILE:first_name::STRING as first_name,
    RAW_FILE:prev_company[0]::STRING as prev_company
FROM my_first_db.PUBLIC.JSON_RAW
UNION ALL 
SELECT 
    RAW_FILE:id::int as id,  
    RAW_FILE:first_name::STRING as first_name,
    RAW_FILE:prev_company[1]::STRING as prev_company
FROM my_first_db.PUBLIC.JSON_RAW
ORDER BY id;
--5th Step - Flattern heirarchical data--
--Gives the list of languages spoken in a raw varient value--
SELECT 
    RAW_FILE:spoken_languages as spoken_languages
FROM my_first_db.PUBLIC.JSON_RAW;
--List the whole json file--
SELECT * FROM my_first_db.PUBLIC.JSON_RAW;
--Lists the number of languages spoken--
SELECT 
     array_size(RAW_FILE:spoken_languages) as spoken_languages
FROM my_first_db.PUBLIC.JSON_RAW;
--Returns each person's name and the count of how many languages they speak--
SELECT 
     RAW_FILE:first_name::STRING as first_name,
     array_size(RAW_FILE:spoken_languages) as spoken_languages
FROM my_first_db.PUBLIC.JSON_RAW;
--Returns the first object like (language - english, level - advanced)in one column--
SELECT 
    RAW_FILE:spoken_languages[0] as First_language
FROM my_first_db.PUBLIC.JSON_RAW;
--Returns the firstname and the first object (Language - english, level - advanced) in one column--
SELECT 
    RAW_FILE:first_name::STRING as first_name,
    RAW_FILE:spoken_languages[0] as First_language
FROM my_first_db.PUBLIC.JSON_RAW;
--Returns the firstname, firstlanguage, level spoken in separate columns--
SELECT 
    RAW_FILE:first_name::STRING as First_name,
    RAW_FILE:spoken_languages[0].language::STRING as First_language,
    RAW_FILE:spoken_languages[0].level::STRING as Level_spoken
FROM my_first_db.PUBLIC.JSON_RAW;
--Manually flatterns the spoken languagues and their level in separate rows for each id and union all data into one table--
SELECT 
    RAW_FILE:id::int as id,
    RAW_FILE:first_name::STRING as First_name,
    RAW_FILE:spoken_languages[0].language::STRING as First_language,
    RAW_FILE:spoken_languages[0].level::STRING as Level_spoken
FROM my_first_db.PUBLIC.JSON_RAW
UNION ALL 
SELECT 
    RAW_FILE:id::int as id,
    RAW_FILE:first_name::STRING as First_name,
    RAW_FILE:spoken_languages[1].language::STRING as First_language,
    RAW_FILE:spoken_languages[1].level::STRING as Level_spoken
FROM my_first_db.PUBLIC.JSON_RAW
UNION ALL 
SELECT 
    RAW_FILE:id::int as id,
    RAW_FILE:first_name::STRING as First_name,
    RAW_FILE:spoken_languages[2].language::STRING as First_language,
    RAW_FILE:spoken_languages[2].level::STRING as Level_spoken
FROM my_first_db.PUBLIC.JSON_RAW
ORDER BY ID;
--Moniter the warehouse--
SHOW RESOURCE MONITORS;
ALTER RESOURCE MONITOR MONTHLY_ACCOUNT_BUDGET 
  TRIGGERS ON 100 PERCENT DO NOTIFY;
--Alternative to the manuall union all aproach--
--flatterns the spoken languagues and their level in separate rows for each id using flattern command--
select
      RAW_FILE:first_name::STRING as First_name,
    f.value:language::STRING as First_language,
   f.value:level::STRING as Level_spoken
from my_first_db.PUBLIC.JSON_RAW, table(flatten(RAW_FILE:spoken_languages)) f;
--6th step : According to the use case create a table for the previous command if needed--
--Option 1: CREATE TABLE AS--
CREATE OR REPLACE TABLE Languages AS
select
      RAW_FILE:first_name::STRING as First_name,
    f.value:language::STRING as First_language,
   f.value:level::STRING as Level_spoken
from my_first_db.PUBLIC.JSON_RAW, table(flatten(RAW_FILE:spoken_languages)) f;
--Show the result of language table--
SELECT * FROM Languages;
--Delete the table and keep the structure alone--
truncate table languages;
--Insert the data into the languages table--
--Option 2: INSERT INTO(another way of previous command)--
INSERT INTO Languages
select
      RAW_FILE:first_name::STRING as First_name,
    f.value:language::STRING as First_language,
   f.value:level::STRING as Level_spoken
from my_first_db.PUBLIC.JSON_RAW, table(flatten(RAW_FILE:spoken_languages)) f;
--Display after inserting the data--
SELECT * FROM Languages;
