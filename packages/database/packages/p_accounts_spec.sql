-- P_ACCOUNTS Package Specification
-- Oracle PL/SQL package for managing accounts table operations
-- Provides standard CRUD operations and JSON utilities

create or replace package p_accounts as

    -- Package version for tracking
   c_package_version constant varchar2(10) := '1.0.0';
    
    -- Custom exception types
   e_account_not_found exception;
   e_duplicate_email exception;
   e_duplicate_unikid exception;
   e_invalid_email_format exception;
   e_required_field_missing exception;
    
    -- Pragma for exception handling
   pragma exception_init ( e_account_not_found,-20001 );
   pragma exception_init ( e_duplicate_email,-20002 );
   pragma exception_init ( e_duplicate_unikid,-20003 );
   pragma exception_init ( e_invalid_email_format,-20004 );
   pragma exception_init ( e_required_field_missing,-20005 );

    -- Create new account record
    -- Parameters: all fields except pk and timestamp fields (auto-generated)
    -- Returns: JSON representation of the newly created account record
   function create_record (
      p_givenname  in accounts.givenname%type,
      p_lastname   in accounts.lastname%type,
      p_unikid     in accounts.unikid%type,
      p_email      in accounts.email%type,
      p_created_by in accounts.created_by%type
   ) return clob;

    -- Update existing account record
    -- Parameters: all fields including pk, except timestamp fields (auto-updated)
    -- Returns: JSON representation of the updated account record
   function update_record (
      p_pk          in accounts.pk%type,
      p_givenname   in accounts.givenname%type,
      p_lastname    in accounts.lastname%type,
      p_unikid      in accounts.unikid%type,
      p_email       in accounts.email%type,
      p_modified_by in accounts.modified_by%type
   ) return clob;

    -- Delete account record by primary key
    -- Parameters: pk of account to delete
    -- Returns: JSON object with success message and deletion details
   function delete_record (
      p_pk in accounts.pk%type
   ) return clob;

    -- Get single account record by primary key
    -- Parameters: pk of account to retrieve
    -- Returns: JSON representation of the account record
   function get_record (
      p_pk in accounts.pk%type
   ) return clob;

    -- Get single account record by email
    -- Parameters: email of account to retrieve
    -- Returns: JSON representation of the account record
   function get_record_by_email (
      p_email in accounts.email%type
   ) return clob;

    -- Get single account record by unique identifier
    -- Parameters: unikid of account to retrieve
    -- Returns: JSON representation of the account record
   function get_record_by_unikid (
      p_unikid in accounts.unikid%type
   ) return clob;

    -- Get multiple account records with pagination, ordering, and filtering
    -- Parameters: pagination, filtering, and sorting options
    -- Returns: JSON array of account records with metadata
   function get_records (
      p_page_number    in number default 1,
      p_page_size      in number default 20,
      p_order_by       in varchar2 default 'created_on',
      p_order_dir      in varchar2 default 'DESC',
      p_filter_email   in varchar2 default null,
      p_filter_name    in varchar2 default null,
      p_created_after  in timestamp default null,
      p_created_before in timestamp default null
   ) return clob;

    -- Get total count of accounts (with optional filtering)
    -- Parameters: same filtering options as get_records
    -- Returns: total number of matching records
   function get_record_count (
      p_filter_email   in varchar2 default null,
      p_filter_name    in varchar2 default null,
      p_created_after  in timestamp default null,
      p_created_before in timestamp default null
   ) return number;

    -- Convert single account record to JSON
    -- Parameters: primary key of account to convert
    -- Returns: JSON representation of the account
   function record_to_json (
      p_pk in accounts.pk%type
   ) return clob;

    -- Validate email format
    -- Parameters: email string to validate
    -- Returns: 1 if valid, 0 if invalid
   function is_valid_email (
      p_email in varchar2
   ) return number;

    -- Check if email exists (for duplicate validation)
    -- Parameters: email to check, optional pk to exclude (for updates)
    -- Returns: 1 if exists, 0 if not
   function email_exists (
      p_email      in varchar2,
      p_exclude_pk in number default null
   ) return number;

    -- Check if unikid exists (for duplicate validation)
    -- Parameters: unikid to check, optional pk to exclude (for updates)
    -- Returns: 1 if exists, 0 if not
   function unikid_exists (
      p_unikid     in varchar2,
      p_exclude_pk in number default null
   ) return number;

    -- Get package version
    -- Returns: current package version string
   function get_version return varchar2;

end p_accounts;
/