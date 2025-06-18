# Advanced ngrok configuration showcasing all available features
{ config, pkgs, ... }:

{
  # Import the ngrok module
  imports = [ ./modules/ngrok.nix ];

  # Basic system configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  # Comprehensive ngrok service configuration
  services.ngrok = {
    enable = true;
    authToken = "YOUR_NGROK_AUTH_TOKEN_HERE";
    region = "us"; # us, eu, au, ap, sa, jp, in
    metadata = "nixos-production-server";

    tunnels = {
      # Basic HTTP tunnel
      web = {
        protocol = "http";
        port = 80;
        hostname = "myapp.example.com"; # Custom domain (paid plan)
        compression = true;
        inspect = true;
      };

      # Secure HTTPS tunnel with authentication
      secure-web = {
        protocol = "https";
        port = 443;
        subdomain = "secure-app"; # Custom subdomain (paid plan)
        auth = "admin:secretpassword"; # HTTP basic auth
        bind_tls = "both"; # Accept both HTTP and HTTPS
        
        # Add custom headers
        request_header_add = {
          "X-Forwarded-Proto" = "https";
          "X-Real-IP" = "$remote_addr";
        };
        
        response_header_add = {
          "X-Frame-Options" = "DENY";
          "X-Content-Type-Options" = "nosniff";
        };
        
        # Remove sensitive headers
        response_header_remove = [ "Server" "X-Powered-By" ];
        
        # IP restrictions
        ip_restriction_allow_cidrs = [ "10.0.0.0/8" "192.168.0.0/16" ];
        
        # Circuit breaker for high error rates
        circuit_breaker = 0.5; # Reject when 50% of requests are 5XX
      };

      # OAuth-protected API endpoint
      api = {
        protocol = "https";
        port = 3000;
        subdomain = "api";
        
        oauth = {
          provider = "google";
          allow_domains = [ "mycompany.com" ];
          scopes = [ "openid" "email" "profile" ];
        };
        
        compression = true;
        websocket_tcp_converter = true;
      };

      # OIDC-protected admin panel
      admin = {
        protocol = "https";
        port = 8080;
        subdomain = "admin";
        
        oidc = {
          issuer_url = "https://auth.example.com";
          client_id = "ngrok-admin";
          client_secret = "oidc-secret";
          allow_emails = [ "admin@mycompany.com" "ops@mycompany.com" ];
          scopes = [ "openid" "email" "groups" ];
        };
      };

      # Webhook endpoint with verification
      webhooks = {
        protocol = "https";
        port = 9000;
        subdomain = "webhooks";
        
        webhook_verification = {
          provider = "github";
          secret = "webhook-secret-key";
        };
        
        # Only allow requests from GitHub's IPs
        ip_restriction_allow_cidrs = [
          "140.82.112.0/20"
          "185.199.108.0/22"
          "192.30.252.0/22"
        ];
      };

      # TCP tunnel for SSH
      ssh = {
        protocol = "tcp";
        port = 22;
        remote_addr = "0.0.0.0:2222"; # Bind to specific address
      };

      # TLS tunnel with custom certificates
      secure-tcp = {
        protocol = "tls";
        port = 5432; # PostgreSQL
        hostname = "db.example.com";
        crt = "/etc/ssl/certs/db.crt";
        key = "/etc/ssl/private/db.key";
        
        # Mutual TLS authentication
        mutual_tls_cas = [ "/etc/ssl/certs/ca.crt" ];
      };

      # Development tunnel with all features disabled for speed
      dev = {
        protocol = "http";
        port = 8000;
        subdomain = "dev";
        inspect = false; # Disable inspection for better performance
        compression = false;
      };
    };
  };

  # Enable required services
  services.openssh.enable = true;
  networking.firewall.allowedTCPPorts = [ 80 443 3000 8080 9000 8000 ];

  system.stateVersion = "23.11";
  nixpkgs.config.allowUnfree = true;
}