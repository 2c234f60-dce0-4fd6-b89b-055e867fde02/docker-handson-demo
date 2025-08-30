# Multi-stage build for React application
# Stage 1: Build stage with lightweight Node.js Alpine
FROM node:18-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package files
COPY package.json package-lock.json ./

# Install all dependencies (including devDependencies for build)
RUN npm ci --no-cache

# Copy source code and config files
COPY src/ ./src/
COPY public/ ./public/
COPY index.html ./
COPY vite.config.js ./
COPY tailwind.config.js ./
COPY postcss.config.js ./

# Build the application
RUN npm run build

# Stage 2: Runtime stage with lightweight Nginx Alpine
FROM nginx:1.25-alpine

# Remove default nginx configuration
RUN rm /etc/nginx/conf.d/default.conf

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/conf.d/

# Copy built application from builder stage
COPY --from=builder /app/dist /usr/share/nginx/html

# Copy environment injection script
COPY inject-env.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/inject-env.sh

# Expose port 8080 (non-privileged port)
EXPOSE 8080

# Add health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# Start with environment injection
CMD ["/usr/local/bin/inject-env.sh"]