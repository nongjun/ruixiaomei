#!/bin/bash

DOMAIN="coze.ireborn.com.cn"
EMAIL="admin@ireborn.com.cn"  # Please update this with your email

echo "Setting up SSL certificates for $DOMAIN"

# Check if certbot is installed
if ! command -v certbot &> /dev/null; then
    echo "Installing certbot..."
    if command -v apt-get &> /dev/null; then
        sudo apt-get update
        sudo apt-get install -y certbot
    elif command -v yum &> /dev/null; then
        sudo yum install -y epel-release
        sudo yum install -y certbot
    else
        echo "Cannot install certbot. Please install it manually."
        exit 1
    fi
fi

# Create SSL directory
mkdir -p ssl

# Obtain certificate
echo "Obtaining SSL certificate..."
sudo certbot certonly \
    --standalone \
    --non-interactive \
    --agree-tos \
    --email $EMAIL \
    --domains $DOMAIN \
    --pre-hook "docker-compose down 2>/dev/null || true" \
    --post-hook "docker-compose up -d 2>/dev/null || true"

# Copy certificates to the SSL directory
if [ -d "/etc/letsencrypt/live/$DOMAIN" ]; then
    sudo cp /etc/letsencrypt/live/$DOMAIN/fullchain.pem ssl/
    sudo cp /etc/letsencrypt/live/$DOMAIN/privkey.pem ssl/
    sudo chmod 644 ssl/fullchain.pem ssl/privkey.pem
    echo "SSL certificates copied successfully"
else
    echo "Error: SSL certificates not found"
    exit 1
fi

# Set up auto-renewal
echo "Setting up auto-renewal..."
(crontab -l 2>/dev/null; echo "0 0,12 * * * certbot renew --quiet --post-hook 'cd /workspace/coze-deployment && docker-compose restart'") | crontab -

echo "SSL setup completed successfully!"