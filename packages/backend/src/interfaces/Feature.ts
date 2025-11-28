/**
 * Feature interface representing the features table
 */
export interface Feature {
  pk: number;
  feature_code: string;
  feature_name: string;
  created_on: Date;
  modified_on: Date;
  created_by: string;
  modified_by: string;
}

/**
 * Feature creation DTO - excludes auto-generated fields
 */
export interface CreateFeatureDTO {
  feature_code: string;
  feature_name: string;
  created_by: string;
}

/**
 * Feature update DTO - includes pk and modifiable fields
 */
export interface UpdateFeatureDTO {
  pk: number;
  feature_code: string;
  feature_name: string;
  modified_by: string;
}

/**
 * Feature query filters
 */
export interface FeatureFilter {
  feature_code?: string;
  feature_name?: string;
  created_by?: string;
}

/**
 * Feature response DTO for API responses
 */
export interface FeatureResponseDTO {
  pk: number;
  feature_code: string;
  feature_name: string;
  created_on: string; // ISO string format
  modified_on: string; // ISO string format
  created_by: string;
  modified_by: string;
}
