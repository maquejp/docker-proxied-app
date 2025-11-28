-- Package Specification: p_sessions
-- Purpose: Comprehensive session management with JWT token validation and lifecycle management
-- Created for: Docker Proxied App - Phase 2 Database Foundation
-- Features: CRUD operations, token validation, session cleanup, JSON API integration

create or replace package p_sessions as

    -- Standard CRUD Operations with JSON responses using json_object_t()
    
    /**
     * Create a new session record
     * @param p_pk_account: Foreign key to accounts table (required)
     * @param p_token: JWT token string (required, unique)
     * @param p_session_start: Session start timestamp (optional, defaults to SYSTIMESTAMP)
     * @param p_session_end: Session end timestamp (optional, calculated from start + 10 hours)
     * @param p_session_duration: Session duration in minutes (optional, defaults to 600 = 10 hours)
     * @return JSON object with created session details or error information
     */
   function create_record (
      p_pk_account       in sessions.pk_account%type,
      p_token            in sessions.token%type,
      p_session_start    in sessions.session_start%type default systimestamp,
      p_session_end      in sessions.session_end%type default null,
      p_session_duration in sessions.session_duration%type default 600
   ) return clob;

    /**
     * Update an existing session record
     * @param p_pk: Primary key of session to update (required)
     * @param p_pk_account: Foreign key to accounts table (required)
     * @param p_token: JWT token string (required, unique)
     * @param p_session_start: Session start timestamp (required)
     * @param p_session_end: Session end timestamp (required)
     * @param p_session_duration: Session duration in minutes (required)
     * @return JSON object with updated session details or error information
     */
   function update_record (
      p_pk               in sessions.pk%type,
      p_pk_account       in sessions.pk_account%type,
      p_token            in sessions.token%type,
      p_session_start    in sessions.session_start%type,
      p_session_end      in sessions.session_end%type,
      p_session_duration in sessions.session_duration%type
   ) return clob;

    /**
     * Delete a session record
     * @param p_pk: Primary key of session to delete (required)
     * @return JSON object with deletion status or error information
     */
   function delete_record (
      p_pk in sessions.pk%type
   ) return clob;

    /**
     * Get a single session record by primary key
     * @param p_pk: Primary key of session to retrieve (required)
     * @return JSON object with session details including account information or error
     */
   function get_record (
      p_pk in sessions.pk%type
   ) return clob;

    /**
     * Get multiple session records with pagination, ordering, and filtering
     * @param p_page_number: Page number for pagination (default 1)
     * @param p_page_size: Records per page (default 10, max 100)
     * @param p_order_by: Column to order by (default 'session_start')
     * @param p_order_direction: ASC or DESC (default 'DESC')
     * @param p_filter_account: Filter by account primary key (optional)
     * @param p_filter_active_only: Filter only active sessions (default 'N')
     * @return JSON object with sessions array, pagination info, and metadata
     */
   function get_records (
      p_page_number        in number default 1,
      p_page_size          in number default 10,
      p_order_by           in varchar2 default 'session_start',
      p_order_direction    in varchar2 default 'DESC',
      p_filter_account     in sessions.pk_account%type default null,
      p_filter_active_only in varchar2 default 'N'
   ) return clob;

    -- Specialized Session Management Functions

    /**
     * Validate JWT token and return session status
     * @param p_token: JWT token to validate (required)
     * @return JSON object with validation result, session info, and account details
     */
   function validate_token (
      p_token in sessions.token%type
   ) return clob;

    /**
     * Get token information and session details
     * @param p_token: JWT token to lookup (required)
     * @return JSON object with complete token/session information or error
     */
   function get_token (
      p_token in sessions.token%type
   ) return clob;

    /**
     * Extend session duration (refresh token functionality)
     * @param p_token: JWT token to extend (required)
     * @param p_additional_minutes: Minutes to extend (default 600 = 10 hours)
     * @return JSON object with updated session information or error
     */
   function extend_session (
      p_token              in sessions.token%type,
      p_additional_minutes in number default 600
   ) return clob;

    /**
     * Terminate a session by token (logout functionality)
     * @param p_token: JWT token to terminate (required)
     * @return JSON object with termination status
     */
   function terminate_session (
      p_token in sessions.token%type
   ) return clob;

    /**
     * Get all active sessions for a specific account
     * @param p_pk_account: Account primary key (required)
     * @return JSON object with array of active sessions for the account
     */
   function get_active_sessions_by_account (
      p_pk_account in sessions.pk_account%type
   ) return clob;

    /**
     * Clean up expired sessions (maintenance function)
     * @param p_cleanup_before_hours: Remove sessions older than X hours (default 24)
     * @return JSON object with cleanup statistics
     */
   function cleanup_expired_sessions (
      p_cleanup_before_hours in number default 24
   ) return clob;

    -- Internal Helper Functions

    /**
     * Convert session record to JSON with account details
     * @param p_session_record: Session row record
     * @return JSON object with session and embedded account information
     */
   function record_to_json (
      p_session_record in sessions%rowtype
   ) return json_object_t;

    /**
     * Check if session is currently active (within time bounds)
     * @param p_session_start: Session start timestamp
     * @param p_session_end: Session end timestamp
     * @return 'Y' if active, 'N' if expired or invalid
     */
   function is_session_active (
      p_session_start in sessions.session_start%type,
      p_session_end   in sessions.session_end%type
   ) return varchar2;

    /**
     * Validate if account exists and is active
     * @param p_pk_account: Account primary key to validate
     * @return 'Y' if valid account, 'N' if invalid
     */
   function is_valid_account (
      p_pk_account in sessions.pk_account%type
   ) return varchar2;

    /**
     * Check if token is unique (not already in use by another session)
     * @param p_token: Token string to check
     * @param p_exclude_pk: Primary key to exclude from check (for updates)
     * @return 'Y' if token is unique, 'N' if already exists
     */
   function is_token_unique (
      p_token      in sessions.token%type,
      p_exclude_pk in sessions.pk%type default null
   ) return varchar2;

end p_sessions;
/