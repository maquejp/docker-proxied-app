-- ACCOUNTS_FEATURES_RIGHTS table for Docker Proxied App
-- This table stores the many-to-many relationship between accounts and features with rights

create table accounts_features_rights (
   pk         number(38) not null,
   pk_account number(38) not null,
   pk_feature number(38) not null,
   right      varchar2(20) not null,
   created_on timestamp default systimestamp not null,
   created_by varchar2(100) not null,
    
    -- Constraints
   constraint pk_accounts_features_rights primary key ( pk ),
   constraint uk_account_feature_combo unique ( pk_account,
                                                pk_feature ),
    
    -- Foreign key constraints
   constraint fk_afr_account foreign key ( pk_account )
      references accounts ( pk )
         on delete cascade,
   constraint fk_afr_feature foreign key ( pk_feature )
      references features ( pk )
         on delete cascade,
    
    -- Check constraints for data validation
   constraint ck_afr_right_values
      check ( right in ( 'READ',
                         'WRITE',
                         'ADMIN',
                         'NONE' ) )
);

-- Add comments for documentation
comment on table accounts_features_rights is
   'Junction table linking accounts to features with specific rights';
comment on column accounts_features_rights.pk is
   'Primary key - unique identifier for each account-feature-right combination';
comment on column accounts_features_rights.pk_account is
   'Foreign key to accounts table';
comment on column accounts_features_rights.pk_feature is
   'Foreign key to features table';
comment on column accounts_features_rights.right is
   'Permission level: READ, WRITE, ADMIN, or NONE';
comment on column accounts_features_rights.created_on is
   'Timestamp when record was created';
comment on column accounts_features_rights.created_by is
   'Username who created this record';

-- Create sequence for primary key
create sequence seq_accounts_features_rights start with 1 increment by 1 nocycle cache 20;

-- Create trigger for auto-incrementing primary key and audit fields
create or replace trigger trg_afr_bi before
   insert on accounts_features_rights
   for each row
begin
    -- Set primary key from sequence if not provided
   if :new.pk is null then
      select seq_accounts_features_rights.nextval
        into :new.pk
        from dual;
   end if;
    
    -- Ensure right value is uppercase
   :new.right := upper(:new.right);
    
    -- Set audit timestamp
   :new.created_on := systimestamp;
end;
/

-- Create trigger for right value validation on update
create or replace trigger trg_afr_bu before
   update on accounts_features_rights
   for each row
begin
    -- Ensure right value is uppercase
   :new.right := upper(:new.right);
    
    -- Preserve audit fields (this is an immutable table - updates should be rare)
   :new.created_on := :old.created_on;
   :new.created_by := :old.created_by;
end;
/