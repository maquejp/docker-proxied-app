-- SESSIONS table for Docker Proxied App
-- This table stores user session information and JWT tokens

create table sessions (
   pk               number(38) not null,
   pk_account       number(38) not null,
   token            clob not null,
   session_start    timestamp default systimestamp not null,
   session_end      timestamp,
   session_duration number(10),     -- Duration in minutes
    
    -- Constraints
   constraint pk_sessions primary key ( pk ),
    
    -- Foreign key constraints
   constraint fk_sessions_account foreign key ( pk_account )
      references accounts ( pk )
         on delete cascade,
    
    -- Check constraints for data validation
   constraint ck_sessions_start_before_end
      check ( session_end is null
          or session_start <= session_end ),
   constraint ck_sessions_duration_positive check ( session_duration is null
       or session_duration > 0 )
);

-- Add comments for documentation
comment on table sessions is
   'User session tracking table storing JWT tokens and session information';
comment on column sessions.pk is
   'Primary key - unique identifier for each session';
comment on column sessions.pk_account is
   'Foreign key to accounts table - which user this session belongs to';
comment on column sessions.token is
   'JWT token string for this session';
comment on column sessions.session_start is
   'Timestamp when session was started';
comment on column sessions.session_end is
   'Timestamp when session ended (NULL for active sessions)';
comment on column sessions.session_duration is
   'Session duration in minutes (calculated when session ends)';

-- Create sequence for primary key
create sequence seq_sessions start with 1 increment by 1 nocycle cache 20;

-- Create trigger for auto-incrementing primary key and audit fields
create or replace trigger trg_sessions_bi before
   insert on sessions
   for each row
begin
    -- Set primary key from sequence if not provided
   if :new.pk is null then
      select seq_sessions.nextval
        into :new.pk
        from dual;
   end if;
    
    -- Set session start timestamp if not provided
   if :new.session_start is null then
      :new.session_start := systimestamp;
   end if;
end;
/

-- Create trigger to calculate session duration on update
create or replace trigger trg_sessions_bu before
   update on sessions
   for each row
begin
    -- Calculate session duration when session_end is set
   if
      :new.session_end is not null
      and :old.session_end is null
   then
        -- Calculate duration in minutes
      :new.session_duration := round(
         extract(day from(:new.session_end - :new.session_start)) * 1440 + extract(hour from(:new.session_end - :new.session_start
         )) * 60 + extract(minute from(:new.session_end - :new.session_start)) + extract(second from(:new.session_end - :new.session_start
         )) / 60,
         2
      );
   end if;
end;
/

-- Create function to end a session (utility function)
create or replace function end_session (
   p_session_pk number
) return number is
   v_count number;
begin
   update sessions
      set
      session_end = systimestamp
    where pk = p_session_pk
      and session_end is null;

   v_count := sql%rowcount;
   commit;
   return v_count;
exception
   when others then
      rollback;
      raise;
end end_session;
/

-- Create function to cleanup expired sessions
create or replace function cleanup_expired_sessions (
   p_hours_old number default 168
) return number is
   v_count number;
begin
    -- Delete sessions older than specified hours (default 7 days)
   delete from sessions
    where session_start < ( systimestamp - numtodsinterval(
      p_hours_old,
      'HOUR'
   ) );

   v_count := sql%rowcount;
   commit;
   return v_count;
exception
   when others then
      rollback;
      raise;
end cleanup_expired_sessions;
/