SHOW TASKS;

USE TASK_DB;
--Use the table function "TASK_HISTORY()" gives us the full history--
select *
  from table(information_schema.task_history())
  order by scheduled_time desc;
--See results for a specific Task in a given time--
select *
from table(information_schema.task_history(
    scheduled_time_range_start=>dateadd('hour',-4,current_timestamp()),
    result_limit => 5,
    task_name=>'CUSTOMER_INSERT2'));
--See results for a given time period--
select *
  from table(information_schema.task_history(
    scheduled_time_range_start=>to_timestamp_ltz('2026-05-20 15:28:32.776 -0700'),
    scheduled_time_range_end=>to_timestamp_ltz('2026-05-20 16:01:19.185 -0700')));  
--Gives us the current timestamp--  
SELECT TO_TIMESTAMP_LTZ(CURRENT_TIMESTAMP) ;
  
  
 