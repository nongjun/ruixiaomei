# Multi-stage build for Coze.js examples

# Stage 1: Build base with Node.js
FROM node:18-alpine AS base
RUN apk add --no-cache git python3 make g++
WORKDIR /app

# Install Rush globally
RUN npm install -g @microsoft/rush@5.140.0

# Stage 2: Clone and prepare repository
FROM base AS prepare
WORKDIR /app
COPY scripts/clone-and-prepare.sh /scripts/
RUN chmod +x /scripts/clone-and-prepare.sh
RUN /scripts/clone-and-prepare.sh

# Stage 3: Build all applications
FROM prepare AS builder
WORKDIR /app/coze-js

# Copy environment configuration scripts
COPY scripts/update-base-urls.sh /scripts/
COPY scripts/comprehensive-url-update.sh /scripts/
RUN chmod +x /scripts/*.sh

# Update base URLs from COZE_COM to COZE_CN
RUN /scripts/comprehensive-url-update.sh

# Build all packages
RUN rush update
RUN rush build

# Build individual examples
WORKDIR /app/coze-js/examples/coze-js-web
RUN npm run build

WORKDIR /app/coze-js/examples/realtime-console
RUN npm run build

WORKDIR /app/coze-js/examples/realtime-quickstart-react
RUN npm run build

WORKDIR /app/coze-js/examples/realtime-quickstart-vue
RUN npm run build

WORKDIR /app/coze-js/examples/realtime-call-up
RUN npm run build

WORKDIR /app/coze-js/examples/realtime-websocket
RUN npm run build

WORKDIR /app/coze-js/examples/simult-extension
RUN npm run build

# Stage 4: Production image with Nginx and Node.js
FROM nginx:alpine

# Install Node.js for OAuth server
RUN apk add --no-cache nodejs npm supervisor

# Copy Nginx configuration
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/default.conf /etc/nginx/conf.d/default.conf
COPY nginx/health.html /usr/share/nginx/html/health.html

# Copy SSL certificates (will be mounted in production)
RUN mkdir -p /etc/nginx/ssl

# Copy built applications
COPY --from=builder /app/coze-js/examples/coze-js-web/build /usr/share/nginx/html/coze-js-web
COPY --from=builder /app/coze-js/examples/realtime-console/build /usr/share/nginx/html/realtime-console
COPY --from=builder /app/coze-js/examples/realtime-quickstart-react/build /usr/share/nginx/html/realtime-quickstart-react
COPY --from=builder /app/coze-js/examples/realtime-quickstart-vue/dist /usr/share/nginx/html/realtime-quickstart-vue
COPY --from=builder /app/coze-js/examples/realtime-call-up/build /usr/share/nginx/html/realtime-call-up
COPY --from=builder /app/coze-js/examples/realtime-websocket/build /usr/share/nginx/html/realtime-websocket
COPY --from=builder /app/coze-js/examples/simult-extension/build /usr/share/nginx/html/simult-extension

# Copy OAuth server
COPY --from=builder /app/coze-js/examples/quickstart-oauth-server /app/quickstart-oauth-server

# Copy supervisor configuration
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Create environment file
COPY scripts/create-env.sh /scripts/
RUN chmod +x /scripts/create-env.sh

# Expose ports
EXPOSE 80 443 3000 3001 3002 3003

# Start supervisor
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]