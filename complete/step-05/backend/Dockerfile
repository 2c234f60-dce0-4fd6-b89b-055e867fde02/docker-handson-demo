# Multi-stage build for Java Spring Boot application
# Stage 1: Build stage with Amazon Corretto JDK 17 Alpine
FROM amazoncorretto:17-alpine AS builder

# Set working directory for build
WORKDIR /workspace

# Copy Gradle configuration files
COPY gradle ./gradle
COPY gradlew .
COPY gradlew.bat .
COPY build.gradle .
COPY settings.gradle .

# Make gradlew executable
RUN chmod +x ./gradlew

# Download dependencies (for better Docker layer caching)
RUN ./gradlew dependencies --no-daemon

# Copy source code
COPY src ./src

# Build the application
RUN ./gradlew build --no-daemon -x test

# Stage 2: Runtime stage with Amazon Corretto JRE 17 Alpine
FROM amazoncorretto:17-alpine

# Install required packages for Alpine
RUN apk add --no-cache \
        ca-certificates \
        sqlite \
        curl \
        tzdata

# Create application user for security (Alpine style)
RUN addgroup -S appuser && adduser -S appuser -G appuser

# Set working directory
WORKDIR /app

# Copy the built JAR from builder stage
COPY --from=builder /workspace/build/libs/*.jar app.jar

# Create SQLite database file with proper permissions
RUN touch sns_api.db && \
    chown appuser:appuser sns_api.db && \
    chmod 664 sns_api.db

# Create data directory for SQLite database
RUN mkdir -p /app/data && \
    chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Expose port 8080
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8080/actuator/health || exit 1

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
