# TripleA Fireblocks Microservice

A TypeScript-based microservice for handling Fireblocks SDK operations in the TripleA ecosystem.

## Features

- **Node.js v22** with TypeScript
- **Express.js** web framework
- **PostgreSQL** database for logging
- **Prometheus** metrics integration
- **Loki** centralized logging
- **Husky** git hooks with ESLint and Prettier
- **Jest** testing framework
- **Docker** containerization
- **Health checks** and monitoring endpoints

## Project Structure

```
src/
├── config/           # Configuration files
├── controller/       # Request handlers
├── middleware/       # Express middleware
├── routes/          # API route definitions
├── services/        # Business logic
└── utils/           # Utility functions
```

## Getting Started

### Prerequisites

- Node.js v22+
- Docker & Docker Compose
- Git

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   npm install
   ```

3. Copy environment variables:
   ```bash
   cp env.example .env
   ```

4. Update `.env` with your configuration

### Database Setup

#### Option 1: Quick Start (Development Database Only)
```bash
# Start PostgreSQL, Redis, and pgAdmin
npm run db:start

# Check database status
npm run db:status
```

#### Option 2: Full Stack with Monitoring
```bash
# Start all services (database, monitoring, etc.)
docker-compose up -d

# Or just the production build
npm run docker:prod
```

#### Database Management Commands
```bash
# Database operations
npm run db:start      # Start development database services
npm run db:stop       # Stop development database services  
npm run db:reset      # Reset database (destroys all data)
npm run db:backup     # Create database backup
npm run db:logs       # Show database logs
npm run db:psql       # Connect to database with psql
npm run db:status     # Show database status

# Docker operations  
npm run docker:dev    # Start development containers
npm run docker:prod   # Start production containers
npm run docker:down   # Stop all containers
```

#### Database Schema

The service automatically creates these tables:
- `application_logs` - Application logging
- `fireblocks_transactions` - Transaction history  
- `fireblocks_wallets` - Wallet management
- `api_requests` - API audit logs

#### Accessing Services

When running `npm run db:start`:
- **PostgreSQL**: `localhost:5432`
- **Redis**: `localhost:6379`  
- **pgAdmin**: http://localhost:5050
  - Email: `admin@fireblocks.local`
  - Password: `admin`

When running full stack:
- **Application**: http://localhost:3000
- **Metrics**: http://localhost:3000/metrics
- **Grafana**: http://localhost:3001 (admin/admin)
- **Prometheus**: http://localhost:9091

### Development

Start the development server:
```bash
npm run dev
```

The server will be available at:
- API: http://localhost:3000
- Metrics: http://localhost:3000/metrics
- Health: http://localhost:3000/health

### Building

Build the TypeScript code:
```bash
npm run build
```

### Testing

Run tests:
```bash
npm test
```

Run tests in watch mode:
```bash
npm run test:watch
```

Generate coverage report:
```bash
npm run test:coverage
```

### Code Quality

Lint the code:
```bash
npm run lint
```

Format the code:
```bash
npm run format
```

## API Endpoints

### Health Endpoints
- `GET /health` - Overall health status
- `GET /health/ready` - Readiness probe
- `GET /health/live` - Liveness probe

### Metrics
- `GET /metrics` - Prometheus metrics

### Fireblocks API


## Docker Deployment

Run with Docker Compose (includes PostgreSQL, Loki, Grafana, and Prometheus):
```bash
docker-compose up -d
```

This will start:
- Fireblocks Service: http://localhost:3000
- Grafana: http://localhost:3001 (admin/admin)
- Prometheus: http://localhost:9091
- Loki: http://localhost:3100

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| NODE_ENV | Environment mode | development |
| PORT | Server port | 3000 |
| DB_HOST | Database host | localhost |
| DB_PORT | Database port | 5432 |
| DB_NAME | Database name | fireblocks_logs |
| DB_USERNAME | Database username | postgres |
| DB_PASSWORD | Database password | password |
| FIREBLOCKS_API_KEY | Fireblocks API key | - |
| FIREBLOCKS_PRIVATE_KEY | Fireblocks private key | - |
| FIREBLOCKS_BASE_URL | Fireblocks API URL | https://api.fireblocks.io |
| LOKI_HOST | Loki server URL | http://localhost:3100 |
| METRICS_ENABLED | Enable Prometheus metrics | true |

## Monitoring

The service includes comprehensive monitoring:

### Prometheus Metrics
- HTTP request duration histogram
- HTTP request counter
- Custom business metrics

### Loki Logging
- Centralized log aggregation
- Structured JSON logging
- Environment-based log levels

### Health Checks
- Kubernetes-compatible health endpoints
- Service dependency checks
- Application status monitoring

## Development Guidelines

### Code Style
- ESLint for code quality
- Prettier for formatting
- Husky pre-commit hooks

### Git Workflow
- Pre-commit hooks run linting and formatting
- Conventional commit messages recommended

### Testing
- Unit tests with Jest
- Integration tests with Supertest
- Coverage reporting

## License

MIT License - see LICENSE file for details
