-- P_ACCOUNTS Package Installation Script
-- Installs the complete p_accounts package (specification and body)

PROMPT
PROMPT ========================================
PROMPT Installing P_ACCOUNTS Package
PROMPT ========================================

-- Install package specification
PROMPT Creating package specification...
@@p_accounts_spec.sql

-- Check if specification was created successfully
select 'Package specification created: ' || count(*) as spec_status
  from user_objects
 where object_name = 'P_ACCOUNTS'
   and object_type = 'PACKAGE';

-- Install package body
PROMPT Creating package body...
@@p_accounts_body.sql

-- Check if body was created successfully
select 'Package body created: ' || count(*) as body_status
  from user_objects
 where object_name = 'P_ACCOUNTS'
   and object_type = 'PACKAGE BODY';

-- Check for compilation errors
PROMPT Checking for compilation errors...
select object_name,
       object_type,
       line,
       position,
       text as error_message
  from user_errors
 where object_name = 'P_ACCOUNTS'
 order by sequence;

-- Test package installation
PROMPT Testing package installation...
select p_accounts.get_version() as package_version
  from dual;

PROMPT
PROMPT ========================================
PROMPT P_ACCOUNTS Package Installation Complete
PROMPT ========================================

-- Display package functions for reference
PROMPT Available functions in P_ACCOUNTS package:
select object_name,
       procedure_name,
       object_type
  from user_procedures
 where object_name = 'P_ACCOUNTS'
 order by procedure_name;

PROMPT
PROMPT Usage Examples:
PROMPT -- Create account: SELECT p_accounts.create_record('John', 'Doe', 'jdoe123', 'john.doe@example.com', 'ADMIN') FROM dual;
PROMPT -- Get account: SELECT p_accounts.get_record(1) FROM dual;
PROMPT -- Get by email: SELECT p_accounts.get_record_by_email('john.doe@example.com') FROM dual;
PROMPT -- Get records: SELECT p_accounts.get_records(1, 10) FROM dual;
PROMPT -- Update: SELECT p_accounts.update_record(1, 'Jane', 'Smith', 'jsmith123', 'jane.smith@example.com', 'ADMIN') FROM dual;
PROMPT -- Delete: SELECT p_accounts.delete_record(1) FROM dual;
PROMPT