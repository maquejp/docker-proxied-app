/**
 * Centralized exports for all interfaces
 */

// Entity interfaces
export * from './Account';
export * from './Feature';
export * from './AccountFeatureRight';
export * from './Session';

// API interfaces
export * from './ApiResponse';
export * from './JWT';
export * from './DTOs';

// Re-export commonly used types for convenience
export type {
  Account,
  CreateAccountDTO,
  UpdateAccountDTO,
  AccountResponseDTO,
} from './Account';

export type {
  Feature,
  CreateFeatureDTO,
  UpdateFeatureDTO,
  FeatureResponseDTO,
} from './Feature';

export type {
  AccountFeatureRight,
  CreateAccountFeatureRightDTO,
  UpdateAccountFeatureRightDTO,
  AccountFeatureRightResponseDTO,
  RightType,
} from './AccountFeatureRight';

export type {
  Session,
  CreateSessionDTO,
  UpdateSessionDTO,
  SessionResponseDTO,
  TokenValidationResult,
} from './Session';

export type {
  ApiResponse,
  ApiErrorResponse,
  PaginatedResponse,
  PaginationParams,
  FilterParams,
  QueryParams,
  OperationResult,
  HealthCheckResponse,
} from './ApiResponse';

export type {
  JWTPayload,
  JWTTokenResponse,
  JWTVerificationResult,
  AuthenticationRequest,
  AuthenticationResponse,
} from './JWT';
