#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    -- Create extension for UUID generation
    CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
    CREATE EXTENSION IF NOT EXISTS "pgcrypto";

    -- Create logs table for application logging
    CREATE TABLE IF NOT EXISTS application_logs (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        level VARCHAR(20) NOT NULL,
        message TEXT NOT NULL,
        meta JSONB,
        timestamp TIMESTAMPTZ DEFAULT NOW(),
        service VARCHAR(100) DEFAULT 'fireblocks-service',
        trace_id UUID,
        user_id VARCHAR(100),
        request_id UUID,
        created_at TIMESTAMPTZ DEFAULT NOW()
    );

    -- Create index for better query performance
    CREATE INDEX IF NOT EXISTS idx_application_logs_timestamp ON application_logs(timestamp DESC);
    CREATE INDEX IF NOT EXISTS idx_application_logs_level ON application_logs(level);
    CREATE INDEX IF NOT EXISTS idx_application_logs_trace_id ON application_logs(trace_id);
    CREATE INDEX IF NOT EXISTS idx_application_logs_user_id ON application_logs(user_id);

    -- Create fireblocks_transactions table for transaction logging
    CREATE TABLE IF NOT EXISTS fireblocks_transactions (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        fireblocks_tx_id VARCHAR(100) UNIQUE NOT NULL,
        asset_id VARCHAR(20) NOT NULL,
        source_type VARCHAR(50),
        source_id VARCHAR(100),
        destination_type VARCHAR(50), 
        destination_id VARCHAR(100),
        amount DECIMAL(36,18) NOT NULL,
        fee DECIMAL(36,18),
        status VARCHAR(50) NOT NULL,
        sub_status VARCHAR(100),
        tx_hash VARCHAR(100),
        network_fee DECIMAL(36,18),
        created_at TIMESTAMPTZ DEFAULT NOW(),
        updated_at TIMESTAMPTZ DEFAULT NOW(),
        completed_at TIMESTAMPTZ,
        failed_at TIMESTAMPTZ,
        note TEXT,
        external_tx_id VARCHAR(100),
        user_id VARCHAR(100),
        raw_response JSONB
    );

    -- Create indexes for fireblocks_transactions
    CREATE INDEX IF NOT EXISTS idx_fireblocks_tx_id ON fireblocks_transactions(fireblocks_tx_id);
    CREATE INDEX IF NOT EXISTS idx_fireblocks_status ON fireblocks_transactions(status);
    CREATE INDEX IF NOT EXISTS idx_fireblocks_asset_id ON fireblocks_transactions(asset_id);
    CREATE INDEX IF NOT EXISTS idx_fireblocks_user_id ON fireblocks_transactions(user_id);
    CREATE INDEX IF NOT EXISTS idx_fireblocks_created_at ON fireblocks_transactions(created_at DESC);

    -- Create fireblocks_wallets table for wallet tracking
    CREATE TABLE IF NOT EXISTS fireblocks_wallets (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        fireblocks_wallet_id VARCHAR(100) UNIQUE NOT NULL,
        name VARCHAR(200) NOT NULL,
        wallet_type VARCHAR(50) NOT NULL,
        status VARCHAR(50) NOT NULL DEFAULT 'ACTIVE',
        created_at TIMESTAMPTZ DEFAULT NOW(),
        updated_at TIMESTAMPTZ DEFAULT NOW(),
        user_id VARCHAR(100),
        tags JSONB,
        raw_response JSONB
    );

    -- Create indexes for fireblocks_wallets
    CREATE INDEX IF NOT EXISTS idx_fireblocks_wallets_id ON fireblocks_wallets(fireblocks_wallet_id);
    CREATE INDEX IF NOT EXISTS idx_fireblocks_wallets_user_id ON fireblocks_wallets(user_id);
    CREATE INDEX IF NOT EXISTS idx_fireblocks_wallets_type ON fireblocks_wallets(wallet_type);

    -- Create api_requests table for API audit logging
    CREATE TABLE IF NOT EXISTS api_requests (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        method VARCHAR(10) NOT NULL,
        path VARCHAR(500) NOT NULL,
        status_code INTEGER NOT NULL,
        response_time_ms INTEGER,
        user_agent TEXT,
        ip_address INET,
        user_id VARCHAR(100),
        request_id UUID,
        request_body JSONB,
        response_body JSONB,
        headers JSONB,
        created_at TIMESTAMPTZ DEFAULT NOW()
    );

    -- Create indexes for api_requests
    CREATE INDEX IF NOT EXISTS idx_api_requests_path ON api_requests(path);
    CREATE INDEX IF NOT EXISTS idx_api_requests_status ON api_requests(status_code);
    CREATE INDEX IF NOT EXISTS idx_api_requests_user_id ON api_requests(user_id);
    CREATE INDEX IF NOT EXISTS idx_api_requests_created_at ON api_requests(created_at DESC);

    -- Create function to update updated_at timestamp
    CREATE OR REPLACE FUNCTION update_updated_at_column()
    RETURNS TRIGGER AS \$\$
    BEGIN
        NEW.updated_at = NOW();
        RETURN NEW;
    END;
    \$\$ language 'plpgsql';

    -- Create triggers to auto-update updated_at columns
    CREATE TRIGGER update_fireblocks_transactions_updated_at 
        BEFORE UPDATE ON fireblocks_transactions 
        FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

    CREATE TRIGGER update_fireblocks_wallets_updated_at 
        BEFORE UPDATE ON fireblocks_wallets 
        FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

    -- Grant permissions
    GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO $POSTGRES_USER;
    GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO $POSTGRES_USER;

    -- Insert some sample data for development
    INSERT INTO fireblocks_wallets (fireblocks_wallet_id, name, wallet_type, user_id) 
    VALUES 
        ('vault_001', 'Main Vault Wallet', 'VAULT', 'dev_user_1'),
        ('vault_002', 'Trading Wallet', 'VAULT', 'dev_user_1')
    ON CONFLICT (fireblocks_wallet_id) DO NOTHING;

EOSQL

echo "Database initialization completed successfully!"
