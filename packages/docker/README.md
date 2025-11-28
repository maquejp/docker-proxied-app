# Docker Configuration

This directory contains Docker-related configuration files for containerizing the application.

## Files

- `Dockerfile` - Production container using pre-built artifacts
- `nginx.conf` - Nginx reverse proxy configuration
- `docker-compose.yml` - Development environment setup (optional)
- `startup.sh` - Container startup script
- `build.sh` - Build script that compiles frontend/backend then creates Docker image
- `deploy.sh` - Deployment script
- `.env.example` - Environment variables template

## Docker Architecture

The application uses a **pre-built artifacts approach**:

1. **Frontend & Backend Build** - Built locally before Docker image creation
2. **Docker Image** - Single-stage container copying pre-built distributions
3. **Runtime** - Nginx serving static files and proxying API calls to Node.js backend

## Build Process

1. Frontend is built using `yarn build --configuration=production`
2. Backend is compiled using `npm run build` and production dependencies installed
3. Docker image copies only the built artifacts (`dist` folders and `node_modules`)
4. Final image runs nginx + Node.js backend via supervisor

## Usage

### Building the Application

```bash
# Clean previous builds (optional)
./packages/docker/clean.sh

# Build everything and create Docker image
./packages/docker/build.sh

# Build with specific tag
./packages/docker/build.sh v1.0.0
```

### Running the Container

```bash
# Using docker-compose (recommended)
cd packages/docker
docker-compose up -d

# Using docker run directly
docker run -p 8095:8095 --env-file packages/docker/.env docker-proxied-app:latest

# Running in background
docker run -d -p 8095:8095 --env-file packages/docker/.env --name docker-proxied-app docker-proxied-app:latest
```

### Environment Configuration

1. Copy the environment template:

   ```bash
   cp packages/docker/.env.example packages/docker/.env
   ```

2. Edit `.env` with your configuration:

   ```bash
   # Database configuration
   ORACLE_SERVER=localhost
   ORACLE_PORT=1521
   ORACLE_USERNAME=your_username
   ORACLE_PASSWORD=your_password
   ORACLE_DATABASE=your_database

   # Application configuration
   JWT_SECRET=your_jwt_secret
   NODE_ENV=production
   ```

### Development Commands

```bash
# View container logs
docker logs docker-proxied-app

# Access container shell
docker exec -it docker-proxied-app /bin/sh

# Stop and remove container
docker stop docker-proxied-app
docker rm docker-proxied-app

# View running containers
docker ps

# Clean up Docker resources
./packages/docker/clean.sh
```

### Accessing the Application

Once running, the application will be available at:

- **Main Application**: <http://localhost:8095>
- **API Endpoints**: <http://localhost:8095/api/*>
- **Health Check**: <http://localhost:8095/api/health>

## Nginx Configuration

- Static files (frontend) served from `/`
- API requests proxied to backend at `/api`
- HTTPS/SSL configuration
- Security headers and optimizations
