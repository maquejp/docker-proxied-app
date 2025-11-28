#!/bin/sh

# Docker Proxied App Startup Script
# This script starts both the Express backend and Nginx frontend server

set -e

echo "=== Docker Proxied App Startup ==="
echo "Starting application containers..."

# Create log directories
mkdir -p /var/log/supervisor /var/log/nginx /var/log/app

# Set permissions
chown -R nginx:nginx /var/log/nginx
chmod 755 /var/log/supervisor /var/log/app

# Environment variables with defaults
export NODE_ENV="${NODE_ENV:-production}"
export PORT="${PORT:-3000}"
export ORACLE_SERVER="${ORACLE_SERVER:-localhost}"
export ORACLE_PORT="${ORACLE_PORT:-1521}"
export JWT_SECRET="${JWT_SECRET:-change-this-in-production}"

echo "Environment: $NODE_ENV"
echo "Backend Port: $PORT"
echo "Oracle Server: $ORACLE_SERVER:$ORACLE_PORT"

# Validate required environment variables
if [ -z "$ORACLE_USERNAME" ] || [ -z "$ORACLE_PASSWORD" ] || [ -z "$ORACLE_DATABASE" ]; then
    echo "WARNING: Oracle database credentials not fully configured"
    echo "Set ORACLE_USERNAME, ORACLE_PASSWORD, and ORACLE_DATABASE environment variables"
fi

# Start backend in background
echo "Starting Express backend..."
cd /app/backend
node index.js &
BACKEND_PID=$!

# Wait a moment for backend to start
sleep 3

# Check if backend is running
if ! kill -0 $BACKEND_PID 2>/dev/null; then
    echo "ERROR: Backend failed to start"
    exit 1
fi

echo "Backend started with PID: $BACKEND_PID"

# Test backend health
echo "Testing backend health..."
timeout 10 sh -c 'until wget -q -O - http://localhost:3000/api/health >/dev/null 2>&1; do sleep 1; done' || {
    echo "WARNING: Backend health check failed, continuing anyway..."
}

# Start nginx in foreground
echo "Starting Nginx..."
exec nginx -g 'daemon off;'