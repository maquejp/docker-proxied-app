# Docker Configuration

This directory contains Docker-related configuration files for containerizing the application.

## Files

- `Dockerfile` - Multi-stage Docker build configuration
- `nginx.conf` - Nginx reverse proxy configuration
- `docker-compose.yml` - Development environment setup (optional)
- `startup.sh` - Container startup script
- `.env.example` - Environment variables template

## Docker Architecture

The application will use a multi-stage build:

1. **Build Stage** - Compile TypeScript backend and Angular frontend
2. **Production Stage** - Nginx serving static files and proxying API calls

## Nginx Configuration

- Static files (frontend) served from `/`
- API requests proxied to backend at `/api`
- HTTPS/SSL configuration
- Security headers and optimizations