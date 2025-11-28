-- Installation Script for p_sessions Package
-- Purpose: Install session management package with JWT token validation
-- Created for: Docker Proxied App - Phase 2 Database Foundation
-- Dependencies: Requires accounts table, sessions table, and sessions_seq sequence

-- Display installation start message
PROMPT ================================
PROMPT Installing p_sessions Package...
PROMPT ================================

-- Create package specification
PROMPT Creating p_sessions package specification...
@@p_sessions_spec.sql

-- Verify specification compilation
select object_name,
       object_type,
       status
  from user_objects
 where object_name = 'P_SESSIONS'
   and object_type = 'PACKAGE';

-- Create package body
PROMPT Creating p_sessions package body...
@@p_sessions_body.sql

-- Verify body compilation
select object_name,
       object_type,
       status
  from user_objects
 where object_name = 'P_SESSIONS'
   and object_type = 'PACKAGE BODY';

-- Display any compilation errors
PROMPT Checking for compilation errors...
select line,
       position,
       text as error_message
  from user_errors
 where name = 'P_SESSIONS'
 order by line,
          position;

-- Test basic package functionality
PROMPT ================================
PROMPT Testing p_sessions Package...
PROMPT ================================

-- Test helper functions
PROMPT Testing helper functions...

-- Test is_valid_account function
select 'Testing is_valid_account...' as test_description
  from dual;
declare
   v_result varchar2(1);
begin
    -- Test with non-existent account
   v_result := p_sessions.is_valid_account(99999);
   dbms_output.put_line('is_valid_account(99999): ' || v_result);
    
    -- Test with existing account if any exists
   for rec in (
      select pk
        from accounts
       where rownum = 1
   ) loop
      v_result := p_sessions.is_valid_account(rec.pk);
      dbms_output.put_line('is_valid_account('
                           || rec.pk
                           || '): ' || v_result);
   end loop;
end;
/

-- Test is_token_unique function
select 'Testing is_token_unique...' as test_description
  from dual;
declare
   v_result varchar2(1);
begin
   v_result := p_sessions.is_token_unique('test-token-unique');
   dbms_output.put_line('is_token_unique(test-token-unique): ' || v_result);
end;
/

-- Test is_session_active function
select 'Testing is_session_active...' as test_description
  from dual;
declare
   v_result varchar2(1);
   v_start  timestamp := systimestamp;
   v_end    timestamp := systimestamp + interval '10' hour;
begin
   v_result := p_sessions.is_session_active(
      v_start,
      v_end
   );
   dbms_output.put_line('is_session_active (current session): ' || v_result);
   v_result := p_sessions.is_session_active(
      v_start - interval '2' hour,
      v_start - interval '1' hour
   );
   dbms_output.put_line('is_session_active (past session): ' || v_result);
end;
/

-- Test CRUD operations if accounts exist
PROMPT Testing CRUD operations...

declare
   v_account_pk accounts.pk%type;
   v_result     clob;
   v_session_pk sessions.pk%type;
   v_test_token varchar2(100) := 'test-jwt-token-' || to_char(
      systimestamp,
      'YYYYMMDDHH24MISS'
   );
begin
    -- Get first available account for testing
   select pk
     into v_account_pk
     from accounts
    where rownum = 1;

   dbms_output.put_line('=== Testing CREATE_RECORD ===');
   v_result := p_sessions.create_record(
      p_pk_account       => v_account_pk,
      p_token            => v_test_token,
      p_session_duration => 600
   );
   dbms_output.put_line('Create result: '
                        || substr(
      v_result,
      1,
      200
   ) || '...');
    
    -- Get the created session pk for further testing
   select pk
     into v_session_pk
     from sessions
    where token = v_test_token;

   dbms_output.put_line('=== Testing VALIDATE_TOKEN ===');
   v_result := p_sessions.validate_token(v_test_token);
   dbms_output.put_line('Validate result: '
                        || substr(
      v_result,
      1,
      200
   ) || '...');

   dbms_output.put_line('=== Testing GET_TOKEN ===');
   v_result := p_sessions.get_token(v_test_token);
   dbms_output.put_line('Get token result: '
                        || substr(
      v_result,
      1,
      200
   ) || '...');

   dbms_output.put_line('=== Testing GET_RECORD ===');
   v_result := p_sessions.get_record(v_session_pk);
   dbms_output.put_line('Get record result: '
                        || substr(
      v_result,
      1,
      200
   ) || '...');

   dbms_output.put_line('=== Testing EXTEND_SESSION ===');
   v_result := p_sessions.extend_session(
      v_test_token,
      60
   );
   dbms_output.put_line('Extend session result: '
                        || substr(
      v_result,
      1,
      200
   ) || '...');

   dbms_output.put_line('=== Testing GET_ACTIVE_SESSIONS_BY_ACCOUNT ===');
   v_result := p_sessions.get_active_sessions_by_account(v_account_pk);
   dbms_output.put_line('Active sessions result: '
                        || substr(
      v_result,
      1,
      200
   ) || '...');

   dbms_output.put_line('=== Testing GET_RECORDS ===');
   v_result := p_sessions.get_records(
      p_page_number    => 1,
      p_page_size      => 5,
      p_filter_account => v_account_pk
   );
   dbms_output.put_line('Get records result: '
                        || substr(
      v_result,
      1,
      200
   ) || '...');

   dbms_output.put_line('=== Testing TERMINATE_SESSION ===');
   v_result := p_sessions.terminate_session(v_test_token);
   dbms_output.put_line('Terminate result: '
                        || substr(
      v_result,
      1,
      200
   ) || '...');

   dbms_output.put_line('=== Testing DELETE_RECORD ===');
   v_result := p_sessions.delete_record(v_session_pk);
   dbms_output.put_line('Delete result: '
                        || substr(
      v_result,
      1,
      200
   ) || '...');

exception
   when no_data_found then
      dbms_output.put_line('No accounts found for testing. Please create at least one account first.');
   when others then
      dbms_output.put_line('Test error: ' || sqlerrm);
end;
/

-- Test cleanup function
PROMPT Testing cleanup_expired_sessions...
declare
   v_result clob;
begin
   v_result := p_sessions.cleanup_expired_sessions(24);
   dbms_output.put_line('Cleanup result: '
                        || substr(
      v_result,
      1,
      200
   ) || '...');
end;
/

-- Verify package objects are valid
PROMPT ================================
PROMPT Final Package Status Check
PROMPT ================================

select object_name,
       object_type,
       status,
       last_ddl_time
  from user_objects
 where object_name = 'P_SESSIONS'
 order by object_type;

-- Display completion message
PROMPT ================================
PROMPT p_sessions Package Installation Complete!
PROMPT ================================
PROMPT Package provides:
PROMPT - Standard CRUD operations with JSON responses
PROMPT - JWT token validation and session management
PROMPT - Session lifecycle management (create, extend, terminate)
PROMPT - Active session queries and cleanup procedures
PROMPT - Comprehensive validation and error handling
PROMPT ================================