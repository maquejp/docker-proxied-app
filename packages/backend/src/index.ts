import App from './app';
import { logger } from './utils/logger';

// Create and start the application
const app = new App();

// Start server
try {
  app.listen();
  logger.info('🎯 Application started successfully');
} catch (error) {
  logger.error('Failed to start application:', error);
  process.exit(1);
}
