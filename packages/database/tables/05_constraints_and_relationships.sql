-- CONSTRAINTS AND RELATIONSHIPS for Docker Proxied App
-- Additional constraints and relationships not covered in individual table scripts

-- Note: Primary keys, unique constraints, and foreign keys are already defined in individual table scripts
-- This file contains additional constraints and relationship validations

-- Ensure email domain validation (additional business rule)
alter table accounts
   add constraint ck_accounts_email_domain
      check ( email not like '%@example.com'
         and email not like '%@test.com' );

-- Ensure feature codes follow naming convention
alter table features
   add constraint ck_features_code_convention
      check ( feature_code not like '%_%_%_%_%'
         and length(feature_code) between 3 and 50 );

-- Ensure session tokens are not empty
alter table sessions
   add constraint ck_sessions_token_not_empty
      check ( length(trim(token)) > 10 );

-- Add constraint to ensure sessions don't exceed maximum duration (24 hours)
alter table sessions
   add constraint ck_sessions_max_duration
      check ( session_duration is null
          or session_duration <= 1440 ); -- 1440 minutes = 24 hours

-- Create additional unique constraint for active sessions (one active session per user)
-- Note: This is implemented as a function-based unique index to allow multiple ended sessions
create unique index uk_sessions_active_user on
   sessions (
      pk_account,
      case
         when
            session_end
         is null then
            'ACTIVE'
         else
            null
      end
   );

-- Note: Ensures only one active session per user account

-- Verify referential integrity with a sample query function
create or replace function verify_referential_integrity return varchar2 is
   v_account_orphans number;
   v_feature_orphans number;
   v_session_orphans number;
   v_result          varchar2(1000);
begin
    -- Check for orphaned records in accounts_features_rights
   select count(*)
     into v_account_orphans
     from accounts_features_rights afr
    where not exists (
      select 1
        from accounts a
       where a.pk = afr.pk_account
   );

   select count(*)
     into v_feature_orphans
     from accounts_features_rights afr
    where not exists (
      select 1
        from features f
       where f.pk = afr.pk_feature
   );
    
    -- Check for orphaned sessions
   select count(*)
     into v_session_orphans
     from sessions s
    where not exists (
      select 1
        from accounts a
       where a.pk = s.pk_account
   );

   v_result := 'Orphaned accounts_features_rights (account): '
               || v_account_orphans
               || ', Orphaned accounts_features_rights (feature): '
               || v_feature_orphans
               || ', Orphaned sessions: '
               || v_session_orphans;

   return v_result;
end verify_referential_integrity;
/

-- Create a view for active user sessions
create or replace view v_active_sessions as
   select s.pk,
          s.pk_account,
          a.givenname,
          a.lastname,
          a.email,
          s.session_start,
          round(
             (systimestamp - s.session_start) * 24 * 60,
             2
          ) as minutes_active
     from sessions s
     join accounts a
   on a.pk = s.pk_account
    where s.session_end is null
    order by s.session_start desc;

comment on table v_active_sessions is
   'View showing all currently active user sessions with user details';

-- Create a view for user permissions
create or replace view v_user_permissions as
   select a.pk as account_pk,
          a.givenname,
          a.lastname,
          a.email,
          f.feature_code,
          f.feature_name,
          afr.right,
          afr.created_on as permission_granted_on
     from accounts a
     join accounts_features_rights afr
   on afr.pk_account = a.pk
     join features f
   on f.pk = afr.pk_feature
    where afr.right != 'NONE'
    order by a.email,
             f.feature_code;

comment on table v_user_permissions is
   'View showing all active user permissions (excludes NONE rights)';