-- P_ACCOUNTS_FEATURES_RIGHTS Package Specification
-- Oracle PL/SQL package for managing accounts_features_rights table operations
-- Provides standard CRUD operations and JSON utilities for user permission management

create or replace package p_accounts_features_rights as

    -- Package version for tracking
   c_package_version constant varchar2(10) := '1.0.0';
    
    -- Custom exception types
   e_record_not_found exception;
   e_duplicate_assignment exception;
   e_invalid_account exception;
   e_invalid_feature exception;
   e_invalid_right exception;
   e_required_field_missing exception;
    
    -- Pragma for exception handling
   pragma exception_init ( e_record_not_found,-20001 );
   pragma exception_init ( e_duplicate_assignment,-20002 );
   pragma exception_init ( e_invalid_account,-20003 );
   pragma exception_init ( e_invalid_feature,-20004 );
   pragma exception_init ( e_invalid_right,-20005 );
   pragma exception_init ( e_required_field_missing,-20006 );

    -- Create new accounts_features_rights record
    -- Parameters: all fields except pk and timestamp fields (auto-generated)
    -- Returns: JSON representation of the newly created record
   function create_record (
      p_pk_account in accounts_features_rights.pk_account%type,
      p_pk_feature in accounts_features_rights.pk_feature%type,
      p_right      in accounts_features_rights.right%type,
      p_created_by in accounts_features_rights.created_by%type
   ) return clob;

    -- Update existing accounts_features_rights record
    -- Parameters: all fields including pk, except timestamp fields (auto-updated)
    -- Returns: JSON representation of the updated record
   function update_record (
      p_pk         in accounts_features_rights.pk%type,
      p_pk_account in accounts_features_rights.pk_account%type,
      p_pk_feature in accounts_features_rights.pk_feature%type,
      p_right      in accounts_features_rights.right%type
   ) return clob;

    -- Delete accounts_features_rights record by primary key
    -- Parameters: pk of record to delete
    -- Returns: JSON object with success message and deletion details
   function delete_record (
      p_pk in accounts_features_rights.pk%type
   ) return clob;

    -- Delete accounts_features_rights record by account and feature
    -- Parameters: pk_account and pk_feature to identify the record
    -- Returns: JSON object with success message and deletion details
   function delete_by_account_feature (
      p_pk_account in accounts_features_rights.pk_account%type,
      p_pk_feature in accounts_features_rights.pk_feature%type
   ) return clob;

    -- Get single accounts_features_rights record by primary key
    -- Parameters: pk of record to retrieve
    -- Returns: JSON representation of the record
   function get_record (
      p_pk in accounts_features_rights.pk%type
   ) return clob;

    -- Get single accounts_features_rights record by account and feature
    -- Parameters: pk_account and pk_feature to search for
    -- Returns: JSON representation of the record
   function get_record_by_account_feature (
      p_pk_account in accounts_features_rights.pk_account%type,
      p_pk_feature in accounts_features_rights.pk_feature%type
   ) return clob;

    -- Get all features for a specific account
    -- Parameters: pk_account and pagination options
    -- Returns: JSON object with data array and metadata
   function get_features_by_account (
      p_pk_account   in accounts_features_rights.pk_account%type,
      p_page_number  in number default 1,
      p_page_size    in number default 20,
      p_filter_right in varchar2 default null
   ) return clob;

    -- Get all accounts for a specific feature
    -- Parameters: pk_feature and pagination options
    -- Returns: JSON object with data array and metadata
   function get_accounts_by_feature (
      p_pk_feature   in accounts_features_rights.pk_feature%type,
      p_page_number  in number default 1,
      p_page_size    in number default 20,
      p_filter_right in varchar2 default null
   ) return clob;

    -- Get multiple accounts_features_rights records with pagination, ordering, and filtering
    -- Parameters: pagination and filtering options
    -- Returns: JSON object with data array and metadata
   function get_records (
      p_page_number    in number default 1,
      p_page_size      in number default 20,
      p_order_by       in varchar2 default 'created_on',
      p_order_dir      in varchar2 default 'DESC',
      p_filter_account in number default null,
      p_filter_feature in number default null,
      p_filter_right   in varchar2 default null,
      p_created_after  in timestamp default null,
      p_created_before in timestamp default null
   ) return clob;

    -- Get total count of accounts_features_rights records (with optional filtering)
    -- Parameters: optional filtering parameters
    -- Returns: total count of matching records
   function get_record_count (
      p_filter_account in number default null,
      p_filter_feature in number default null,
      p_filter_right   in varchar2 default null,
      p_created_after  in timestamp default null,
      p_created_before in timestamp default null
   ) return number;

    -- Convert single accounts_features_rights record to JSON
    -- Parameters: pk of record
    -- Returns: JSON representation of the record with account and feature details
   function record_to_json (
      p_pk in accounts_features_rights.pk%type
   ) return clob;

    -- Check if account and feature combination already exists
    -- Parameters: pk_account and pk_feature, optional pk to exclude from check
    -- Returns: 1 if exists, 0 if not
   function assignment_exists (
      p_pk_account in accounts_features_rights.pk_account%type,
      p_pk_feature in accounts_features_rights.pk_feature%type,
      p_exclude_pk in number default null
   ) return number;

    -- Validate account exists in accounts table
    -- Parameters: pk_account to validate
    -- Returns: 1 if valid, 0 if not
   function is_valid_account (
      p_pk_account in number
   ) return number;

    -- Validate feature exists in features table
    -- Parameters: pk_feature to validate
    -- Returns: 1 if valid, 0 if not
   function is_valid_feature (
      p_pk_feature in number
   ) return number;

    -- Validate right value (F or R)
    -- Parameters: right value to validate
    -- Returns: 1 if valid, 0 if not
   function is_valid_right (
      p_right in varchar2
   ) return number;

    -- Get package version
    -- Returns: package version string
   function get_version return varchar2;

end p_accounts_features_rights;
/