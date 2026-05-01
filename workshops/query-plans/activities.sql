-- WORKSHOP 
-- Query plans
-- 2026-04-30 


-- Setup and use new schema
--  AFTER selecting aws-us-east-1-free
--    cluster in the pull-down
--
--  **DID YOU CHANGE your-name 
--  **  TO YOUR FIRST & LAST NAME
--  **  IN THE CATALOG SETUP?? 



-- spin up the cluster with simple query
SELECT * FROM tpch.tiny.customer LIMIT 250;



-- verify 3 tables are present (should be in UI, too)
--   IF NOT, rerun the setup scripts
SET SESSION skip_results_cache = true;
USE tmp_cat.query_plans;
SHOW tables;

-- ******* NOTE...
--
-- I'M GOING TO SAY IT 20 TIMES...
--   WE ARE TESTING ON A SINGLE, TINY, AND **FREE** NODE 
--     (even the coordinator is on that same node!!)
--


----------------------------------------------------------
-- EXAMPLE 0 - "seeing" the QP diff ways
----------------------------------------------------------

-- run the following statement
--EXPLAIN --ANALYZE --this line intentionally commented out
SELECT s.name  AS supplier_name, p.brand AS brand_name,
       r.name  AS region_name, count() AS nbr_line_items
       --the region of the customer, not the supplier
FROM
   tpch.tiny.lineitem      AS l
   JOIN tpch.tiny.orders   AS o ON l.orderkey = o.orderkey
   JOIN tpch.tiny.customer AS c ON o.custkey = c.custkey
   JOIN tpch.tiny.nation   AS n ON c.nationkey = n.nationkey
   JOIN tpch.tiny.region   AS r ON n.regionkey = r.regionkey
   JOIN tpch.tiny.part     AS p ON l.partkey = p.partkey
   JOIN tpch.tiny.supplier AS s ON l.suppkey = s.suppkey
GROUP BY ROLLUP (s.name, p.brand, r.name)
HAVING count() > 650
ORDER BY s.name, p.brand, r.name;

-- navigate around UI to see the query plan a few diff ways...
--
-- then run it twice more ucommented these bits from the top
--   EXPLAIN
--   EXPLAIN ANALYZE
--
-- the GOAL is to just SEE where the QP surfaces



----------------------------------------------------------
-- EXAMPLE 1 - estimates, table scan, all cols accessed
----------------------------------------------------------

-- run the following statement
EXPLAIN 
SELECT *
  FROM logs_daily_rollup_orc;

-- NOTICE IN OUTPUT
--  - Trino is the engine (first line)
--      Trino version: 480-galaxy-20260403-u89-ga0068d26ad6
--      ^^^^^          >>>>>>>>>>
--  - Single stage (0 is last to run) and it is reading data
--      Fragment 0 [SOURCE]
--      ^^^^^^^^^^  ^^^^^^
--  - Full scan of all rows
--      TableScan[table = tmp_cat:query_plans:logs_daily_rollup_orc]
--      ^^^^^^^^^                             >>>>>>>>>>>>>>>>>>>>>
--  - Reading all cols
--      Layout: Layout: [event_time:timestamp(3), ip_address:varchar(15), app_name:varchar(25), process_id:smallint, log_type:varchar(15), log_level:varchar(15), message_id:varchar(15), message_details:varchar(555)]
--      ^^^^^^   >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
--     AND
--      Output layout: [event_time, ip_address, app_name, process_id, log_type, log_level, message_id, message_details]
--      ^^^^^^^^^^^^^   >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 
--  - No statistics are present
--      Estimates: {rows: ? (?), ...
--      ^^^^^^^^^   >>>>>>>>>>>

-- no estimates as no stats
SHOW STATS FOR logs_daily_rollup_orc;



----------------------------------------------------------
-- EXAMPLE 2 - same data, but with this table has stats
----------------------------------------------------------

-- verify stats are present
SHOW STATS FOR logs_daily_rollup_orc_stats;

-- fills in the estimates for the size of the full table (20GB)
EXPLAIN 
SELECT *
  FROM logs_daily_rollup_orc_stats;

-- NOTICE IN OUTPUT
--  - Stats are present (not that they are all that useful on this simple query)
--      Estimates: {rows: 100778400 (20.01GB) ...
--      ^^^^        >>>>>>>>>>>>>>>  >>>>>>>



----------------------------------------------------------
-- EXAMPLE 3 - analyze to run it and get real #s
----------------------------------------------------------

-- run the following ANALYZE statement
EXPLAIN ANALYZE
SELECT *
  FROM logs_daily_rollup_orc_stats;

-- NOTICE IN OUTPUT
--  - ANALYZE triggered actual execution
--      Execution: 2.10m
--      CPU: 2.26m
--      Physical input time: 3.05m
--  - statistics from the last example are still here (again, not helping a lot in this simple query, but beneficial for richer queries)
--      Estimates: {100778400 (20.01GB) 
--     AND they matched up to actuals
--      Input: 100778400 rows (20.54GB)
--     AND the actual data was compressed
--      Physical input: 4.73GB
--  - splits line up to the # of files present
--      Splits: 210

-- run the following to see the 210 files that made up the splits
SELECT COUNT(distinct("$path")) AS nbr_file, 
       format_number(AVG("$file_size")) AS avg_file_size
  FROM logs_daily_rollup_orc_stats;
-- why TWICE as many as the number of files???
--   see https://www.starburst.io/community/forum/t/number-of-splits-using-the-hive-connector/363



----------------------------------------------------------
-- EXAMPLE 4 - fewer, larger files PLUS ICEBERG 
----------------------------------------------------------

-- has 8 instead of 105 files
SELECT COUNT() AS nbr_files,
       format_number(AVG(file_size_in_bytes)) AS avg_file_size
  FROM "logs_iceberg$files";

-- run the following ANALYZE statement
EXPLAIN ANALYZE
SELECT *
  FROM logs_iceberg;

-- NOTICE IN OUTPUT
--  - finished a bit faster than before 
--      Execution: 1.68m (was 2.10m)
--      CPU: 1.45m (was 2.26m)
--      Physical input time: 2.61m (was 3.05m)
--  - splits are smaller
--      Splits: 40 (was 210)

-- why FIVE times as many as the number of files???
--   see https://lestermartin.blog/2023/07/18/determining-of-splits-w-trino-starburst-galaxy-iceberg-table-format/



----------------------------------------------------------
-- EXAMPLE 5 - the power of projection!! 
----------------------------------------------------------

EXPLAIN ANALYZE
SELECT app_name, log_type, log_level, 
       message_id, ip_address
  FROM logs_iceberg;

-- NOTICE IN OUTPUT
--  - Reading and returning SELECTED cols ONLY
--      Layout: [ip_address:varchar, app_name:varchar, log_type:varchar, log_level:varchar, message_id:varchar]
--      Output layout: [ip_address, app_name, log_type, log_level, message_id]
--  - finished MUCH MUCH faster than before 
--      Execution: 18.78s (was 1.68m)
--      CPU: 13.00s (was 1.45m)
--      Physical input time: 31.27S (was 2.61m)



----------------------------------------------------------
-- EXAMPLE 6 - a bit of predicate pushdown for FUN 
----------------------------------------------------------

EXPLAIN analyze
SELECT app_name, log_type, log_level, 
       message_id, ip_address
  FROM logs_iceberg
 WHERE app_name IN ('CRM', 'ERP');

-- NOTICE IN OUTPUT
--  - TableScan becomes ScanFilter
--      filterPredicate = (app_name IN (varchar 'CRM', varchar 'ERP'))
--        ** not any faster as all splits have all values (not sorted) **
--  - estimates on # of records being returned was good
--      est >> rows: 7752185 (322.56MB)
--      act >> 7751504 rows  (591.59MB)



----------------------------------------------------------
-- EXAMPLE 7 - sorting for a few more stages
----------------------------------------------------------

-- add a sort which adds 2 more stages for sorting
--  (a distributed partial sort and a single merge 
--   of sorted lists)
EXPLAIN 
SELECT app_name, log_type, log_level, 
       message_id, ip_address
  FROM logs_iceberg
 WHERE app_name IN ('CRM', 'ERP')
 ORDER BY app_name, log_type, log_level, 
          message_id, ip_address;



----------------------------------------------------------
-- EXAMPLE 8 - aggregation happens in 2 stages
----------------------------------------------------------

 -- the big callouts are the partial aggregate in the source stage and
 --  then the final aggregation in the next stage and the rest is the
 --  two stages for partial/final sorting as before
EXPLAIN
 SELECT app_name, count() as num_events  
  FROM logs_iceberg
 WHERE event_time >=  from_iso8601_timestamp('2021-07-02T00:00:00')
   AND event_time <   from_iso8601_timestamp('2021-07-05T00:00:00')
 GROUP BY app_name  
 ORDER BY num_events, app_name;



----------------------------------------------------------
-- EXAMPLE 9 - partition join (2 table)
----------------------------------------------------------

EXPLAIN 
SELECT c.name, c.acctbal, o.orderkey, o.totalprice
  FROM tpch.sf100.orders   AS o 
  LEFT JOIN tpch.sf100.customer AS c 
    ON c.custkey = o.custkey;

-- prolly could have been a broadcast join, but no stats
--   on sf100.customer table
show stats for tpch.sf100.customer;



----------------------------------------------------------
-- EXAMPLE 10 - broadcast join (2 table)
----------------------------------------------------------

-- check sf1's customer table
show stats for tpch.sf1.customer;

EXPLAIN
SELECT c.name, c.acctbal, o.orderkey, o.totalprice
  FROM tpch.sf1.orders   AS o 
  LEFT JOIN tpch.sf1.customer AS c 
    ON c.custkey = o.custkey;



----------------------------------------------------------
-- EXAMPLE 11 - broadcast joins (MANY tables)
----------------------------------------------------------

-- so pretty!
SELECT s.ss_item_sk, i.i_color, d.d_year, st.s_city, p.p_purpose
  FROM tpcds.sf1.store_sales s
  JOIN tpcds.sf1.item i ON (s.ss_item_sk = i.i_item_sk)
  JOIN tpcds.sf1.promotion p ON (s.ss_promo_sk = p.p_promo_sk)
  JOIN tpcds.sf1.store st ON (s.ss_store_sk = st.s_store_sk)
  JOIN tpcds.sf1.date_dim d ON (s.ss_sold_date_sk = d.d_date_sk)
 LIMIT 950;



----------------------------------------------------------
-- EXAMPLE 12 - partition joins (MANY tables)
----------------------------------------------------------

-- so BIZZY!!
SELECT s.ss_item_sk, i.i_color, d.d_year, st.s_city, p.p_purpose
  FROM tpcds.sf10.store_sales s
  JOIN tpcds.sf10.item i ON (s.ss_item_sk = i.i_item_sk)
  JOIN tpcds.sf10.promotion p ON (s.ss_promo_sk = p.p_promo_sk)
  JOIN tpcds.sf10.store st ON (s.ss_store_sk = st.s_store_sk)
  JOIN tpcds.sf10.date_dim d ON (s.ss_sold_date_sk = d.d_date_sk)
 LIMIT 950;



------------------------------------
-- CLEANUP
------------------------------------

DROP SCHEMA tmp_cat.query_plans CASCADE;
