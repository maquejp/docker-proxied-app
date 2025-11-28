import express, { Request, Response } from 'express';

const router = express.Router();

// Health check endpoint
router.get('/', (req: Request, res: Response) => {
  res.status(200).json({
    status: 'OK',
    message: 'API is healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: process.env.NODE_ENV || 'development',
    version: '1.0.0',
  });
});

// Database health check (will be implemented later with Oracle connection)
router.get('/db', (req: Request, res: Response) => {
  // TODO: Implement Oracle database health check
  res.status(200).json({
    status: 'OK',
    message: 'Database health check - to be implemented',
    timestamp: new Date().toISOString(),
  });
});

export default router;
