import { logger } from './logger';
import { databaseService } from '@/services/database';

/**
 * Graceful shutdown handler type
 */
type ShutdownHandler = () => Promise<void>;

/**
 * List of cleanup handlers to execute during shutdown
 */
const shutdownHandlers: ShutdownHandler[] = [];

/**
 * Flag to prevent multiple shutdown attempts
 */
let isShuttingDown = false;

/**
 * Add a handler to be executed during graceful shutdown
 */
export const addShutdownHandler = (handler: ShutdownHandler): void => {
  shutdownHandlers.push(handler);
};

/**
 * Execute graceful shutdown sequence
 */
export const gracefulShutdown = async (signal: string): Promise<void> => {
  if (isShuttingDown) {
    logger.warn('Shutdown already in progress, ignoring signal', { signal });
    return;
  }

  isShuttingDown = true;
  logger.info('Graceful shutdown initiated', {
    signal,
    handlersCount: shutdownHandlers.length,
    pid: process.pid,
  });

  // Set timeout for forceful shutdown if graceful shutdown takes too long
  const forceShutdownTimeout = setTimeout(() => {
    logger.error('Graceful shutdown timeout exceeded, forcing exit');
    process.exit(1);
  }, 30000); // 30 seconds timeout

  try {
    // Execute all shutdown handlers
    await Promise.all(
      shutdownHandlers.map(async (handler, index) => {
        try {
          await handler();
          logger.debug(`Shutdown handler ${index + 1} completed successfully`);
        } catch (error) {
          logger.error(
            `Shutdown handler ${index + 1} failed`,
            error instanceof Error ? error : new Error(String(error))
          );
        }
      })
    );

    logger.info('Graceful shutdown completed successfully');
    clearTimeout(forceShutdownTimeout);
    process.exit(0);
  } catch (error) {
    logger.error(
      'Error during graceful shutdown',
      error instanceof Error ? error : new Error(String(error))
    );
    clearTimeout(forceShutdownTimeout);
    process.exit(1);
  }
};

/**
 * Setup graceful shutdown handlers for various signals
 */
export const setupGracefulShutdown = (
  appShutdownHandler?: ShutdownHandler
): void => {
  // Add database shutdown handler
  addShutdownHandler(async () => {
    try {
      if (databaseService.isReady()) {
        logger.info('Shutting down database service...');
        await databaseService.shutdown();
        logger.info('Database service shutdown completed');
      }
    } catch (error) {
      logger.error('Error during database shutdown:', error instanceof Error ? error : new Error(String(error)));
    }
  });

  // Add application-specific shutdown handler if provided
  if (appShutdownHandler) {
    addShutdownHandler(appShutdownHandler);
  }

  // Handle different shutdown signals
  const signals: NodeJS.Signals[] = ['SIGTERM', 'SIGINT', 'SIGUSR2'];

  signals.forEach(signal => {
    process.on(signal, () => {
      logger.info(`Received ${signal}, initiating graceful shutdown`);
      gracefulShutdown(signal);
    });
  });

  // Handle uncaught exceptions
  process.on('uncaughtException', (error: Error) => {
    logger.error('Uncaught Exception - initiating emergency shutdown', error);

    // Try graceful shutdown but with shorter timeout
    const emergencyTimeout = setTimeout(() => {
      logger.error('Emergency shutdown timeout, forcing exit');
      process.exit(1);
    }, 5000);

    gracefulShutdown('uncaughtException').finally(() => {
      clearTimeout(emergencyTimeout);
      process.exit(1);
    });
  });

  // Handle unhandled promise rejections
  process.on(
    'unhandledRejection',
    (reason: unknown, promise: Promise<unknown>) => {
      logger.error(
        'Unhandled Promise Rejection - initiating emergency shutdown',
        {
          reason: String(reason),
          promise: String(promise),
        }
      );

      // Try graceful shutdown but with shorter timeout
      const emergencyTimeout = setTimeout(() => {
        logger.error('Emergency shutdown timeout, forcing exit');
        process.exit(1);
      }, 5000);

      gracefulShutdown('unhandledRejection').finally(() => {
        clearTimeout(emergencyTimeout);
        process.exit(1);
      });
    }
  );

  logger.info('Graceful shutdown handlers registered', {
    signals: signals,
    handlersCount: shutdownHandlers.length,
  });
};

/**
 * Health check for shutdown state
 */
export const isApplicationShuttingDown = (): boolean => {
  return isShuttingDown;
};
