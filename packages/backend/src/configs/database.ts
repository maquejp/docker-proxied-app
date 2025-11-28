import oracledb from 'oracledb';
import { ORACLE_CONFIG } from '@/configs/environment';
import { logger } from '@/utils/logger';

// Database configuration interface
export interface DatabaseConfig {
  user: string;
  password: string;
  connectString: string;
  poolMin: number;
  poolMax: number;
  poolIncrement: number;
  poolTimeout: number;
  stmtCacheSize: number;
  queueTimeout: number;
  poolPingInterval: number;
}

// Oracle database configuration
export const dbConfig: DatabaseConfig = {
  user: ORACLE_CONFIG.user,
  password: ORACLE_CONFIG.password,
  connectString: ORACLE_CONFIG.connectString,
  poolMin: ORACLE_CONFIG.poolMin,
  poolMax: ORACLE_CONFIG.poolMax,
  poolIncrement: ORACLE_CONFIG.poolIncrement,
  poolTimeout: ORACLE_CONFIG.poolTimeout,
  stmtCacheSize: ORACLE_CONFIG.stmtCacheSize,
  queueTimeout: ORACLE_CONFIG.queueTimeout,
  poolPingInterval: ORACLE_CONFIG.poolPingInterval
};

// Oracle connection pool configuration
export const poolConfig: oracledb.PoolAttributes = {
  user: dbConfig.user,
  password: dbConfig.password,
  connectString: dbConfig.connectString,
  poolMin: dbConfig.poolMin,
  poolMax: dbConfig.poolMax,
  poolIncrement: dbConfig.poolIncrement,
  poolTimeout: dbConfig.poolTimeout,
  stmtCacheSize: dbConfig.stmtCacheSize,
  queueTimeout: dbConfig.queueTimeout,
  poolPingInterval: dbConfig.poolPingInterval,
  
  // Pool alias for easy reference
  poolAlias: 'docker-app-pool'
};

// Oracle connection options
export const connectionOptions: oracledb.ExecuteOptions = {
  // Auto commit for non-transactional operations
  autoCommit: false,
  
  // Fetch array size for better performance
  fetchArraySize: 100,
  
  // Result set format
  outFormat: oracledb.OUT_FORMAT_OBJECT,
  
  // Maximum rows to fetch
  maxRows: 1000
};

// Initialize Oracle client configuration
export function initializeOracleClient(): void {
  try {
    // Set Oracle client configuration
    oracledb.initOracleClient({
      // Oracle Instant Client path (if needed)
      libDir: ORACLE_CONFIG.clientLibDir,
      
      // Oracle configuration directory (if needed)
      configDir: ORACLE_CONFIG.configDir,
      
      // Error URL for better error messages
      errorUrl: 'https://oracle.github.io/node-oracledb/INSTALL.html'
    });
    
    logger.info('Oracle client initialized successfully');
  } catch (error) {
    const errorMessage = error instanceof Error ? error : new Error(String(error));
    logger.error('Failed to initialize Oracle client:', errorMessage);
    throw errorMessage;
  }
}

// Database connection pool health check query
export const healthCheckQuery = 'SELECT 1 as health_check FROM dual';

// Export Oracle DB for type definitions
export { oracledb };