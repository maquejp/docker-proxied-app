/**
 * Data Transfer Objects (DTOs) for API requests and responses
 */

import { PaginationParams, FilterParams } from './ApiResponse';
import { AccountFilter, CreateAccountDTO, UpdateAccountDTO } from './Account';
import { FeatureFilter, CreateFeatureDTO, UpdateFeatureDTO } from './Feature';
import {
  AccountFeatureRightFilter,
  CreateAccountFeatureRightDTO,
  UpdateAccountFeatureRightDTO,
} from './AccountFeatureRight';
import { SessionFilter, CreateSessionDTO, UpdateSessionDTO } from './Session';

/**
 * Account-related DTOs
 */
export interface GetAccountsRequest extends PaginationParams, AccountFilter {
  include_inactive?: boolean;
}

export interface GetAccountRequest {
  id: number;
}

export interface CreateAccountRequest extends CreateAccountDTO {
  // Additional validation or business logic fields can be added here
}

export interface UpdateAccountRequest extends UpdateAccountDTO {
  // Additional validation or business logic fields can be added here
}

export interface DeleteAccountRequest {
  id: number;
  deleted_by: string;
}

/**
 * Feature-related DTOs
 */
export interface GetFeaturesRequest extends PaginationParams, FeatureFilter {
  include_inactive?: boolean;
}

export interface GetFeatureRequest {
  id: number;
}

export interface CreateFeatureRequest extends CreateFeatureDTO {
  // Additional validation or business logic fields can be added here
}

export interface UpdateFeatureRequest extends UpdateFeatureDTO {
  // Additional validation or business logic fields can be added here
}

export interface DeleteFeatureRequest {
  id: number;
  deleted_by: string;
}

/**
 * Account Feature Rights DTOs
 */
export interface GetAccountFeatureRightsRequest
  extends PaginationParams, AccountFeatureRightFilter {
  account_id?: number;
  feature_id?: number;
}

export interface GetAccountFeatureRightRequest {
  id: number;
}

export interface CreateAccountFeatureRightRequest extends CreateAccountFeatureRightDTO {
  // Additional validation or business logic fields can be added here
}

export interface UpdateAccountFeatureRightRequest extends UpdateAccountFeatureRightDTO {
  // Additional validation or business logic fields can be added here
}

export interface DeleteAccountFeatureRightRequest {
  id: number;
}

/**
 * Account Features endpoint DTOs
 */
export interface GetAccountFeaturesRequest extends PaginationParams {
  account_id: number;
  right?: string;
}

export interface AssignFeatureToAccountRequest {
  account_id: number;
  feature_id: number;
  right: string;
  created_by: string;
}

export interface UpdateAccountFeatureRightRequest {
  account_id: number;
  feature_id: number;
  right: string;
}

export interface RemoveFeatureFromAccountRequest {
  account_id: number;
  feature_id: number;
}

/**
 * Session-related DTOs
 */
export interface GetSessionsRequest extends PaginationParams, SessionFilter {
  account_id?: number;
  active_only?: boolean;
}

export interface GetSessionRequest {
  id: number;
}

export interface CreateSessionRequest extends CreateSessionDTO {
  // Additional validation or business logic fields can be added here
}

export interface UpdateSessionRequest extends UpdateSessionDTO {
  // Additional validation or business logic fields can be added here
}

export interface ValidateTokenRequest {
  token: string;
}

export interface EndSessionRequest {
  token?: string;
  session_id?: number;
}

/**
 * Authentication DTOs
 */
export interface LoginRequest {
  email?: string;
  unikid?: string;
  password?: string; // For internal authentication
  external_token?: string; // For external authentication
  provider?: 'internal' | 'external';
}

export interface LogoutRequest {
  token?: string;
  all_sessions?: boolean; // Logout from all sessions
}

export interface RefreshTokenRequest {
  refresh_token: string;
}

export interface ForgotPasswordRequest {
  email: string;
}

export interface ResetPasswordRequest {
  token: string;
  new_password: string;
}

/**
 * Validation DTOs
 */
export interface ValidationError {
  field: string;
  message: string;
  value?: any;
}

export interface ValidationResult {
  valid: boolean;
  errors: ValidationError[];
}

/**
 * Bulk operation DTOs
 */
export interface BulkOperationRequest<T> {
  items: T[];
  operation: 'create' | 'update' | 'delete';
  created_by?: string;
  modified_by?: string;
}

export interface BulkOperationResponse {
  success: boolean;
  processed: number;
  failed: number;
  errors?: Array<{
    index: number;
    error: string;
    item?: any;
  }>;
}
