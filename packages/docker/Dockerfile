# Production Docker image using pre-built artifacts
FROM nginx:alpine

# Install Node.js for backend API and supervisor for process management
RUN apk add --no-cache nodejs npm supervisor curl

# Create application directories
RUN mkdir -p /app/backend /var/log/supervisor

# Copy pre-built frontend distribution to nginx html directory
COPY packages/frontend/dist /usr/share/nginx/html

# Copy pre-built backend distribution and production dependencies
COPY packages/backend/dist /app/backend/
COPY packages/backend/node_modules /app/backend/node_modules
COPY packages/backend/package.json /app/backend/

# Copy nginx configuration
COPY packages/docker/nginx.conf /etc/nginx/nginx.conf

# Copy startup script and supervisor configuration
COPY packages/docker/startup.sh /usr/local/bin/startup.sh
COPY packages/docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Make startup script executable
RUN chmod +x /usr/local/bin/startup.sh

# Expose port 8095 as specified in requirements
EXPOSE 8095

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8095/api/health || exit 1

# Use supervisor to run both nginx and backend
CMD ["/usr/local/bin/startup.sh"]