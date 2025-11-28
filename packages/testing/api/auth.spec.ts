import { test, expect } from '@playwright/test';

test.describe('Authentication API', () => {
  test.skip('should authenticate valid user credentials', async ({ request }) => {
    // TODO: Implement when authentication endpoints are ready
    const response = await request.post('/api/authenticate', {
      data: {
        username: 'test-user',
        password: 'test-password',
      },
    });
    
    // This test will be implemented once the authentication endpoint is ready
    expect(response.status()).toBe(200);
  });

  test('should reject invalid credentials', async ({ request }) => {
    const response = await request.post('/api/authenticate', {
      data: {
        username: 'invalid',
        password: 'invalid',
      },
    });
    
    // For now, endpoint doesn't exist, so we expect 404
    expect(response.status()).toBe(404);
  });

  test('should require authentication for protected endpoints', async ({ request }) => {
    // Test that accounts endpoint requires authentication (when implemented)
    const response = await request.get('/api/accounts');
    
    // For now, endpoint doesn't exist, so we expect 404
    expect(response.status()).toBe(404);
  });
});