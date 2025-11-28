import { APIRequestContext } from '@playwright/test';

export interface ApiResponse<T = any> {
  success: boolean;
  data?: T;
  error?: {
    message: string;
    details?: any;
  };
  timestamp?: string;
  path?: string;
  method?: string;
}

export class ApiTestUtils {
  constructor(private request: APIRequestContext) {}

  async healthCheck(): Promise<ApiResponse> {
    const response = await this.request.get('/api/health');
    return await response.json();
  }

  async authenticateUser(credentials: {
    username: string;
    password: string;
  }): Promise<ApiResponse<{ token: string }>> {
    const response = await this.request.post('/api/authenticate', {
      data: credentials,
    });
    return await response.json();
  }

  async getAccounts(token?: string): Promise<ApiResponse> {
    const headers: Record<string, string> = {};
    if (token) {
      headers.Authorization = `Bearer ${token}`;
    }
    const response = await this.request.get('/api/accounts', { headers });
    return await response.json();
  }

  async createAccount(accountData: any, token?: string): Promise<ApiResponse> {
    const headers: Record<string, string> = {};
    if (token) {
      headers.Authorization = `Bearer ${token}`;
    }
    const response = await this.request.post('/api/accounts', {
      data: accountData,
      headers,
    });
    return await response.json();
  }

  async getFeatures(token?: string): Promise<ApiResponse> {
    const headers: Record<string, string> = {};
    if (token) {
      headers.Authorization = `Bearer ${token}`;
    }
    const response = await this.request.get('/api/features', { headers });
    return await response.json();
  }

  async createFeature(featureData: any, token?: string): Promise<ApiResponse> {
    const headers: Record<string, string> = {};
    if (token) {
      headers.Authorization = `Bearer ${token}`;
    }
    const response = await this.request.post('/api/features', {
      data: featureData,
      headers,
    });
    return await response.json();
  }
}

export function createApiUtils(request: APIRequestContext): ApiTestUtils {
  return new ApiTestUtils(request);
}
