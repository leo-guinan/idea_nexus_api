# Multi-stage build for Mastra Skippy Agent with SQLite
FROM node:20-slim AS base

# Install dependencies only when needed
FROM base AS deps
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    make \
    g++ \
    curl \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /app

# Copy package files
COPY package*.json ./
RUN npm ci --legacy-peer-deps

# Build the application
FROM base AS builder
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    make \
    g++ \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /app

# Copy all source files
COPY . .

# Install dependencies fresh for build
RUN npm ci --legacy-peer-deps

# Initialize SQLite database before build
COPY database ./database
RUN npm run db:init

# Build Mastra application
RUN npm run build

# Production image
FROM base AS runner
WORKDIR /app

ENV NODE_ENV=production
ENV PORT=4112

# Install curl for healthcheck and other runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 mastra

# Copy built application and dependencies
COPY --from=builder /app/.mastra/output ./.mastra/output
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/database ./database
COPY --from=builder /app/skippy.db ./skippy.db

# Create data directory for SQLite with proper permissions
RUN mkdir -p /app/data && \
    chown -R mastra:nodejs /app

# Switch to non-root user
USER mastra

# Expose port
EXPOSE 4112

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:4112/api/health || exit 1

# Start the production server
CMD ["node", "--import=./.mastra/output/instrumentation.mjs", ".mastra/output/index.mjs"]
