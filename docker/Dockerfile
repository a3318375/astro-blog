# =============================================================================
# astro-koharu Dockerfile (SSR Mode)
# Multi-stage build for SSR with Node.js server
# =============================================================================

# =============================================================================
# Stage 1: Builder
# =============================================================================
FROM node:22-alpine AS builder
WORKDIR /app

# Install pnpm
RUN corepack enable && corepack prepare pnpm@9.15.1 --activate

# Copy deps first
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile --prod=false

# Copy source
COPY . .

# Build-time args (still used if you embed config in JS during build)
ARG REMARK_URL
ARG REMARK_SITE_ID
ARG UMAMI_ID
ARG UMAMI_ENDPOINT

ENV REMARK_URL=${REMARK_URL}
ENV REMARK_SITE_ID=${REMARK_SITE_ID}
ENV UMAMI_ID=${UMAMI_ID}
ENV UMAMI_ENDPOINT=${UMAMI_ENDPOINT}

# Build SSR app → outputs dist/client and dist/server
RUN pnpm build

# =============================================================================
# Stage 2: Production (Node.js runtime)
# =============================================================================
FROM node:22-alpine AS production

WORKDIR /app

# Install only production dependencies
COPY package.json pnpm-lock.yaml ./
RUN corepack enable && \
    corepack prepare pnpm@9.15.1 --activate && \
    pnpm install --frozen-lockfile --prod=true

# Copy built output
COPY --from=builder /app/dist ./dist

# Optional: copy public assets if not in dist/client
# COPY --from=builder /app/public ./public

# Expose port (Astro SSR defaults to 4321, but you can set env)
EXPOSE 4321

# Health check (adjust port if needed)
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:4321/ || exit 1

# Start the SSR server
CMD ["node", "dist/server/entry.mjs"]