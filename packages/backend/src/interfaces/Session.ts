/**
 * Session interface representing the sessions table
 */
export interface Session {
  pk: number;
  pk_account: number;
  token: string;
  session_start: Date;
  session_end: Date;
  session_duration: number;
}

/**
 * Session creation DTO - excludes auto-generated fields
 */
export interface CreateSessionDTO {
  pk_account: number;
  token: string;
  session_start: Date;
  session_end: Date;
  session_duration: number;
}

/**
 * Session update DTO - includes pk and modifiable fields
 */
export interface UpdateSessionDTO {
  pk: number;
  pk_account: number;
  token: string;
  session_start: Date;
  session_end: Date;
  session_duration: number;
}

/**
 * Session query filters
 */
export interface SessionFilter {
  pk_account?: number;
  token?: string;
  active_only?: boolean; // Filter for non-expired sessions
}

/**
 * Session response DTO for API responses
 */
export interface SessionResponseDTO {
  pk: number;
  pk_account: number;
  token: string;
  session_start: string; // ISO string format
  session_end: string; // ISO string format
  session_duration: number;
  is_active: boolean; // computed field
  time_remaining?: number; // computed field - seconds until expiration
  // Joined account data
  account?: {
    givenname: string;
    lastname: string;
    email: string;
  };
}

/**
 * Token validation result
 */
export interface TokenValidationResult {
  valid: boolean;
  session?: SessionResponseDTO;
  account?: {
    pk: number;
    givenname: string;
    lastname: string;
    email: string;
  };
  error?: string;
}
