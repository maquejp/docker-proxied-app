import express, { Application, Request, Response, NextFunction } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import dotenv from 'dotenv';

// Import configurations
import { PORT, NODE_ENV } from '@/configs/environment';

// Import middlewares
import { errorHandler } from '@/middlewares/errorHandler';
import { logger, requestLogger } from '@/utils/logger';

// Import routes
import healthRoutes from '@/routes/health';

// Import services
import { databaseService } from '@/services/database';

// Load environment variables
dotenv.config();

class App {
  public app: Application;
  private port: string | number;
  private logger = logger;
  private server: any;

  constructor() {
    this.app = express();
    this.port = PORT || 3000;

    this.initializeMiddlewares();
    this.initializeRoutes();
    this.initializeErrorHandling();
  }

  /**
   * Initialize database connection
   */
  public async initializeDatabase(): Promise<void> {
    try {
      this.logger.info('Initializing database connection...');
      await databaseService.initialize();
      this.logger.info('Database connection initialized successfully');
    } catch (error) {
      const errorMessage =
        error instanceof Error ? error : new Error(String(error));
      this.logger.error(
        'Failed to initialize database connection:',
        errorMessage
      );
      throw errorMessage;
    }
  }

  private initializeMiddlewares(): void {
    // Security middleware with comprehensive configuration
    this.app.use(
      helmet({
        contentSecurityPolicy: {
          directives: {
            defaultSrc: ["'self'"],
            styleSrc: ["'self'", "'unsafe-inline'"],
            scriptSrc: ["'self'"],
            imgSrc: ["'self'", 'data:', 'https:'],
          },
        },
        crossOriginEmbedderPolicy: false,
      })
    );

    // Enhanced CORS configuration
    this.app.use(
      cors({
        origin: process.env.ALLOWED_ORIGINS?.split(',') || [
          'http://localhost:4200',
        ],
        credentials: true,
        methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
        allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With'],
      })
    );

    // Body parsing middleware
    this.app.use(express.json({ limit: '10mb' }));
    this.app.use(express.urlencoded({ extended: true, limit: '10mb' }));

    // Request logging middleware (minimal as specified)
    if (NODE_ENV !== 'test') {
      this.app.use(requestLogger);
    }
  }

  private initializeRoutes(): void {
    // Health check route
    this.app.use('/api/health', healthRoutes);

    // API status endpoint
    this.app.get('/api/status', (req: Request, res: Response) => {
      res.status(200).json({
        api: 'Docker Proxied App API',
        status: 'operational',
        timestamp: new Date().toISOString(),
        version: process.env.npm_package_version || '1.0.0',
      });
    });

    // Database status endpoint
    this.app.get(
      '/api/database/status',
      async (req: Request, res: Response) => {
        try {
          const isHealthy = await databaseService.testConnection();
          const poolStats = databaseService.getPoolStatistics();

          res.status(isHealthy ? 200 : 503).json({
            database: 'Oracle Database',
            status: isHealthy ? 'connected' : 'disconnected',
            pool: poolStats,
            timestamp: new Date().toISOString(),
          });
        } catch (error) {
          const errorMessage =
            error instanceof Error ? error.message : 'Unknown error';
          res.status(503).json({
            database: 'Oracle Database',
            status: 'error',
            error: errorMessage,
            timestamp: new Date().toISOString(),
          });
        }
      }
    );

    // API routes will be added here in future phases
    // this.app.use('/api/auth', authRoutes);
    // this.app.use('/api/accounts', accountRoutes);
    // this.app.use('/api/features', featureRoutes);
    // this.app.use('/api/sessions', sessionRoutes);

    // Root endpoint
    this.app.get('/', (req: Request, res: Response) => {
      res.json({
        message: 'Docker Proxied App API',
        version: process.env.npm_package_version || '1.0.0',
        environment: NODE_ENV,
        status: 'running',
        documentation: '/api/docs',
        health: '/api/health',
        timestamp: new Date().toISOString(),
      });
    });

    // 404 handler for undefined routes
    this.app.use('*', (req: Request, res: Response) => {
      res.status(404).json({
        error: 'Route not found',
        path: req.originalUrl,
        method: req.method,
        timestamp: new Date().toISOString(),
      });
    });
  }

  private initializeErrorHandling(): void {
    this.app.use(errorHandler);
  }

  public listen(): void {
    const server = this.app.listen(this.port, () => {
      this.logger.info(
        `🚀 Server running on port ${this.port} in ${NODE_ENV} mode`
      );
      this.logger.info(
        `📝 API documentation available at http://localhost:${this.port}/api-docs`
      );
    });

    server.on('error', (error: Error) => {
      this.logger.error('Server startup error:', error);
      process.exit(1);
    });

    // Setup graceful shutdown
    const gracefulShutdown =
      require('./utils/gracefulShutdown').setupGracefulShutdown;
    gracefulShutdown(() => {
      return new Promise<void>(resolve => {
        this.logger.info('Closing HTTP server...');
        server.close(() => {
          this.logger.info('HTTP server closed.');
          resolve();
        });
      });
    });

    this.server = server;
  }

  public getServer(): Application {
    return this.app;
  }

  public getHttpServer() {
    return this.server;
  }
}

export default App;
