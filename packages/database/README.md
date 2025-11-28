# Database Package

This directory contains the complete database schema and Oracle packages for the Docker Proxied App.

## Quick Start

To install the complete database schema:

```sql
-- Connect as your application database user
sqlplus username/password@database

-- Run the master installation script
@install.sql
```

## Database Schema

### Core Tables

1. **ACCOUNTS** - User account information

   - Primary fields: pk, givenname, lastname, unikid, email
   - Audit fields: created_on, modified_on, created_by, modified_by

2. **FEATURES** - Application features/permissions

   - Primary fields: pk, feature_code, feature_name
   - Includes default system features

3. **ACCOUNTS_FEATURES_RIGHTS** - User permission junction table

   - Links users to features with specific rights (READ, WRITE, ADMIN, NONE)
   - Enforces one permission per user-feature combination

4. **SESSIONS** - JWT session tracking
   - Stores active and historical user sessions
   - Automatic session duration calculation

### Installation Files

- `install.sql` - Master installation script (run this first)
- `tables/01_accounts.sql` - ACCOUNTS table with triggers and sequences
- `tables/02_features.sql` - FEATURES table with default data
- `tables/03_accounts_features_rights.sql` - Permission junction table
- `tables/04_sessions.sql` - Session management table with utilities
- `tables/05_constraints_and_relationships.sql` - Additional constraints and views
- `tables/06_indexes.sql` - Performance indexes and statistics

### Views and Functions

- `v_active_sessions` - Currently active user sessions
- `v_user_permissions` - User permission summary
- `verify_referential_integrity()` - Data integrity checker
- `end_session()` - Session management utility
- `cleanup_expired_sessions()` - Maintenance function
- `analyze_index_usage()` - Performance monitoring

## Oracle Database Requirements

- Oracle Database 12c or higher
- Required privileges: CREATE TABLE, CREATE SEQUENCE, CREATE TRIGGER, CREATE PROCEDURE, CREATE VIEW
- Recommended: Dedicated schema for the application

## Usage

### Install Schema

```sql
@install.sql
```

### Verify Installation

```sql
SELECT verify_referential_integrity() FROM dual;
SELECT * FROM v_active_sessions;
```

### Maintenance

```sql
-- Clean up old sessions (older than 7 days)
SELECT cleanup_expired_sessions(168) FROM dual;

-- Analyze index performance
SELECT analyze_index_usage(30) FROM dual;
```

## Development Notes

All packages will follow consistent patterns:

- Standard CRUD functions (create_record, update_record, delete_record, get_record, get_records)
- JSON helper functions for API responses
- Pagination, ordering, and filtering support
- Proper error handling and validation
