import { Request, Response, NextFunction } from 'express';

export const requestLogger = (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  // Minimal logging as specified in requirements
  const start = Date.now();
  
  res.on('finish', () => {
    const duration = Date.now() - start;
    const logMessage = `${req.method} ${req.originalUrl} - ${res.statusCode} (${duration}ms)`;
    
    // Only log errors and important requests in production
    if (process.env.NODE_ENV === 'production') {
      if (res.statusCode >= 400) {
        console.error(logMessage);
      }
    } else {
      // Log all requests in development
      console.log(logMessage);
    }
  });

  next();
};