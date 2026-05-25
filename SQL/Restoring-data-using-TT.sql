--Setting up table--
CREATE OR REPLACE TABLE MY_FIRST_DB.public.test (
   id int,
   first_name string,
  last_name string,
  email string,
  gender string,
  Job string,
  Phone string);
--Copy command--
COPY INTO MY_FIRST_DB.public.test
from @STAGING_DB.external_stages.time_travel_stage
files = ('customers.csv');
--Display the table--
-- 01c43cd7-0005-7438-000d-77de000ec10e --
SELECT * FROM MY_FIRST_DB.public.test;
--Use-case1 : Update data (by mistake) changing the last name to tyson for all the users--
UPDATE MY_FIRST_DB.public.test
SET LAST_NAME = 'Tyson';
--Use case2: Changing the jon role to data analyst for all the users--
UPDATE MY_FIRST_DB.public.test
SET JOB = 'Data Analyst';
--Display the correct table by using query id--
SELECT * FROM MY_FIRST_DB.public.test before (statement => '01c43cd7-0005-7438-000d-77de000ec10e');

--Bad method : By creating the table for each mistake/update--
--First you didnt fine the last name mistake. you only found the job role mistake and corrected it--
--Then again you have to create the table for the last name mistake--
--The below command is to fix the job title error--
CREATE OR REPLACE TABLE MY_FIRST_DB.public.test as
SELECT * FROM MY_FIRST_DB.public.test before (statement => '01c43cd8-0005-67fe-000d-77de000c2c0a');
--Displaying the fixed job title column of table--
SELECT * FROM MY_FIRST_DB.public.test;
--Fixing the lastname error--
CREATE OR REPLACE TABLE MY_FIRST_DB.public.test as
SELECT * FROM MY_FIRST_DB.public.test before (statement => '01c43cd8-0005-67fe-000d-77de000c2c06');
--Output: (Error)Time travel data is not available for table TEST. The requested time is either beyond the allowed time travel period or before the object creation time.--
--Lesson: Using CREATE OR REPLACE TABLE for restoring data is destructive — it resets time travel history. A safer approach is to use a separate backup table or restore both issues in a single time travel query back to the original state.--

--Good method--
--Setting up table--
CREATE OR REPLACE TABLE MY_FIRST_DB.public.test (
   id int,
   first_name string,
  last_name string,
  email string,
  gender string,
  Job string,
  Phone string);
--Copy command--
COPY INTO MY_FIRST_DB.public.test
from @STAGING_DB.external_stages.time_travel_stage
files = ('customers.csv');
--Display the table--
-- 01c43cd7-0005-7438-000d-77de000ec10e --
SELECT * FROM MY_FIRST_DB.public.test;
--Use-case1 : Update data (by mistake) changing the last name to tyson for all the users--
UPDATE MY_FIRST_DB.public.test
SET LAST_NAME = 'Tyson';
--Use case2: Changing the jon role to data analyst for all the users--
UPDATE MY_FIRST_DB.public.test
SET JOB = 'Data Analyst';

--Changing the mistake for job title in the table--
CREATE OR REPLACE TABLE MY_FIRST_DB.public.test_backup as
SELECT * FROM MY_FIRST_DB.public.test before (statement => '01c43cf5-0005-74c5-000d-77de000ed1a2');
--Truncating the original table--
TRUNCATE MY_FIRST_DB.public.test;
--Inserting the backup table contents into the original table--
INSERT INTO MY_FIRST_DB.public.test
SELECT * FROM MY_FIRST_DB.public.test_backup;
--Displaying the correct job title table--
SELECT * FROM MY_FIRST_DB.public.test; 

--Changing the mistake for lastname in the table--
CREATE OR REPLACE TABLE MY_FIRST_DB.public.test_backup as
SELECT * FROM MY_FIRST_DB.public.test before (statement => '01c43cf5-0005-61ef-000d-77de000e91f6');
--Truncating the original table--
TRUNCATE MY_FIRST_DB.public.test;
--Inserting the backup table contents into the original table--
INSERT INTO MY_FIRST_DB.public.test
SELECT * FROM MY_FIRST_DB.public.test_backup;
--Displaying the correct lastname table--
SELECT * FROM MY_FIRST_DB.public.test; 
--Key takeaway: Using TRUNCATE + INSERT instead of CREATE OR REPLACE preserves the table's time travel history, allowing multiple sequential fixes.--