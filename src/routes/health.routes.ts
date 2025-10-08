import { Router, Request, Response } from 'express';
import { logger } from '../config/logger';

const router = Router();

interface HealthStatus {
  status: 'healthy' | 'unhealthy';
  timestamp: string;
  uptime: number;
  version: string;
  environment: string;
  services: {
    database?: 'healthy' | 'unhealthy';
    fireblocks?: 'healthy' | 'unhealthy';
    loki?: 'healthy' | 'unhealthy';
  };
}

router.get('/', (req: Request, res: Response) => {
  const healthStatus: HealthStatus = {
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    version: process.env.npm_package_version || '1.0.0',
    environment: process.env.NODE_ENV || 'development',
    services: {
      // Add service health checks here
    },
  };

  logger.info('Health check performed', { healthStatus });
  res.json(healthStatus);
});

router.get('/ready', (req: Request, res: Response) => {
  // Add readiness checks here (database connections, etc.)
  res.json({ status: 'ready', timestamp: new Date().toISOString() });
});

router.get('/live', (req: Request, res: Response) => {
  // Basic liveness check
  res.json({ status: 'live', timestamp: new Date().toISOString() });
});

export default router;
