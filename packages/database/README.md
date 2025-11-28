# Database Package

This directory contains Oracle database schema definitions and PL/SQL packages.

## Structure

- `packages/` - Oracle PL/SQL package specifications and bodies
- `tables/` - Database table creation scripts

## Database Objects

### Tables

- `accounts` - User account information
- `features` - Application features
- `accounts_features_rights` - User feature permissions
- `sessions` - User session management

### PL/SQL Packages

- `p_accounts` - Account CRUD operations
- `p_features` - Feature management operations
- `p_accounts_features_rights` - User permissions management
- `p_sessions` - Session management and token validation

## Development Notes

All packages will follow consistent patterns:

- Standard CRUD functions (create_record, update_record, delete_record, get_record, get_records)
- JSON helper functions for API responses
- Pagination, ordering, and filtering support
- Proper error handling and validation
