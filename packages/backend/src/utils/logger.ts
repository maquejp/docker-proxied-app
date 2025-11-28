/**
 * Minimal Logger Utility
 * Provides structured logging with minimal overhead as specified
 */

export interface LogData {
  [key: string]: any;
}

export interface LogEntry {
  level: string;
  message: string;
  timestamp: string;
  data?: LogData;
}

/**
 * Logger class with minimal implementation
 * Outputs structured logs to console with timestamp and level
 */
class Logger {
  private isDevelopment: boolean;

  constructor() {
    this.isDevelopment = process.env.NODE_ENV === 'development';
  }

  /**
   * Format log entry for output
   */
  private formatLog(level: string, message: string, data?: LogData): LogEntry {
    return {
      level: level.toUpperCase(),
      message,
      timestamp: new Date().toISOString(),
      ...(data && { data }),
    };
  }

  /**
   * Output log to console
   */
  private output(logEntry: LogEntry): void {
    const output = this.isDevelopment
      ? JSON.stringify(logEntry, null, 2)
      : JSON.stringify(logEntry);

    console.log(output);
  }

  /**
   * Log info level messages
   */
  public info(message: string, data?: LogData): void {
    const logEntry = this.formatLog('info', message, data);
    this.output(logEntry);
  }

  /**
   * Log warning level messages
   */
  public warn(message: string, data?: LogData): void {
    const logEntry = this.formatLog('warn', message, data);
    this.output(logEntry);
  }

  /**
   * Log error level messages
   */
  public error(message: string, error?: Error | LogData, data?: LogData): void {
    let errorData: LogData = {};

    if (error instanceof Error) {
      errorData = {
        error: error.message,
        stack: error.stack,
        name: error.name,
        ...data,
      };
    } else if (error) {
      errorData = { ...error, ...data };
    }

    const logEntry = this.formatLog('error', message, errorData);
    this.output(logEntry);
  }

  /**
   * Log debug level messages (only in development)
   */
  public debug(message: string, data?: LogData): void {
    if (this.isDevelopment) {
      const logEntry = this.formatLog('debug', message, data);
      this.output(logEntry);
    }
  }

  /**
   * Log HTTP request details
   */
  public http(message: string, data?: LogData): void {
    if (process.env.NODE_ENV !== 'test') {
      const logEntry = this.formatLog('http', message, data);
      this.output(logEntry);
    }
  }
}

// Export singleton instance
export const logger = new Logger();

/**
 * Request logging middleware
 */
export const requestLogger = (req: any, res: any, next: any) => {
  const start = Date.now();

  res.on('finish', () => {
    const duration = Date.now() - start;

    logger.http(`${req.method} ${req.path}`, {
      method: req.method,
      path: req.path,
      statusCode: res.statusCode,
      duration: `${duration}ms`,
      ip: req.ip || req.connection?.remoteAddress,
      userAgent: req.get('User-Agent'),
      contentLength: res.get('Content-Length'),
    });
  });

  next();
};
