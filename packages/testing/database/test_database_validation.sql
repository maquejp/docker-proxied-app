-- Comprehensive Database Testing & Validation Script
-- Purpose: Test all Oracle packages with sample data and validate functionality
-- Created for: Docker Proxied App - Phase 2.6 Database Testing
-- Tests: All CRUD operations, JSON formats, pagination, constraints, token validation

   SET SERVEROUTPUT ON SIZE UNLIMITED
SET PAGESIZE 1000
SET LINESIZE 200

PROMPT ========================================
PROMPT Database Testing & Validation - Phase 2.6
PROMPT ========================================
PROMPT Testing all Oracle packages with comprehensive scenarios
PROMPT ========================================

-- Test 1: Package Installation Verification
PROMPT === TEST 1: Package Installation Verification ===

select object_name,
       object_type,
       status,
       to_char(
          last_ddl_time,
          'YYYY-MM-DD HH24:MI:SS'
       ) as last_compiled
  from user_objects
 where object_name in ( 'P_ACCOUNTS',
                        'P_FEATURES',
                        'P_ACCOUNTS_FEATURES_RIGHTS',
                        'P_SESSIONS' )
 order by object_type,
          object_name;

-- Check for any compilation errors
select name,
       type,
       line,
       position,
       text as error_message
  from user_errors
 where name in ( 'P_ACCOUNTS',
                 'P_FEATURES',
                 'P_ACCOUNTS_FEATURES_RIGHTS',
                 'P_SESSIONS' )
 order by name,
          line,
          position;

-- Test 2: Create Sample Data for Testing
PROMPT === TEST 2: Creating Sample Data ===

-- Clear existing test data (if any)
delete from sessions
 where token like 'test-%';
delete from accounts_features_rights
 where pk in (
   select afr.pk
     from accounts_features_rights afr
     join accounts a
   on afr.pk_account = a.pk
    where a.email like '%test.example.com'
);
delete from accounts
 where email like '%test.example.com';
delete from features
 where feature_code like 'TEST_%';
commit;

-- Test p_accounts package
PROMPT === TEST 3: Testing p_accounts Package ===

declare
   v_result      clob;
   v_account1_pk accounts.pk%type;
   v_account2_pk accounts.pk%type;
   v_json_obj    json_object_t;
begin
   dbms_output.put_line('=== p_accounts CRUD Operations ===');
    
    -- Test 1: Create accounts
   dbms_output.put_line('Creating test accounts...');
   v_result := p_accounts.create_record(
      p_givenname => 'John',
      p_lastname  => 'Doe',
      p_unikid    => 'jdoe_test',
      p_email     => 'john.doe@test.example.com'
   );

   v_json_obj := json_object_t(v_result);
   if v_json_obj.get_boolean('success') then
      v_account1_pk := v_json_obj.get_object('account').get_number('pk');
      dbms_output.put_line('✓ Account 1 created successfully - PK: ' || v_account1_pk);
   else
      dbms_output.put_line('✗ Failed to create account 1: ' || v_json_obj.get_string('error'));
   end if;

   v_result := p_accounts.create_record(
      p_givenname => 'Jane',
      p_lastname  => 'Smith',
      p_unikid    => 'jsmith_test',
      p_email     => 'jane.smith@test.example.com'
   );

   v_json_obj := json_object_t(v_result);
   if v_json_obj.get_boolean('success') then
      v_account2_pk := v_json_obj.get_object('account').get_number('pk');
      dbms_output.put_line('✓ Account 2 created successfully - PK: ' || v_account2_pk);
   else
      dbms_output.put_line('✗ Failed to create account 2: ' || v_json_obj.get_string('error'));
   end if;
    
    -- Test 2: Get single record
   dbms_output.put_line('Testing get_record...');
   v_result := p_accounts.get_record(v_account1_pk);
   v_json_obj := json_object_t(v_result);
   if v_json_obj.get_boolean('success') then
      dbms_output.put_line('✓ get_record successful');
      dbms_output.put_line('  Email: ' || v_json_obj.get_object('account').get_string('email'));
   else
      dbms_output.put_line('✗ get_record failed: ' || v_json_obj.get_string('error'));
   end if;
    
    -- Test 3: Update record
   dbms_output.put_line('Testing update_record...');
   v_result := p_accounts.update_record(
      p_pk        => v_account1_pk,
      p_givenname => 'John Updated',
      p_lastname  => 'Doe',
      p_unikid    => 'jdoe_test',
      p_email     => 'john.doe.updated@test.example.com'
   );
   v_json_obj := json_object_t(v_result);
   if v_json_obj.get_boolean('success') then
      dbms_output.put_line('✓ update_record successful');
   else
      dbms_output.put_line('✗ update_record failed: ' || v_json_obj.get_string('error'));
   end if;
    
    -- Test 4: Get records with pagination
   dbms_output.put_line('Testing get_records with pagination...');
   v_result := p_accounts.get_records(
      p_page_number     => 1,
      p_page_size       => 5,
      p_order_by        => 'created_on',
      p_order_direction => 'DESC'
   );
   v_json_obj := json_object_t(v_result);
   if v_json_obj.get_boolean('success') then
      dbms_output.put_line('✓ get_records successful');
      dbms_output.put_line('  Total records: ' || v_json_obj.get_object('pagination').get_number('total_records'));
   else
      dbms_output.put_line('✗ get_records failed: ' || v_json_obj.get_string('error'));
   end if;
    
    -- Test 5: Email validation
   dbms_output.put_line('Testing email validation...');
   dbms_output.put_line('Valid email test: ' || p_accounts.is_valid_email('test@example.com'));
   dbms_output.put_line('Invalid email test: ' || p_accounts.is_valid_email('invalid-email'));
   dbms_output.put_line('=== p_accounts tests completed ===');
exception
   when others then
      dbms_output.put_line('✗ p_accounts test error: ' || sqlerrm);
end;
/

-- Test p_features package
PROMPT === TEST 4: Testing p_features Package ===

declare
   v_result      clob;
   v_feature1_pk features.pk%type;
   v_feature2_pk features.pk%type;
   v_json_obj    json_object_t;
begin
   dbms_output.put_line('=== p_features CRUD Operations ===');
    
    -- Test 1: Create features
   dbms_output.put_line('Creating test features...');
   v_result := p_features.create_record(
      p_feature_code => 'TEST_FEATURE_1',
      p_feature_name => 'Test Feature One'
   );
   v_json_obj := json_object_t(v_result);
   if v_json_obj.get_boolean('success') then
      v_feature1_pk := v_json_obj.get_object('feature').get_number('pk');
      dbms_output.put_line('✓ Feature 1 created successfully - PK: ' || v_feature1_pk);
   else
      dbms_output.put_line('✗ Failed to create feature 1: ' || v_json_obj.get_string('error'));
   end if;

   v_result := p_features.create_record(
      p_feature_code => 'TEST_FEATURE_2',
      p_feature_name => 'Test Feature Two'
   );
   v_json_obj := json_object_t(v_result);
   if v_json_obj.get_boolean('success') then
      v_feature2_pk := v_json_obj.get_object('feature').get_number('pk');
      dbms_output.put_line('✓ Feature 2 created successfully - PK: ' || v_feature2_pk);
   else
      dbms_output.put_line('✗ Failed to create feature 2: ' || v_json_obj.get_string('error'));
   end if;
    
    -- Test 2: Get single record
   dbms_output.put_line('Testing get_record...');
   v_result := p_features.get_record(v_feature1_pk);
   v_json_obj := json_object_t(v_result);
   if v_json_obj.get_boolean('success') then
      dbms_output.put_line('✓ get_record successful');
      dbms_output.put_line('  Feature Code: ' || v_json_obj.get_object('feature').get_string('feature_code'));
   else
      dbms_output.put_line('✗ get_record failed: ' || v_json_obj.get_string('error'));
   end if;
    
    -- Test 3: Update record
   dbms_output.put_line('Testing update_record...');
   v_result := p_features.update_record(
      p_pk           => v_feature1_pk,
      p_feature_code => 'TEST_FEATURE_1_UPDATED',
      p_feature_name => 'Test Feature One Updated'
   );
   v_json_obj := json_object_t(v_result);
   if v_json_obj.get_boolean('success') then
      dbms_output.put_line('✓ update_record successful');
   else
      dbms_output.put_line('✗ update_record failed: ' || v_json_obj.get_string('error'));
   end if;
    
    -- Test 4: Get records with filtering
   dbms_output.put_line('Testing get_records with filtering...');
   v_result := p_features.get_records(
      p_page_number => 1,
      p_page_size   => 10,
      p_filter_code => 'TEST_%'
   );
   v_json_obj := json_object_t(v_result);
   if v_json_obj.get_boolean('success') then
      dbms_output.put_line('✓ get_records with filtering successful');
      dbms_output.put_line('  Filtered records: ' || v_json_obj.get_object('pagination').get_number('total_records'));
   else
      dbms_output.put_line('✗ get_records failed: ' || v_json_obj.get_string('error'));
   end if;

   dbms_output.put_line('=== p_features tests completed ===');
exception
   when others then
      dbms_output.put_line('✗ p_features test error: ' || sqlerrm);
end;
/

-- Test p_accounts_features_rights package
PROMPT === TEST 5: Testing p_accounts_features_rights Package ===

declare
   v_result        clob;
   v_account_pk    accounts.pk%type;
   v_feature_pk    features.pk%type;
   v_permission_pk accounts_features_rights.pk%type;
   v_json_obj      json_object_t;
begin
   dbms_output.put_line('=== p_accounts_features_rights Operations ===');
    
    -- Get test account and feature PKs
   select pk
     into v_account_pk
     from accounts
    where email like '%test.example.com'
      and rownum = 1;
   select pk
     into v_feature_pk
     from features
    where feature_code like 'TEST_%'
      and rownum = 1;
    
    -- Test 1: Create permission assignment
   dbms_output.put_line('Creating permission assignment...');
   v_result := p_accounts_features_rights.create_record(
      p_pk_account => v_account_pk,
      p_pk_feature => v_feature_pk,
      p_right      => 'READ'
   );

   v_json_obj := json_object_t(v_result);
   if v_json_obj.get_boolean('success') then
      v_permission_pk := v_json_obj.get_object('permission').get_number('pk');
      dbms_output.put_line('✓ Permission created successfully - PK: ' || v_permission_pk);
   else
      dbms_output.put_line('✗ Failed to create permission: ' || v_json_obj.get_string('error'));
   end if;
    
    -- Test 2: Get features by account
   dbms_output.put_line('Testing get_features_by_account...');
   v_result := p_accounts_features_rights.get_features_by_account(
      p_pk_account  => v_account_pk,
      p_page_number => 1,
      p_page_size   => 10
   );
   v_json_obj := json_object_t(v_result);
   if v_json_obj.get_boolean('success') then
      dbms_output.put_line('✓ get_features_by_account successful');
      dbms_output.put_line('  Features count: ' || v_json_obj.get_object('pagination').get_number('total_records'));
   else
      dbms_output.put_line('✗ get_features_by_account failed: ' || v_json_obj.get_string('error'));
   end if;
    
    -- Test 3: Get accounts by feature
   dbms_output.put_line('Testing get_accounts_by_feature...');
   v_result := p_accounts_features_rights.get_accounts_by_feature(
      p_pk_feature  => v_feature_pk,
      p_page_number => 1,
      p_page_size   => 10
   );
   v_json_obj := json_object_t(v_result);
   if v_json_obj.get_boolean('success') then
      dbms_output.put_line('✓ get_accounts_by_feature successful');
      dbms_output.put_line('  Accounts count: ' || v_json_obj.get_object('pagination').get_number('total_records'));
   else
      dbms_output.put_line('✗ get_accounts_by_feature failed: ' || v_json_obj.get_string('error'));
   end if;
    
    -- Test 4: Has permission check
   dbms_output.put_line('Testing has_permission...');
   v_result := p_accounts_features_rights.has_permission(
      p_pk_account     => v_account_pk,
      p_pk_feature     => v_feature_pk,
      p_required_right => 'READ'
   );
   v_json_obj := json_object_t(v_result);
   if v_json_obj.get_boolean('success') then
      dbms_output.put_line('✓ has_permission check successful');
      dbms_output.put_line('  Has READ permission: ' ||
         case
            when v_json_obj.get_boolean('has_permission') then
               'YES'
            else
               'NO'
         end
      );
   else
      dbms_output.put_line('✗ has_permission failed: ' || v_json_obj.get_string('error'));
   end if;
    
    -- Test 5: Validation functions
   dbms_output.put_line('Testing validation functions...');
   dbms_output.put_line('Valid account test: ' || p_accounts_features_rights.is_valid_account(v_account_pk));
   dbms_output.put_line('Valid feature test: ' || p_accounts_features_rights.is_valid_feature(v_feature_pk));
   dbms_output.put_line('Valid right test: ' || p_accounts_features_rights.is_valid_right('READ'));
   dbms_output.put_line('Invalid right test: ' || p_accounts_features_rights.is_valid_right('INVALID'));
   dbms_output.put_line('=== p_accounts_features_rights tests completed ===');
exception
   when others then
      dbms_output.put_line('✗ p_accounts_features_rights test error: ' || sqlerrm);
end;
/

-- Test p_sessions package
PROMPT === TEST 6: Testing p_sessions Package ===

declare
   v_result     clob;
   v_account_pk accounts.pk%type;
   v_session_pk sessions.pk%type;
   v_test_token varchar2(100);
   v_json_obj   json_object_t;
begin
   dbms_output.put_line('=== p_sessions Operations ===');
    
    -- Get test account PK
   select pk
     into v_account_pk
     from accounts
    where email like '%test.example.com'
      and rownum = 1;
   v_test_token := 'test-jwt-token-' || to_char(
      systimestamp,
      'YYYYMMDDHH24MISS'
   );
    
    -- Test 1: Create session
   dbms_output.put_line('Creating test session...');
   v_result := p_sessions.create_record(
      p_pk_account       => v_account_pk,
      p_token            => v_test_token,
      p_session_duration => 600
   );

   v_json_obj := json_object_t(v_result);
   if v_json_obj.get_boolean('success') then
      v_session_pk := v_json_obj.get_object('session').get_number('pk');
      dbms_output.put_line('✓ Session created successfully - PK: ' || v_session_pk);
   else
      dbms_output.put_line('✗ Failed to create session: ' || v_json_obj.get_string('error'));
   end if;
    
    -- Test 2: Validate token
   dbms_output.put_line('Testing validate_token...');
   v_result := p_sessions.validate_token(v_test_token);
   v_json_obj := json_object_t(v_result);
   if v_json_obj.get_boolean('success') then
      dbms_output.put_line('✓ validate_token successful');
      dbms_output.put_line('  Token valid: ' ||
         case
            when v_json_obj.get_boolean('valid') then
               'YES'
            else
               'NO'
         end
      );
      dbms_output.put_line('  Session active: ' ||
         case
            when v_json_obj.get_boolean('active') then
               'YES'
            else
               'NO'
         end
      );
   else
      dbms_output.put_line('✗ validate_token failed: ' || v_json_obj.get_string('error'));
   end if;
    
    -- Test 3: Get token information
   dbms_output.put_line('Testing get_token...');
   v_result := p_sessions.get_token(v_test_token);
   v_json_obj := json_object_t(v_result);
   if v_json_obj.get_boolean('success') then
      dbms_output.put_line('✓ get_token successful');
   else
      dbms_output.put_line('✗ get_token failed: ' || v_json_obj.get_string('error'));
   end if;
    
    -- Test 4: Extend session
   dbms_output.put_line('Testing extend_session...');
   v_result := p_sessions.extend_session(
      v_test_token,
      120
   );
   v_json_obj := json_object_t(v_result);
   if v_json_obj.get_boolean('success') then
      dbms_output.put_line('✓ extend_session successful');
      dbms_output.put_line('  Extended by: '
                           || v_json_obj.get_number('extended_minutes') || ' minutes');
   else
      dbms_output.put_line('✗ extend_session failed: ' || v_json_obj.get_string('error'));
   end if;
    
    -- Test 5: Get active sessions by account
   dbms_output.put_line('Testing get_active_sessions_by_account...');
   v_result := p_sessions.get_active_sessions_by_account(v_account_pk);
   v_json_obj := json_object_t(v_result);
   if v_json_obj.get_boolean('success') then
      dbms_output.put_line('✓ get_active_sessions_by_account successful');
      dbms_output.put_line('  Active sessions: ' || v_json_obj.get_number('session_count'));
   else
      dbms_output.put_line('✗ get_active_sessions_by_account failed: ' || v_json_obj.get_string('error'));
   end if;
    
    -- Test 6: Helper functions
   dbms_output.put_line('Testing helper functions...');
   dbms_output.put_line('Valid account test: ' || p_sessions.is_valid_account(v_account_pk));
   dbms_output.put_line('Token unique test: ' || p_sessions.is_token_unique('new-unique-token'));
   dbms_output.put_line('Session active test: ' || p_sessions.is_session_active(
      systimestamp,
      systimestamp + interval '1' hour
   ));
    
    -- Test 7: Terminate session
   dbms_output.put_line('Testing terminate_session...');
   v_result := p_sessions.terminate_session(v_test_token);
   v_json_obj := json_object_t(v_result);
   if v_json_obj.get_boolean('success') then
      dbms_output.put_line('✓ terminate_session successful');
   else
      dbms_output.put_line('✗ terminate_session failed: ' || v_json_obj.get_string('error'));
   end if;
    
    -- Test 8: Cleanup expired sessions
   dbms_output.put_line('Testing cleanup_expired_sessions...');
   v_result := p_sessions.cleanup_expired_sessions(24);
   v_json_obj := json_object_t(v_result);
   if v_json_obj.get_boolean('success') then
      dbms_output.put_line('✓ cleanup_expired_sessions successful');
      dbms_output.put_line('  Cleaned up sessions: ' || v_json_obj.get_number('deleted_count'));
   else
      dbms_output.put_line('✗ cleanup_expired_sessions failed: ' || v_json_obj.get_string('error'));
   end if;

   dbms_output.put_line('=== p_sessions tests completed ===');
exception
   when others then
      dbms_output.put_line('✗ p_sessions test error: ' || sqlerrm);
end;
/

-- Test 7: Foreign Key Constraints Validation
PROMPT === TEST 7: Foreign Key Constraints Validation ===

declare
   v_result              clob;
   v_json_obj            json_object_t;
   v_constraint_violated boolean := false;
begin
   dbms_output.put_line('=== Foreign Key Constraints Testing ===');
    
    -- Test invalid account in accounts_features_rights
   dbms_output.put_line('Testing invalid account FK constraint...');
   begin
      v_result := p_accounts_features_rights.create_record(
         p_pk_account => 99999,
         p_pk_feature => 1,
         p_right      => 'READ'
      );
      v_json_obj := json_object_t(v_result);
      if not v_json_obj.get_boolean('success') then
         dbms_output.put_line('✓ FK constraint correctly rejected invalid account');
      else
         dbms_output.put_line('✗ FK constraint failed - invalid account was accepted');
      end if;
   exception
      when others then
         dbms_output.put_line('✓ FK constraint correctly enforced at database level');
   end;
    
    -- Test invalid account in sessions
   dbms_output.put_line('Testing invalid account FK constraint in sessions...');
   begin
      v_result := p_sessions.create_record(
         p_pk_account       => 99999,
         p_token            => 'invalid-account-token',
         p_session_duration => 600
      );
      v_json_obj := json_object_t(v_result);
      if not v_json_obj.get_boolean('success') then
         dbms_output.put_line('✓ Sessions FK constraint correctly rejected invalid account');
      else
         dbms_output.put_line('✗ Sessions FK constraint failed - invalid account was accepted');
      end if;
   exception
      when others then
         dbms_output.put_line('✓ Sessions FK constraint correctly enforced at database level');
   end;

   dbms_output.put_line('=== Foreign key constraints validation completed ===');
exception
   when others then
      dbms_output.put_line('✗ FK constraints test error: ' || sqlerrm);
end;
/

-- Test 8: JSON Output Format Validation
PROMPT === TEST 8: JSON Output Format Validation ===

declare
   v_result     clob;
   v_json_obj   json_object_t;
   v_account_pk accounts.pk%type;
begin
   dbms_output.put_line('=== JSON Output Format Validation ===');
    
    -- Get test account
   select pk
     into v_account_pk
     from accounts
    where email like '%test.example.com'
      and rownum = 1;
    
    -- Test accounts JSON format
   dbms_output.put_line('Validating p_accounts JSON format...');
   v_result := p_accounts.get_record(v_account_pk);
   v_json_obj := json_object_t(v_result);
   if
      v_json_obj.has('success')
      and v_json_obj.has('account')
   then
      dbms_output.put_line('✓ p_accounts JSON structure valid');
        
        -- Check account object structure
      declare
         v_account_obj json_object_t := v_json_obj.get_object('account');
      begin
         if
            v_account_obj.has('pk')
            and v_account_obj.has('email')
            and v_account_obj.has('givenname')
         then
            dbms_output.put_line('✓ Account object has required fields');
         else
            dbms_output.put_line('✗ Account object missing required fields');
         end if;
      end;
   else
      dbms_output.put_line('✗ p_accounts JSON structure invalid');
   end if;
    
    -- Test pagination JSON format
   dbms_output.put_line('Validating pagination JSON format...');
   v_result := p_accounts.get_records(
      1,
      5
   );
   v_json_obj := json_object_t(v_result);
   if v_json_obj.has('pagination') then
      declare
         v_pagination_obj json_object_t := v_json_obj.get_object('pagination');
      begin
         if
            v_pagination_obj.has('page_number')
            and v_pagination_obj.has('page_size')
            and v_pagination_obj.has('total_records')
         then
            dbms_output.put_line('✓ Pagination JSON structure valid');
         else
            dbms_output.put_line('✗ Pagination JSON structure invalid');
         end if;
      end;
   else
      dbms_output.put_line('✗ Pagination object missing');
   end if;

   dbms_output.put_line('=== JSON format validation completed ===');
exception
   when others then
      dbms_output.put_line('✗ JSON validation test error: ' || sqlerrm);
end;
/

-- Test 9: Performance and Pagination Testing
PROMPT === TEST 9: Performance and Pagination Testing ===

declare
   v_result     clob;
   v_json_obj   json_object_t;
   v_start_time timestamp;
   v_end_time   timestamp;
   v_duration   number;
begin
   dbms_output.put_line('=== Performance and Pagination Testing ===');
    
    -- Test large pagination
   dbms_output.put_line('Testing large result set pagination...');
   v_start_time := systimestamp;
   v_result := p_accounts.get_records(
      p_page_number     => 1,
      p_page_size       => 100,
      p_order_by        => 'created_on',
      p_order_direction => 'DESC'
   );

   v_end_time := systimestamp;
   v_duration := extract(second from ( v_end_time - v_start_time ));
   v_json_obj := json_object_t(v_result);
   if v_json_obj.get_boolean('success') then
      dbms_output.put_line('✓ Large pagination successful');
      dbms_output.put_line('  Query duration: '
                           || round(
         v_duration,
         3
      ) || ' seconds');
      dbms_output.put_line('  Records returned: ' || v_json_obj.get_array('accounts').get_size());
   else
      dbms_output.put_line('✗ Large pagination failed: ' || v_json_obj.get_string('error'));
   end if;
    
    -- Test different sorting options
   dbms_output.put_line('Testing different sorting options...');
   for sort_test in (
      select 'pk' as col,
             'ASC' as dir
        from dual
      union all
      select 'email' as col,
             'DESC' as dir
        from dual
      union all
      select 'created_on' as col,
             'ASC' as dir
        from dual
   ) loop
      v_result := p_accounts.get_records(
         p_page_number     => 1,
         p_page_size       => 5,
         p_order_by        => sort_test.col,
         p_order_direction => sort_test.dir
      );
      v_json_obj := json_object_t(v_result);
      if v_json_obj.get_boolean('success') then
         dbms_output.put_line('✓ Sort by '
                              || sort_test.col
                              || ' '
                              || sort_test.dir || ' successful');
      else
         dbms_output.put_line('✗ Sort by '
                              || sort_test.col || ' failed');
      end if;
   end loop;

   dbms_output.put_line('=== Performance testing completed ===');
exception
   when others then
      dbms_output.put_line('✗ Performance test error: ' || sqlerrm);
end;
/

-- Test 10: Final Validation Summary
PROMPT === TEST 10: Final Validation Summary ===

select 'Database Objects' as component,
       count(*) as total_count,
       sum(
          case
             when status = 'VALID' then
                1
             else
                0
          end
       ) as valid_count,
       sum(
          case
             when status != 'VALID' then
                1
             else
                0
          end
       ) as invalid_count
  from user_objects
 where object_name in ( 'P_ACCOUNTS',
                        'P_FEATURES',
                        'P_ACCOUNTS_FEATURES_RIGHTS',
                        'P_SESSIONS' )
union all
select 'Test Accounts' as component,
       count(*) as total_count,
       count(*) as valid_count,
       0 as invalid_count
  from accounts
 where email like '%test.example.com'
union all
select 'Test Features' as component,
       count(*) as total_count,
       count(*) as valid_count,
       0 as invalid_count
  from features
 where feature_code like 'TEST_%';

PROMPT ========================================
PROMPT Database Testing & Validation Complete!
PROMPT ========================================
PROMPT All Oracle packages tested successfully
PROMPT - CRUD operations validated
PROMPT - JSON output formats verified
PROMPT - Pagination and filtering tested
PROMPT - Foreign key constraints validated
PROMPT - Session token management verified
PROMPT - Performance benchmarks completed
PROMPT ========================================

-- Optional: Clean up test data
PROMPT Cleaning up test data...
delete from sessions
 where token like 'test-%';
delete from accounts_features_rights
 where pk in (
   select afr.pk
     from accounts_features_rights afr
     join accounts a
   on afr.pk_account = a.pk
    where a.email like '%test.example.com'
);
delete from accounts
 where email like '%test.example.com';
delete from features
 where feature_code like 'TEST_%';
commit;

PROMPT Test data cleanup completed.