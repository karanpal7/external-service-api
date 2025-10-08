import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import compression from 'compression';
import { config } from './config/config';
import { logger } from './config/logger';
import { errorHandler } from './middleware/error';
import { metricsMiddleware } from './middleware/metrics';
import fireblocksRoutes from './routes/fireblocks.routes';
import metricsRoutes from './routes/metrics.routes';
import healthRoutes from './routes/health.routes';

const app = express();

// Security middleware
app.use(helmet());
app.use(cors());
app.use(compression());

// Logging middleware
app.use(morgan('combined', { stream: { write: message => logger.info(message.trim()) } }));

// Body parsing middleware
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Metrics middleware
app.use(metricsMiddleware);

// Routes
app.use('/api/v1/fireblocks', fireblocksRoutes);
app.use('/metrics', metricsRoutes);
app.use('/health', healthRoutes);

// 404 handler  
app.use((req, res) => {
  res.status(404).json({ message: 'Route not found' });
});

// Global error handler
app.use(errorHandler);

const server = app.listen(config.port, () => {
  logger.info(`Server running on port ${config.port} in ${config.env} mode`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  logger.info('SIGTERM received');
  server.close(() => {
    logger.info('Process terminated');
    process.exit(0);
  });
});

process.on('SIGINT', () => {
  logger.info('SIGINT received');
  server.close(() => {
    logger.info('Process terminated');
    process.exit(0);
  });
});

export default app;
