# NixOS ngrok Service

A NixOS flake that provides a comprehensive ngrok service module for tunneling local services to the internet.

## Features

### Core Features
- **Systemd Service**: Runs ngrok as a proper systemd service with automatic restart
- **Multiple Tunnels**: Support for multiple named tunnels with different configurations
- **Protocol Support**: HTTP, HTTPS, TCP, and TLS tunnels
- **User Management**: Runs under dedicated user for security
- **Regional Support**: Choose from US, EU, AU, AP, SA, JP, IN regions

### Authentication & Security
- **HTTP Basic Auth**: Username/password authentication
- **OAuth Integration**: Google, GitHub, Microsoft, Facebook
- **OIDC Support**: OpenID Connect with custom providers
- **Webhook Verification**: Slack, SNS, Stripe, GitHub, Twilio, Shopify, Zoom, Svix
- **Mutual TLS**: Client certificate authentication
- **IP Restrictions**: Allow/deny specific CIDR blocks

### Advanced Features
- **Custom Domains**: Use your own hostnames and subdomains
- **Header Manipulation**: Add/remove request and response headers  
- **Circuit Breaker**: Automatic failover on high error rates
- **Compression**: Gzip compression for HTTP responses
- **WebSocket TCP Converter**: WebSocket to TCP conversion
- **Request Inspection**: Enable/disable traffic inspection
- **TLS Termination**: Flexible HTTPS/HTTP binding options

### Performance & Monitoring
- **Metadata Support**: Add custom metadata to tunnel sessions
- **Traffic Inspection**: Built-in request/response inspection
- **Logging Integration**: Full systemd journal integration
- **Health Monitoring**: Automatic service health checks

## Quick Start

1. **Set your ngrok auth token** in `configuration.nix`:
   ```nix
   services.ngrok.authToken = "YOUR_NGROK_AUTH_TOKEN_HERE";
   ```

2. **Build and switch to the configuration**:
   ```bash
   # For NixOS systems
   sudo nixos-rebuild switch --flake .#nixgrok
   
   # To test the flake
   NIXPKGS_ALLOW_UNFREE=1 nix flake check --impure
   ```

## Configuration Examples

### Basic HTTP Tunnel
```nix
services.ngrok = {
  enable = true;
  authToken = "your_auth_token_here";
  
  tunnels.web = {
    protocol = "http";
    port = 8080;
  };
};
```

### Multiple Tunnels
```nix
services.ngrok = {
  enable = true;
  authToken = "your_auth_token_here";
  
  tunnels = {
    web = {
      protocol = "http";
      port = 8080;
      subdomain = "myapp"; # Requires paid plan
    };
    
    ssh = {
      protocol = "tcp";
      port = 22;
    };
    
    api = {
      protocol = "https";
      port = 3000;
      auth = "user:password"; # HTTP basic auth
    };
  };
};
```

### Using Custom Config File
```nix
services.ngrok = {
  enable = true;
  configFile = /path/to/your/ngrok.yml;
};
```

## Service Management

The service creates individual systemd units for each tunnel:

```bash
# Check status of all ngrok services
systemctl status ngrok-*

# Start/stop/restart specific tunnel
systemctl start ngrok-web
systemctl stop ngrok-ssh
systemctl restart ngrok-api

# View logs
journalctl -u ngrok-web -f
```

## Configuration Options

### `services.ngrok`

- `enable`: Enable the ngrok service
- `authToken`: Your ngrok authentication token (required)
- `package`: ngrok package to use (default: `pkgs.ngrok`)
- `user`: User to run ngrok as (default: "ngrok")
- `group`: Group to run ngrok as (default: "ngrok")
- `configFile`: Path to custom ngrok config file (optional)
- `tunnels`: Attribute set of tunnel configurations

### `services.ngrok.tunnels.<name>`

#### Basic Options
- `protocol`: Protocol to tunnel ("http", "https", "tcp", "tls")
- `port`: Local port to tunnel
- `hostname`: Custom hostname (overrides subdomain)
- `subdomain`: Custom subdomain (requires paid plan)

#### Authentication
- `auth`: HTTP basic authentication ("user:password")
- `oauth`: OAuth configuration (Google, GitHub, Microsoft, Facebook)
  - `provider`: OAuth provider
  - `allow_emails`: List of allowed email addresses
  - `allow_domains`: List of allowed email domains
  - `scopes`: OAuth scopes to request
- `oidc`: OpenID Connect configuration
  - `issuer_url`: OIDC issuer URL
  - `client_id`: OIDC client ID
  - `client_secret`: OIDC client secret
  - `allow_emails`: List of allowed email addresses
  - `allow_domains`: List of allowed email domains
  - `scopes`: OIDC scopes to request

#### Security
- `webhook_verification`: Webhook verification settings
  - `provider`: Verification provider (slack, sns, stripe, github, etc.)
  - `secret`: Webhook verification secret
- `mutual_tls_cas`: List of PEM TLS certificate authorities
- `ip_restriction_allow_cidrs`: List of allowed CIDR blocks
- `ip_restriction_deny_cidrs`: List of denied CIDR blocks

#### Performance & Features
- `compression`: Enable gzip compression (boolean)
- `websocket_tcp_converter`: Enable WebSocket TCP conversion (boolean)
- `circuit_breaker`: Reject requests when 5XX responses exceed this ratio (float)
- `inspect`: Enable/disable request inspection (boolean)

#### Headers
- `request_header_add`: Headers to add to requests (attribute set)
- `request_header_remove`: Headers to remove from requests (list)
- `response_header_add`: Headers to add to responses (attribute set)
- `response_header_remove`: Headers to remove from responses (list)

#### TLS Options
- `bind_tls`: Bind HTTPS, HTTP, or both ("true", "false", "both")
- `crt`: PEM TLS certificate file path
- `key`: PEM TLS private key file path

#### TCP Options
- `remote_addr`: Bind remote TCP port on specific address

#### Other
- `extraArgs`: List of extra arguments to pass to ngrok

## Security Notes

- The service runs under a dedicated `ngrok` user
- Configuration files are created with restricted permissions (600)
- Auth tokens are stored in `/etc/ngrok/ngrok.yml` with proper permissions
- The service home directory is `/var/lib/ngrok`

## Troubleshooting

1. **Check service status**:
   ```bash
   systemctl status ngrok-*
   ```

2. **View logs**:
   ```bash
   journalctl -u ngrok-web -f
   ```

3. **Test configuration**:
   ```bash
   sudo -u ngrok ngrok --config=/etc/ngrok/ngrok.yml start --all
   ```

4. **Verify auth token**:
   ```bash
   sudo -u ngrok ngrok --config=/etc/ngrok/ngrok.yml authtoken YOUR_TOKEN
   ```

## Getting Your Auth Token

1. Sign up at [ngrok.com](https://ngrok.com)
2. Go to your dashboard
3. Copy your auth token
4. Replace `YOUR_NGROK_AUTH_TOKEN_HERE` in the configuration

## Flake-Parts Integration

This repository provides a flake-parts implementation for better modularity and composability:

### Using flake-parts

```bash
# Use the flake-parts version
nix develop -f flake-parts.nix

# Check flake-parts configuration
nix flake check -f flake-parts.nix --impure
```

### Available Templates

The flake provides several templates for different use cases:

```bash
# Basic ngrok setup
nix flake init -t github:yourusername/nixgrok#basic

# Advanced features with security
nix flake init -t github:yourusername/nixgrok#advanced

# OAuth-protected tunnels
nix flake init -t github:yourusername/nixgrok#oauth

# Enterprise-grade setup
nix flake init -t github:yourusername/nixgrok#enterprise
```

### Template Overview

| Template | Description | Features |
|----------|-------------|----------|
| `basic` | Simple HTTP tunnel | Basic web server, minimal config |
| `advanced` | Multi-service setup | Multiple tunnels, security headers, rate limiting |
| `oauth` | OAuth integration | Google/GitHub/Microsoft/Facebook auth |
| `enterprise` | Production setup | OIDC, mutual TLS, compliance features |

### Modular Parts

The flake-parts implementation splits functionality into modules:

- **`parts/ngrok-module.nix`** - Core ngrok module exports
- **`parts/dev-shells.nix`** - Development environments  
- **`parts/nixos-configs.nix`** - Example NixOS configurations
- **`parts/packages.nix`** - Package exports and documentation

### Using in Your Flake

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    ngrok-nixos.url = "github:yourusername/nixgrok";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" ];
      
      flake.nixosConfigurations.my-server = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          inputs.ngrok-nixos.nixosModules.default
          ./configuration.nix
        ];
      };
    };
}
```

## Testing with aarch64 Linux VM

This flake includes comprehensive VM testing capabilities for testing the ngrok service on aarch64 Linux from macOS ARM.

### Quick Start - VM Testing

1. **Enter development environment**:
   ```bash
   nix develop
   ```

2. **Build VM image**:
   ```bash
   ./scripts/build-vm.sh
   ```

3. **Start VM with QEMU** (command line):
   ```bash
   ./scripts/start-vm.sh
   ```

4. **Or use UTM** (GUI on macOS):
   ```bash
   ./scripts/utm-setup.sh  # Follow the instructions
   ```

5. **Test the ngrok service**:
   ```bash
   ./scripts/test-ngrok.sh localhost 2222 8080
   ```

6. **Update auth token for real testing**:
   ```bash
   ./scripts/update-auth-token.sh localhost YOUR_NGROK_TOKEN 2222
   ```

### VM Testing Scripts

- `./scripts/build-vm.sh` - Builds both QEMU and UTM-compatible VM images
- `./scripts/start-vm.sh` - Starts VM with QEMU (creates port forwards)
- `./scripts/stop-vm.sh` - Stops the running QEMU VM
- `./scripts/test-ngrok.sh` - Tests ngrok service functionality in VM
- `./scripts/update-auth-token.sh` - Updates ngrok auth token in running VM
- `./scripts/utm-setup.sh` - Helper for UTM setup on macOS

### VM Details

**Login Credentials**:
- Username: `testuser`, Password: `testpass`
- Root password: `nixos`

**Port Forwards** (QEMU mode):
- SSH: `localhost:2222` → `VM:22`
- HTTP: `localhost:8080` → `VM:8080`

**Pre-installed Services**:
- ngrok service (configured but needs valid auth token)
- Test web server on port 8080
- SSH server for remote access

### Cross-Platform Testing

The flake supports building for multiple architectures:

```bash
# Test on aarch64-linux (native or VM)
NIXPKGS_ALLOW_UNFREE=1 nix build --system aarch64-linux .#nixosConfigurations.nixgrok-aarch64.config.system.build.toplevel --impure

# Test on x86_64-linux
NIXPKGS_ALLOW_UNFREE=1 nix build --system x86_64-linux .#nixosConfigurations.nixgrok-x86.config.system.build.toplevel --impure

# Check all systems
NIXPKGS_ALLOW_UNFREE=1 nix flake check --impure --all-systems
```

## License

This flake configuration is provided as-is. ngrok itself is proprietary software - see their terms of service.