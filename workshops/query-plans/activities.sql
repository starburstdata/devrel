-- WORKSHOP 
-- Query plans
-- 2026-04-30 


-- Setup and use new schema
--  AFTER selecting aws-us-east-1-free
--    cluster in the pull-down
--  **AND** you change 
--    first       << YOUR first name
--    last       << YOUR last name
--    postalcode << YOUR postal code

CREATE SCHEMA tmp_cat.tmp_first_last_postalcode;
USE tmp_cat.tmp_first_last_postalcode;




------------------------------------
-- CLEANUP
------------------------------------

-- update tmp_first_last_postalcode 
--  before running
DROP SCHEMA tmp_cat.tmp_first_last_postalcode CASCADE;
