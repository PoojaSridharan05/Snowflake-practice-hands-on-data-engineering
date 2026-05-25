show shares;
--See details on share--
DESC SHARE BZLOQAF.RC57230.VIEW_SHARE;
--Create a database in consumer account using the share--
CREATE DATABASE VIEW_DB FROM SHARE BZLOQAF.RC57230.VIEW_SHARE;
--Validate table access--
SELECT * FROM VIEW_DB.PUBLIC.CUSTOMER_VIEW_SECURE;