#!/bin/bash

# Clean build artifacts for Docker Proxied App
set -e

echo "=== Cleaning Build Artifacts ==="

PROJECT_ROOT=$(cd "$(dirname "$0")/../.." && pwd)
echo "Project root: $PROJECT_ROOT"

# Clean frontend build
if [ -d "$PROJECT_ROOT/packages/frontend/dist" ]; then
    echo "Removing frontend dist..."
    rm -rf "$PROJECT_ROOT/packages/frontend/dist"
fi

# Clean backend build
if [ -d "$PROJECT_ROOT/packages/backend/dist" ]; then
    echo "Removing backend dist..."
    rm -rf "$PROJECT_ROOT/packages/backend/dist"
fi

# Clean node_modules (optional - uncomment if needed)
# if [ -d "$PROJECT_ROOT/packages/frontend/node_modules" ]; then
#     echo "Removing frontend node_modules..."
#     rm -rf "$PROJECT_ROOT/packages/frontend/node_modules"
# fi

# if [ -d "$PROJECT_ROOT/packages/backend/node_modules" ]; then
#     echo "Removing backend node_modules..."
#     rm -rf "$PROJECT_ROOT/packages/backend/node_modules"
# fi

# Clean Docker images (optional - uncomment if needed)
# echo "Removing Docker images..."
# docker rmi docker-proxied-app:latest 2>/dev/null || echo "No Docker image to remove"

echo ""
echo "Clean completed successfully!"
echo ""
echo "To rebuild everything, run:"
echo "  ./packages/docker/build.sh"