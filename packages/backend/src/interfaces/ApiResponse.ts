/**
 * Standard API response wrapper
 */
export interface ApiResponse<T = any> {
  success: boolean;
  data?: T;
  message: string;
  timestamp: string;
  request_id?: string;
}

/**
 * API error response
 */
export interface ApiErrorResponse {
  success: false;
  error: {
    code: string;
    message: string;
    details?: any;
    stack?: string; // Only in development
  };
  timestamp: string;
  request_id?: string;
}

/**
 * Paginated response wrapper
 */
export interface PaginatedResponse<T = any> {
  success: boolean;
  data: T[];
  pagination: {
    page: number;
    page_size: number;
    total_records: number;
    total_pages: number;
    has_next: boolean;
    has_previous: boolean;
  };
  message: string;
  timestamp: string;
  request_id?: string;
}

/**
 * Pagination parameters
 */
export interface PaginationParams {
  page?: number;
  page_size?: number;
  order_by?: string;
  order_dir?: 'ASC' | 'DESC';
}

/**
 * Filter parameters
 */
export interface FilterParams {
  filter_field?: string;
  filter_value?: string;
  filter_operator?: 'EQUALS' | 'CONTAINS' | 'STARTS_WITH' | 'ENDS_WITH';
}

/**
 * Query parameters combining pagination and filtering
 */
export interface QueryParams extends PaginationParams, FilterParams {
  [key: string]: any;
}

/**
 * Operation result
 */
export interface OperationResult {
  success: boolean;
  affected_rows?: number;
  id?: number;
  message: string;
}

/**
 * Health check response
 */
export interface HealthCheckResponse {
  status: 'healthy' | 'unhealthy' | 'degraded';
  timestamp: string;
  version: string;
  environment: string;
  services: {
    database: {
      status: 'connected' | 'disconnected' | 'error';
      connection_pool?: {
        connections_open: number;
        connections_in_use: number;
        pool_min: number;
        pool_max: number;
      };
    };
    api: {
      status: 'operational' | 'error';
      uptime: number;
    };
  };
}
