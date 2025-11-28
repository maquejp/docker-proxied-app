import { chromium, FullConfig } from '@playwright/test';

async function globalSetup(config: FullConfig) {
  console.log('🚀 Starting global test setup...');
  
  // Wait for servers to be ready
  const browser = await chromium.launch();
  const page = await browser.newPage();
  
  try {
    // Check if backend API is ready
    console.log('⏳ Waiting for backend API...');
    let apiReady = false;
    for (let i = 0; i < 30; i++) {
      try {
        const response = await page.request.get('http://localhost:3000/api/health');
        if (response.ok()) {
          apiReady = true;
          console.log('✅ Backend API is ready');
          break;
        }
      } catch (error) {
        // Continue waiting
      }
      await page.waitForTimeout(1000);
    }
    
    if (!apiReady) {
      throw new Error('❌ Backend API failed to start');
    }
    
    // Check if frontend is ready
    console.log('⏳ Waiting for frontend...');
    let frontendReady = false;
    for (let i = 0; i < 60; i++) {
      try {
        const response = await page.request.get('http://localhost:4200');
        if (response.ok()) {
          frontendReady = true;
          console.log('✅ Frontend is ready');
          break;
        }
      } catch (error) {
        // Continue waiting
      }
      await page.waitForTimeout(1000);
    }
    
    if (!frontendReady) {
      console.warn('⚠️ Frontend may not be ready, continuing with tests...');
    }
    
    console.log('✅ Global setup completed successfully');
    
  } finally {
    await browser.close();
  }
}

export default globalSetup;