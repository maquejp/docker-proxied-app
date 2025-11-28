-- FEATURES table for Docker Proxied App
-- This table stores application features/permissions information

create table features (
   pk           number(38) not null,
   feature_code varchar2(100) not null unique,
   feature_name varchar2(255) not null,
   created_on   timestamp default systimestamp not null,
   modified_on  timestamp default systimestamp not null,
   created_by   varchar2(100) not null,
   modified_by  varchar2(100) not null,
    
    -- Constraints
   constraint pk_features primary key ( pk ),
   constraint uk_features_code unique ( feature_code ),
    
    -- Check constraints for data validation
   constraint ck_features_code_format
      check ( regexp_like ( feature_code,
                            '^[A-Z0-9_]+$' )
         and length(feature_code) >= 3 ),
   constraint ck_features_name_length check ( length(feature_name) >= 3 ),
   constraint ck_features_code_length check ( length(feature_code) <= 100 ),
   constraint ck_features_name_max_length check ( length(feature_name) <= 255 )
);

-- Add comments for documentation
comment on table features is
   'Application features/permissions table';
comment on column features.pk is
   'Primary key - unique identifier for each feature';
comment on column features.feature_code is
   'Unique feature code identifier (uppercase with underscores)';
comment on column features.feature_name is
   'Human-readable feature name/description';
comment on column features.created_on is
   'Timestamp when record was created';
comment on column features.modified_on is
   'Timestamp when record was last modified';
comment on column features.created_by is
   'Username who created this record';
comment on column features.modified_by is
   'Username who last modified this record';

-- Create sequence for primary key
create sequence seq_features start with 1 increment by 1 nocycle cache 20;

-- Create trigger for auto-incrementing primary key and audit fields
create or replace trigger trg_features_bi before
   insert on features
   for each row
begin
    -- Set primary key from sequence if not provided
   if :new.pk is null then
      select seq_features.nextval
        into :new.pk
        from dual;
   end if;
    
    -- Ensure feature_code is uppercase
   :new.feature_code := upper(:new.feature_code);
    
    -- Set audit timestamps
   :new.created_on := systimestamp;
   :new.modified_on := systimestamp;
end;
/

-- Create trigger for audit fields on update
create or replace trigger trg_features_bu before
   update on features
   for each row
begin
    -- Ensure feature_code is uppercase
   :new.feature_code := upper(:new.feature_code);
    
    -- Update modified timestamp
   :new.modified_on := systimestamp;
    -- Preserve original created_on and created_by
   :new.created_on := :old.created_on;
   :new.created_by := :old.created_by;
end;
/

-- Insert some default features
insert into features (
   feature_code,
   feature_name,
   created_by,
   modified_by
) values ( 'USER_MANAGEMENT',
           'User Account Management',
           'SYSTEM',
           'SYSTEM' );

insert into features (
   feature_code,
   feature_name,
   created_by,
   modified_by
) values ( 'FEATURE_MANAGEMENT',
           'Feature Management',
           'SYSTEM',
           'SYSTEM' );

insert into features (
   feature_code,
   feature_name,
   created_by,
   modified_by
) values ( 'SESSION_MANAGEMENT',
           'Session Management',
           'SYSTEM',
           'SYSTEM' );

insert into features (
   feature_code,
   feature_name,
   created_by,
   modified_by
) values ( 'ADMIN_ACCESS',
           'Administrative Access',
           'SYSTEM',
           'SYSTEM' );

commit;