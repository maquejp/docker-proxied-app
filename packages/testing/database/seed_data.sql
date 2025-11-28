-- Database Seed Data for Development and Testing
-- Purpose: Create initial data for development environment and testing
-- Created for: Docker Proxied App - Phase 2.6 Database Testing

   SET SERVEROUTPUT ON SIZE UNLIMITED

PROMPT ========================================
PROMPT Creating Database Seed Data
PROMPT ========================================

-- Clear existing seed data if any
delete from sessions
 where pk_account in (
   select pk
     from accounts
    where email like '%@dockerapp.dev'
);
delete from accounts_features_rights
 where pk_account in (
   select pk
     from accounts
    where email like '%@dockerapp.dev'
);
delete from accounts
 where email like '%@dockerapp.dev';
delete from features
 where feature_code like 'SEED_%';
commit;

-- Create seed accounts using p_accounts package
PROMPT Creating seed accounts...

declare
   v_result   clob;
   v_json_obj json_object_t;
   v_admin_pk accounts.pk%type;
   v_user1_pk accounts.pk%type;
   v_user2_pk accounts.pk%type;
begin
    -- Create admin account
   v_result := p_accounts.create_record(
      p_givenname => 'Admin',
      p_lastname  => 'User',
      p_unikid    => 'admin_seed',
      p_email     => 'admin@dockerapp.dev'
   );

   v_json_obj := json_object_t(v_result);
   if v_json_obj.get_boolean('success') then
      v_admin_pk := v_json_obj.get_object('account').get_number('pk');
      dbms_output.put_line('✓ Admin account created - PK: ' || v_admin_pk);
   else
      dbms_output.put_line('✗ Failed to create admin account: ' || v_json_obj.get_string('error'));
   end if;
    
    -- Create regular user 1
   v_result := p_accounts.create_record(
      p_givenname => 'John',
      p_lastname  => 'Developer',
      p_unikid    => 'jdev_seed',
      p_email     => 'john.developer@dockerapp.dev'
   );

   v_json_obj := json_object_t(v_result);
   if v_json_obj.get_boolean('success') then
      v_user1_pk := v_json_obj.get_object('account').get_number('pk');
      dbms_output.put_line('✓ User 1 account created - PK: ' || v_user1_pk);
   else
      dbms_output.put_line('✗ Failed to create user 1 account: ' || v_json_obj.get_string('error'));
   end if;
    
    -- Create regular user 2
   v_result := p_accounts.create_record(
      p_givenname => 'Jane',
      p_lastname  => 'Tester',
      p_unikid    => 'jtester_seed',
      p_email     => 'jane.tester@dockerapp.dev'
   );

   v_json_obj := json_object_t(v_result);
   if v_json_obj.get_boolean('success') then
      v_user2_pk := v_json_obj.get_object('account').get_number('pk');
      dbms_output.put_line('✓ User 2 account created - PK: ' || v_user2_pk);
   else
      dbms_output.put_line('✗ Failed to create user 2 account: ' || v_json_obj.get_string('error'));
   end if;

exception
   when others then
      dbms_output.put_line('✗ Error creating seed accounts: ' || sqlerrm);
end;
/

-- Create seed features using p_features package
PROMPT Creating seed features...

declare
   v_result      clob;
   v_json_obj    json_object_t;
   v_feature_pks number_table := number_table();
begin
    -- Extend collection and create features
   v_feature_pks.extend(6);
    
    -- User Management Feature
   v_result := p_features.create_record(
      p_feature_code => 'SEED_USER_MGMT',
      p_feature_name => 'User Management'
   );
   v_json_obj := json_object_t(v_result);
   if v_json_obj.get_boolean('success') then
      v_feature_pks(1) := v_json_obj.get_object('feature').get_number('pk');
      dbms_output.put_line('✓ User Management feature created - PK: ' || v_feature_pks(1));
   end if;
    
    -- Feature Management Feature
   v_result := p_features.create_record(
      p_feature_code => 'SEED_FEATURE_MGMT',
      p_feature_name => 'Feature Management'
   );
   v_json_obj := json_object_t(v_result);
   if v_json_obj.get_boolean('success') then
      v_feature_pks(2) := v_json_obj.get_object('feature').get_number('pk');
      dbms_output.put_line('✓ Feature Management feature created - PK: ' || v_feature_pks(2));
   end if;
    
    -- Reports Feature
   v_result := p_features.create_record(
      p_feature_code => 'SEED_REPORTS',
      p_feature_name => 'Reports and Analytics'
   );
   v_json_obj := json_object_t(v_result);
   if v_json_obj.get_boolean('success') then
      v_feature_pks(3) := v_json_obj.get_object('feature').get_number('pk');
      dbms_output.put_line('✓ Reports feature created - PK: ' || v_feature_pks(3));
   end if;
    
    -- API Access Feature
   v_result := p_features.create_record(
      p_feature_code => 'SEED_API_ACCESS',
      p_feature_name => 'API Access'
   );
   v_json_obj := json_object_t(v_result);
   if v_json_obj.get_boolean('success') then
      v_feature_pks(4) := v_json_obj.get_object('feature').get_number('pk');
      dbms_output.put_line('✓ API Access feature created - PK: ' || v_feature_pks(4));
   end if;
    
    -- Dashboard Feature
   v_result := p_features.create_record(
      p_feature_code => 'SEED_DASHBOARD',
      p_feature_name => 'Dashboard Access'
   );
   v_json_obj := json_object_t(v_result);
   if v_json_obj.get_boolean('success') then
      v_feature_pks(5) := v_json_obj.get_object('feature').get_number('pk');
      dbms_output.put_line('✓ Dashboard feature created - PK: ' || v_feature_pks(5));
   end if;
    
    -- System Settings Feature
   v_result := p_features.create_record(
      p_feature_code => 'SEED_SYSTEM_SETTINGS',
      p_feature_name => 'System Settings'
   );
   v_json_obj := json_object_t(v_result);
   if v_json_obj.get_boolean('success') then
      v_feature_pks(6) := v_json_obj.get_object('feature').get_number('pk');
      dbms_output.put_line('✓ System Settings feature created - PK: ' || v_feature_pks(6));
   end if;

exception
   when others then
      dbms_output.put_line('✗ Error creating seed features: ' || sqlerrm);
end;
/

-- Create seed permissions using p_accounts_features_rights package
PROMPT Creating seed permissions...

declare
   v_result   clob;
   v_json_obj json_object_t;
   v_admin_pk accounts.pk%type;
   v_user1_pk accounts.pk%type;
   v_user2_pk accounts.pk%type;
   cursor c_features is
   select pk,
          feature_code
     from features
    where feature_code like 'SEED_%'
    order by feature_code;

   cursor c_accounts is
   select pk,
          email
     from accounts
    where email like '%@dockerapp.dev'
    order by email;
begin
    -- Get account PKs
   select pk
     into v_admin_pk
     from accounts
    where email = 'admin@dockerapp.dev';
   select pk
     into v_user1_pk
     from accounts
    where email = 'john.developer@dockerapp.dev';
   select pk
     into v_user2_pk
     from accounts
    where email = 'jane.tester@dockerapp.dev';
    
    -- Give admin full access to all features
   for feature_rec in c_features loop
      v_result := p_accounts_features_rights.create_record(
         p_pk_account => v_admin_pk,
         p_pk_feature => feature_rec.pk,
         p_right      => 'ADMIN'
      );

      v_json_obj := json_object_t(v_result);
      if v_json_obj.get_boolean('success') then
         dbms_output.put_line('✓ Admin granted ADMIN access to ' || feature_rec.feature_code);
      end if;
   end loop;
    
    -- Give User 1 selective permissions
    -- Dashboard and API access
   for feature_rec in (
      select pk
        from features
       where feature_code in ( 'SEED_DASHBOARD',
                               'SEED_API_ACCESS' )
   ) loop
      v_result := p_accounts_features_rights.create_record(
         p_pk_account => v_user1_pk,
         p_pk_feature => feature_rec.pk,
         p_right      => 'READ'
      );
      v_json_obj := json_object_t(v_result);
      if v_json_obj.get_boolean('success') then
         dbms_output.put_line('✓ User 1 granted READ access to dashboard/API features');
      end if;
   end loop;
    
    -- Give User 2 different permissions
    -- Reports and Dashboard
   for feature_rec in (
      select pk
        from features
       where feature_code in ( 'SEED_REPORTS',
                               'SEED_DASHBOARD' )
   ) loop
      v_result := p_accounts_features_rights.create_record(
         p_pk_account => v_user2_pk,
         p_pk_feature => feature_rec.pk,
         p_right      => 'WRITE'
      );
      v_json_obj := json_object_t(v_result);
      if v_json_obj.get_boolean('success') then
         dbms_output.put_line('✓ User 2 granted WRITE access to reports/dashboard features');
      end if;
   end loop;

exception
   when others then
      dbms_output.put_line('✗ Error creating seed permissions: ' || sqlerrm);
end;
/

-- Create seed sessions for testing
PROMPT Creating seed sessions...

declare
   v_result   clob;
   v_json_obj json_object_t;
   v_admin_pk accounts.pk%type;
   v_user1_pk accounts.pk%type;
   v_user2_pk accounts.pk%type;
begin
    -- Get account PKs
   select pk
     into v_admin_pk
     from accounts
    where email = 'admin@dockerapp.dev';
   select pk
     into v_user1_pk
     from accounts
    where email = 'john.developer@dockerapp.dev';
   select pk
     into v_user2_pk
     from accounts
    where email = 'jane.tester@dockerapp.dev';
    
    -- Create active session for admin
   v_result := p_sessions.create_record(
      p_pk_account       => v_admin_pk,
      p_token            => 'seed-admin-jwt-token-' || to_char(
         systimestamp,
         'YYYYMMDDHH24MISS'
      ),
      p_session_duration => 600
   );

   v_json_obj := json_object_t(v_result);
   if v_json_obj.get_boolean('success') then
      dbms_output.put_line('✓ Admin session created');
   end if;
    
    -- Create active session for user1
   v_result := p_sessions.create_record(
      p_pk_account       => v_user1_pk,
      p_token            => 'seed-user1-jwt-token-' || to_char(
         systimestamp,
         'YYYYMMDDHH24MISS'
      ),
      p_session_duration => 600
   );

   v_json_obj := json_object_t(v_result);
   if v_json_obj.get_boolean('success') then
      dbms_output.put_line('✓ User 1 session created');
   end if;
    
    -- Create expired session for testing cleanup
   v_result := p_sessions.create_record(
      p_pk_account       => v_user2_pk,
      p_token            => 'seed-expired-jwt-token-' || to_char(
         systimestamp,
         'YYYYMMDDHH24MISS'
      ),
      p_session_start    => systimestamp - interval '2' day,
      p_session_end      => systimestamp - interval '1' day,
      p_session_duration => 600
   );

   v_json_obj := json_object_t(v_result);
   if v_json_obj.get_boolean('success') then
      dbms_output.put_line('✓ Expired session created for testing');
   end if;
exception
   when others then
      dbms_output.put_line('✗ Error creating seed sessions: ' || sqlerrm);
end;
/

-- Display seed data summary
PROMPT ========================================
PROMPT Seed Data Creation Summary
PROMPT ========================================

select 'Accounts Created' as data_type,
       count(*) as count
  from accounts
 where email like '%@dockerapp.dev'
union all
select 'Features Created' as data_type,
       count(*) as count
  from features
 where feature_code like 'SEED_%'
union all
select 'Permissions Created' as data_type,
       count(*) as count
  from accounts_features_rights afr
  join accounts a
on afr.pk_account = a.pk
 where a.email like '%@dockerapp.dev'
union all
select 'Sessions Created' as data_type,
       count(*) as count
  from sessions s
  join accounts a
on s.pk_account = a.pk
 where a.email like '%@dockerapp.dev';

-- Display account-feature matrix
PROMPT ========================================
PROMPT Account-Feature Permission Matrix
PROMPT ========================================

select a.email,
       f.feature_code,
       afr.right
  from accounts a
  join accounts_features_rights afr
on a.pk = afr.pk_account
  join features f
on afr.pk_feature = f.pk
 where a.email like '%@dockerapp.dev'
 order by a.email,
          f.feature_code;

-- Display active sessions
PROMPT ========================================
PROMPT Active Sessions Summary
PROMPT ========================================

select a.email,
       s.token,
       to_char(
          s.session_start,
          'YYYY-MM-DD HH24:MI:SS'
       ) as session_start,
       to_char(
          s.session_end,
          'YYYY-MM-DD HH24:MI:SS'
       ) as session_end,
       case
          when systimestamp between s.session_start and s.session_end then
             'ACTIVE'
          else
             'EXPIRED'
       end as status
  from sessions s
  join accounts a
on s.pk_account = a.pk
 where a.email like '%@dockerapp.dev'
 order by s.session_start desc;

commit;

PROMPT ========================================
PROMPT Database Seed Data Creation Complete!
PROMPT ========================================
PROMPT Created:
PROMPT - 3 Test accounts (admin, developer, tester)
PROMPT - 6 Application features with permissions
PROMPT - Multiple permission assignments for testing
PROMPT - Sample sessions (active and expired)
PROMPT ========================================
PROMPT Ready for development and testing!
PROMPT ========================================