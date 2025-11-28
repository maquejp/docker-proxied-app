-- PERFORMANCE INDEXES for Docker Proxied App
-- Indexes to optimize query performance based on expected usage patterns

-- ACCOUNTS table indexes
-- Index for email lookups (frequent during authentication)
create index idx_accounts_email on
   accounts ( lower(email) );

-- Index for unikid lookups (external system integration)
create index idx_accounts_unikid on
   accounts ( lower(unikid) );

-- Index for name searches (user management features)
create index idx_accounts_names on
   accounts ( lower(lastname),
   lower(givenname) );

-- Index for audit queries (created/modified tracking)
create index idx_accounts_created_on on
   accounts (
      created_on
   );
create index idx_accounts_modified_on on
   accounts (
      modified_on
   );

-- Composite index for active user searches
create index idx_accounts_active_lookup on
   accounts (
      email,
      unikid,
      created_on
   );

-- FEATURES table indexes
-- Index for feature code lookups (most common query pattern)
create index idx_features_code on
   features ( upper(feature_code) );

-- Index for feature name searches
create index idx_features_name on
   features ( lower(feature_name) );

-- Index for audit queries
create index idx_features_created_on on
   features (
      created_on
   );

-- ACCOUNTS_FEATURES_RIGHTS table indexes
-- Index for user permission lookups (most frequent query)
create index idx_afr_account on
   accounts_features_rights (
      pk_account
   );

-- Index for feature-based permission queries
create index idx_afr_feature on
   accounts_features_rights (
      pk_feature
   );

-- Index for right-type queries (finding users with specific permissions)
create index idx_afr_right on
   accounts_features_rights (
      right
   );

-- Composite index for permission checks (account + feature)
create index idx_afr_account_feature on
   accounts_features_rights (
      pk_account,
      pk_feature,
      right
   );

-- Index for audit queries
create index idx_afr_created_on on
   accounts_features_rights (
      created_on
   );

-- Composite index for admin queries (all permissions for a right type)
create index idx_afr_feature_right on
   accounts_features_rights (
      pk_feature,
      right,
      pk_account
   );

-- SESSIONS table indexes
-- Index for user session lookups (most frequent query)
create index idx_sessions_account on
   sessions (
      pk_account
   );

-- Index for active session queries
create index idx_sessions_active on
   sessions (
      pk_account,
      session_end
   );

-- Index for session start time (cleanup and reporting)
create index idx_sessions_start on
   sessions (
      session_start
   );

-- Index for session end time (duration analysis)
create index idx_sessions_end on
   sessions (
      session_end
   );

-- Composite index for session management queries
create index idx_sessions_account_start on
   sessions (
      pk_account,
      session_start
   );

-- Index for token lookups (JWT validation)
-- Note: Using function-based index for performance on CLOB
create index idx_sessions_token_hash on
   sessions (
      dbms_crypto.hash
   (
         utl_raw.cast_to_raw
      (substr(
         token,
         1,
         100
      )),
         2
   ) );

-- Composite index for cleanup operations
create index idx_sessions_cleanup on
   sessions (
      session_start,
      session_end
   );

-- CROSS-TABLE indexes for common joins
-- This is already covered by foreign key indexes, but adding composite ones for performance

-- Index for user session with account info queries
create index idx_sessions_account_detail on
   sessions (
      pk_account,
      session_start,
      session_end
   );

-- Statistics update job (Oracle will gather stats automatically, but this ensures optimal performance)
-- This would typically be run by a DBA job, included here for completeness
begin
    -- Gather statistics on all tables for optimal query execution plans
   dbms_stats.gather_schema_stats(
      ownname          => user,
      options          => 'GATHER AUTO',
      estimate_percent => dbms_stats.auto_sample_size,
      method_opt       => 'FOR ALL COLUMNS SIZE AUTO',
      cascade          => true
   );
end;
/

-- Create a function to analyze table and index usage
create or replace function analyze_index_usage (
   p_days number default 7
) return varchar2 is
   v_result varchar2(4000);
   cursor c_index_usage is
   select i.index_name,
          i.table_name,
          nvl(
             u.used,
             0
          ) as times_used
     from user_indexes i
     left join (
      select object_name,
             count(*) as used
        from v$sql_plan
       where object_owner = user
         and object_type = 'INDEX'
         and timestamp > sysdate - p_days
       group by object_name
   ) u
   on i.index_name = u.object_name
    where i.table_name in ( 'ACCOUNTS',
                            'FEATURES',
                            'ACCOUNTS_FEATURES_RIGHTS',
                            'SESSIONS' )
    order by nvl(
      u.used,
      0
   ) desc;
begin
   v_result := 'Index Usage Analysis (Last '
               || p_days
               || ' days):'
               || chr(10);
   for rec in c_index_usage loop
      v_result := v_result
                  || rec.table_name
                  || '.'
                  || rec.index_name
                  || ': '
                  || rec.times_used
                  || ' times'
                  || chr(10);
   end loop;

   return v_result;
end analyze_index_usage;
/