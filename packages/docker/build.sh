#!/bin/bash

# Docker Proxied App Build Script - Pre-build frontend and backend then create Docker image
set -e

echo "=== Building Docker Proxied App with Pre-built Artifacts ==="

# Configuration
IMAGE_NAME="docker-proxied-app"
IMAGE_TAG="${1:-latest}"
PROJECT_ROOT=$(cd "$(dirname "$0")/../.." && pwd)

echo "Project root: $PROJECT_ROOT"

# Build frontend
echo ""
echo "=== Building Frontend (Angular with eUI) ==="
cd "$PROJECT_ROOT/packages/frontend"
if [ ! -d "node_modules" ]; then
    echo "Installing frontend dependencies..."
    yarn install --frozen-lockfile
fi
echo "Building frontend for production..."
yarn build --configuration=production

# Build backend
echo ""
echo "=== Building Backend (Express with TypeScript) ==="
cd "$PROJECT_ROOT/packages/backend"
if [ ! -d "node_modules" ]; then
    echo "Installing backend dependencies..."
    npm ci
fi
echo "Building backend..."
npm run build
echo "Installing production dependencies..."
npm ci --only=production

# Build Docker image
echo ""
echo "=== Building Docker Image ==="
cd "$PROJECT_ROOT"
echo "Building image: $IMAGE_NAME:$IMAGE_TAG"

docker build \
  -f "packages/docker/Dockerfile" \
  -t "$IMAGE_NAME:$IMAGE_TAG" \
  .

echo ""
echo "Build completed successfully!"
echo "Image: $IMAGE_NAME:$IMAGE_TAG"

# Show image size
echo ""
echo "=== Image Information ==="
docker images "$IMAGE_NAME:$IMAGE_TAG"

echo ""
echo "=== Next Steps ==="
echo "To run the container:"
echo "  docker run -p 8095:8095 --env-file .env $IMAGE_NAME:$IMAGE_TAG"
echo ""
echo "To run with docker-compose:"
echo "  docker-compose up -d"
echo ""
echo "To push to registry (if needed):"
echo "  docker tag $IMAGE_NAME:$IMAGE_TAG your-registry/$IMAGE_NAME:$IMAGE_TAG"
echo "  docker push your-registry/$IMAGE_NAME:$IMAGE_TAG"