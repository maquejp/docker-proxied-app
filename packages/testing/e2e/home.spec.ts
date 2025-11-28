import { test, expect } from '@playwright/test';

test.describe('Home Page', () => {
  test('should load the home page successfully', async ({ page }) => {
    await page.goto('/');
    
    // Wait for the page to load
    await page.waitForLoadState('networkidle');
    
    // Check that the page loaded successfully
    expect(page.url()).toContain('localhost:4200');
    
    // Check for eUI elements (these will be updated once frontend is accessible)
    await expect(page).toHaveTitle(/eUI Angular App/i);
  });

  test('should have proper navigation elements', async ({ page }) => {
    await page.goto('/');
    
    // Wait for the page to load
    await page.waitForLoadState('networkidle');
    
    // Check for navigation elements (to be updated based on actual eUI implementation)
    // This is a placeholder test that will be updated once the frontend is accessible
    const body = await page.locator('body');
    await expect(body).toBeVisible();
  });
});