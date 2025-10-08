import dotenv from 'dotenv';
import path from 'path';

// Load environment variables from .env file
dotenv.config({ path: path.join(process.cwd(), '.env') });

export const config = {
  env: process.env.NODE_ENV || 'development',
  port: parseInt(process.env.PORT || '3000', 10),

  // Database configuration for logging
  database: {
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT || '5432', 10),
    name: process.env.DB_NAME || 'fireblocks_logs',
    username: process.env.DB_USERNAME || 'postgres',
    password: process.env.DB_PASSWORD || 'password',
    dialect: 'postgres' as const,
  },

  // Fireblocks configuration
  fireblocks: {
    apiKey: process.env.FIREBLOCKS_API_KEY || '',
    privateKey: process.env.FIREBLOCKS_PRIVATE_KEY || '',
    baseUrl: process.env.FIREBLOCKS_BASE_URL || 'https://api.fireblocks.io',
  },

  // Loki configuration for centralized logging
  loki: {
    host: process.env.LOKI_HOST || 'http://localhost:3100',
    labels: {
      job: 'fireblocks-service',
      environment: process.env.NODE_ENV || 'development',
    },
  },

  // Monitoring
  metrics: {
    enabled: process.env.METRICS_ENABLED === 'true' || true,
    port: parseInt(process.env.METRICS_PORT || '9090', 10),
  },
};
