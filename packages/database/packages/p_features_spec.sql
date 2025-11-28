-- P_FEATURES Package Specification
-- Oracle PL/SQL package for managing features table operations
-- Provides standard CRUD operations and JSON utilities

create or replace package p_features as

    -- Package version for tracking
   c_package_version constant varchar2(10) := '1.0.0';
    
    -- Custom exception types
   e_feature_not_found exception;
   e_duplicate_feature_code exception;
   e_duplicate_feature_name exception;
   e_required_field_missing exception;
    
    -- Pragma for exception handling
   pragma exception_init ( e_feature_not_found,-20001 );
   pragma exception_init ( e_duplicate_feature_code,-20002 );
   pragma exception_init ( e_duplicate_feature_name,-20003 );
   pragma exception_init ( e_required_field_missing,-20005 );

    -- Create new feature record
    -- Parameters: all fields except pk and timestamp fields (auto-generated)
    -- Returns: JSON representation of the newly created feature record
   function create_record (
      p_feature_code in features.feature_code%type,
      p_feature_name in features.feature_name%type,
      p_created_by   in features.created_by%type
   ) return clob;

    -- Update existing feature record
    -- Parameters: all fields including pk, except timestamp fields (auto-updated)
    -- Returns: JSON representation of the updated feature record
   function update_record (
      p_pk           in features.pk%type,
      p_feature_code in features.feature_code%type,
      p_feature_name in features.feature_name%type,
      p_modified_by  in features.modified_by%type
   ) return clob;

    -- Delete feature record by primary key
    -- Parameters: pk of feature to delete
    -- Returns: JSON object with success message and deletion details
   function delete_record (
      p_pk in features.pk%type
   ) return clob;

    -- Get single feature record by primary key
    -- Parameters: pk of feature to retrieve
    -- Returns: JSON representation of the feature record
   function get_record (
      p_pk in features.pk%type
   ) return clob;

    -- Get single feature record by feature code
    -- Parameters: feature_code to search for
    -- Returns: JSON representation of the feature record
   function get_record_by_code (
      p_feature_code in features.feature_code%type
   ) return clob;

    -- Get single feature record by feature name
    -- Parameters: feature_name to search for
    -- Returns: JSON representation of the feature record
   function get_record_by_name (
      p_feature_name in features.feature_name%type
   ) return clob;

    -- Get multiple feature records with pagination, ordering, and filtering
    -- Parameters: pagination and filtering options
    -- Returns: JSON object with data array and metadata
   function get_records (
      p_page_number    in number default 1,
      p_page_size      in number default 20,
      p_order_by       in varchar2 default 'created_on',
      p_order_dir      in varchar2 default 'DESC',
      p_filter_code    in varchar2 default null,
      p_filter_name    in varchar2 default null,
      p_created_after  in timestamp default null,
      p_created_before in timestamp default null
   ) return clob;

    -- Get total count of features (with optional filtering)
    -- Parameters: optional filtering parameters
    -- Returns: total count of matching records
   function get_record_count (
      p_filter_code    in varchar2 default null,
      p_filter_name    in varchar2 default null,
      p_created_after  in timestamp default null,
      p_created_before in timestamp default null
   ) return number;

    -- Convert single feature record to JSON
    -- Parameters: pk of feature record
    -- Returns: JSON representation of the feature record
   function record_to_json (
      p_pk in features.pk%type
   ) return clob;

    -- Check if feature code exists (for duplicate validation)
    -- Parameters: feature_code to check, optional pk to exclude from check
    -- Returns: 1 if exists, 0 if not
   function feature_code_exists (
      p_feature_code in varchar2,
      p_exclude_pk   in number default null
   ) return number;

    -- Check if feature name exists (for duplicate validation)
    -- Parameters: feature_name to check, optional pk to exclude from check
    -- Returns: 1 if exists, 0 if not
   function feature_name_exists (
      p_feature_name in varchar2,
      p_exclude_pk   in number default null
   ) return number;

    -- Get package version
    -- Returns: package version string
   function get_version return varchar2;

end p_features;
/