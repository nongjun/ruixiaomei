#!/bin/sh
set -e

echo "Updating base URLs from COZE_COM_BASE_URL to COZE_CN_BASE_URL..."

# Find and replace in all JavaScript/TypeScript files
find /app/coze-js/examples -type f \( -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" -o -name "*.mjs" \) -exec sed -i 's/COZE_COM_BASE_URL/COZE_CN_BASE_URL/g' {} +

# Also update any environment files
find /app/coze-js/examples -type f \( -name ".env*" -o -name "*.env" \) -exec sed -i 's/COZE_COM_BASE_URL/COZE_CN_BASE_URL/g' {} +

# Update configuration files
find /app/coze-js/examples -type f \( -name "config.js" -o -name "config.ts" -o -name "*.config.js" -o -name "*.config.ts" \) -exec sed -i 's/api\.coze\.com/api\.coze\.cn/g' {} +
find /app/coze-js/examples -type f \( -name "config.js" -o -name "config.ts" -o -name "*.config.js" -o -name "*.config.ts" \) -exec sed -i 's/www\.coze\.com/www\.coze\.cn/g' {} +

echo "Base URLs updated successfully"