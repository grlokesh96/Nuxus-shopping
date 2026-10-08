# ──────────────────────────────────────────────────────────
# Stage 1 — Build
# ──────────────────────────────────────────────────────────
FROM node:25-alpine AS builder

WORKDIR /app

# Copy dependency manifests first for better layer caching
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy application source
COPY . .

# Build production SPA
RUN npm run build


# ──────────────────────────────────────────────────────────
# Stage 2 — Production
# ──────────────────────────────────────────────────────────
FROM gcr.io/distroless/static-debian12:nonroot

WORKDIR /usr/share/nginx/html

# Copy compiled SPA
COPY --from=builder /app/dist .

# Copy static nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Nginx listens on an unprivileged port
EXPOSE 8080

# Run as non-root
USER nonroot:nonroot

# Distroless has no shell
ENTRYPOINT ["/usr/sbin/nginx"]

CMD ["-g", "daemon off;"]
