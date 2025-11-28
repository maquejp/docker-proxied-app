-- Package Body: p_sessions
-- Purpose: Complete implementation of session management with JWT token validation
-- Created for: Docker Proxied App - Phase 2 Database Foundation
-- Features: CRUD operations, token validation, session lifecycle, JSON responses

create or replace package body p_sessions as

    -- Standard CRUD Operations Implementation

   function create_record (
      p_pk_account       in sessions.pk_account%type,
      p_token            in sessions.token%type,
      p_session_start    in sessions.session_start%type default systimestamp,
      p_session_end      in sessions.session_end%type default null,
      p_session_duration in sessions.session_duration%type default 600
   ) return clob is
      v_result         json_object_t := json_object_t();
      v_session_record sessions%rowtype;
      v_calculated_end sessions.session_end%type;
      v_pk             sessions.pk%type;
   begin
        -- Input validation
      if p_pk_account is null then
         v_result.put(
            'success',
            false
         );
         v_result.put(
            'error',
            'Account ID is required'
         );
         return v_result.to_clob();
      end if;

      if p_token is null
      or length(trim(p_token)) = 0 then
         v_result.put(
            'success',
            false
         );
         v_result.put(
            'error',
            'Token is required'
         );
         return v_result.to_clob();
      end if;

        -- Validate account exists
      if is_valid_account(p_pk_account) = 'N' then
         v_result.put(
            'success',
            false
         );
         v_result.put(
            'error',
            'Invalid account ID'
         );
         return v_result.to_clob();
      end if;

        -- Validate token uniqueness
      if is_token_unique(p_token) = 'N' then
         v_result.put(
            'success',
            false
         );
         v_result.put(
            'error',
            'Token already exists'
         );
         return v_result.to_clob();
      end if;

        -- Calculate session end time if not provided
      v_calculated_end := nvl(
         p_session_end,
         p_session_start + interval '1' minute * p_session_duration
      );

        -- Get next primary key
      select sessions_seq.nextval
        into v_pk
        from dual;

        -- Insert new session
      insert into sessions (
         pk,
         pk_account,
         token,
         session_start,
         session_end,
         session_duration
      ) values ( v_pk,
                 p_pk_account,
                 p_token,
                 p_session_start,
                 v_calculated_end,
                 p_session_duration ) returning pk,
                                                pk_account,
                                                token,
                                                session_start,
                                                session_end,
                                                session_duration into v_session_record.pk,v_session_record.pk_account,v_session_record.token
                                                ,v_session_record.session_start,v_session_record.session_end,v_session_record.session_duration
                                                ;

        -- Build success response with created session
      v_result.put(
         'success',
         true
      );
      v_result.put(
         'message',
         'Session created successfully'
      );
      v_result.put(
         'session',
         record_to_json(v_session_record)
      );
      return v_result.to_clob();
   exception
      when dup_val_on_index then
         v_result := json_object_t();
         v_result.put(
            'success',
            false
         );
         v_result.put(
            'error',
            'Token already exists'
         );
         return v_result.to_clob();
      when others then
         v_result := json_object_t();
         v_result.put(
            'success',
            false
         );
         v_result.put(
            'error',
            'Database error: ' || sqlerrm
         );
         return v_result.to_clob();
   end create_record;

   function update_record (
      p_pk               in sessions.pk%type,
      p_pk_account       in sessions.pk_account%type,
      p_token            in sessions.token%type,
      p_session_start    in sessions.session_start%type,
      p_session_end      in sessions.session_end%type,
      p_session_duration in sessions.session_duration%type
   ) return clob is
      v_result         json_object_t := json_object_t();
      v_session_record sessions%rowtype;
      v_count          number;
   begin
        -- Input validation
      if p_pk is null then
         v_result.put(
            'success',
            false
         );
         v_result.put(
            'error',
            'Session ID is required'
         );
         return v_result.to_clob();
      end if;

      if p_pk_account is null then
         v_result.put(
            'success',
            false
         );
         v_result.put(
            'error',
            'Account ID is required'
         );
         return v_result.to_clob();
      end if;

      if p_token is null
      or length(trim(p_token)) = 0 then
         v_result.put(
            'success',
            false
         );
         v_result.put(
            'error',
            'Token is required'
         );
         return v_result.to_clob();
      end if;

        -- Check if session exists
      select count(*)
        into v_count
        from sessions
       where pk = p_pk;
      if v_count = 0 then
         v_result.put(
            'success',
            false
         );
         v_result.put(
            'error',
            'Session not found'
         );
         return v_result.to_clob();
      end if;

        -- Validate account exists
      if is_valid_account(p_pk_account) = 'N' then
         v_result.put(
            'success',
            false
         );
         v_result.put(
            'error',
            'Invalid account ID'
         );
         return v_result.to_clob();
      end if;

        -- Validate token uniqueness (excluding current record)
      if is_token_unique(
         p_token,
         p_pk
      ) = 'N' then
         v_result.put(
            'success',
            false
         );
         v_result.put(
            'error',
            'Token already exists'
         );
         return v_result.to_clob();
      end if;

        -- Update session
      update sessions
         set pk_account = p_pk_account,
             token = p_token,
             session_start = p_session_start,
             session_end = p_session_end,
             session_duration = p_session_duration
       where pk = p_pk returning pk,
                                 pk_account,
                                 token,
                                 session_start,
                                 session_end,
                                 session_duration into v_session_record.pk,v_session_record.pk_account,v_session_record.token
                                 ,v_session_record.session_start,v_session_record.session_end,v_session_record.session_duration
                                 ;

        -- Build success response
      v_result.put(
         'success',
         true
      );
      v_result.put(
         'message',
         'Session updated successfully'
      );
      v_result.put(
         'session',
         record_to_json(v_session_record)
      );
      return v_result.to_clob();
   exception
      when dup_val_on_index then
         v_result := json_object_t();
         v_result.put(
            'success',
            false
         );
         v_result.put(
            'error',
            'Token already exists'
         );
         return v_result.to_clob();
      when others then
         v_result := json_object_t();
         v_result.put(
            'success',
            false
         );
         v_result.put(
            'error',
            'Database error: ' || sqlerrm
         );
         return v_result.to_clob();
   end update_record;

   function delete_record (
      p_pk in sessions.pk%type
   ) return clob is
      v_result json_object_t := json_object_t();
      v_count  number;
   begin
        -- Input validation
      if p_pk is null then
         v_result.put(
            'success',
            false
         );
         v_result.put(
            'error',
            'Session ID is required'
         );
         return v_result.to_clob();
      end if;

        -- Delete session
      delete from sessions
       where pk = p_pk;
      v_count := sql%rowcount;
      if v_count = 0 then
         v_result.put(
            'success',
            false
         );
         v_result.put(
            'error',
            'Session not found'
         );
         return v_result.to_clob();
      end if;

        -- Build success response
      v_result.put(
         'success',
         true
      );
      v_result.put(
         'message',
         'Session deleted successfully'
      );
      v_result.put(
         'deleted_count',
         v_count
      );
      return v_result.to_clob();
   exception
      when others then
         v_result := json_object_t();
         v_result.put(
            'success',
            false
         );
         v_result.put(
            'error',
            'Database error: ' || sqlerrm
         );
         return v_result.to_clob();
   end delete_record;

   function get_record (
      p_pk in sessions.pk%type
   ) return clob is
      v_result         json_object_t := json_object_t();
      v_session_record sessions%rowtype;
   begin
        -- Input validation
      if p_pk is null then
         v_result.put(
            'success',
            false
         );
         v_result.put(
            'error',
            'Session ID is required'
         );
         return v_result.to_clob();
      end if;

        -- Get session record
      select *
        into v_session_record
        from sessions
       where pk = p_pk;

        -- Build success response
      v_result.put(
         'success',
         true
      );
      v_result.put(
         'session',
         record_to_json(v_session_record)
      );
      return v_result.to_clob();
   exception
      when no_data_found then
         v_result := json_object_t();
         v_result.put(
            'success',
            false
         );
         v_result.put(
            'error',
            'Session not found'
         );
         return v_result.to_clob();
      when others then
         v_result := json_object_t();
         v_result.put(
            'success',
            false
         );
         v_result.put(
            'error',
            'Database error: ' || sqlerrm
         );
         return v_result.to_clob();
   end get_record;

   function get_records (
      p_page_number        in number default 1,
      p_page_size          in number default 10,
      p_order_by           in varchar2 default 'session_start',
      p_order_direction    in varchar2 default 'DESC',
      p_filter_account     in sessions.pk_account%type default null,
      p_filter_active_only in varchar2 default 'N'
   ) return clob is
      v_result         json_object_t := json_object_t();
      v_sessions       json_array_t := json_array_t();
      v_session_record sessions%rowtype;
      v_total_count    number;
      v_offset         number;
      v_limit          number;
      v_where_clause   varchar2(1000) := '1=1';
      v_order_clause   varchar2(200);
      v_sql            varchar2(4000);
      v_count_sql      varchar2(4000);
      cur              sys_refcursor;
   begin
        -- Input validation and defaults
      v_offset := greatest(
         0,
         (nvl(
            p_page_number,
            1
         ) - 1) * least(
            nvl(
               p_page_size,
               10
            ),
            100
         )
      );
      v_limit := least(
         nvl(
            p_page_size,
            10
         ),
         100
      );

        -- Build WHERE clause
      if p_filter_account is not null then
         v_where_clause := v_where_clause
                           || ' AND pk_account = '
                           || p_filter_account;
      end if;

      if nvl(
         p_filter_active_only,
         'N'
      ) = 'Y' then
         v_where_clause := v_where_clause || ' AND SYSTIMESTAMP BETWEEN session_start AND session_end';
      end if;

        -- Build ORDER BY clause with validation
      v_order_clause := 'ORDER BY ';
      case lower(nvl(
         p_order_by,
         'session_start'
      ))
         when 'pk' then
            v_order_clause := v_order_clause || 'pk';
         when 'pk_account' then
            v_order_clause := v_order_clause || 'pk_account';
         when 'token' then
            v_order_clause := v_order_clause || 'token';
         when 'session_start' then
            v_order_clause := v_order_clause || 'session_start';
         when 'session_end' then
            v_order_clause := v_order_clause || 'session_end';
         when 'session_duration' then
            v_order_clause := v_order_clause || 'session_duration';
         else
            v_order_clause := v_order_clause || 'session_start';
      end case;

      if upper(nvl(
         p_order_direction,
         'DESC'
      )) = 'ASC' then
         v_order_clause := v_order_clause || ' ASC';
      else
         v_order_clause := v_order_clause || ' DESC';
      end if;

        -- Get total count
      v_count_sql := 'SELECT COUNT(*) FROM sessions WHERE ' || v_where_clause;
      execute immediate v_count_sql
        into v_total_count;

        -- Build main query with pagination
      v_sql := 'SELECT * FROM (
                    SELECT s.*, ROW_NUMBER() OVER ('
               || v_order_clause
               || ') as rn 
                    FROM sessions s 
                    WHERE '
               || v_where_clause
               || '
                  ) WHERE rn > '
               || v_offset
               || ' AND rn <= '
               || ( v_offset + v_limit );

        -- Execute query and build JSON array
      open cur for v_sql;
      loop
         fetch cur into v_session_record;
         exit when cur%notfound;
         v_sessions.append(record_to_json(v_session_record));
      end loop;
      close cur;

        -- Build response with pagination metadata
      v_result.put(
         'success',
         true
      );
      v_result.put(
         'sessions',
         v_sessions
      );
      v_result.put(
         'pagination',
         json_object_t('{
                "page_number": '
                       || nvl(
            p_page_number,
            1
         )
                       || ',
                "page_size": '
                       || v_limit
                       || ',
                "total_records": '
                       || v_total_count
                       || ',
                "total_pages": '
                       || ceil(v_total_count / v_limit) || '
            }')
      );
      v_result.put(
         'filters',
         json_object_t('{
                "account_filter": '
                       ||
            case
               when p_filter_account is null then
                  'null'
               else
                  '"'
                  || p_filter_account
                  || '"'
            end
                       || ',
                "active_only": "'
                       || nvl(
            p_filter_active_only,
            'N'
         )
                       || '",
                "order_by": "'
                       || nvl(
            p_order_by,
            'session_start'
         )
                       || '",
                "order_direction": "'
                       || nvl(
            p_order_direction,
            'DESC'
         ) || '"
            }')
      );

      return v_result.to_clob();
   exception
      when others then
         if cur%isopen then
            close cur;
         end if;
         v_result := json_object_t();
         v_result.put(
            'success',
            false
         );
         v_result.put(
            'error',
            'Database error: ' || sqlerrm
         );
         return v_result.to_clob();
   end get_records;

    -- Specialized Session Management Functions Implementation

   function validate_token (
      p_token in sessions.token%type
   ) return clob is
      v_result         json_object_t := json_object_t();
      v_session_record sessions%rowtype;
      v_is_active      varchar2(1);
      v_account_info   json_object_t;
   begin
        -- Input validation
      if p_token is null
      or length(trim(p_token)) = 0 then
         v_result.put(
            'success',
            false
         );
         v_result.put(
            'valid',
            false
         );
         v_result.put(
            'error',
            'Token is required'
         );
         return v_result.to_clob();
      end if;

        -- Find session by token
      select *
        into v_session_record
        from sessions
       where token = p_token;

        -- Check if session is active
      v_is_active := is_session_active(
         v_session_record.session_start,
         v_session_record.session_end
      );

        -- Get account information
      select
         json_object(
            'pk' value a.pk,
                     'givenname' value a.givenname,
                     'lastname' value a.lastname,
                     'unikid' value a.unikid,
                     'email' value a.email
         )
        into v_account_info
        from accounts a
       where a.pk = v_session_record.pk_account;

        -- Build response
      v_result.put(
         'success',
         true
      );
      v_result.put(
         'valid',
         case
            when v_is_active = 'Y' then
                  true
            else
               false
         end
      );
      v_result.put(
         'active',
         case
            when v_is_active = 'Y' then
                  true
            else
               false
         end
      );
      v_result.put(
         'session',
         record_to_json(v_session_record)
      );
      v_result.put(
         'account',
         v_account_info
      );
      if v_is_active = 'N' then
         v_result.put(
            'message',
            'Session has expired'
         );
      else
         v_result.put(
            'message',
            'Session is valid and active'
         );
      end if;

      return v_result.to_clob();
   exception
      when no_data_found then
         v_result := json_object_t();
         v_result.put(
            'success',
            true
         );
         v_result.put(
            'valid',
            false
         );
         v_result.put(
            'active',
            false
         );
         v_result.put(
            'error',
            'Token not found'
         );
         return v_result.to_clob();
      when others then
         v_result := json_object_t();
         v_result.put(
            'success',
            false
         );
         v_result.put(
            'valid',
            false
         );
         v_result.put(
            'error',
            'Database error: ' || sqlerrm
         );
         return v_result.to_clob();
   end validate_token;

   function get_token (
      p_token in sessions.token%type
   ) return clob is
      v_result         json_object_t := json_object_t();
      v_session_record sessions%rowtype;
   begin
        -- Input validation
      if p_token is null
      or length(trim(p_token)) = 0 then
         v_result.put(
            'success',
            false
         );
         v_result.put(
            'error',
            'Token is required'
         );
         return v_result.to_clob();
      end if;

        -- Find session by token
      select *
        into v_session_record
        from sessions
       where token = p_token;

        -- Build response with complete session information
      v_result.put(
         'success',
         true
      );
      v_result.put(
         'session',
         record_to_json(v_session_record)
      );
      v_result.put(
         'is_active',
         case
            when is_session_active(
                  v_session_record.session_start,
                  v_session_record.session_end
               ) = 'Y' then
                  true
            else
               false
         end
      );

      return v_result.to_clob();
   exception
      when no_data_found then
         v_result := json_object_t();
         v_result.put(
            'success',
            false
         );
         v_result.put(
            'error',
            'Token not found'
         );
         return v_result.to_clob();
      when others then
         v_result := json_object_t();
         v_result.put(
            'success',
            false
         );
         v_result.put(
            'error',
            'Database error: ' || sqlerrm
         );
         return v_result.to_clob();
   end get_token;

   function extend_session (
      p_token              in sessions.token%type,
      p_additional_minutes in number default 600
   ) return clob is
      v_result         json_object_t := json_object_t();
      v_session_record sessions%rowtype;
      v_new_end_time   timestamp;
      v_new_duration   number;
   begin
        -- Input validation
      if p_token is null
      or length(trim(p_token)) = 0 then
         v_result.put(
            'success',
            false
         );
         v_result.put(
            'error',
            'Token is required'
         );
         return v_result.to_clob();
      end if;

      if p_additional_minutes <= 0 then
         v_result.put(
            'success',
            false
         );
         v_result.put(
            'error',
            'Additional minutes must be greater than 0'
         );
         return v_result.to_clob();
      end if;

        -- Find session by token
      select *
        into v_session_record
        from sessions
       where token = p_token;

        -- Calculate new end time and duration
      v_new_end_time := v_session_record.session_end + interval '1' minute * p_additional_minutes;
      v_new_duration := v_session_record.session_duration + p_additional_minutes;

        -- Update session
      update sessions
         set session_end = v_new_end_time,
             session_duration = v_new_duration
       where token = p_token returning pk,
                                       pk_account,
                                       token,
                                       session_start,
                                       session_end,
                                       session_duration into v_session_record.pk,v_session_record.pk_account,v_session_record.token
                                       ,v_session_record.session_start,v_session_record.session_end,v_session_record.session_duration
                                       ;

        -- Build success response
      v_result.put(
         'success',
         true
      );
      v_result.put(
         'message',
         'Session extended successfully'
      );
      v_result.put(
         'extended_minutes',
         p_additional_minutes
      );
      v_result.put(
         'session',
         record_to_json(v_session_record)
      );
      return v_result.to_clob();
   exception
      when no_data_found then
         v_result := json_object_t();
         v_result.put(
            'success',
            false
         );
         v_result.put(
            'error',
            'Token not found'
         );
         return v_result.to_clob();
      when others then
         v_result := json_object_t();
         v_result.put(
            'success',
            false
         );
         v_result.put(
            'error',
            'Database error: ' || sqlerrm
         );
         return v_result.to_clob();
   end extend_session;

   function terminate_session (
      p_token in sessions.token%type
   ) return clob is
      v_result json_object_t := json_object_t();
      v_count  number;
   begin
        -- Input validation
      if p_token is null
      or length(trim(p_token)) = 0 then
         v_result.put(
            'success',
            false
         );
         v_result.put(
            'error',
            'Token is required'
         );
         return v_result.to_clob();
      end if;

        -- Terminate session by setting end time to current time
      update sessions
         set
         session_end = systimestamp
       where token = p_token
         and session_end > systimestamp; -- Only update if not already expired

      v_count := sql%rowcount;
      if v_count = 0 then
            -- Check if session exists but is already expired
         select count(*)
           into v_count
           from sessions
          where token = p_token;
         if v_count > 0 then
            v_result.put(
               'success',
               true
            );
            v_result.put(
               'message',
               'Session was already expired'
            );
            v_result.put(
               'was_already_expired',
               true
            );
         else
            v_result.put(
               'success',
               false
            );
            v_result.put(
               'error',
               'Token not found'
            );
         end if;
      else
         v_result.put(
            'success',
            true
         );
         v_result.put(
            'message',
            'Session terminated successfully'
         );
         v_result.put(
            'was_already_expired',
            false
         );
      end if;

      return v_result.to_clob();
   exception
      when others then
         v_result := json_object_t();
         v_result.put(
            'success',
            false
         );
         v_result.put(
            'error',
            'Database error: ' || sqlerrm
         );
         return v_result.to_clob();
   end terminate_session;

   function get_active_sessions_by_account (
      p_pk_account in sessions.pk_account%type
   ) return clob is
      v_result         json_object_t := json_object_t();
      v_sessions       json_array_t := json_array_t();
      v_session_record sessions%rowtype;
      v_count          number := 0;
      cursor c_active_sessions is
      select *
        from sessions
       where pk_account = p_pk_account
         and systimestamp between session_start and session_end
       order by session_start desc;
   begin
        -- Input validation
      if p_pk_account is null then
         v_result.put(
            'success',
            false
         );
         v_result.put(
            'error',
            'Account ID is required'
         );
         return v_result.to_clob();
      end if;

        -- Validate account exists
      if is_valid_account(p_pk_account) = 'N' then
         v_result.put(
            'success',
            false
         );
         v_result.put(
            'error',
            'Invalid account ID'
         );
         return v_result.to_clob();
      end if;

        -- Get all active sessions for account
      for v_session_record in c_active_sessions loop
         v_sessions.append(record_to_json(v_session_record));
         v_count := v_count + 1;
      end loop;

        -- Build response
      v_result.put(
         'success',
         true
      );
      v_result.put(
         'active_sessions',
         v_sessions
      );
      v_result.put(
         'session_count',
         v_count
      );
      v_result.put(
         'account_id',
         p_pk_account
      );
      return v_result.to_clob();
   exception
      when others then
         v_result := json_object_t();
         v_result.put(
            'success',
            false
         );
         v_result.put(
            'error',
            'Database error: ' || sqlerrm
         );
         return v_result.to_clob();
   end get_active_sessions_by_account;

   function cleanup_expired_sessions (
      p_cleanup_before_hours in number default 24
   ) return clob is
      v_result            json_object_t := json_object_t();
      v_cleanup_timestamp timestamp;
      v_deleted_count     number;
   begin
        -- Input validation
      if p_cleanup_before_hours <= 0 then
         v_result.put(
            'success',
            false
         );
         v_result.put(
            'error',
            'Cleanup hours must be greater than 0'
         );
         return v_result.to_clob();
      end if;

        -- Calculate cleanup timestamp
      v_cleanup_timestamp := systimestamp - interval '1' hour * p_cleanup_before_hours;

        -- Delete expired sessions older than specified hours
      delete from sessions
       where session_end < v_cleanup_timestamp;

      v_deleted_count := sql%rowcount;

        -- Build response
      v_result.put(
         'success',
         true
      );
      v_result.put(
         'message',
         'Expired sessions cleaned up successfully'
      );
      v_result.put(
         'deleted_count',
         v_deleted_count
      );
      v_result.put(
         'cleanup_before_hours',
         p_cleanup_before_hours
      );
      v_result.put(
         'cleanup_timestamp',
         to_char(
            v_cleanup_timestamp,
            'YYYY-MM-DD HH24:MI:SS'
         )
      );
      return v_result.to_clob();
   exception
      when others then
         v_result := json_object_t();
         v_result.put(
            'success',
            false
         );
         v_result.put(
            'error',
            'Database error: ' || sqlerrm
         );
         return v_result.to_clob();
   end cleanup_expired_sessions;

    -- Internal Helper Functions Implementation

   function record_to_json (
      p_session_record in sessions%rowtype
   ) return json_object_t is
      v_json         json_object_t := json_object_t();
      v_account_json json_object_t;
   begin
        -- Build session JSON with account details embedded
      select
         json_object(
            'pk' value a.pk,
                     'givenname' value a.givenname,
                     'lastname' value a.lastname,
                     'full_name' value(a.givenname
                                       || ' ' || a.lastname),
                     'unikid' value a.unikid,
                     'email' value a.email,
                     'created_on' value to_char(
               a.created_on,
               'YYYY-MM-DD"T"HH24:MI:SS"Z"'
            )
         )
        into v_account_json
        from accounts a
       where a.pk = p_session_record.pk_account;

        -- Build complete session JSON
      v_json.put(
         'pk',
         p_session_record.pk
      );
      v_json.put(
         'pk_account',
         p_session_record.pk_account
      );
      v_json.put(
         'token',
         p_session_record.token
      );
      v_json.put(
         'session_start',
         to_char(
            p_session_record.session_start,
            'YYYY-MM-DD"T"HH24:MI:SS"Z"'
         )
      );
      v_json.put(
         'session_end',
         to_char(
            p_session_record.session_end,
            'YYYY-MM-DD"T"HH24:MI:SS"Z"'
         )
      );
      v_json.put(
         'session_duration',
         p_session_record.session_duration
      );
      v_json.put(
         'is_active',
         case
            when is_session_active(
                  p_session_record.session_start,
                  p_session_record.session_end
               ) = 'Y' then
                  true
            else
               false
         end
      );
      v_json.put(
         'account',
         v_account_json
      );
      return v_json;
   exception
      when others then
            -- Fallback without account details if there's an error
         v_json := json_object_t();
         v_json.put(
            'pk',
            p_session_record.pk
         );
         v_json.put(
            'pk_account',
            p_session_record.pk_account
         );
         v_json.put(
            'token',
            p_session_record.token
         );
         v_json.put(
            'session_start',
            to_char(
               p_session_record.session_start,
               'YYYY-MM-DD"T"HH24:MI:SS"Z"'
            )
         );
         v_json.put(
            'session_end',
            to_char(
               p_session_record.session_end,
               'YYYY-MM-DD"T"HH24:MI:SS"Z"'
            )
         );
         v_json.put(
            'session_duration',
            p_session_record.session_duration
         );
         v_json.put(
            'is_active',
            case
               when is_session_active(
                     p_session_record.session_start,
                     p_session_record.session_end
                  ) = 'Y' then
                     true
               else
                  false
            end
         );
         v_json.put(
            'account_error',
            'Could not load account details'
         );
         return v_json;
   end record_to_json;

   function is_session_active (
      p_session_start in sessions.session_start%type,
      p_session_end   in sessions.session_end%type
   ) return varchar2 is
      v_current_time timestamp := systimestamp;
   begin
      if p_session_start is null
      or p_session_end is null then
         return 'N';
      end if;
      if v_current_time between p_session_start and p_session_end then
         return 'Y';
      else
         return 'N';
      end if;
   exception
      when others then
         return 'N';
   end is_session_active;

   function is_valid_account (
      p_pk_account in sessions.pk_account%type
   ) return varchar2 is
      v_count number;
   begin
      if p_pk_account is null then
         return 'N';
      end if;
      select count(*)
        into v_count
        from accounts
       where pk = p_pk_account;

      if v_count > 0 then
         return 'Y';
      else
         return 'N';
      end if;
   exception
      when others then
         return 'N';
   end is_valid_account;

   function is_token_unique (
      p_token      in sessions.token%type,
      p_exclude_pk in sessions.pk%type default null
   ) return varchar2 is
      v_count number;
   begin
      if p_token is null then
         return 'N';
      end if;
      select count(*)
        into v_count
        from sessions
       where token = p_token
         and ( p_exclude_pk is null
          or pk != p_exclude_pk );

      if v_count = 0 then
         return 'Y';
      else
         return 'N';
      end if;
   exception
      when others then
         return 'N';
   end is_token_unique;

end p_sessions;
/