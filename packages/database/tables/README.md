# Database Tables

This directory contains Oracle database table creation scripts.

## Table Scripts

- `accounts.sql` - User accounts table
- `features.sql` - Application features table
- `accounts_features_rights.sql` - User feature permissions table
- `sessions.sql` - User session management table

## Schema Design

All tables follow consistent patterns:

- Primary key named `pk`
- Audit fields: `created_on`, `modified_on`, `created_by`, `modified_by`
- Proper foreign key constraints
- Indexes for performance optimization
