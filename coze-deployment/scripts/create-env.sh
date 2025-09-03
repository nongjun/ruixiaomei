#!/bin/sh
set -e

# Create environment variables file for OAuth server
cat > /app/quickstart-oauth-server/.env << EOF
# Coze API Configuration
COZE_CN_BASE_URL=https://api.coze.cn
COZE_BOT_ID=7467988865836777510
COZE_API_TOKEN=***REMOVED-COZE-PAT***

# OAuth Server Ports
WEB_OAUTH_PORT=3000
PKCE_OAUTH_PORT=3001
JWT_OAUTH_PORT=3002
DEVICE_OAUTH_PORT=3003
EOF

echo "Environment file created successfully"