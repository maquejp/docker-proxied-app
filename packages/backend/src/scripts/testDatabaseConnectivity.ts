/**
 * Database connectivity test script
 * Run this script to test Oracle database connection and package calls
 */

import dotenv from 'dotenv';
import { databaseService } from '@/services/database';
import { logger } from '@/utils/logger';

// Load environment variables
dotenv.config();

async function testDatabaseConnectivity(): Promise<void> {
  try {
    logger.info('🧪 Starting database connectivity test...');

    // Initialize database service
    await databaseService.initialize();
    logger.info('✅ Database service initialized');

    // Test basic connectivity
    const isConnected = await databaseService.testConnection();
    if (isConnected) {
      logger.info('✅ Database connection test passed');
    } else {
      throw new Error('Database connection test failed');
    }

    // Test pool statistics
    const stats = databaseService.getPoolStatistics();
    logger.info('📊 Connection pool statistics:', stats);

    // Test a basic query
    logger.info('🔍 Testing basic SQL query...');
    const basicResult = await databaseService.executeQuery(
      'SELECT SYSDATE as current_date, USER as current_user FROM dual'
    );
    logger.info('✅ Basic query result:', basicResult.rows?.[0]);

    // Test package function calls (if packages exist)
    logger.info('📦 Testing Oracle package calls...');
    
    try {
      // Test p_accounts package
      logger.info('Testing p_accounts.get_records...');
      const accountsResult = await databaseService.callPackageFunction(
        'p_accounts', 
        'get_records',
        {
          p_page_number: 1,
          p_page_size: 5,
          p_order_by: 'pk',
          p_order_dir: 'ASC',
          p_filter_field: '',
          p_filter_value: ''
        }
      );
      logger.info('✅ p_accounts.get_records result:', accountsResult);
    } catch (packageError) {
      logger.warn('📦 Package test failed (packages might not be deployed):', packageError instanceof Error ? packageError : new Error(String(packageError)));
    }

    logger.info('🎉 Database connectivity test completed successfully!');

  } catch (error) {
    logger.error('❌ Database connectivity test failed:', error instanceof Error ? error : new Error(String(error)));
    process.exit(1);
  } finally {
    // Cleanup
    try {
      await databaseService.shutdown();
      logger.info('✅ Database service shutdown completed');
    } catch (shutdownError) {
      logger.error('❌ Error during database shutdown:', shutdownError instanceof Error ? shutdownError : new Error(String(shutdownError)));
    }
    
    process.exit(0);
  }
}

// Run the test
if (require.main === module) {
  testDatabaseConnectivity().catch(error => {
    logger.error('❌ Test runner error:', error instanceof Error ? error : new Error(String(error)));
    process.exit(1);
  });
}

export { testDatabaseConnectivity };