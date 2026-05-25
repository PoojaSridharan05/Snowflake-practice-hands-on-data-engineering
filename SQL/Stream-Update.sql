--Example1 Display the tables--
SELECT * FROM SALES_RAW_STAGING;          
SELECT * FROM SALES_STREAM;
--Update a data from banana to potato--
UPDATE SALES_RAW_STAGING
SET PRODUCT ='Potato' WHERE PRODUCT = 'Banana';

SELECT * FROM SALES_STREAM;
--Do the changes using merge into--
merge into SALES_FINAL_TABLE F      -- Target table to merge changes from source table
using SALES_STREAM S                -- Stream that has captured the changes
   on  f.id = s.id                 
when matched 
    and S.METADATA$ACTION ='INSERT'
    and S.METADATA$ISUPDATE ='TRUE'        -- Indicates the record has been updated 
    then update 
    set f.product = s.product,
        f.price = s.price,
        f.amount= s.amount,
        f.store_id=s.store_id;
--Display the tables--
SELECT * FROM SALES_FINAL_TABLE;
SELECT * FROM SALES_RAW_STAGING;          
SELECT * FROM SALES_STREAM;
--Example 2--
UPDATE SALES_RAW_STAGING
SET PRODUCT ='Green apple' WHERE PRODUCT = 'Apple';
--Do the merge--
merge into SALES_FINAL_TABLE F      -- Target table to merge changes from source table
using SALES_STREAM S                -- Stream that has captured the changes
   on  f.id = s.id                 
when matched 
    and S.METADATA$ACTION ='INSERT'
    and S.METADATA$ISUPDATE ='TRUE'        -- Indicates the record has been updated 
    then update 
    set f.product = s.product,
        f.price = s.price,
        f.amount= s.amount,
        f.store_id=s.store_id;
--Display the tables--
SELECT * FROM SALES_FINAL_TABLE;
SELECT * FROM SALES_RAW_STAGING;     
SELECT * FROM SALES_STREAM;


