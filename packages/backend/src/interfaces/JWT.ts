/**
 * JWT payload interface
 */
export interface JWTPayload {
  // Standard JWT claims
  sub: string; // Subject (user ID)
  iat: number; // Issued at
  exp: number; // Expiration time
  aud: string; // Audience
  iss: string; // Issuer

  // Custom claims
  account_id: number;
  email: string;
  given_name: string;
  family_name: string;
  unikid: string;
  session_id: number;
  roles?: string[];
  features?: string[]; // Array of feature codes the user has access to
}

/**
 * JWT token response
 */
export interface JWTTokenResponse {
  access_token: string;
  token_type: 'Bearer';
  expires_in: number; // seconds until expiration
  expires_at: string; // ISO string format
  refresh_token?: string;
  scope?: string;
}

/**
 * JWT verification result
 */
export interface JWTVerificationResult {
  valid: boolean;
  payload?: JWTPayload;
  expired?: boolean;
  error?: string;
}

/**
 * JWT configuration interface
 */
export interface JWTConfig {
  secret: string;
  expiresIn: string | number;
  refreshExpiresIn: string | number;
  issuer: string;
  audience: string;
  algorithm: string;
}

/**
 * Authentication request
 */
export interface AuthenticationRequest {
  email?: string;
  unikid?: string;
  external_token?: string; // For external authentication systems
  provider?: 'internal' | 'external';
}

/**
 * Authentication response
 */
export interface AuthenticationResponse {
  success: boolean;
  token?: JWTTokenResponse;
  user?: {
    pk: number;
    email: string;
    given_name: string;
    family_name: string;
    unikid: string;
    features: string[];
  };
  session?: {
    pk: number;
    expires_at: string;
  };
  message: string;
}
