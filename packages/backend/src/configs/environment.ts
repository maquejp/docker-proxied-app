import dotenv from 'dotenv';

// Load environment variables
dotenv.config();

export const NODE_ENV = process.env.NODE_ENV || 'development';
export const PORT = process.env.PORT || 3000;
export const FRONTEND_URL = process.env.FRONTEND_URL || 'http://localhost:4200';

// Oracle Database Configuration
export const ORACLE_CONFIG = {
  server: process.env.ORACLE_SERVER || 'localhost',
  port: parseInt(process.env.ORACLE_PORT || '1521', 10),
  username: process.env.ORACLE_USERNAME || '',
  password: process.env.ORACLE_PASSWORD || '',
  database: process.env.ORACLE_DATABASE || '',
  poolMin: parseInt(process.env.ORACLE_POOL_MIN || '2', 10),
  poolMax: parseInt(process.env.ORACLE_POOL_MAX || '10', 10),
  poolIncrement: parseInt(process.env.ORACLE_POOL_INCREMENT || '1', 10),
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
