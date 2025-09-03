#!/bin/sh
set -e

echo "Performing comprehensive URL updates..."

# Update all references to coze.com domains
find /app/coze-js -type f \( -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" -o -name "*.json" -o -name "*.env*" -o -name "*.md" \) -exec sed -i 's/api\.coze\.com/api.coze.cn/g' {} +
find /app/coze-js -type f \( -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" -o -name "*.json" -o -name "*.env*" -o -name "*.md" \) -exec sed -i 's/www\.coze\.com/www.coze.cn/g' {} +

# Update COZE_COM_BASE_URL to COZE_CN_BASE_URL
find /app/coze-js -type f \( -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" -o -name "*.mjs" -o -name "*.env*" \) -exec sed -i 's/COZE_COM_BASE_URL/COZE_CN_BASE_URL/g' {} +

# Create .env files for each example with proper configuration
for dir in /app/coze-js/examples/*/; do
    if [ -d "$dir" ]; then
        echo "Creating .env for $dir"
        cat > "$dir/.env" << EOF
VITE_COZE_API_BASE=https://api.coze.cn
REACT_APP_COZE_API_BASE=https://api.coze.cn
COZE_CN_BASE_URL=https://api.coze.cn
COZE_API_BASE=https://api.coze.cn
COZE_BOT_ID=7467988865836777510
COZE_API_TOKEN=pat_toUWNvmtg6r8wdhG0hezbJrLlT64G0CaH26Jh5wxxFveK50F2PGrDWlIEfMNjk3u
VITE_COZE_BOT_ID=7467988865836777510
REACT_APP_COZE_BOT_ID=7467988865836777510
VITE_COZE_API_TOKEN=pat_toUWNvmtg6r8wdhG0hezbJrLlT64G0CaH26Jh5wxxFveK50F2PGrDWlIEfMNjk3u
REACT_APP_COZE_API_TOKEN=pat_toUWNvmtg6r8wdhG0hezbJrLlT64G0CaH26Jh5wxxFveK50F2PGrDWlIEfMNjk3u
EOF
    fi
done

echo "URL updates completed successfully"