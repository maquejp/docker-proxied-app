import express, { Application, Request, Response, NextFunction } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import dotenv from 'dotenv';

// Import configurations
import { PORT, NODE_ENV } from '@/configs/environment';

// Import middlewares
import { errorHandler } from '@/middlewares/errorHandler';
import { requestLogger } from '@/middlewares/logging';

// Import routes
import healthRoutes from '@/routes/health';

// Load environment variables
dotenv.config();

class App {
  public app: Application;
  private port: string | number;

  constructor() {
    this.app = express();
    this.port = PORT || 3000;

    this.initializeMiddlewares();
    this.initializeRoutes();
    this.initializeErrorHandling();
  }

  private initializeMiddlewares(): void {
    // Security middleware
    this.app.use(
      helmet({
        crossOriginEmbedderPolicy: false,
      })
    );

    // CORS configuration
    this.app.use(
      cors({
        origin: process.env.FRONTEND_URL || 'http://localhost:4200',
        credentials: true,
        methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
        allowedHeaders: ['Content-Type', 'Authorization'],
      })
    );

    // Body parsing middleware
    this.app.use(express.json({ limit: '10mb' }));
    this.app.use(express.urlencoded({ extended: true, limit: '10mb' }));

    // Request logging middleware (minimal as specified)
    this.app.use(requestLogger);
  }

  private initializeRoutes(): void {
    // Health check route
    this.app.use('/api/health', healthRoutes);

    // API routes will be added here
    // this.app.use('/api/auth', authRoutes);
    // this.app.use('/api/accounts', accountRoutes);
    // this.app.use('/api/features', featureRoutes);
    // this.app.use('/api/sessions', sessionRoutes);

    // Default route
    this.app.get('/', (req: Request, res: Response) => {
      res.json({
        message: 'Docker Proxied App API',
        version: '1.0.0',
        environment: NODE_ENV,
        status: 'running',
      });
    });

    // 404 handler
    this.app.use('*', (req: Request, res: Response) => {
      res.status(404).json({
        error: 'Route not found',
        path: req.originalUrl,
        method: req.method,
      });
    });
  }

  private initializeErrorHandling(): void {
    this.app.use(errorHandler);
  }

  public listen(): void {
    this.app.listen(this.port, () => {
      console.log(`🚀 Server running on port ${this.port} in ${NODE_ENV} mode`);
    });
  }

  public getServer(): Application {
    return this.app;
  }
}

export default App;
