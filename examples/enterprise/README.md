# Enterprise ngrok Example

This example demonstrates an enterprise-grade ngrok deployment with maximum security, compliance features, and monitoring for production use.

## Enterprise Features

### Security
- **OIDC Integration**: Enterprise identity provider
- **Mutual TLS**: Client certificate authentication
- **Zero Trust**: IP restrictions and multi-factor auth
- **Security Headers**: HSTS, CSP, X-Frame-Options
- **Circuit Breakers**: Automatic failover protection

### Compliance
- **SOX Compliance**: Financial data protection
- **PCI DSS**: Payment card industry standards  
- **Data Classification**: Confidential/Restricted markings
- **Audit Logging**: Complete request/response logs
- **File Integrity**: AIDE monitoring

### Monitoring
- **Prometheus**: Metrics collection
- **Alert Manager**: Incident response
- **Log Aggregation**: Centralized logging
- **Health Checks**: Service availability monitoring

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Enterprise Architecture                  │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Internet → WAF → ngrok → OIDC → mTLS → Services           │
│                                                             │
│  Services:                                                  │
│  ┌─────────────────┐ ┌─────────────────┐                   │
│  │ Executive       │ │ HR System       │                   │
│  │ Dashboard       │ │ (mTLS)          │                   │
│  │ (VIP IPs)       │ │ (Confidential)  │                   │
│  └─────────────────┘ └─────────────────┘                   │
│                                                             │
│  ┌─────────────────┐ ┌─────────────────┐                   │
│  │ Finance API     │ │ Customer Portal │                   │
│  │ (SOX/PCI)       │ │ (Public)        │                   │
│  │ (Webhook Verify)│ │ (Rate Limited)  │                   │
│  └─────────────────┘ └─────────────────┘                   │
│                                                             │
│  ┌─────────────────┐ ┌─────────────────┐                   │
│  │ Internal Tools  │ │ Monitoring      │                   │
│  │ (OIDC + Basic)  │ │ (DevOps Only)   │                   │
│  │ (Emergency)     │ │ (Real-time)     │                   │
│  └─────────────────┘ └─────────────────┘                   │
└─────────────────────────────────────────────────────────────┘
```

## Service Tiers

### Tier 1: Executive (Maximum Security)
- **Custom Domain**: `exec.mycompany.com`
- **Authentication**: OIDC with C-level allowlist
- **Network**: VIP IP ranges only  
- **Circuit Breaker**: 5% error tolerance
- **Headers**: Maximum security (HSTS, CSP, etc.)

### Tier 2: Confidential (HR/Finance)
- **Authentication**: OIDC with department restrictions
- **Security**: Mutual TLS, webhook verification
- **Compliance**: SOX, PCI DSS headers
- **Logging**: Disabled for sensitive data
- **Network**: Internal subnets only

### Tier 3: Internal Tools
- **Authentication**: OIDC + basic auth fallback
- **Network**: Company networks only
- **Monitoring**: Full request inspection
- **Emergency**: Basic auth for OIDC outages

### Tier 4: Customer-Facing
- **Authentication**: None (public)
- **Security**: Rate limiting, DDoS protection
- **Performance**: Compression enabled
- **Monitoring**: Full analytics

## Setup

### 1. Identity Provider Configuration

Configure your OIDC provider (e.g., Okta, Azure AD, Auth0):

```yaml
# Example OIDC app configuration
issuer_url: "https://auth.mycompany.com"
client_id: "ngrok-enterprise"
redirect_uris:
  - "https://exec.mycompany.com/oauth/callback"
  - "https://hr-internal.mycompany.com/oauth/callback"
  - "https://finance-api.mycompany.com/oauth/callback"
scopes:
  - "openid"
  - "email" 
  - "profile"
  - "groups"
  - "hr:read"
  - "hr:write"
  - "finance:read"
  - "finance:write"
  - "monitoring:read"
```

### 2. Certificate Setup

Generate company CA and client certificates:

```bash
# Generate company CA
openssl genrsa -out company-ca.key 4096
openssl req -new -x509 -days 3650 -key company-ca.key -out company-ca.crt

# Generate client certificate
openssl genrsa -out client.key 2048
openssl req -new -key client.key -out client.csr
openssl x509 -req -in client.csr -CA company-ca.crt -CAkey company-ca.key -out client.crt
```

### 3. Configuration

Update the configuration with your values:

```bash
# Set ngrok auth token
sed -i 's/YOUR_NGROK_AUTH_TOKEN_HERE/your_actual_token/' configuration.nix

# Update OIDC settings
vim configuration.nix  # Edit issuer URLs, client IDs, secrets

# Add company CA certificate
cp company-ca.crt /etc/ssl/certs/
```

### 4. Deploy

```bash
sudo nixos-rebuild switch --flake .#enterprise-server
```

### 5. Verify Services

```bash
# Check all ngrok tunnels
systemctl status ngrok-*

# Check enterprise services
systemctl status executive-dashboard hr-system finance-api

# Check security services
systemctl status postgresql prometheus aide
```

## Security Verification

### 1. OIDC Authentication
Test each service requires proper authentication:
```bash
# Should redirect to OIDC provider
curl -I https://exec.mycompany.com/

# Should return 401 without auth
curl -I https://hr-internal.mycompany.com/api/employees
```

### 2. IP Restrictions
Verify IP allowlists work:
```bash
# From allowed IP - should work
curl https://exec.mycompany.com/

# From blocked IP - should return 403
curl --interface bad-ip https://exec.mycompany.com/
```

### 3. Mutual TLS
Test client certificate requirement:
```bash
# Without client cert - should fail
curl https://hr-internal.mycompany.com/

# With client cert - should work
curl --cert client.crt --key client.key https://hr-internal.mycompany.com/
```

### 4. Circuit Breakers
Test error tolerance:
```bash
# Generate errors to trigger circuit breaker
for i in {1..100}; do
  curl https://exec.mycompany.com/error-endpoint
done
```

## Monitoring

### Prometheus Metrics
Access monitoring dashboard:
```
https://monitoring.your-domain.ngrok.app/
```

Key metrics:
- Request rate and latency
- Error rates by service
- Authentication success/failure
- Circuit breaker status

### Log Analysis
```bash
# View OIDC authentication logs
journalctl -u ngrok-* | grep oidc

# Monitor security events
journalctl -u aide | grep VIOLATION

# Database audit logs
journalctl -u postgresql | grep AUDIT
```

## Compliance

### SOX Compliance (Finance)
- All financial data requests logged
- Dual authentication required
- Data classification headers
- Audit trail maintained

### PCI DSS (Payments)
- No payment data inspection/logging
- Encrypted communication only
- Restricted network access
- Regular security scanning

### GDPR (Personal Data)
- Data classification headers
- Retention policy headers
- Right to be forgotten support
- Consent tracking

## Incident Response

### Emergency Access
If OIDC is down, use basic auth fallback:
```bash
curl -u admin:emergency-access-password https://internal-tools.your-domain.ngrok.app/
```

### Circuit Breaker Recovery
Reset circuit breakers:
```bash
systemctl restart ngrok-*
```

### Certificate Renewal
Update certificates before expiry:
```bash
# Update client certificates
cp new-client.crt /etc/ssl/certs/
cp new-client.key /etc/ssl/private/
systemctl restart ngrok-hr-system
```

## Security Hardening

### Additional Recommendations
1. **WAF**: Add Web Application Firewall
2. **DDoS**: Configure DDoS protection
3. **Backup**: Implement secure backup strategy
4. **Secrets**: Use HashiCorp Vault for secrets
5. **Network**: Implement network segmentation
6. **Monitoring**: Add SIEM integration

### Regular Security Tasks
- Monthly security updates
- Quarterly penetration testing
- Annual compliance audits
- Certificate renewal monitoring
- Log review and analysis

## Next Steps

- Integrate with your existing OIDC provider
- Customize compliance headers for your industry
- Add additional monitoring and alerting
- Implement backup and disaster recovery
- Scale horizontally with load balancers