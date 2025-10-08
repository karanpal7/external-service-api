#!/bin/bash

# Database management script for Fireblocks service

set -e

DB_CONTAINER="fireblocks-postgres-dev"
DB_NAME="fireblocks_logs"
DB_USER="postgres"
BACKUP_DIR="./database/backups"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

function print_usage() {
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  start-dev     Start development database services"
    echo "  stop-dev      Stop development database services"
    echo "  reset-dev     Reset development database (WARNING: destroys data)"
    echo "  backup        Create database backup"
    echo "  restore       Restore database from backup"
    echo "  logs          Show database logs"
    echo "  psql          Connect to database with psql"
    echo "  status        Show database status"
    echo ""
}

function start_dev() {
    echo -e "${GREEN}Starting development database services...${NC}"
    docker-compose -f docker-compose.dev.yml up -d
    
    echo -e "${YELLOW}Waiting for database to be ready...${NC}"
    sleep 5
    docker-compose -f docker-compose.dev.yml exec postgres pg_isready -U postgres
    
    echo -e "${GREEN}Database services started successfully!${NC}"
    echo ""
    echo "Services available at:"
    echo "  PostgreSQL: localhost:5432"
    echo "  Redis: localhost:6379"
    echo "  pgAdmin: http://localhost:5050 (admin@fireblocks.local / admin)"
}

function stop_dev() {
    echo -e "${YELLOW}Stopping development database services...${NC}"
    docker-compose -f docker-compose.dev.yml down
    echo -e "${GREEN}Database services stopped.${NC}"
}

function reset_dev() {
    read -p "Are you sure you want to reset the development database? This will destroy all data. (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${RED}Resetting development database...${NC}"
        docker-compose -f docker-compose.dev.yml down -v
        docker-compose -f docker-compose.dev.yml up -d
        echo -e "${GREEN}Database reset complete.${NC}"
    else
        echo "Reset cancelled."
    fi
}

function backup_db() {
    echo -e "${GREEN}Creating database backup...${NC}"
    mkdir -p $BACKUP_DIR
    
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    BACKUP_FILE="$BACKUP_DIR/fireblocks_backup_$TIMESTAMP.sql"
    
    docker exec $DB_CONTAINER pg_dump -U $DB_USER -d $DB_NAME > $BACKUP_FILE
    
    echo -e "${GREEN}Backup created: $BACKUP_FILE${NC}"
}

function restore_db() {
    if [ -z "$1" ]; then
        echo -e "${RED}Please specify backup file to restore${NC}"
        echo "Available backups:"
        ls -la $BACKUP_DIR/*.sql 2>/dev/null || echo "No backups found"
        return 1
    fi
    
    if [ ! -f "$1" ]; then
        echo -e "${RED}Backup file not found: $1${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}Restoring database from $1...${NC}"
    docker exec -i $DB_CONTAINER psql -U $DB_USER -d $DB_NAME < $1
    echo -e "${GREEN}Database restored successfully.${NC}"
}

function show_logs() {
    docker-compose -f docker-compose.dev.yml logs -f postgres
}

function connect_psql() {
    echo -e "${GREEN}Connecting to PostgreSQL...${NC}"
    docker exec -it $DB_CONTAINER psql -U $DB_USER -d $DB_NAME
}

function show_status() {
    echo -e "${GREEN}Database Service Status:${NC}"
    docker-compose -f docker-compose.dev.yml ps
    
    echo ""
    echo -e "${GREEN}Database Health:${NC}"
    docker exec $DB_CONTAINER pg_isready -U $DB_USER 2>/dev/null && echo "PostgreSQL: ✅ Ready" || echo "PostgreSQL: ❌ Not Ready"
    
    echo ""
    echo -e "${GREEN}Database Size:${NC}"
    docker exec $DB_CONTAINER psql -U $DB_USER -d $DB_NAME -c "
        SELECT 
            schemaname,
            tablename,
            attname,
            n_distinct,
            correlation
        FROM pg_stats
        WHERE schemaname = 'public'
        ORDER BY schemaname, tablename;
    " 2>/dev/null || echo "Could not retrieve database information"
}

# Main script logic
case "$1" in
    "start-dev")
        start_dev
        ;;
    "stop-dev") 
        stop_dev
        ;;
    "reset-dev")
        reset_dev
        ;;
    "backup")
        backup_db
        ;;
    "restore")
        restore_db "$2"
        ;;
    "logs")
        show_logs
        ;;
    "psql")
        connect_psql
        ;;
    "status")
        show_status
        ;;
    *)
        print_usage
        exit 1
        ;;
esac
