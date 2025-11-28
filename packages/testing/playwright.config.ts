import { defineConfig, devices } from '@playwright/test';

/**
 * @see https://playwright.dev/docs/test-configuration
 */
export default defineConfig({
  testDir: './tests',
  /* Run tests in files in parallel */
  fullyParallel: true,
  /* Fail the build on CI if you accidentally left test.only in the source code. */
  forbidOnly: !!process.env.CI,
  /* Retry on CI only */
  retries: process.env.CI ? 2 : 0,
  /* Opt out of parallel tests on CI. */
  workers: process.env.CI ? 1 : undefined,
  /* Reporter to use. See https://playwright.dev/docs/test-reporters */
  reporter: [
    ['html'],
    ['json', { outputFile: 'playwright-report/results.json' }],
    ['junit', { outputFile: 'playwright-report/results.xml' }]
  ],
  /* Shared settings for all the projects below. See https://playwright.dev/docs/api/class-testoptions. */
  use: {
    /* Base URL to use in actions like `await page.goto('/')`. */
    baseURL: process.env.BASE_URL || 'http://localhost:4200',
    
    /* Collect trace when retrying the failed test. See https://playwright.dev/docs/trace-viewer */
    trace: 'on-first-retry',
    
    /* Take screenshot only when test fails */
    screenshot: 'only-on-failure',
    
    /* Record video only when test fails */
    video: 'retain-on-failure',
  },

  /* Global setup and teardown */
  globalSetup: './utils/global-setup.ts',
  globalTeardown: './utils/global-teardown.ts',

  /* Configure projects for major browsers */
  projects: [
    // Setup project
    {
      name: 'setup',
      testMatch: /.*\.setup\.ts/,
    },
    
    // API Tests
    {
      name: 'api-tests',
      testDir: './api',
      use: {
        baseURL: process.env.API_BASE_URL || 'http://localhost:3000',
      },
    },

    // E2E Tests - Chrome
    {
      name: 'chromium',
      testDir: './e2e',
      use: { ...devices['Desktop Chrome'] },
      dependencies: ['setup'],
    },

    // E2E Tests - Firefox
    {
      name: 'firefox',
      testDir: './e2e',
      use: { ...devices['Desktop Firefox'] },
      dependencies: ['setup'],
    },

    // E2E Tests - WebKit
    {
      name: 'webkit',
      testDir: './e2e',
      use: { ...devices['Desktop Safari'] },
      dependencies: ['setup'],
    },

    /* Test against mobile viewports. */
    {
      name: 'Mobile Chrome',
      testDir: './e2e',
      use: { ...devices['Pixel 5'] },
      dependencies: ['setup'],
    },
    {
      name: 'Mobile Safari',
      testDir: './e2e',
      use: { ...devices['iPhone 12'] },
      dependencies: ['setup'],
    },

    /* Test against branded browsers. */
    // {
    //   name: 'Microsoft Edge',
    //   use: { ...devices['Desktop Edge'], channel: 'msedge' },
    // },
    // {
    //   name: 'Google Chrome',
    //   use: { ...devices['Desktop Chrome'], channel: 'chrome' },
    // },
  ],

  /* Run your local dev server before starting the tests */
  webServer: [
    {
      command: 'cd ../backend && npm run dev',
      port: 3000,
      reuseExistingServer: !process.env.CI,
    },
    {
      command: 'cd ../frontend && npm start',
      port: 4200,
      reuseExistingServer: !process.env.CI,
    },
  ],
});