#!/bin/bash

echo "Testing Coze.js deployment..."

# Function to test URL
test_url() {
    local url=$1
    local name=$2
    
    echo -n "Testing $name... "
    if curl -k -s -o /dev/null -w "%{http_code}" "$url" | grep -q "200\|301\|302"; then
        echo "✓ OK"
    else
        echo "✗ Failed"
    fi
}

# Test health endpoint
test_url "http://localhost/health" "Health Check"

# Test all applications
echo ""
echo "Testing Frontend Applications:"
test_url "http://localhost/coze-js-web/" "Coze JS Web"
test_url "http://localhost/realtime-console/" "Realtime Console"
test_url "http://localhost/realtime-quickstart-react/" "Realtime Quickstart React"
test_url "http://localhost/realtime-quickstart-vue/" "Realtime Quickstart Vue"
test_url "http://localhost/realtime-call-up/" "Realtime Call Up"
test_url "http://localhost/realtime-websocket/" "Realtime WebSocket"
test_url "http://localhost/simult-extension/" "Simult Extension"

echo ""
echo "Testing OAuth Endpoints:"
test_url "http://localhost/oauth/web/" "Web OAuth"
test_url "http://localhost/oauth/pkce/" "PKCE OAuth"
test_url "http://localhost/oauth/jwt/" "JWT OAuth"
test_url "http://localhost/oauth/device/" "Device OAuth"

echo ""
echo "Deployment test complete!"