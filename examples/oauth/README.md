# OAuth ngrok Example

This example demonstrates OAuth-protected ngrok tunnels using different providers (Google, GitHub, Microsoft, Facebook) for different types of applications.

## Features

### OAuth Providers
- **Google OAuth**: Admin panel with domain restrictions
- **GitHub OAuth**: Development tools with email allowlist  
- **Microsoft OAuth**: Enterprise tools with Azure AD integration
- **Facebook OAuth**: Marketing tools with team access
- **Public API**: No authentication required

### Security Features
- Domain-based access control
- Email allowlists
- Scope-based permissions
- Provider-specific configurations
- Circuit breakers and rate limiting

## Architecture

```
Internet → ngrok → OAuth Provider → Your Services

┌─────────────────────────────────────────────────────────┐
│                   OAuth Flow                            │
├─────────────────────────────────────────────────────────┤
│ User → ngrok → OAuth Provider → ngrok → Your Service    │
│                                                         │
│ Providers:                                              │
│ • Google (admin-google.ngrok.app)                      │  
│ • GitHub (dev-github.ngrok.app)                        │
│ • Microsoft (enterprise-ms.ngrok.app)                  │
│ • Facebook (marketing-fb.ngrok.app)                    │
│ • Public API (public-api.ngrok.app)                    │
└─────────────────────────────────────────────────────────┘
```

## OAuth Configuration

### Google OAuth
- **Domain Restrictions**: Only `mycompany.com` and `trusted-partner.com`
- **Scopes**: `openid`, `email`, `profile`
- **Use Case**: Admin panels, management tools

### GitHub OAuth  
- **Email Allowlist**: Specific developer email addresses
- **Scopes**: `user:email`, `read:org`
- **Use Case**: Development tools, CI/CD interfaces

### Microsoft OAuth
- **Domain Restrictions**: Enterprise domain only
- **Scopes**: `openid`, `email`, `profile`, `User.Read`
- **Use Case**: Enterprise applications, HR tools

### Facebook OAuth
- **Email Allowlist**: Marketing team members
- **Scopes**: `email`, `public_profile`
- **Use Case**: Social media tools, campaign management

## Setup

1. **Configure OAuth Applications**:
   
   For each provider, create an OAuth application:
   
   **Google**: https://console.developers.google.com/
   - Authorized redirect URIs: `https://admin-google.your-domain.ngrok.app/oauth/callback`
   
   **GitHub**: https://github.com/settings/applications/new
   - Authorization callback URL: `https://dev-github.your-domain.ngrok.app/oauth/callback`
   
   **Microsoft**: https://portal.azure.com/
   - Redirect URI: `https://enterprise-ms.your-domain.ngrok.app/oauth/callback`
   
   **Facebook**: https://developers.facebook.com/
   - Valid OAuth Redirect URIs: `https://marketing-fb.your-domain.ngrok.app/oauth/callback`

2. **Update configuration**:
   ```bash
   # Add your ngrok auth token
   sed -i 's/YOUR_NGROK_AUTH_TOKEN_HERE/your_actual_token/' configuration.nix
   
   # Update domain restrictions
   vim configuration.nix  # Edit allow_domains and allow_emails
   ```

3. **Deploy**:
   ```bash
   sudo nixos-rebuild switch --flake .#oauth-server
   ```

4. **Check services**:
   ```bash
   systemctl status ngrok-* admin-panel dev-server enterprise-server marketing-server public-api
   ```

## Testing

### Admin Panel (Google OAuth)
1. Visit: `https://admin-google.your-domain.ngrok.app`
2. Sign in with Google account from allowed domain
3. Access admin features

### Development Tools (GitHub OAuth)
1. Visit: `https://dev-github.your-domain.ngrok.app`  
2. Sign in with GitHub account from allowlist
3. Access development tools

### Enterprise Tools (Microsoft OAuth)
1. Visit: `https://enterprise-ms.your-domain.ngrok.app`
2. Sign in with Microsoft/Azure AD account
3. Access enterprise features

### Marketing Tools (Facebook OAuth)
1. Visit: `https://marketing-fb.your-domain.ngrok.app`
2. Sign in with Facebook account from allowlist
3. Access marketing tools

### Public API (No Auth)
1. Visit: `https://public-api.your-domain.ngrok.app`
2. No authentication required
3. Test endpoints: `/health`, `/status`, `/info`, `/metrics`

## User Information

When users authenticate via OAuth, ngrok provides headers with user information:

```
ngrok-auth-user-email: user@example.com
ngrok-auth-user-name: John Doe
ngrok-auth-user-login: johndoe (GitHub only)
```

Your applications can use these headers to personalize the experience.

## Security Best Practices

### Domain Restrictions
```nix
oauth = {
  provider = "google";
  allow_domains = [ "mycompany.com" ];  # Company domain only
};
```

### Email Allowlists  
```nix
oauth = {
  provider = "github";
  allow_emails = [
    "alice@mycompany.com"
    "bob@mycompany.com"
  ];
};
```

### Minimal Scopes
Only request the OAuth scopes you actually need:
```nix
scopes = [ "openid" "email" ];  # Don't request "profile" if not needed
```

### Circuit Breakers
Protect against OAuth provider outages:
```nix
circuit_breaker = 0.1;  # Low tolerance for auth failures
```

## Monitoring

View OAuth authentication logs:
```bash
# ngrok OAuth logs
journalctl -u ngrok-admin-google -f | grep oauth

# Service access logs  
journalctl -u admin-panel -f
journalctl -u dev-server -f
```

## Troubleshooting

### OAuth Errors
- Check OAuth app configuration in provider console
- Verify redirect URIs match your ngrok URLs
- Check domain/email restrictions
- Review OAuth scopes

### Access Denied
- Verify user email/domain is in allowlist
- Check OAuth application is approved by admin
- Ensure user has required permissions

## Next Steps

- Customize OAuth scopes for your needs
- Add role-based access control
- Integrate with existing identity providers
- See `enterprise` example for advanced OIDC features