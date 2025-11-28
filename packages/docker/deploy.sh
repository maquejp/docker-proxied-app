#!/bin/bash

# Docker Proxied App Deployment Script
set -e

echo "=== Deploying Docker Proxied App ==="

# Configuration
IMAGE_NAME="docker-proxied-app"
IMAGE_TAG="${1:-latest}"
CONTAINER_NAME="docker-proxied-app-container"
PORT="${2:-8095}"

echo "Deploying container: $CONTAINER_NAME"
echo "Image: $IMAGE_NAME:$IMAGE_TAG"
echo "Port: $PORT"

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo "WARNING: .env file not found. Copy from .env.example and configure:"
    echo "  cp .env.example .env"
    echo "  # Edit .env with your configuration"
    exit 1
fi

# Stop existing container if running
if docker ps -q -f name="$CONTAINER_NAME" | grep -q .; then
    echo "Stopping existing container..."
    docker stop "$CONTAINER_NAME"
fi

# Remove existing container if exists
if docker ps -aq -f name="$CONTAINER_NAME" | grep -q .; then
    echo "Removing existing container..."
    docker rm "$CONTAINER_NAME"
fi

# Run the new container
echo "Starting new container..."
docker run -d \
  --name "$CONTAINER_NAME" \
  -p "$PORT:8095" \
  --env-file .env \
  --restart unless-stopped \
  --health-cmd="wget --no-verbose --tries=1 --spider http://localhost:8095/api/health || exit 1" \
  --health-interval=30s \
  --health-timeout=3s \
  --health-retries=3 \
  --health-start-period=40s \
  "$IMAGE_NAME:$IMAGE_TAG"

echo "Container started successfully!"
echo ""

# Show container status
echo "=== Container Status ==="
docker ps -f name="$CONTAINER_NAME"

echo ""
echo "=== Application URLs ==="
echo "Frontend: https://localhost:$PORT/"
echo "API: https://localhost:$PORT/api"
echo "Health Check: https://localhost:$PORT/api/health"

echo ""
echo "=== Useful Commands ==="
echo "View logs: docker logs -f $CONTAINER_NAME"
echo "Execute shell: docker exec -it $CONTAINER_NAME sh"
echo "Stop container: docker stop $CONTAINER_NAME"
echo "Container stats: docker stats $CONTAINER_NAME"