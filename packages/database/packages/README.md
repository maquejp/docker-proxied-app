# Oracle PL/SQL Packages

This directory contains Oracle PL/SQL package specifications and bodies for the Docker Proxied App.

## Available Packages

### P_ACCOUNTS ✅ COMPLETE

Account management operations with full CRUD functionality.

**Files:**

- `p_accounts_spec.sql` - Package specification
- `p_accounts_body.sql` - Package implementation
- `install_p_accounts.sql` - Installation script

**Functions:**

- `create_record()` - Create new account
- `update_record()` - Update existing account
- `delete_record()` - Delete account by PK
- `get_record()` - Get account by PK (JSON)
- `get_record_by_email()` - Get account by email (JSON)
- `get_record_by_unikid()` - Get account by unique ID (JSON)
- `get_records()` - Get paginated accounts list (JSON)
- `get_record_count()` - Get total count with filters
- `record_to_json()` - Convert record to JSON
- `is_valid_email()` - Email format validation
- `email_exists()` - Check email duplicates
- `unikid_exists()` - Check unique ID duplicates
- `get_version()` - Package version info

### P_FEATURES ✅ COMPLETE

Feature management operations for application permissions and functionality control.

**Files:**

- `p_features_spec.sql` - Package specification
- `p_features_body.sql` - Package implementation
- `install_p_features.sql` - Installation script

**Functions:**

- `create_record()` - Create new feature
- `update_record()` - Update existing feature
- `delete_record()` - Delete feature by PK
- `get_record()` - Get feature by PK (JSON)
- `get_record_by_code()` - Get feature by code (JSON)
- `get_record_by_name()` - Get feature by name (JSON)
- `get_records()` - Get paginated features list (JSON)
- `get_record_count()` - Get total count with filters
- `record_to_json()` - Convert record to JSON
- `feature_code_exists()` - Check feature code duplicates
- `feature_name_exists()` - Check feature name duplicates
- `get_version()` - Package version info

### P_ACCOUNTS_FEATURES_RIGHTS ✅ COMPLETE

User permission management linking accounts to features with granular access control.

**Files:**

- `p_accounts_features_rights_spec.sql` - Package specification
- `p_accounts_features_rights_body.sql` - Package implementation
- `install_p_accounts_features_rights.sql` - Installation script

**Functions:**

- `create_record()` - Create new account-feature assignment
- `update_record()` - Update existing assignment
- `delete_record()` - Delete assignment by PK
- `delete_by_account_feature()` - Delete by account and feature IDs
- `get_record()` - Get assignment by PK (JSON)
- `get_record_by_account_feature()` - Get by account and feature IDs (JSON)
- `get_features_by_account()` - Get all features for an account (paginated)
- `get_accounts_by_feature()` - Get all accounts for a feature (paginated)
- `get_records()` - Get paginated assignments list (JSON)
- `get_record_count()` - Get total count with filters
- `record_to_json()` - Convert record to JSON with account/feature details
- `assignment_exists()` - Check duplicate assignments
- `is_valid_account()` - Validate account ID
- `is_valid_feature()` - Validate feature ID
- `is_valid_right()` - Validate right value (F/R)
- `get_version()` - Package version info

### P_SESSIONS (Planned)

Session and JWT token management operations.

## Installation

### Install Individual Packages

```sql
-- Install P_ACCOUNTS package
@@install_p_accounts.sql

-- Install P_FEATURES package
@@install_p_features.sql

-- Install P_ACCOUNTS_FEATURES_RIGHTS package
@@install_p_accounts_features_rights.sql

-- Or install specific package
@packages/install_p_accounts.sql

-- Or install individual components
@packages/p_accounts_spec.sql
@packages/p_accounts_body.sql
```

### Verify Installation

```sql
-- Check package compilation
SELECT object_name, object_type, status
FROM user_objects
WHERE object_name = 'P_ACCOUNTS';

-- Test package
SELECT p_accounts.get_version() FROM dual;
```

## Usage Examples

### P_ACCOUNTS Package

```sql
-- Create account
SELECT p_accounts.create_record(
    'John', 'Doe', 'jdoe123',
    'john.doe@example.com', 'ADMIN'
) AS new_account_id FROM dual;

-- Get account by ID (returns JSON)
SELECT p_accounts.get_record(1) FROM dual;

-- Get account by email
SELECT p_accounts.get_record_by_email('john.doe@example.com') FROM dual;

-- Get paginated list (page 1, 10 records per page)
SELECT p_accounts.get_records(1, 10, 'created_on', 'DESC') FROM dual;

-- Update account
SELECT p_accounts.update_record(
    1, 'Jane', 'Smith', 'jsmith123',
    'jane.smith@example.com', 'ADMIN'
) FROM dual;

-- Delete account
SELECT p_accounts.delete_record(1) FROM dual;
```

## 4. p_sessions

**Purpose:** Session management with JWT token validation and lifecycle management

**Files:**

- `p_sessions_spec.sql` - Package specification
- `p_sessions_body.sql` - Package implementation
- `install_p_sessions.sql` - Installation script

**Standard CRUD Functions:**

- `create_record()` - Create new session with JWT token
- `update_record()` - Update existing session
- `delete_record()` - Delete session by PK
- `get_record()` - Get session by PK (JSON with account details)
- `get_records()` - Get paginated sessions with filtering

**Specialized Session Management:**

- `validate_token()` - Validate JWT token and return session status
- `get_token()` - Get complete session information by token
- `extend_session()` - Extend session duration (refresh token)
- `terminate_session()` - Terminate session by token (logout)
- `get_active_sessions_by_account()` - Get all active sessions for account
- `cleanup_expired_sessions()` - Clean up expired sessions (maintenance)

**Helper Functions:**

- `record_to_json()` - Convert session to JSON with account details
- `is_session_active()` - Check if session is currently active
- `is_valid_account()` - Validate account exists
- `is_token_unique()` - Check token uniqueness for new sessions

### Session Management Examples

```sql
-- Create session with JWT token
SELECT p_sessions.create_record(
    1, 'jwt-token-string-here',
    SYSTIMESTAMP, NULL, 600
) FROM dual;

-- Validate token
SELECT p_sessions.validate_token('jwt-token-string-here') FROM dual;

-- Extend session by 2 hours (120 minutes)
SELECT p_sessions.extend_session('jwt-token-string-here', 120) FROM dual;

-- Get all active sessions for account
SELECT p_sessions.get_active_sessions_by_account(1) FROM dual;

-- Terminate session (logout)
SELECT p_sessions.terminate_session('jwt-token-string-here') FROM dual;

-- Cleanup expired sessions older than 24 hours
SELECT p_sessions.cleanup_expired_sessions(24) FROM dual;
```

## Package Standards

All packages follow consistent patterns:

- Standard CRUD functions with validation
- JSON return format for data retrieval
- Comprehensive error handling with custom exceptions
- Parameter validation and sanitization
- Audit trail support
- Version tracking
