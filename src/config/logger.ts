import winston from 'winston';
import LokiTransport from 'winston-loki';
import { config } from './config';

const logFormat = winston.format.combine(
  winston.format.timestamp(),
  winston.format.errors({ stack: true }),
  winston.format.json(),
  winston.format.prettyPrint()
);

const transports: winston.transport[] = [
  new winston.transports.Console({
    format: winston.format.combine(winston.format.colorize(), winston.format.simple()),
  }),
];

// Add file transport for local development
if (config.env === 'development') {
  transports.push(
    new winston.transports.File({
      filename: 'logs/error.log',
      level: 'error',
      format: logFormat,
    }),
    new winston.transports.File({
      filename: 'logs/combined.log',
      format: logFormat,
    })
  );
}

// Add Loki transport for centralized logging in production
if (config.env === 'production' && config.loki.host) {
  transports.push(
    new LokiTransport({
      host: config.loki.host,
      labels: config.loki.labels,
      json: true,
      format: logFormat,
      onConnectionError: (err) => {
        // eslint-disable-next-line no-console
        console.error('Loki connection error:', err);
      },
    })
  );
}

export const logger = winston.createLogger({
  level: config.env === 'production' ? 'info' : 'debug',
  format: logFormat,
  transports,
  exitOnError: false,
});

// Create logs directory if it doesn't exist
if (config.env === 'development') {
  const fs = require('fs');
  const logsDir = 'logs';
  if (!fs.existsSync(logsDir)) {
    fs.mkdirSync(logsDir);
  }
}
