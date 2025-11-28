import oracledb, { Connection, Pool, Result } from 'oracledb';
import {
  poolConfig,
  connectionOptions,
  healthCheckQuery,
  initializeOracleClient,
} from '@/configs/database';
import { logger } from '@/utils/logger';

export class DatabaseService {
  private static instance: DatabaseService;
  private pool: Pool | null = null;
  private isInitialized = false;
  private healthCheckInterval: NodeJS.Timeout | null = null;

  private constructor() {
    // Private constructor for singleton pattern
  }

  public static getInstance(): DatabaseService {
    if (!DatabaseService.instance) {
      DatabaseService.instance = new DatabaseService();
    }
    return DatabaseService.instance;
  }

  /**
   * Initialize Oracle client and create connection pool
   */
  public async initialize(): Promise<void> {
    if (this.isInitialized) {
      logger.warn('Database service is already initialized');
      return;
    }

    try {
      // Initialize Oracle client
      initializeOracleClient();

      // Create connection pool
      this.pool = await oracledb.createPool(poolConfig);

      logger.info('Database connection pool created successfully', {
        poolAlias: poolConfig.poolAlias,
        poolMin: poolConfig.poolMin,
        poolMax: poolConfig.poolMax,
        connectString: poolConfig.connectString,
      });

      // Test initial connection
      await this.testConnection();

      // Start health check monitoring
      this.startHealthCheckMonitoring();

      this.isInitialized = true;
      logger.info('Database service initialized successfully');
    } catch (error) {
      const errorMessage =
        error instanceof Error ? error : new Error(String(error));
      logger.error('Failed to initialize database service:', errorMessage);
      throw errorMessage;
    }
  }

  /**
   * Test database connection
   */
  public async testConnection(): Promise<boolean> {
    if (!this.pool) {
      throw new Error('Database pool not initialized');
    }

    let connection: Connection | null = null;
    try {
      connection = await this.pool.getConnection();
      const result = await connection.execute(healthCheckQuery);

      logger.info('Database connection test successful', {
        result: result.rows?.[0] || 'No result',
      });

      return true;
    } catch (error) {
      const errorMessage =
        error instanceof Error ? error : new Error(String(error));
      logger.error('Database connection test failed:', errorMessage);
      return false;
    } finally {
      if (connection) {
        try {
          await connection.close();
        } catch (closeError) {
          logger.warn(
            'Failed to close test connection:',
            closeError instanceof Error
              ? closeError
              : new Error(String(closeError))
          );
        }
      }
    }
  }

  /**
   * Get a connection from the pool
   */
  public async getConnection(): Promise<Connection> {
    if (!this.pool) {
      throw new Error(
        'Database pool not initialized. Call initialize() first.'
      );
    }

    try {
      const connection = await this.pool.getConnection();
      logger.debug('Database connection acquired from pool');
      return connection;
    } catch (error) {
      const errorMessage =
        error instanceof Error ? error : new Error(String(error));
      logger.error('Failed to get database connection:', errorMessage);
      throw errorMessage;
    }
  }

  /**
   * Execute a query with automatic connection management
   */
  public async executeQuery<T = any>(
    sql: string,
    binds: any[] | Record<string, any> = [],
    options: Partial<typeof connectionOptions> = {}
  ): Promise<Result<T>> {
    let connection: Connection | null = null;

    try {
      connection = await this.getConnection();

      const executeOptions = { ...connectionOptions, ...options };
      const result = await connection.execute<T>(sql, binds, executeOptions);

      logger.debug('Query executed successfully', {
        sql: sql.substring(0, 100) + (sql.length > 100 ? '...' : ''),
        rowsAffected: result.rowsAffected,
        rowCount: result.rows?.length || 0,
      });

      return result;
    } catch (error) {
      const errorMessage =
        error instanceof Error ? error : new Error(String(error));
      logger.error('Failed to execute query:', errorMessage, {
        sql: sql.substring(0, 100) + (sql.length > 100 ? '...' : ''),
      });
      throw errorMessage;
    } finally {
      if (connection) {
        try {
          await connection.close();
          logger.debug('Database connection released to pool');
        } catch (closeError) {
          logger.warn(
            'Failed to close connection:',
            closeError instanceof Error
              ? closeError
              : new Error(String(closeError))
          );
        }
      }
    }
  }

  /**
   * Execute a transaction with automatic commit/rollback
   */
  public async executeTransaction<T>(
    callback: (connection: Connection) => Promise<T>
  ): Promise<T> {
    let connection: Connection | null = null;

    try {
      connection = await this.getConnection();

      logger.debug('Starting database transaction');
      const result = await callback(connection);

      await connection.commit();
      logger.debug('Database transaction committed successfully');

      return result;
    } catch (error) {
      if (connection) {
        try {
          await connection.rollback();
          logger.debug('Database transaction rolled back');
        } catch (rollbackError) {
          logger.error(
            'Failed to rollback transaction:',
            rollbackError instanceof Error
              ? rollbackError
              : new Error(String(rollbackError))
          );
        }
      }

      const errorMessage =
        error instanceof Error ? error : new Error(String(error));
      logger.error('Database transaction failed:', errorMessage);
      throw errorMessage;
    } finally {
      if (connection) {
        try {
          await connection.close();
          logger.debug('Database connection released after transaction');
        } catch (closeError) {
          logger.warn(
            'Failed to close connection after transaction:',
            closeError instanceof Error
              ? closeError
              : new Error(String(closeError))
          );
        }
      }
    }
  }

  /**
   * Call Oracle package function
   */
  public async callPackageFunction(
    packageName: string,
    functionName: string,
    parameters: Record<string, any> = {}
  ): Promise<any> {
    const paramList = Object.keys(parameters)
      .map(key => `:${key}`)
      .join(', ');
    const sql = `BEGIN :result := ${packageName}.${functionName}(${paramList}); END;`;

    const binds: Record<string, any> = {
      result: { dir: oracledb.BIND_OUT, type: oracledb.STRING, maxSize: 32767 },
      ...parameters,
    };

    try {
      const result = await this.executeQuery(sql, binds, { autoCommit: true });

      // Parse JSON result if it's a string
      let parsedResult;
      try {
        parsedResult = JSON.parse(result.outBinds?.result || '{}');
      } catch (parseError) {
        // If not JSON, return as is
        parsedResult = result.outBinds?.result;
      }

      logger.debug('Package function executed successfully', {
        package: packageName,
        function: functionName,
        parameterCount: Object.keys(parameters).length,
      });

      return parsedResult;
    } catch (error) {
      const errorMessage =
        error instanceof Error ? error : new Error(String(error));
      logger.error('Failed to call package function:', errorMessage, {
        package: packageName,
        function: functionName,
      });
      throw errorMessage;
    }
  }

  /**
   * Get connection pool statistics
   */
  public getPoolStatistics(): Record<string, any> {
    if (!this.pool) {
      return { status: 'not_initialized' };
    }

    return {
      status: 'active',
      connectionsOpen: this.pool.connectionsOpen,
      connectionsInUse: this.pool.connectionsInUse,
      poolAlias: this.pool.poolAlias,
      poolMin: poolConfig.poolMin,
      poolMax: poolConfig.poolMax,
    };
  }

  /**
   * Start health check monitoring
   */
  private startHealthCheckMonitoring(): void {
    const interval = 30000; // 30 seconds

    this.healthCheckInterval = setInterval(async () => {
      try {
        const isHealthy = await this.testConnection();
        if (!isHealthy) {
          logger.warn('Database health check failed');
        }
      } catch (error) {
        logger.error(
          'Health check monitoring error:',
          error instanceof Error ? error : new Error(String(error))
        );
      }
    }, interval);

    logger.info('Database health check monitoring started', {
      intervalMs: interval,
    });
  }

  /**
   * Stop health check monitoring
   */
  private stopHealthCheckMonitoring(): void {
    if (this.healthCheckInterval) {
      clearInterval(this.healthCheckInterval);
      this.healthCheckInterval = null;
      logger.info('Database health check monitoring stopped');
    }
  }

  /**
   * Gracefully shutdown database service
   */
  public async shutdown(): Promise<void> {
    logger.info('Shutting down database service...');

    try {
      // Stop health monitoring
      this.stopHealthCheckMonitoring();

      // Close connection pool
      if (this.pool) {
        await this.pool.close(0); // 0 = force close immediately
        this.pool = null;
        logger.info('Database connection pool closed');
      }

      this.isInitialized = false;
      logger.info('Database service shutdown completed');
    } catch (error) {
      const errorMessage =
        error instanceof Error ? error : new Error(String(error));
      logger.error('Error during database service shutdown:', errorMessage);
      throw errorMessage;
    }
  }

  /**
   * Check if database service is initialized
   */
  public isReady(): boolean {
    return this.isInitialized && this.pool !== null;
  }
}

// Export singleton instance
export const databaseService = DatabaseService.getInstance();
