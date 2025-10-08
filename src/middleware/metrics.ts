import { Request, Response, NextFunction } from 'express';
import client from 'prom-client';

// Create Prometheus metrics
const httpRequestDuration = new client.Histogram({
  name: 'http_request_duration_ms',
  help: 'Duration of HTTP requests in ms',
  labelNames: ['route', 'method', 'status'],
  buckets: [0.1, 5, 15, 50, 100, 500],
});

const httpRequestsTotal = new client.Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['route', 'method', 'status'],
});

// Register metrics
client.register.registerMetric(httpRequestDuration);
client.register.registerMetric(httpRequestsTotal);

export const metricsMiddleware = (req: Request, res: Response, next: NextFunction) => {
  const startTime = Date.now();

  // Capture metrics when response finishes
  res.on('finish', () => {
    const duration = Date.now() - startTime;
    const route = req.route ? req.route.path : req.path;

    httpRequestDuration.labels(route, req.method, res.statusCode.toString()).observe(duration);

    httpRequestsTotal.labels(route, req.method, res.statusCode.toString()).inc();
  });

  next();
};

export { client };
