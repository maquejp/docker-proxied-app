import { test, expect } from '@playwright/test';
import { createApiUtils } from '../utils/api-helpers';

test.describe('API Health Checks', () => {
  test('should return healthy status for main health endpoint', async ({ request }) => {
    const apiUtils = createApiUtils(request);
    const response = await apiUtils.healthCheck();
    
    expect(response).toHaveProperty('status', 'OK');
    expect(response).toHaveProperty('message');
    expect(response).toHaveProperty('timestamp');
    expect(response).toHaveProperty('uptime');
    expect(response).toHaveProperty('environment');
    expect(response).toHaveProperty('version');
  });

  test('should return 404 for non-existent endpoints', async ({ request }) => {
    const response = await request.get('/api/non-existent-endpoint');
    expect(response.status()).toBe(404);
    
    const body = await response.json();
    expect(body).toHaveProperty('error', 'Route not found');
    expect(body).toHaveProperty('path', '/api/non-existent-endpoint');
    expect(body).toHaveProperty('method', 'GET');
  });
});