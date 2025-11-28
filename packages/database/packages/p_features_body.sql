-- P_FEATURES Package Body
-- Complete Oracle PL/SQL package implementation for managing features table operations

create or replace package body p_features as

    -- Create new feature record
   function create_record (
      p_feature_code in features.feature_code%type,
      p_feature_name in features.feature_name%type,
      p_created_by   in features.created_by%type
   ) return clob is
      v_new_pk features.pk%type;
   begin
        -- Validate required fields
      if p_feature_code is null
      or length(trim(p_feature_code)) = 0 then
         raise_application_error(
            -20005,
            'Feature code is required'
         );
      end if;

      if p_feature_name is null
      or length(trim(p_feature_name)) = 0 then
         raise_application_error(
            -20005,
            'Feature name is required'
         );
      end if;

      if p_created_by is null
      or length(trim(p_created_by)) = 0 then
         raise_application_error(
            -20005,
            'Created by is required'
         );
      end if;

        -- Check for duplicate feature code
      if feature_code_exists(p_feature_code) = 1 then
         raise_application_error(
            -20002,
            'Feature code already exists'
         );
      end if;

        -- Check for duplicate feature name
      if feature_name_exists(p_feature_name) = 1 then
         raise_application_error(
            -20003,
            'Feature name already exists'
         );
      end if;

        -- Insert new record
      insert into features (
         feature_code,
         feature_name,
         created_by,
         modified_by
      ) values ( upper(trim(p_feature_code)),
                 trim(p_feature_name),
                 trim(p_created_by),
                 trim(p_created_by) ) returning pk into v_new_pk;

        -- Return the created record as JSON
      return record_to_json(v_new_pk);
   exception
      when dup_val_on_index then
         if instr(
            upper(sqlerrm),
            'UK_FEATURES_CODE'
         ) > 0 then
            raise_application_error(
               -20002,
               'Feature code already exists'
            );
         elsif instr(
            upper(sqlerrm),
            'UK_FEATURES_NAME'
         ) > 0 then
            raise_application_error(
               -20003,
               'Feature name already exists'
            );
         else
            raise;
         end if;
      when others then
         raise;
   end create_record;

    -- Update existing feature record
   function update_record (
      p_pk           in features.pk%type,
      p_feature_code in features.feature_code%type,
      p_feature_name in features.feature_name%type,
      p_modified_by  in features.modified_by%type
   ) return clob is
      v_rows_updated number;
   begin
        -- Validate required fields
      if p_pk is null then
         raise_application_error(
            -20005,
            'Primary key is required'
         );
      end if;
      if p_feature_code is null
      or length(trim(p_feature_code)) = 0 then
         raise_application_error(
            -20005,
            'Feature code is required'
         );
      end if;

      if p_feature_name is null
      or length(trim(p_feature_name)) = 0 then
         raise_application_error(
            -20005,
            'Feature name is required'
         );
      end if;

      if p_modified_by is null
      or length(trim(p_modified_by)) = 0 then
         raise_application_error(
            -20005,
            'Modified by is required'
         );
      end if;

        -- Check for duplicate feature code (excluding current record)
      if feature_code_exists(
         p_feature_code,
         p_pk
      ) = 1 then
         raise_application_error(
            -20002,
            'Feature code already exists'
         );
      end if;

        -- Check for duplicate feature name (excluding current record)
      if feature_name_exists(
         p_feature_name,
         p_pk
      ) = 1 then
         raise_application_error(
            -20003,
            'Feature name already exists'
         );
      end if;

        -- Update record
      update features
         set feature_code = upper(trim(p_feature_code)),
             feature_name = trim(p_feature_name),
             modified_by = trim(p_modified_by)
       where pk = p_pk;

      v_rows_updated := sql%rowcount;
        
        -- Check if record was found and updated
      if v_rows_updated = 0 then
         raise_application_error(
            -20001,
            'Feature not found'
         );
      end if;

        -- Return the updated record as JSON
      return record_to_json(p_pk);
   exception
      when dup_val_on_index then
         if instr(
            upper(sqlerrm),
            'UK_FEATURES_CODE'
         ) > 0 then
            raise_application_error(
               -20002,
               'Feature code already exists'
            );
         elsif instr(
            upper(sqlerrm),
            'UK_FEATURES_NAME'
         ) > 0 then
            raise_application_error(
               -20003,
               'Feature name already exists'
            );
         else
            raise;
         end if;
      when others then
         raise;
   end update_record;

    -- Delete feature record by primary key
   function delete_record (
      p_pk in features.pk%type
   ) return clob is
      v_rows_deleted number;
   begin
        -- Validate required parameter
      if p_pk is null then
         raise_application_error(
            -20005,
            'Primary key is required'
         );
      end if;

        -- Delete record
      delete from features
       where pk = p_pk;

      v_rows_deleted := sql%rowcount;
        
        -- Check if record was found and deleted
      if v_rows_deleted = 0 then
         raise_application_error(
            -20001,
            'Feature not found'
         );
      end if;

        -- Return success message with deleted record count using json_object_t
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
            'Feature deleted successfully'
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

    -- Convert single feature record to JSON
   function record_to_json (
      p_pk in features.pk%type
   ) return clob is
      l_record_object json_object_t;
      rec             features%rowtype;
   begin
        -- Validate required parameter
      if p_pk is null then
         raise_application_error(
            -20005,
            'Primary key is required'
         );
      end if;

        -- Query the feature record
      begin
         select *
           into rec
           from features
          where pk = p_pk;
      exception
         when no_data_found then
            raise_application_error(
               -20001,
               'Feature not found'
            );
      end;

        -- Build JSON using json_object_t
      l_record_object := json_object_t();
      l_record_object.put(
         'pk',
         rec.pk
      );
      l_record_object.put(
         'feature_code',
         rec.feature_code
      );
      l_record_object.put(
         'feature_name',
         rec.feature_name
      );
      l_record_object.put(
         'created_on',
         to_char(
            rec.created_on,
            'YYYY-MM-DD"T"HH24:MI:SS.FF3"Z"'
         )
      );
      l_record_object.put(
         'modified_on',
         to_char(
            rec.modified_on,
            'YYYY-MM-DD"T"HH24:MI:SS.FF3"Z"'
         )
      );
      l_record_object.put(
         'created_by',
         rec.created_by
      );
      l_record_object.put(
         'modified_by',
         rec.modified_by
      );
      return l_record_object.to_clob();
   exception
      when others then
         raise;
   end record_to_json;

    -- Get single feature record by primary key
   function get_record (
      p_pk in features.pk%type
   ) return clob is
      v_result clob;
   begin
        -- Validate required parameter
      if p_pk is null then
         raise_application_error(
            -20005,
            'Primary key is required'
         );
      end if;

        -- Convert to JSON using record_to_json function
      v_result := record_to_json(p_pk);
      return v_result;
   exception
      when others then
         raise;
   end get_record;

    -- Get single feature record by feature code
   function get_record_by_code (
      p_feature_code in features.feature_code%type
   ) return clob is
      v_result clob;
      v_pk     features.pk%type;
   begin
        -- Validate required parameter
      if p_feature_code is null
      or length(trim(p_feature_code)) = 0 then
         raise_application_error(
            -20005,
            'Feature code is required'
         );
      end if;

        -- Get record PK first
      begin
         select pk
           into v_pk
           from features
          where upper(feature_code) = upper(trim(p_feature_code));
      exception
         when no_data_found then
            raise_application_error(
               -20001,
               'Feature not found'
            );
      end;

        -- Convert to JSON using record_to_json function
      v_result := record_to_json(v_pk);
      return v_result;
   exception
      when others then
         raise;
   end get_record_by_code;

    -- Get single feature record by feature name
   function get_record_by_name (
      p_feature_name in features.feature_name%type
   ) return clob is
      v_result clob;
      v_pk     features.pk%type;
   begin
        -- Validate required parameter
      if p_feature_name is null
      or length(trim(p_feature_name)) = 0 then
         raise_application_error(
            -20005,
            'Feature name is required'
         );
      end if;

        -- Get record PK first
      begin
         select pk
           into v_pk
           from features
          where lower(feature_name) = lower(trim(p_feature_name));
      exception
         when no_data_found then
            raise_application_error(
               -20001,
               'Feature not found'
            );
      end;

        -- Convert to JSON using record_to_json function
      v_result := record_to_json(v_pk);
      return v_result;
   exception
      when others then
         raise;
   end get_record_by_name;

    -- Get multiple feature records with pagination, ordering, and filtering
   function get_records (
      p_page_number    in number default 1,
      p_page_size      in number default 20,
      p_order_by       in varchar2 default 'created_on',
      p_order_dir      in varchar2 default 'DESC',
      p_filter_code    in varchar2 default null,
      p_filter_name    in varchar2 default null,
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
      c_features        t_cursor;
      v_pk              features.pk%type;
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
      if p_filter_code is not null then
         v_where_clause := v_where_clause
                           || ' AND UPPER(feature_code) LIKE UPPER(''%'
                           || replace(
            p_filter_code,
            '''',
            ''''''
         )
                           || '%'')';
      end if;

      if p_filter_name is not null then
         v_where_clause := v_where_clause
                           || ' AND LOWER(feature_name) LIKE LOWER(''%'
                           || replace(
            p_filter_name,
            '''',
            ''''''
         )
                           || '%'')';
      end if;
        
        -- Build ORDER BY clause
      v_order_clause :=
         case upper(p_order_by)
            when 'FEATURE_CODE' then
               'feature_code'
            when 'FEATURE_NAME' then
               'feature_name'
            when 'CREATED_ON'   then
               'created_on'
            when 'MODIFIED_ON'  then
               'modified_on'
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
         p_filter_code,
         p_filter_name,
         p_created_after,
         p_created_before
      );

        -- Build main query to get only primary keys
      v_sql := 'SELECT pk '
               || 'FROM features WHERE '
               || v_where_clause
               || ' ORDER BY '
               || v_order_clause
               || ' OFFSET '
               || v_offset
               || ' ROWS FETCH NEXT '
               || v_limit
               || ' ROWS ONLY';

        -- Execute query and build JSON array using json_array_t
      l_records_array := json_array_t();
      open c_features for v_sql;
      loop
         fetch c_features into v_pk;
         exit when c_features%notfound;
            
            -- Add each record to the array using record_to_json
         l_records_array.append(json_object_t.parse(record_to_json(v_pk)));
      end loop;
      close c_features;

        -- Build metadata object using json_object_t
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
         if c_features%isopen then
            close c_features;
         end if;
         raise;
   end get_records;

    -- Get total count of features (with optional filtering)
   function get_record_count (
      p_filter_code    in varchar2 default null,
      p_filter_name    in varchar2 default null,
      p_created_after  in timestamp default null,
      p_created_before in timestamp default null
   ) return number is
      v_count        number;
      v_sql          varchar2(2000);
      v_where_clause varchar2(1000) := '1=1';
   begin
        -- Build WHERE clause for filtering (same logic as get_records)
      if p_filter_code is not null then
         v_where_clause := v_where_clause
                           || ' AND UPPER(feature_code) LIKE UPPER(''%'
                           || replace(
            p_filter_code,
            '''',
            ''''''
         )
                           || '%'')';
      end if;

      if p_filter_name is not null then
         v_where_clause := v_where_clause
                           || ' AND LOWER(feature_name) LIKE LOWER(''%'
                           || replace(
            p_filter_name,
            '''',
            ''''''
         )
                           || '%'')';
      end if;

      v_sql := 'SELECT COUNT(*) FROM features WHERE ' || v_where_clause;
      execute immediate v_sql
        into v_count;
      return v_count;
   exception
      when others then
         raise;
   end get_record_count;

    -- Check if feature code exists (for duplicate validation)
   function feature_code_exists (
      p_feature_code in varchar2,
      p_exclude_pk   in number default null
   ) return number is
      v_count number;
   begin
      if p_feature_code is null then
         return 0;
      end if;
      if p_exclude_pk is null then
         select count(*)
           into v_count
           from features
          where upper(feature_code) = upper(trim(p_feature_code));
      else
         select count(*)
           into v_count
           from features
          where upper(feature_code) = upper(trim(p_feature_code))
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
   end feature_code_exists;

    -- Check if feature name exists (for duplicate validation)
   function feature_name_exists (
      p_feature_name in varchar2,
      p_exclude_pk   in number default null
   ) return number is
      v_count number;
   begin
      if p_feature_name is null then
         return 0;
      end if;
      if p_exclude_pk is null then
         select count(*)
           into v_count
           from features
          where lower(feature_name) = lower(trim(p_feature_name));
      else
         select count(*)
           into v_count
           from features
          where lower(feature_name) = lower(trim(p_feature_name))
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
   end feature_name_exists;

    -- Get package version
   function get_version return varchar2 is
   begin
      return c_package_version;
   end get_version;

end p_features;
/