--This query retrieves your Snowflake account's daily storage usage ordered by most recent date first.--
SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.STORAGE_USAGE ORDER BY USAGE_DATE DESC;
--This query retrieves per-table storage metrics from the  view--
SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.TABLE_STORAGE_METRICS;
--Query time travel storage--
SELECT 	ID, 
		TABLE_NAME, 
		TABLE_SCHEMA,
        TABLE_CATALOG,
		ACTIVE_BYTES / (1024*1024*1024) AS STORAGE_USED_GB,
		TIME_TRAVEL_BYTES / (1024*1024*1024) AS TIME_TRAVEL_STORAGE_USED_GB
FROM SNOWFLAKE.ACCOUNT_USAGE.TABLE_STORAGE_METRICS
ORDER BY STORAGE_USED_GB DESC,TIME_TRAVEL_STORAGE_USED_GB DESC;

/* 1024 is the number of bytes in a kilobyte (KB). The conversion chain is:
1 KB = 1024 bytes
1 MB = 1024 KB
1 GB = 1024 MB
So 1024 * 1024 * 1024 = 1,073,741,824 bytes = 1 GB. */