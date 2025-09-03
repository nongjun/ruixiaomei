# Coze.js Examples Deployment

This deployment contains all web-based examples from the Coze.js repository, configured to work with the Chinese Coze API (coze.cn).

## Deployed Applications

All applications are accessible via HTTPS at `https://coze.ireborn.com.cn/`

### Frontend Applications

1. **Coze JS Web Demo**
   - URL: https://coze.ireborn.com.cn/coze-js-web/
   - Description: React-based web demo for Coze API
   - Also available at root: https://coze.ireborn.com.cn/

2. **Realtime Console**
   - URL: https://coze.ireborn.com.cn/realtime-console/
   - Description: Full console demo for Realtime API

3. **Realtime Quickstart React**
   - URL: https://coze.ireborn.com.cn/realtime-quickstart-react/
   - Description: Quickstart React demo for Realtime API

4. **Realtime Quickstart Vue**
   - URL: https://coze.ireborn.com.cn/realtime-quickstart-vue/
   - Description: Quickstart Vue demo for Realtime API

5. **Realtime Call Up**
   - URL: https://coze.ireborn.com.cn/realtime-call-up/
   - Description: Sample call up demo

6. **Realtime WebSocket**
   - URL: https://coze.ireborn.com.cn/realtime-websocket/
   - Description: WebSocket realtime demo

7. **Simult Extension**
   - URL: https://coze.ireborn.com.cn/simult-extension/
   - Description: Simultaneous interpretation extension demo

### Backend Services (OAuth Server)

1. **Web OAuth**
   - URL: https://coze.ireborn.com.cn/oauth/web/
   - Description: Web-based OAuth flow

2. **PKCE OAuth**
   - URL: https://coze.ireborn.com.cn/oauth/pkce/
   - Description: PKCE OAuth flow

3. **JWT OAuth**
   - URL: https://coze.ireborn.com.cn/oauth/jwt/
   - Description: JWT-based OAuth flow

4. **Device OAuth**
   - URL: https://coze.ireborn.com.cn/oauth/device/
   - Description: Device OAuth flow

## Configuration

All applications are configured with:
- **Base URL**: https://api.coze.cn (Chinese Coze API)
- **Bot ID**: 7467988865836777510
- **API Token**: pat_toUWNvmtg6r8wdhG0hezbJrLlT64G0CaH26Jh5wxxFveK50F2PGrDWlIEfMNjk3u

## Deployment Instructions

### Prerequisites
- Docker and Docker Compose installed
- Domain pointing to your server
- Ports 80 and 443 available

### Quick Start

1. Clone this deployment directory
2. Set up SSL certificates:
   ```bash
   ./setup-ssl.sh
   ```
3. Build and start the services:
   ```bash
   docker-compose up -d --build
   ```

### Manual SSL Setup

If automatic SSL setup fails, you can manually place your SSL certificates:
1. Create an `ssl` directory
2. Place your certificate files:
   - `ssl/fullchain.pem` - Full certificate chain
   - `ssl/privkey.pem` - Private key

### Monitoring

View logs:
```bash
docker-compose logs -f
```

Check individual service logs:
```bash
docker exec -it coze-apps tail -f /var/log/nginx/access.log
docker exec -it coze-apps tail -f /var/log/oauth-web.out.log
```

### Updating

To update the applications:
```bash
docker-compose down
docker-compose up -d --build
```

## Architecture

- **Nginx**: Serves static files and proxies OAuth server requests
- **Supervisor**: Manages multiple Node.js processes for OAuth servers
- **Docker**: Containerizes the entire stack for easy deployment

## Troubleshooting

1. **SSL Certificate Issues**: Ensure your domain is properly configured and pointing to the server
2. **Application Not Loading**: Check if the build process completed successfully in Docker logs
3. **OAuth Server Errors**: Check the specific OAuth server logs in `/var/log/`

## Security Notes

- The API token is included for demo purposes. In production, use environment variables
- SSL/TLS is enforced for all connections
- Security headers are configured in Nginx