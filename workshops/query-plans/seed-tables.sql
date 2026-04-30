-- highlight ALL and then click 'Run selected' button
--  this should take approximately 6 minutes to run

DROP SCHEMA IF EXISTS tmp_cat.query_plans CASCADE;
CREATE SCHEMA tmp_cat.query_plans;
USE tmp_cat.query_plans;

CREATE TABLE logs_daily_rollup_orc (
 event_time      TIMESTAMP,
 ip_address      VARCHAR(15),
 app_name        VARCHAR(25),
 process_id      SMALLINT,
 log_type        VARCHAR(15),
 log_level       VARCHAR(15),
 message_id      VARCHAR(15),
 message_details VARCHAR(555)
) WITH ( 
 type = 'HIVE',
 external_location = 's3://starburst-tutorials/serverlogs/logs_daily_rollup_orc/',
 format = 'ORC'
);

CREATE TABLE logs_daily_rollup_orc_stats (
 event_time      TIMESTAMP,
 ip_address      VARCHAR(15),
 app_name        VARCHAR(25),
 process_id      SMALLINT,
 log_type        VARCHAR(15),
 log_level       VARCHAR(15),
 message_id      VARCHAR(15),
 message_details VARCHAR(555)
) WITH ( 
 type = 'HIVE',
 external_location = 's3://starburst-tutorials/serverlogs/logs_daily_rollup_orc/',
 format = 'ORC'
);
-- 1.5 mins to run
ANALYZE logs_daily_rollup_orc_stats;

-- 4.5 mins to run
CREATE TABLE logs_iceberg WITH(type='iceberg', format_version=3)
AS SELECT * FROM logs_daily_rollup_orc_stats;
