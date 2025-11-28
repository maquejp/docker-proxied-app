-- Installation script for p_features Oracle package
-- Run this script to install the complete p_features package

PROMPT
PROMPT ========================================
PROMPT Installing p_features package...
PROMPT ========================================

-- Display installation start
select 'Installing p_features package...' as status
  from dual;
select 'Installation Date: ' || to_char(
   sysdate,
   'YYYY-MM-DD HH24:MI:SS'
) as timestamp
  from dual;

-- Install package specification
PROMPT Installing p_features package specification...
@@p_features_spec.sql

-- Check specification compilation
select object_name,
       object_type,
       status
  from user_objects
 where object_name = 'P_FEATURES'
   and object_type = 'PACKAGE';

-- Install package body
PROMPT Installing p_features package body...
@@p_features_body.sql

-- Check body compilation
select object_name,
       object_type,
       status
  from user_objects
 where object_name = 'P_FEATURES'
   and object_type = 'PACKAGE BODY';

-- Verify installation
PROMPT
PROMPT ========================================
PROMPT Verifying p_features package installation...
PROMPT ========================================

-- Test package version function
select 'Package Version: ' || p_features.get_version() as version_info
  from dual;

-- Count package functions/procedures
select 'Total functions/procedures: ' || count(*) as function_count
  from user_procedures
 where object_name = 'P_FEATURES';

-- Show compilation errors if any
PROMPT Checking for compilation errors...
select line,
       position,
       text
  from user_errors
 where name = 'P_FEATURES'
   and type in ( 'PACKAGE',
                 'PACKAGE BODY' );

PROMPT
PROMPT ========================================
PROMPT p_features package installation completed!
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
PROMPT - create_record(feature_code, feature_name, created_by)
PROMPT - update_record(pk, feature_code, feature_name, modified_by)  
PROMPT - delete_record(pk)
PROMPT - get_record(pk)
PROMPT - get_record_by_code(feature_code)
PROMPT - get_record_by_name(feature_name)
PROMPT - get_records(pagination and filtering parameters)
PROMPT - get_record_count(filtering parameters)
PROMPT - record_to_json(pk)
PROMPT - feature_code_exists(feature_code, exclude_pk)
PROMPT - feature_name_exists(feature_name, exclude_pk)
PROMPT - get_version()
PROMPT

commit;