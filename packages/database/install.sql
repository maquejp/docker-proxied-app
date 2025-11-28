-- MASTER INSTALLATION SCRIPT for Docker Proxied App Database Schema
-- This script creates all tables, constraints, indexes, and initial data
-- Run this script as the application database user

-- Set session parameters for optimal installation
alter session set recyclebin = off;
alter session set nls_length_semantics = char;

-- Display installation start
select 'Starting Docker Proxied App Database Schema Installation...' as status
  from dual;
select 'Installation Date: ' || to_char(
   sysdate,
   'YYYY-MM-DD HH24:MI:SS'
) as timestamp
  from dual;
select 'Database User: ' || user as db_user
  from dual;

-- Create tables in dependency order
PROMPT
PROMPT ========================================
PROMPT Creating ACCOUNTS table...
PROMPT ========================================
@@01_accounts.sql

PROMPT
PROMPT ========================================
PROMPT Creating FEATURES table...
PROMPT ========================================
@@02_features.sql

PROMPT
PROMPT ========================================
PROMPT Creating ACCOUNTS_FEATURES_RIGHTS table...
PROMPT ========================================
@@03_accounts_features_rights.sql

PROMPT
PROMPT ========================================
PROMPT Creating SESSIONS table...
PROMPT ========================================
@@04_sessions.sql

PROMPT
PROMPT ========================================
PROMPT Adding constraints and relationships...
PROMPT ========================================
@@05_constraints_and_relationships.sql

PROMPT
PROMPT ========================================
PROMPT Creating performance indexes...
PROMPT ========================================
@@06_indexes.sql

-- Verify installation
PROMPT
PROMPT ========================================
PROMPT Verifying installation...
PROMPT ========================================

-- Check all tables are created
select 'Tables created: ' || count(*) as table_count
  from user_tables
 where table_name in ( 'ACCOUNTS',
                       'FEATURES',
                       'ACCOUNTS_FEATURES_RIGHTS',
                       'SESSIONS' );

-- Check all sequences are created
select 'Sequences created: ' || count(*) as sequence_count
  from user_sequences
 where sequence_name like 'SEQ_%';

-- Check all triggers are created
select 'Triggers created: ' || count(*) as trigger_count
  from user_triggers
 where table_name in ( 'ACCOUNTS',
                       'FEATURES',
                       'ACCOUNTS_FEATURES_RIGHTS',
                       'SESSIONS' );

-- Check all indexes are created
select 'Indexes created: ' || count(*) as index_count
  from user_indexes
 where table_name in ( 'ACCOUNTS',
                       'FEATURES',
                       'ACCOUNTS_FEATURES_RIGHTS',
                       'SESSIONS' )
   and index_name not like 'SYS_%';

-- Check all functions/procedures are created
select 'Functions/Procedures created: ' || count(*) as function_count
  from user_procedures;

-- Check all views are created
select 'Views created: ' || count(*) as view_count
  from user_views;

-- Display sample data
PROMPT
PROMPT ========================================
PROMPT Sample data verification...
PROMPT ========================================

-- Show default features
select 'Default features loaded: ' || count(*) as feature_count
  from features;

-- Test referential integrity function
select verify_referential_integrity() as integrity_check
  from dual;

-- Display final status
PROMPT
PROMPT ========================================
PROMPT Installation completed successfully!
PROMPT ========================================
select 'Installation completed at: ' || to_char(
   sysdate,
   'YYYY-MM-DD HH24:MI:SS'
) as completion_time
  from dual;

PROMPT
PROMPT Next steps:
PROMPT 1. Review the created objects using SQL*Plus DESCRIBE commands
PROMPT 2. Test database connectivity from your application
PROMPT 3. Load initial application data as needed
PROMPT 4. Configure Oracle packages (p_accounts, p_features) for business logic
PROMPT

-- Commit all changes
commit;