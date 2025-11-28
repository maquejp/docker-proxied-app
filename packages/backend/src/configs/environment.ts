import dotenv from 'dotenv';

// Load environment variables
dotenv.config();

export const NODE_ENV = process.env.NODE_ENV || 'development';
export const PORT = process.env.BACKEND_PORT || process.env.PORT || 3000;
export const FRONTEND_URL = process.env.FRONTEND_URL || 'http://localhost:4200';

// Oracle Database Configuration
export const ORACLE_CONFIG = {
  server: process.env.ORACLE_SERVER || 'localhost',
  port: parseInt(process.env.ORACLE_PORT || '1521', 10),
  user: process.env.ORACLE_USER || 'docker_app_user',
  password: process.env.ORACLE_PASSWORD || 'docker_app_password',
  service: process.env.ORACLE_SERVICE || 'XE',
  database: process.env.ORACLE_DATABASE || 'XE',
  connectString: process.env.ORACLE_CONNECT_STRING || `${process.env.ORACLE_SERVER || 'localhost'}:${process.env.ORACLE_PORT || '1521'}/${process.env.ORACLE_SERVICE || 'XE'}`,
  
  // Connection pool settings
  poolMin: parseInt(process.env.DB_POOL_MIN || '2', 10),
  poolMax: parseInt(process.env.DB_POOL_MAX || '10', 10),
  poolIncrement: parseInt(process.env.DB_POOL_INCREMENT || '1', 10),
  poolTimeout: parseInt(process.env.DB_POOL_TIMEOUT || '60', 10),
  stmtCacheSize: parseInt(process.env.DB_STMT_CACHE_SIZE || '30', 10),
  queueTimeout: parseInt(process.env.DB_QUEUE_TIMEOUT || '60000', 10),
  poolPingInterval: parseInt(process.env.DB_POOL_PING_INTERVAL || '60', 10),
  
  // Oracle client configuration
  clientLibDir: process.env.ORACLE_CLIENT_LIB_DIR || undefined,
  configDir: process.env.ORACLE_CONFIG_DIR || undefined,
};

// JWT Configuration
export const JWT_CONFIG = {
  secret: process.env.JWT_SECRET || 'your-jwt-secret-key',
  expiresIn: process.env.JWT_EXPIRES_IN || '10h',
  refreshExpiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '7d',
};

// API Configuration
export const API_CONFIG = {
  prefix: '/api',
  version: 'v1',
  rateLimitWindow: parseInt(process.env.RATE_LIMIT_WINDOW || '900000', 10), // 15 minutes
  rateLimitMax: parseInt(process.env.RATE_LIMIT_MAX || '100', 10), // limit each IP to 100 requests per windowMs
};
