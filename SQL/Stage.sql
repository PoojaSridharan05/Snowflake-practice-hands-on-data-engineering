--Creating a Db for stage--
CREATE OR REPLACE DATABASE STAGING_DB;
--Creating a schema for the above db--
CREATE OR REPLACE SCHEMA external_stages;
--Creating external stage--
CREATE OR REPLACE STAGE STAGING_DB.external_stages.aws_stage
    url='s3://bucketsnowflakes3'
    credentials=(aws_key_id='ABCD_DUMMY_ID' aws_secret_key='1234abcd_key');
--Description ofan existing stage--
DESC stage STAGING_DB.external_stages.aws_stage;
--Alter an existing stage--
ALTER stage aws_stage
 set credentials = (aws_key_id='XYZ_DUMMY_ID' aws_secret_key='987xyz');
--When the bucket is public we dont have to give the credentials--
create or replace stage STAGING_DB.external_stages.aws_stage
 url = 's3://bucketsnowflakes3';
--List the files in the current stage--
list @aws_stage;
