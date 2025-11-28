import App from './app';
import { logger } from './utils/logger';

// Create application instance
const app = new App();

// Start application with database initialization
async function startApplication(): Promise<void> {
  try {
    // Initialize database connection
    await app.initializeDatabase();

    // Start server
    app.listen();
    logger.info('🎯 Application started successfully');
  } catch (error) {
    logger.error(
      'Failed to start application:',
      error instanceof Error ? error : new Error(String(error))
    );
    process.exit(1);
  }
}

// Start the application
startApplication();
