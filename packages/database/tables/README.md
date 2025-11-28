# Database Tables

This directory contains SQL scripts for creating all database tables, constraints, and indexes for the Docker Proxied App.

## Installation Order

Run scripts in this order (or use the master `install.sql` script in the parent directory):

1. `01_accounts.sql` - User accounts table with audit triggers
2. `02_features.sql` - Application features table with default data
3. `03_accounts_features_rights.sql` - User permissions junction table
4. `04_sessions.sql` - Session management with utility functions
5. `05_constraints_and_relationships.sql` - Additional constraints and views
6. `06_indexes.sql` - Performance indexes and statistics

## Table Relationships

```text
ACCOUNTS (1) ----< ACCOUNTS_FEATURES_RIGHTS >---- (1) FEATURES
    |
    |
    v
SESSIONS (n)
```

## Key Features

- **Audit Trail**: All tables include created_on, modified_on, created_by, modified_by fields
- **Auto-incrementing PKs**: All primary keys auto-increment via sequences and triggers
- **Data Validation**: Check constraints ensure data integrity
- **Performance**: Comprehensive indexing for optimal query performance
- **Session Management**: Built-in functions for session lifecycle management
- **Referential Integrity**: Foreign key constraints maintain data consistency

## Usage

### Install All Tables

```sql
-- From the database directory
@install.sql
```

### Install Individual Table

```sql
-- Example: Install accounts table only
@tables/01_accounts.sql
```

### Verify Installation

```sql
-- Check all tables are created
SELECT table_name FROM user_tables
WHERE table_name IN ('ACCOUNTS', 'FEATURES', 'ACCOUNTS_FEATURES_RIGHTS', 'SESSIONS');

-- Verify referential integrity
SELECT verify_referential_integrity() FROM dual;
```
