import { Request, Response, NextFunction } from 'express';
import { logger } from '../config/logger';
import { ApiError } from '../utils/ApiError';

export const errorHandler = (
  err: Error,
  req: Request,
  res: Response,
  // eslint-disable-next-line @typescript-eslint/no-unused-vars, no-unused-vars
  _next: NextFunction
) => {
  let error = err;

  if (!(error instanceof ApiError)) {
    const statusCode = 500;
    const message = 'Internal Server Error';
    error = new ApiError(statusCode, message, false, err.stack);
  }

  const { statusCode, message } = error as ApiError;

  // Log error details
  logger.error({
    error: message,
    stack: error.stack,
    url: req.url,
    method: req.method,
    ip: req.ip,
    userAgent: req.get('User-Agent'),
  });

  const response = {
    code: statusCode,
    message,
    ...(process.env.NODE_ENV === 'development' && { stack: error.stack }),
  };

  res.status(statusCode).json(response);
};
