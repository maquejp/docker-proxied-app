/**
 * Account Feature Right interface representing the accounts_features_rights table
 */
export interface AccountFeatureRight {
  pk: number;
  pk_account: number;
  pk_feature: number;
  right: string;
  created_on: Date;
  created_by: string;
}

/**
 * Account Feature Right creation DTO - excludes auto-generated fields
 */
export interface CreateAccountFeatureRightDTO {
  pk_account: number;
  pk_feature: number;
  right: string;
  created_by: string;
}

/**
 * Account Feature Right update DTO - includes pk and modifiable fields
 */
export interface UpdateAccountFeatureRightDTO {
  pk: number;
  pk_account: number;
  pk_feature: number;
  right: string;
}

/**
 * Account Feature Right query filters
 */
export interface AccountFeatureRightFilter {
  pk_account?: number;
  pk_feature?: number;
  right?: string;
  created_by?: string;
}

/**
 * Account Feature Right response DTO for API responses
 */
export interface AccountFeatureRightResponseDTO {
  pk: number;
  pk_account: number;
  pk_feature: number;
  right: string;
  created_on: string; // ISO string format
  created_by: string;
  // Joined data from related tables
  account?: {
    givenname: string;
    lastname: string;
    email: string;
  };
  feature?: {
    feature_code: string;
    feature_name: string;
  };
}

/**
 * Right types enumeration
 */
export enum RightType {
  READ = 'READ',
  WRITE = 'WRITE',
  DELETE = 'DELETE',
  ADMIN = 'ADMIN',
}
