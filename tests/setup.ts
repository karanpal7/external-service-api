// Global test setup
import { logger } from '../src/config/logger';

// Mock logger for tests
jest.mock('../src/config/logger', () => ({
  logger: {
    info: jest.fn(),
    error: jest.fn(),
    warn: jest.fn(),
    debug: jest.fn(),
  },
}));

// Set test environment variables
process.env.NODE_ENV = 'test';
process.env.PORT = '3001';
process.env.DB_HOST = 'localhost';
process.env.DB_PORT = '5432';
process.env.DB_NAME = 'fireblocks_logs_test';
process.env.DB_USERNAME = 'postgres';
process.env.DB_PASSWORD = 'password';
