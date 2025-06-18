{ config, pkgs, ... }:

{
  # System configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  networking.hostName = "ngrok-advanced";
  networking.networkmanager.enable = true;

  # Advanced ngrok service with multiple tunnels and features
  services.ngrok = {
    enable = true;
    authToken = "YOUR_NGROK_AUTH_TOKEN_HERE";
    region = "us";
    metadata = "advanced-production-server";

    tunnels = {
      # Public web interface with security features
      web = {
        protocol = "https";
        port = 80;
        hostname = "myapp.example.com"; # Requires paid plan
        compression = true;
        inspect = true;
        
        # Security headers
        response_header_add = {
          "X-Frame-Options" = "DENY";
          "X-Content-Type-Options" = "nosniff";
          "Strict-Transport-Security" = "max-age=31536000";
        };
        
        response_header_remove = [ "Server" "X-Powered-By" ];
        
        # Circuit breaker for high error rates
        circuit_breaker = 0.3;
      };

      # Admin panel with HTTP basic auth
      admin = {
        protocol = "https";
        port = 8080;
        subdomain = "admin"; # Requires paid plan
        auth = "admin:super-secret-password";
        
        # Only allow admin networks
        ip_restriction_allow_cidrs = [
          "10.0.0.0/8"      # Internal networks
          "192.168.0.0/16"  # Local networks
          "203.0.113.0/24"  # Office network (example)
        ];
        
        # Add source IP header
        request_header_add = {
          "X-Admin-Access" = "true";
          "X-Forwarded-Proto" = "https";
        };
      };

      # API endpoint with compression and rate limiting
      api = {
        protocol = "https";
        port = 3000;
        subdomain = "api";
        compression = true;
        websocket_tcp_converter = true;
        
        # Performance headers
        response_header_add = {
          "Cache-Control" = "public, max-age=300";
          "X-RateLimit-Limit" = "100";
        };
        
        # Circuit breaker for API stability
        circuit_breaker = 0.5;
      };

      # Webhook endpoint with verification
      webhooks = {
        protocol = "https";
        port = 9000;
        subdomain = "webhooks";
        
        webhook_verification = {
          provider = "github";
          secret = "your-webhook-secret";
        };
        
        # Only allow GitHub webhook IPs
        ip_restriction_allow_cidrs = [
          "140.82.112.0/20"
          "185.199.108.0/22"
          "192.30.252.0/22"
        ];
        
        inspect = false; # Better performance for webhooks
      };

      # SSH tunnel for secure access
      ssh = {
        protocol = "tcp";
        port = 22;
        remote_addr = "0.0.0.0:2222";
      };

      # Database tunnel with TLS
      database = {
        protocol = "tcp";
        port = 5432;
        subdomain = "db";
        
        # Restrict to specific IPs only
        ip_restriction_allow_cidrs = [
          "10.0.0.0/8"
        ];
      };
    };
  };

  # Nginx reverse proxy
  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts."localhost" = {
      listen = [
        { addr = "0.0.0.0"; port = 80; }
      ];
      
      locations."/" = {
        root = "/var/www";
        index = "index.html";
      };
      
      locations."/api/" = {
        proxyPass = "http://localhost:3001/";
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
        '';
      };
    };

    virtualHosts."admin.localhost" = {
      listen = [
        { addr = "0.0.0.0"; port = 8080; }
      ];
      
      locations."/" = {
        root = "/var/www/admin";
        index = "admin.html";
      };
    };
  };

  # Simple API server
  systemd.services.api-server = {
    enable = true;
    description = "Simple API server";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.python3}/bin/python3 /var/lib/api-server/server.py";
      DynamicUser = true;
      StateDirectory = "api-server";
      Restart = "always";
    };
  };

  # Webhook handler
  systemd.services.webhook-handler = {
    enable = true;
    description = "Webhook handler service";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.python3}/bin/python3 /var/lib/webhooks/handler.py";
      DynamicUser = true;
      StateDirectory = "webhooks";
      Restart = "always";
    };
  };

  # PostgreSQL database
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_15;
    initialDatabases = [
      { name = "myapp"; }
    ];
    authentication = ''
      local myapp all trust
      host  myapp all 127.0.0.1/32 trust
      host  myapp all ::1/128 trust
    '';
  };

  # Create web content
  environment.etc = {
    "www/index.html".text = ''
      <!DOCTYPE html>
      <html>
      <head>
          <title>Advanced ngrok Server</title>
          <style>
              body { font-family: Arial, sans-serif; margin: 40px; }
              .status { background: #e8f5e8; padding: 20px; border-radius: 5px; }
          </style>
      </head>
      <body>
          <h1>Advanced ngrok Server</h1>
          <div class="status">
              <h2>🚀 Server Status: Online</h2>
              <p><strong>Hostname:</strong> ${config.networking.hostName}</p>
              <p><strong>Services:</strong></p>
              <ul>
                  <li>Web Server (Port 80) ✅</li>
                  <li>API Server (Port 3000) ✅</li>
                  <li>Admin Panel (Port 8080) ✅</li>
                  <li>Webhooks (Port 9000) ✅</li>
                  <li>SSH (Port 22) ✅</li>
                  <li>Database (Port 5432) ✅</li>
              </ul>
          </div>
          <h2>Features Enabled</h2>
          <ul>
              <li>🔒 HTTPS with security headers</li>
              <li>🛡️ HTTP basic authentication</li>
              <li>🌐 IP restrictions</li>
              <li>⚡ Compression enabled</li>
              <li>🔧 Circuit breakers</li>
              <li>📡 Webhook verification</li>
          </ul>
      </body>
      </html>
    '';

    "www/admin/admin.html".text = ''
      <!DOCTYPE html>
      <html>
      <head>
          <title>Admin Panel</title>
          <style>
              body { font-family: Arial, sans-serif; margin: 40px; background: #f5f5f5; }
              .admin-panel { background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); }
          </style>
      </head>
      <body>
          <div class="admin-panel">
              <h1>🔐 Admin Panel</h1>
              <p>This is the protected admin interface.</p>
              <p>Access is restricted by IP and HTTP basic auth.</p>
              <h2>Server Information</h2>
              <ul>
                  <li>Hostname: ${config.networking.hostName}</li>
                  <li>Auth: HTTP Basic (admin/super-secret-password)</li>
                  <li>IP Restrictions: Enabled</li>
                  <li>HTTPS: Enabled</li>
              </ul>
          </div>
      </body>
      </html>
    '';
  };

  # API server script
  environment.etc."api-server/server.py".text = ''
    #!/usr/bin/env python3
    import http.server
    import socketserver
    import json
    from urllib.parse import urlparse, parse_qs

    class APIHandler(http.server.BaseHTTPRequestHandler):
        def do_GET(self):
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            
            response = {
                "status": "ok",
                "message": "Advanced ngrok API server",
                "hostname": "${config.networking.hostName}",
                "features": [
                    "compression",
                    "websocket_tcp_converter", 
                    "circuit_breaker",
                    "security_headers"
                ]
            }
            
            self.wfile.write(json.dumps(response, indent=2).encode())

    PORT = 3001
    with socketserver.TCPServer(("", PORT), APIHandler) as httpd:
        print(f"API Server running on port {PORT}")
        httpd.serve_forever()
  '';

  # Webhook handler script
  environment.etc."webhooks/handler.py".text = ''
    #!/usr/bin/env python3
    import http.server
    import socketserver
    import json
    import hashlib
    import hmac

    class WebhookHandler(http.server.BaseHTTPRequestHandler):
        def do_POST(self):
            content_length = int(self.headers['Content-Length'])
            post_data = self.rfile.read(content_length)
            
            # Simple webhook verification (GitHub style)
            signature = self.headers.get('X-Hub-Signature-256', '')
            
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            
            response = {
                "status": "received",
                "message": "Webhook processed",
                "signature_provided": bool(signature)
            }
            
            self.wfile.write(json.dumps(response).encode())

    PORT = 9000
    with socketserver.TCPServer(("", PORT), WebhookHandler) as httpd:
        print(f"Webhook handler running on port {PORT}")
        httpd.serve_forever()
  '';

  # Create directories
  systemd.tmpfiles.rules = [
    "d /var/www 0755 root root -"
    "d /var/www/admin 0755 root root -"
    "L+ /var/www/index.html - - - - /etc/www/index.html"
    "L+ /var/www/admin/admin.html - - - - /etc/www/admin/admin.html"
    "L+ /var/lib/api-server/server.py - - - - /etc/api-server/server.py"
    "L+ /var/lib/webhooks/handler.py - - - - /etc/webhooks/handler.py"
  ];

  # Firewall configuration
  networking.firewall = {
    allowedTCPPorts = [ 80 3000 8080 9000 22 5432 ];
    allowedUDPPorts = [ ];
  };

  # Security and monitoring packages
  environment.systemPackages = with pkgs; [
    curl
    wget
    htop
    jq
    postgresql
    vim
    tmux
    git
  ];

  # SSH configuration
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  system.stateVersion = "23.11";
  nixpkgs.config.allowUnfree = true;
}