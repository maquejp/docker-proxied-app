-- Installation script for p_accounts_features_rights Oracle package
-- Run this script to install the complete p_accounts_features_rights package

PROMPT
PROMPT ========================================
PROMPT Installing p_accounts_features_rights package...
PROMPT ========================================

-- Display installation start
select 'Installing p_accounts_features_rights package...' as status
  from dual;
select 'Installation Date: ' || to_char(
   sysdate,
   'YYYY-MM-DD HH24:MI:SS'
) as timestamp
  from dual;

-- Install package specification
PROMPT Installing p_accounts_features_rights package specification...
@@p_accounts_features_rights_spec.sql

-- Check specification compilation
select object_name,
       object_type,
       status
  from user_objects
 where object_name = 'P_ACCOUNTS_FEATURES_RIGHTS'
   and object_type = 'PACKAGE';

-- Install package body
PROMPT Installing p_accounts_features_rights package body...
@@p_accounts_features_rights_body.sql

-- Check body compilation
select object_name,
       object_type,
       status
  from user_objects
 where object_name = 'P_ACCOUNTS_FEATURES_RIGHTS'
   and object_type = 'PACKAGE BODY';

-- Verify installation
PROMPT
PROMPT ========================================
PROMPT Verifying p_accounts_features_rights package installation...
PROMPT ========================================

-- Test package version function
select 'Package Version: ' || p_accounts_features_rights.get_version() as version_info
  from dual;

-- Count package functions/procedures
select 'Total functions/procedures: ' || count(*) as function_count
  from user_procedures
 where object_name = 'P_ACCOUNTS_FEATURES_RIGHTS';

-- Show compilation errors if any
PROMPT Checking for compilation errors...
select line,
       position,
       text
  from user_errors
 where name = 'P_ACCOUNTS_FEATURES_RIGHTS'
   and type in ( 'PACKAGE',
                 'PACKAGE BODY' );

PROMPT
PROMPT ========================================
PROMPT p_accounts_features_rights package installation completed!
PROMPT ========================================

select 'Installation completed at: ' || to_char(
   sysdate,
   'YYYY-MM-DD HH24:MI:SS'
) as completion_time
  from dual;

-- Test basic functionality
PROMPT Testing basic functionality...

PROMPT
PROMPT Package ready for use. Available functions:
PROMPT - create_record(pk_account, pk_feature, right, created_by)
PROMPT - update_record(pk, pk_account, pk_feature, right)
PROMPT - delete_record(pk)
PROMPT - delete_by_account_feature(pk_account, pk_feature)
PROMPT - get_record(pk)
PROMPT - get_record_by_account_feature(pk_account, pk_feature)
PROMPT - get_features_by_account(pk_account, pagination parameters)
PROMPT - get_accounts_by_feature(pk_feature, pagination parameters)
PROMPT - get_records(pagination and filtering parameters)
PROMPT - get_record_count(filtering parameters)
PROMPT - record_to_json(pk)
PROMPT - assignment_exists(pk_account, pk_feature, exclude_pk)
PROMPT - is_valid_account(pk_account)
PROMPT - is_valid_feature(pk_feature)
PROMPT - is_valid_right(right)
PROMPT - get_version()
PROMPT

commit;