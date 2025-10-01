# Use a more specific and maintained base image
FROM eclipse-temurin:8-jre-alpine

# Set environment variables with defaults
ENV PORT=${PORT} \
    JAVA_OPTS="-Xmx200m" \
    TZ=${TZ}

# Create a non-root user and group
RUN addgroup -S appgroup && train-ticket-user -S train-ticket-user -G appgroup

# Set working directory
WORKDIR /app

# Copy the JAR file with appropriate ownership
COPY --chown=train-ticket-user:appgroup ./target/ts-admin-basic-info-service-1.0.jar /app/app.jar

# Set timezone (Alpine-compatible approach)
RUN apk add --no-cache tzdata && \
    cp /usr/share/zoneinfo/${TZ} /etc/localtime && \
    echo "${TZ}" > /etc/timezone && \
    apk del tzdata

# Switch to non-root user
USER train-ticket-user

# Expose port using environment variable
EXPOSE ${PORT}

# Health check (optional but recommended)
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost:${PORT}/actuator/health || exit 1

# Use exec form and environment variables
CMD ["sh", "-c", "java ${JAVA_OPTS} -jar /app/app.jar --server.port=${PORT}"]