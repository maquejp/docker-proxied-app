-- P_ACCOUNTS_FEATURES_RIGHTS Package Body
-- Complete Oracle PL/SQL package implementation for managing accounts_features_rights table operations

create or replace package body p_accounts_features_rights as

    -- Create new accounts_features_rights record
   function create_record (
      p_pk_account in accounts_features_rights.pk_account%type,
      p_pk_feature in accounts_features_rights.pk_feature%type,
      p_right      in accounts_features_rights.right%type,
      p_created_by in accounts_features_rights.created_by%type
   ) return clob is
      v_new_pk accounts_features_rights.pk%type;
   begin
        -- Validate required fields
      if p_pk_account is null then
         raise_application_error(
            -20006,
            'Account ID is required'
         );
      end if;
      if p_pk_feature is null then
         raise_application_error(
            -20006,
            'Feature ID is required'
         );
      end if;
      if p_right is null
      or length(trim(p_right)) = 0 then
         raise_application_error(
            -20006,
            'Right is required'
         );
      end if;

      if p_created_by is null
      or length(trim(p_created_by)) = 0 then
         raise_application_error(
            -20006,
            'Created by is required'
         );
      end if;

        -- Validate account exists
      if is_valid_account(p_pk_account) = 0 then
         raise_application_error(
            -20003,
            'Invalid account ID'
         );
      end if;

        -- Validate feature exists
      if is_valid_feature(p_pk_feature) = 0 then
         raise_application_error(
            -20004,
            'Invalid feature ID'
         );
      end if;

        -- Validate right value
      if is_valid_right(p_right) = 0 then
         raise_application_error(
            -20005,
            'Invalid right value. Must be F (full) or R (read)'
         );
      end if;

        -- Check for duplicate assignment
      if assignment_exists(
         p_pk_account,
         p_pk_feature
      ) = 1 then
         raise_application_error(
            -20002,
            'Account-Feature assignment already exists'
         );
      end if;

        -- Insert new record
      insert into accounts_features_rights (
         pk_account,
         pk_feature,
         right,
         created_by
      ) values ( p_pk_account,
                 p_pk_feature,
                 upper(trim(p_right)),
                 trim(p_created_by) ) returning pk into v_new_pk;

        -- Return the created record as JSON
      return record_to_json(v_new_pk);
   exception
      when dup_val_on_index then
         raise_application_error(
            -20002,
            'Account-Feature assignment already exists'
         );
      when others then
         raise;
   end create_record;

    -- Update existing accounts_features_rights record
   function update_record (
      p_pk         in accounts_features_rights.pk%type,
      p_pk_account in accounts_features_rights.pk_account%type,
      p_pk_feature in accounts_features_rights.pk_feature%type,
      p_right      in accounts_features_rights.right%type
   ) return clob is
      v_rows_updated number;
   begin
        -- Validate required fields
      if p_pk is null then
         raise_application_error(
            -20006,
            'Primary key is required'
         );
      end if;
      if p_pk_account is null then
         raise_application_error(
            -20006,
            'Account ID is required'
         );
      end if;
      if p_pk_feature is null then
         raise_application_error(
            -20006,
            'Feature ID is required'
         );
      end if;
      if p_right is null
      or length(trim(p_right)) = 0 then
         raise_application_error(
            -20006,
            'Right is required'
         );
      end if;

        -- Validate account exists
      if is_valid_account(p_pk_account) = 0 then
         raise_application_error(
            -20003,
            'Invalid account ID'
         );
      end if;

        -- Validate feature exists
      if is_valid_feature(p_pk_feature) = 0 then
         raise_application_error(
            -20004,
            'Invalid feature ID'
         );
      end if;

        -- Validate right value
      if is_valid_right(p_right) = 0 then
         raise_application_error(
            -20005,
            'Invalid right value. Must be F (full) or R (read)'
         );
      end if;

        -- Check for duplicate assignment (excluding current record)
      if assignment_exists(
         p_pk_account,
         p_pk_feature,
         p_pk
      ) = 1 then
         raise_application_error(
            -20002,
            'Account-Feature assignment already exists'
         );
      end if;

        -- Update record
      update accounts_features_rights
         set pk_account = p_pk_account,
             pk_feature = p_pk_feature,
             right = upper(trim(p_right))
       where pk = p_pk;

      v_rows_updated := sql%rowcount;
        
        -- Check if record was found and updated
      if v_rows_updated = 0 then
         raise_application_error(
            -20001,
            'Record not found'
         );
      end if;

        -- Return the updated record as JSON
      return record_to_json(p_pk);
   exception
      when dup_val_on_index then
         raise_application_error(
            -20002,
            'Account-Feature assignment already exists'
         );
      when others then
         raise;
   end update_record;

    -- Delete accounts_features_rights record by primary key
   function delete_record (
      p_pk in accounts_features_rights.pk%type
   ) return clob is
      v_rows_deleted number;
   begin
        -- Validate required parameter
      if p_pk is null then
         raise_application_error(
            -20006,
            'Primary key is required'
         );
      end if;

        -- Delete record
      delete from accounts_features_rights
       where pk = p_pk;

      v_rows_deleted := sql%rowcount;
        
        -- Check if record was found and deleted
      if v_rows_deleted = 0 then
         raise_application_error(
            -20001,
            'Record not found'
         );
      end if;

        -- Return success message using json_object_t
      declare
         l_response_object json_object_t;
      begin
         l_response_object := json_object_t();
         l_response_object.put(
            'success',
            'true'
         );
         l_response_object.put(
            'message',
            'Account-Feature assignment deleted successfully'
         );
         l_response_object.put(
            'deleted_count',
            v_rows_deleted
         );
         l_response_object.put(
            'pk',
            p_pk
         );
         return l_response_object.to_clob();
      end;

   exception
      when others then
         raise;
   end delete_record;

    -- Delete accounts_features_rights record by account and feature
   function delete_by_account_feature (
      p_pk_account in accounts_features_rights.pk_account%type,
      p_pk_feature in accounts_features_rights.pk_feature%type
   ) return clob is
      v_rows_deleted number;
      v_pk           accounts_features_rights.pk%type;
   begin
        -- Validate required parameters
      if p_pk_account is null then
         raise_application_error(
            -20006,
            'Account ID is required'
         );
      end if;
      if p_pk_feature is null then
         raise_application_error(
            -20006,
            'Feature ID is required'
         );
      end if;

        -- Get the pk before deletion for response
      begin
         select pk
           into v_pk
           from accounts_features_rights
          where pk_account = p_pk_account
            and pk_feature = p_pk_feature;
      exception
         when no_data_found then
            raise_application_error(
               -20001,
               'Account-Feature assignment not found'
            );
      end;

        -- Delete record
      delete from accounts_features_rights
       where pk_account = p_pk_account
         and pk_feature = p_pk_feature;

      v_rows_deleted := sql%rowcount;

        -- Return success message using json_object_t
      declare
         l_response_object json_object_t;
      begin
         l_response_object := json_object_t();
         l_response_object.put(
            'success',
            'true'
         );
         l_response_object.put(
            'message',
            'Account-Feature assignment deleted successfully'
         );
         l_response_object.put(
            'deleted_count',
            v_rows_deleted
         );
         l_response_object.put(
            'pk',
            v_pk
         );
         l_response_object.put(
            'pk_account',
            p_pk_account
         );
         l_response_object.put(
            'pk_feature',
            p_pk_feature
         );
         return l_response_object.to_clob();
      end;

   exception
      when others then
         raise;
   end delete_by_account_feature;

    -- Convert single accounts_features_rights record to JSON with account and feature details
   function record_to_json (
      p_pk in accounts_features_rights.pk%type
   ) return clob is
      l_record_object  json_object_t;
      l_account_object json_object_t;
      l_feature_object json_object_t;
      rec              accounts_features_rights%rowtype;
      v_account_email  accounts.email%type;
      v_account_name   varchar2(200);
      v_feature_code   features.feature_code%type;
      v_feature_name   features.feature_name%type;
   begin
        -- Validate required parameter
      if p_pk is null then
         raise_application_error(
            -20006,
            'Primary key is required'
         );
      end if;

        -- Query the record
      begin
         select *
           into rec
           from accounts_features_rights
          where pk = p_pk;
      exception
         when no_data_found then
            raise_application_error(
               -20001,
               'Record not found'
            );
      end;

        -- Get account details
      begin
         select email,
                givenname
                || ' '
                || lastname
           into
            v_account_email,
            v_account_name
           from accounts
          where pk = rec.pk_account;
      exception
         when no_data_found then
            v_account_email := 'UNKNOWN';
            v_account_name := 'UNKNOWN';
      end;

        -- Get feature details
      begin
         select feature_code,
                feature_name
           into
            v_feature_code,
            v_feature_name
           from features
          where pk = rec.pk_feature;
      exception
         when no_data_found then
            v_feature_code := 'UNKNOWN';
            v_feature_name := 'UNKNOWN';
      end;

        -- Build account object
      l_account_object := json_object_t();
      l_account_object.put(
         'pk',
         rec.pk_account
      );
      l_account_object.put(
         'email',
         v_account_email
      );
      l_account_object.put(
         'name',
         v_account_name
      );

        -- Build feature object
      l_feature_object := json_object_t();
      l_feature_object.put(
         'pk',
         rec.pk_feature
      );
      l_feature_object.put(
         'feature_code',
         v_feature_code
      );
      l_feature_object.put(
         'feature_name',
         v_feature_name
      );

        -- Build main record object
      l_record_object := json_object_t();
      l_record_object.put(
         'pk',
         rec.pk
      );
      l_record_object.put(
         'pk_account',
         rec.pk_account
      );
      l_record_object.put(
         'pk_feature',
         rec.pk_feature
      );
      l_record_object.put(
         'right',
         rec.right
      );
      l_record_object.put(
         'created_on',
         to_char(
            rec.created_on,
            'YYYY-MM-DD"T"HH24:MI:SS.FF3"Z"'
         )
      );
      l_record_object.put(
         'created_by',
         rec.created_by
      );
      l_record_object.put(
         'account',
         l_account_object
      );
      l_record_object.put(
         'feature',
         l_feature_object
      );
      return l_record_object.to_clob();
   exception
      when others then
         raise;
   end record_to_json;

    -- Get single record by primary key
   function get_record (
      p_pk in accounts_features_rights.pk%type
   ) return clob is
   begin
        -- Validate required parameter
      if p_pk is null then
         raise_application_error(
            -20006,
            'Primary key is required'
         );
      end if;

        -- Convert to JSON using record_to_json function
      return record_to_json(p_pk);
   exception
      when others then
         raise;
   end get_record;

    -- Get single record by account and feature
   function get_record_by_account_feature (
      p_pk_account in accounts_features_rights.pk_account%type,
      p_pk_feature in accounts_features_rights.pk_feature%type
   ) return clob is
      v_pk accounts_features_rights.pk%type;
   begin
        -- Validate required parameters
      if p_pk_account is null then
         raise_application_error(
            -20006,
            'Account ID is required'
         );
      end if;
      if p_pk_feature is null then
         raise_application_error(
            -20006,
            'Feature ID is required'
         );
      end if;

        -- Get record PK first
      begin
         select pk
           into v_pk
           from accounts_features_rights
          where pk_account = p_pk_account
            and pk_feature = p_pk_feature;
      exception
         when no_data_found then
            raise_application_error(
               -20001,
               'Record not found'
            );
      end;

        -- Convert to JSON using record_to_json function
      return record_to_json(v_pk);
   exception
      when others then
         raise;
   end get_record_by_account_feature;

    -- Get all features for a specific account
   function get_features_by_account (
      p_pk_account   in accounts_features_rights.pk_account%type,
      p_page_number  in number default 1,
      p_page_size    in number default 20,
      p_filter_right in varchar2 default null
   ) return clob is
      v_result          clob;
      v_sql             varchar2(4000);
      v_where_clause    varchar2(1000);
      v_offset          number;
      v_limit           number;
      v_total_count     number;
      l_records_array   json_array_t;
      l_result_object   json_object_t;
      l_metadata_object json_object_t;
      type t_cursor is ref cursor;
      c_records         t_cursor;
      v_pk              accounts_features_rights.pk%type;
   begin
        -- Validate required parameter
      if p_pk_account is null then
         raise_application_error(
            -20006,
            'Account ID is required'
         );
      end if;

        -- Validate pagination parameters
      v_offset := greatest(
         (nvl(
            p_page_number,
            1
         ) - 1) * nvl(
            p_page_size,
            20
         ),
         0
      );
      v_limit := least(
         nvl(
            p_page_size,
            20
         ),
         100
      ); -- Max 100 records per page
        
        -- Build WHERE clause
      v_where_clause := 'pk_account = ' || p_pk_account;
      if p_filter_right is not null then
         v_where_clause := v_where_clause
                           || ' AND UPPER(right) = UPPER('''
                           || replace(
            p_filter_right,
            '''',
            ''''''
         )
                           || ''')';
      end if;

        -- Get total count
      v_sql := 'SELECT COUNT(*) FROM accounts_features_rights WHERE ' || v_where_clause;
      execute immediate v_sql
        into v_total_count;

        -- Build main query
      v_sql := 'SELECT pk FROM accounts_features_rights WHERE '
               || v_where_clause
               || ' ORDER BY created_on DESC OFFSET '
               || v_offset
               || ' ROWS FETCH NEXT '
               || v_limit
               || ' ROWS ONLY';

        -- Execute query and build JSON array
      l_records_array := json_array_t();
      open c_records for v_sql;
      loop
         fetch c_records into v_pk;
         exit when c_records%notfound;
         l_records_array.append(json_object_t.parse(record_to_json(v_pk)));
      end loop;
      close c_records;

        -- Build metadata object
      l_metadata_object := json_object_t();
      l_metadata_object.put(
         'page',
         p_page_number
      );
      l_metadata_object.put(
         'page_size',
         v_limit
      );
      l_metadata_object.put(
         'total_count',
         v_total_count
      );
      l_metadata_object.put(
         'total_pages',
         ceil(v_total_count / v_limit)
      );
      l_metadata_object.put(
         'has_next_page',
         case
            when(p_page_number * v_limit) < v_total_count then
                  'true'
            else
               'false'
         end
      );
      l_metadata_object.put(
         'has_previous_page',
         case
            when p_page_number > 1 then
                  'true'
            else
               'false'
         end
      );

        -- Build final result object
      l_result_object := json_object_t();
      l_result_object.put(
         'data',
         l_records_array
      );
      l_result_object.put(
         'metadata',
         l_metadata_object
      );
      return l_result_object.to_clob();
   exception
      when others then
         if c_records%isopen then
            close c_records;
         end if;
         raise;
   end get_features_by_account;

    -- Get all accounts for a specific feature
   function get_accounts_by_feature (
      p_pk_feature   in accounts_features_rights.pk_feature%type,
      p_page_number  in number default 1,
      p_page_size    in number default 20,
      p_filter_right in varchar2 default null
   ) return clob is
      v_result          clob;
      v_sql             varchar2(4000);
      v_where_clause    varchar2(1000);
      v_offset          number;
      v_limit           number;
      v_total_count     number;
      l_records_array   json_array_t;
      l_result_object   json_object_t;
      l_metadata_object json_object_t;
      type t_cursor is ref cursor;
      c_records         t_cursor;
      v_pk              accounts_features_rights.pk%type;
   begin
        -- Validate required parameter
      if p_pk_feature is null then
         raise_application_error(
            -20006,
            'Feature ID is required'
         );
      end if;

        -- Validate pagination parameters
      v_offset := greatest(
         (nvl(
            p_page_number,
            1
         ) - 1) * nvl(
            p_page_size,
            20
         ),
         0
      );
      v_limit := least(
         nvl(
            p_page_size,
            20
         ),
         100
      ); -- Max 100 records per page
        
        -- Build WHERE clause
      v_where_clause := 'pk_feature = ' || p_pk_feature;
      if p_filter_right is not null then
         v_where_clause := v_where_clause
                           || ' AND UPPER(right) = UPPER('''
                           || replace(
            p_filter_right,
            '''',
            ''''''
         )
                           || ''')';
      end if;

        -- Get total count
      v_sql := 'SELECT COUNT(*) FROM accounts_features_rights WHERE ' || v_where_clause;
      execute immediate v_sql
        into v_total_count;

        -- Build main query
      v_sql := 'SELECT pk FROM accounts_features_rights WHERE '
               || v_where_clause
               || ' ORDER BY created_on DESC OFFSET '
               || v_offset
               || ' ROWS FETCH NEXT '
               || v_limit
               || ' ROWS ONLY';

        -- Execute query and build JSON array
      l_records_array := json_array_t();
      open c_records for v_sql;
      loop
         fetch c_records into v_pk;
         exit when c_records%notfound;
         l_records_array.append(json_object_t.parse(record_to_json(v_pk)));
      end loop;
      close c_records;

        -- Build metadata object
      l_metadata_object := json_object_t();
      l_metadata_object.put(
         'page',
         p_page_number
      );
      l_metadata_object.put(
         'page_size',
         v_limit
      );
      l_metadata_object.put(
         'total_count',
         v_total_count
      );
      l_metadata_object.put(
         'total_pages',
         ceil(v_total_count / v_limit)
      );
      l_metadata_object.put(
         'has_next_page',
         case
            when(p_page_number * v_limit) < v_total_count then
                  'true'
            else
               'false'
         end
      );
      l_metadata_object.put(
         'has_previous_page',
         case
            when p_page_number > 1 then
                  'true'
            else
               'false'
         end
      );

        -- Build final result object
      l_result_object := json_object_t();
      l_result_object.put(
         'data',
         l_records_array
      );
      l_result_object.put(
         'metadata',
         l_metadata_object
      );
      return l_result_object.to_clob();
   exception
      when others then
         if c_records%isopen then
            close c_records;
         end if;
         raise;
   end get_accounts_by_feature;

    -- Get multiple records with pagination, ordering, and filtering
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
   ) return clob is
      v_result          clob;
      v_sql             varchar2(4000);
      v_where_clause    varchar2(1000) := '';
      v_order_clause    varchar2(200);
      v_offset          number;
      v_limit           number;
      v_total_count     number;
      l_records_array   json_array_t;
      l_result_object   json_object_t;
      l_metadata_object json_object_t;
      type t_cursor is ref cursor;
      c_records         t_cursor;
      v_pk              accounts_features_rights.pk%type;
   begin
        -- Validate pagination parameters
      v_offset := greatest(
         (nvl(
            p_page_number,
            1
         ) - 1) * nvl(
            p_page_size,
            20
         ),
         0
      );
      v_limit := least(
         nvl(
            p_page_size,
            20
         ),
         100
      ); -- Max 100 records per page
        
        -- Build WHERE clause for filtering
      v_where_clause := '1=1';
      if p_filter_account is not null then
         v_where_clause := v_where_clause
                           || ' AND pk_account = '
                           || p_filter_account;
      end if;

      if p_filter_feature is not null then
         v_where_clause := v_where_clause
                           || ' AND pk_feature = '
                           || p_filter_feature;
      end if;

      if p_filter_right is not null then
         v_where_clause := v_where_clause
                           || ' AND UPPER(right) = UPPER('''
                           || replace(
            p_filter_right,
            '''',
            ''''''
         )
                           || ''')';
      end if;
        
        -- Build ORDER BY clause
      v_order_clause :=
         case upper(p_order_by)
            when 'PK_ACCOUNT' then
               'pk_account'
            when 'PK_FEATURE' then
               'pk_feature'
            when 'RIGHT'      then
               'right'
            when 'CREATED_ON' then
               'created_on'
            else
               'created_on'
         end;

      v_order_clause := v_order_clause
                        ||
         case upper(nvl(
            p_order_dir,
            'DESC'
         ))
            when 'ASC' then
               ' ASC'
            else
               ' DESC'
         end;

        -- Get total count for metadata
      v_total_count := get_record_count(
         p_filter_account,
         p_filter_feature,
         p_filter_right,
         p_created_after,
         p_created_before
      );

        -- Build main query to get only primary keys
      v_sql := 'SELECT pk '
               || 'FROM accounts_features_rights WHERE '
               || v_where_clause
               || ' ORDER BY '
               || v_order_clause
               || ' OFFSET '
               || v_offset
               || ' ROWS FETCH NEXT '
               || v_limit
               || ' ROWS ONLY';

        -- Execute query and build JSON array
      l_records_array := json_array_t();
      open c_records for v_sql;
      loop
         fetch c_records into v_pk;
         exit when c_records%notfound;
         l_records_array.append(json_object_t.parse(record_to_json(v_pk)));
      end loop;
      close c_records;

        -- Build metadata object
      l_metadata_object := json_object_t();
      l_metadata_object.put(
         'page',
         p_page_number
      );
      l_metadata_object.put(
         'page_size',
         v_limit
      );
      l_metadata_object.put(
         'total_count',
         v_total_count
      );
      l_metadata_object.put(
         'total_pages',
         ceil(v_total_count / v_limit)
      );
      l_metadata_object.put(
         'has_next_page',
         case
            when(p_page_number * v_limit) < v_total_count then
                  'true'
            else
               'false'
         end
      );
      l_metadata_object.put(
         'has_previous_page',
         case
            when p_page_number > 1 then
                  'true'
            else
               'false'
         end
      );

        -- Build final result object
      l_result_object := json_object_t();
      l_result_object.put(
         'data',
         l_records_array
      );
      l_result_object.put(
         'metadata',
         l_metadata_object
      );
      return l_result_object.to_clob();
   exception
      when others then
         if c_records%isopen then
            close c_records;
         end if;
         raise;
   end get_records;

    -- Get total count of records (with optional filtering)
   function get_record_count (
      p_filter_account in number default null,
      p_filter_feature in number default null,
      p_filter_right   in varchar2 default null,
      p_created_after  in timestamp default null,
      p_created_before in timestamp default null
   ) return number is
      v_count        number;
      v_sql          varchar2(2000);
      v_where_clause varchar2(1000) := '1=1';
   begin
        -- Build WHERE clause for filtering
      if p_filter_account is not null then
         v_where_clause := v_where_clause
                           || ' AND pk_account = '
                           || p_filter_account;
      end if;

      if p_filter_feature is not null then
         v_where_clause := v_where_clause
                           || ' AND pk_feature = '
                           || p_filter_feature;
      end if;

      if p_filter_right is not null then
         v_where_clause := v_where_clause
                           || ' AND UPPER(right) = UPPER('''
                           || replace(
            p_filter_right,
            '''',
            ''''''
         )
                           || ''')';
      end if;

      v_sql := 'SELECT COUNT(*) FROM accounts_features_rights WHERE ' || v_where_clause;
      execute immediate v_sql
        into v_count;
      return v_count;
   exception
      when others then
         raise;
   end get_record_count;

    -- Check if account and feature combination already exists
   function assignment_exists (
      p_pk_account in accounts_features_rights.pk_account%type,
      p_pk_feature in accounts_features_rights.pk_feature%type,
      p_exclude_pk in number default null
   ) return number is
      v_count number;
   begin
      if p_pk_account is null
      or p_pk_feature is null then
         return 0;
      end if;
      if p_exclude_pk is null then
         select count(*)
           into v_count
           from accounts_features_rights
          where pk_account = p_pk_account
            and pk_feature = p_pk_feature;
      else
         select count(*)
           into v_count
           from accounts_features_rights
          where pk_account = p_pk_account
            and pk_feature = p_pk_feature
            and pk != p_exclude_pk;
      end if;

      return
         case
            when v_count > 0 then
               1
            else
               0
         end;
   exception
      when others then
         return 0;
   end assignment_exists;

    -- Validate account exists in accounts table
   function is_valid_account (
      p_pk_account in number
   ) return number is
      v_count number;
   begin
      if p_pk_account is null then
         return 0;
      end if;
      select count(*)
        into v_count
        from accounts
       where pk = p_pk_account;

      return
         case
            when v_count > 0 then
               1
            else
               0
         end;
   exception
      when others then
         return 0;
   end is_valid_account;

    -- Validate feature exists in features table
   function is_valid_feature (
      p_pk_feature in number
   ) return number is
      v_count number;
   begin
      if p_pk_feature is null then
         return 0;
      end if;
      select count(*)
        into v_count
        from features
       where pk = p_pk_feature;

      return
         case
            when v_count > 0 then
               1
            else
               0
         end;
   exception
      when others then
         return 0;
   end is_valid_feature;

    -- Validate right value (F or R)
   function is_valid_right (
      p_right in varchar2
   ) return number is
   begin
      if p_right is null then
         return 0;
      end if;
      if upper(trim(p_right)) in ( 'F',
                                   'R' ) then
         return 1;
      else
         return 0;
      end if;

   exception
      when others then
         return 0;
   end is_valid_right;

    -- Get package version
   function get_version return varchar2 is
   begin
      return c_package_version;
   end get_version;

end p_accounts_features_rights;
/