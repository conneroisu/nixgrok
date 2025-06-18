# Advanced ngrok Example

This example demonstrates a comprehensive ngrok setup with multiple tunnels, security features, and real applications.

## Features

### Multiple Tunnels
- **Web Server** (Port 80): Main application with HTTPS and security headers
- **Admin Panel** (Port 8080): Protected with HTTP basic auth and IP restrictions  
- **API Server** (Port 3000): RESTful API with compression and rate limiting
- **Webhooks** (Port 9000): GitHub webhook handler with verification
- **SSH Access** (Port 22): Secure shell access
- **Database** (Port 5432): PostgreSQL with IP restrictions

### Security Features
- HTTP basic authentication
- IP address restrictions  
- Security headers (HSTS, X-Frame-Options, etc.)
- Circuit breakers for high error rates
- Webhook signature verification
- TLS termination

### Performance Features
- Gzip compression
- WebSocket TCP conversion
- Request/response header manipulation
- Traffic inspection controls
- Caching headers

## Architecture

```
Internet
    ↓
  ngrok
    ↓
┌─────────────────────────────────────┐
│              NixOS Server           │
├─────────────────────────────────────┤
│ Nginx (80) → Static Files           │
│ Admin (8080) → Admin Interface      │
│ API (3000) → Python API Server     │  
│ Webhooks (9000) → Webhook Handler   │
│ SSH (22) → System Access           │
│ PostgreSQL (5432) → Database        │
└─────────────────────────────────────┘
```

## Setup

1. **Update auth token**:
   ```bash
   sed -i 's/YOUR_NGROK_AUTH_TOKEN_HERE/your_actual_token/' configuration.nix
   ```

2. **Build and deploy**:
   ```bash
   sudo nixos-rebuild switch --flake .#advanced-server
   ```

3. **Check all services**:
   ```bash
   systemctl status ngrok-web ngrok-admin ngrok-api ngrok-webhooks ngrok-ssh
   systemctl status nginx api-server webhook-handler postgresql
   ```

4. **View tunnel URLs**:
   ```bash
   journalctl -u ngrok-web -f
   ```

## Testing

### Web Interface
Visit your main tunnel URL to see the status page with all enabled features.

### Admin Panel  
Access the admin tunnel with:
- Username: `admin`
- Password: `super-secret-password`

### API Testing
```bash
curl https://api-your-tunnel.ngrok-free.app/
```

### Webhook Testing
```bash
curl -X POST https://webhooks-your-tunnel.ngrok-free.app/ \
  -H "Content-Type: application/json" \
  -d '{"test": "webhook"}'
```

### SSH Access
```bash
ssh -p 2222 user@tcp-your-tunnel.ngrok-free.app
```

## Configuration

### Customizing Security
Edit the IP restrictions in `configuration.nix`:
```nix
ip_restriction_allow_cidrs = [
  "your.office.ip.range/24"
  "home.ip.address/32"
];
```

### Adding Custom Headers
```nix
response_header_add = {
  "X-Custom-Header" = "my-value";
  "X-API-Version" = "1.0";
};
```

### Webhook Verification
Update the webhook secret:
```nix
webhook_verification = {
  provider = "github";  # or slack, stripe, etc.
  secret = "your-webhook-secret";
};
```

## Monitoring

View logs for different services:
```bash
# ngrok tunnels
journalctl -u ngrok-* -f

# Web services  
journalctl -u nginx -f
journalctl -u api-server -f
journalctl -u webhook-handler -f

# Database
journalctl -u postgresql -f
```

## Security Notes

- Change default passwords before production use
- Update IP restrictions to match your networks
- Use proper TLS certificates for production
- Enable fail2ban for additional protection
- Regular security updates with `nixos-rebuild switch`

## Next Steps

- See `oauth` example for OAuth integration
- See `enterprise` example for advanced enterprise features
- Customize services for your specific use case