#!/bin/bash

echo "Building and deploying Coze.js examples..."

# Ensure we're in the right directory
cd /workspace/coze-deployment

# Build the Docker image
echo "Building Docker image..."
docker-compose build

# Start the services
echo "Starting services..."
docker-compose up -d

echo "Deployment complete!"
echo ""
echo "Applications are available at:"
echo "1. Coze JS Web Demo: https://coze.ireborn.com.cn/coze-js-web/"
echo "2. Realtime Console: https://coze.ireborn.com.cn/realtime-console/"
echo "3. Realtime Quickstart React: https://coze.ireborn.com.cn/realtime-quickstart-react/"
echo "4. Realtime Quickstart Vue: https://coze.ireborn.com.cn/realtime-quickstart-vue/"
echo "5. Realtime Call Up: https://coze.ireborn.com.cn/realtime-call-up/"
echo "6. Realtime WebSocket: https://coze.ireborn.com.cn/realtime-websocket/"
echo "7. Simult Extension: https://coze.ireborn.com.cn/simult-extension/"
echo ""
echo "OAuth Server endpoints:"
echo "- Web OAuth: https://coze.ireborn.com.cn/oauth/web/"
echo "- PKCE OAuth: https://coze.ireborn.com.cn/oauth/pkce/"
echo "- JWT OAuth: https://coze.ireborn.com.cn/oauth/jwt/"
echo "- Device OAuth: https://coze.ireborn.com.cn/oauth/device/"
echo ""
echo "Note: Make sure SSL certificates are properly configured before accessing via HTTPS."