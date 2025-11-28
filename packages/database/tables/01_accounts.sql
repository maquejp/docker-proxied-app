-- ACCOUNTS table for Docker Proxied App
-- This table stores user account information

create table accounts (
   pk          number(38) not null,
   givenname   varchar2(100) not null,
   lastname    varchar2(100) not null,
   unikid      varchar2(255) not null unique,
   email       varchar2(255) not null unique,
   created_on  timestamp default systimestamp not null,
   modified_on timestamp default systimestamp not null,
   created_by  varchar2(100) not null,
   modified_by varchar2(100) not null,
    
    -- Constraints
   constraint pk_accounts primary key ( pk ),
   constraint uk_accounts_unikid unique ( unikid ),
   constraint uk_accounts_email unique ( email ),
    
    -- Check constraints for data validation
   constraint ck_accounts_email_format check ( regexp_like ( email,
                                                             '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$' ) ),
   constraint ck_accounts_givenname_length check ( length(givenname) >= 1 ),
   constraint ck_accounts_lastname_length check ( length(lastname) >= 1 ),
   constraint ck_accounts_unikid_length check ( length(unikid) >= 1 )
);

-- Add comments for documentation
comment on table accounts is
   'User accounts table storing basic user information';
comment on column accounts.pk is
   'Primary key - unique identifier for each account';
comment on column accounts.givenname is
   'User given name (first name)';
comment on column accounts.lastname is
   'User last name (surname)';
comment on column accounts.unikid is
   'Unique user identifier from external system';
comment on column accounts.email is
   'User email address - must be unique and valid format';
comment on column accounts.created_on is
   'Timestamp when record was created';
comment on column accounts.modified_on is
   'Timestamp when record was last modified';
comment on column accounts.created_by is
   'Username who created this record';
comment on column accounts.modified_by is
   'Username who last modified this record';

-- Create sequence for primary key
create sequence seq_accounts start with 1 increment by 1 nocycle cache 20;

-- Create trigger for auto-incrementing primary key and audit fields
create or replace trigger trg_accounts_bi before
   insert on accounts
   for each row
begin
    -- Set primary key from sequence if not provided
   if :new.pk is null then
      select seq_accounts.nextval
        into :new.pk
        from dual;
   end if;
    
    -- Set audit timestamps
   :new.created_on := systimestamp;
   :new.modified_on := systimestamp;
end;
/

-- Create trigger for audit fields on update
create or replace trigger trg_accounts_bu before
   update on accounts
   for each row
begin
    -- Update modified timestamp
   :new.modified_on := systimestamp;
    -- Preserve original created_on and created_by
   :new.created_on := :old.created_on;
   :new.created_by := :old.created_by;
end;
/