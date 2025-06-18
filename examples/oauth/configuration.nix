{ config, pkgs, ... }:

{
  # System configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  networking.hostName = "ngrok-oauth";
  networking.networkmanager.enable = true;

  # OAuth-protected ngrok tunnels
  services.ngrok = {
    enable = true;
    authToken = "YOUR_NGROK_AUTH_TOKEN_HERE";
    region = "us";
    metadata = "oauth-protected-services";

    tunnels = {
      # Google OAuth protected admin panel
      admin-google = {
        protocol = "https";
        port = 8080;
        subdomain = "admin-google";
        
        oauth = {
          provider = "google";
          allow_domains = [ "mycompany.com" "trusted-partner.com" ];
          scopes = [ "openid" "email" "profile" ];
        };
        
        compression = true;
        
        # Add user info headers
        request_header_add = {
          "X-Auth-Provider" = "google";
          "X-Protected-Resource" = "admin";
        };
      };

      # GitHub OAuth protected development tools
      dev-github = {
        protocol = "https";
        port = 3000;
        subdomain = "dev-github";
        
        oauth = {
          provider = "github";
          allow_emails = [
            "developer@mycompany.com"
            "admin@mycompany.com"
            "devops@mycompany.com"
          ];
          scopes = [ "user:email" "read:org" ];
        };
        
        # Development-specific headers
        request_header_add = {
          "X-Environment" = "development";
          "X-Auth-Provider" = "github";
        };
        
        compression = true;
        websocket_tcp_converter = true; # For live reload
      };

      # Microsoft OAuth for enterprise tools
      enterprise-microsoft = {
        protocol = "https";
        port = 8090;
        subdomain = "enterprise-ms";
        
        oauth = {
          provider = "microsoft";
          allow_domains = [ "mycompany.com" ];
          scopes = [ "openid" "email" "profile" "User.Read" ];
        };
        
        # Security headers for enterprise
        response_header_add = {
          "X-Frame-Options" = "DENY";
          "X-Content-Type-Options" = "nosniff";
          "Strict-Transport-Security" = "max-age=31536000";
          "Referrer-Policy" = "strict-origin-when-cross-origin";
        };
        
        # Enterprise security
        circuit_breaker = 0.1; # Very low tolerance for errors
      };

      # Facebook OAuth for marketing tools
      marketing-facebook = {
        protocol = "https";
        port = 4000;
        subdomain = "marketing-fb";
        
        oauth = {
          provider = "facebook";
          allow_emails = [
            "marketing@mycompany.com"
            "social@mycompany.com"
          ];
          scopes = [ "email" "public_profile" ];
        };
        
        # Marketing-specific configuration
        compression = true;
        inspect = true; # Enable for analytics
        
        request_header_add = {
          "X-Department" = "marketing";
          "X-Auth-Provider" = "facebook";
        };
      };

      # Public API with optional OAuth
      public-api = {
        protocol = "https";
        port = 8000;
        subdomain = "public-api";
        
        # No OAuth - public access
        compression = true;
        
        # Rate limiting headers
        response_header_add = {
          "X-RateLimit-Limit" = "1000";
          "X-RateLimit-Window" = "3600";
          "Access-Control-Allow-Origin" = "*";
        };
        
        # Circuit breaker for public API
        circuit_breaker = 0.5;
      };
    };
  };

  # Admin panel service
  systemd.services.admin-panel = {
    enable = true;
    description = "OAuth-protected admin panel";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.python3}/bin/python3 /var/lib/admin-panel/server.py";
      DynamicUser = true;
      StateDirectory = "admin-panel";
      Restart = "always";
    };
  };

  # Development server
  systemd.services.dev-server = {
    enable = true;
    description = "Development tools server";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.python3}/bin/python3 /var/lib/dev-server/server.py";
      DynamicUser = true;
      StateDirectory = "dev-server";
      Restart = "always";
    };
  };

  # Enterprise tools server
  systemd.services.enterprise-server = {
    enable = true;
    description = "Enterprise tools server";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.python3}/bin/python3 /var/lib/enterprise-server/server.py";
      DynamicUser = true;
      StateDirectory = "enterprise-server";
      Restart = "always";
    };
  };

  # Marketing tools server
  systemd.services.marketing-server = {
    enable = true;
    description = "Marketing tools server";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.python3}/bin/python3 /var/lib/marketing-server/server.py";
      DynamicUser = true;
      StateDirectory = "marketing-server";
      Restart = "always";
    };
  };

  # Public API server
  systemd.services.public-api = {
    enable = true;
    description = "Public API server";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.python3}/bin/python3 /var/lib/public-api/server.py";
      DynamicUser = true;
      StateDirectory = "public-api";
      Restart = "always";
    };
  };

  # Server scripts
  environment.etc = {
    "admin-panel/server.py".text = ''
      #!/usr/bin/env python3
      import http.server
      import socketserver
      import json

      class AdminHandler(http.server.BaseHTTPRequestHandler):
          def do_GET(self):
              self.send_response(200)
              self.send_header('Content-type', 'text/html')
              self.end_headers()
              
              # Extract user info from ngrok headers
              user_email = self.headers.get('ngrok-auth-user-email', 'Unknown')
              user_name = self.headers.get('ngrok-auth-user-name', 'Unknown')
              
              html = f"""
              <!DOCTYPE html>
              <html>
              <head>
                  <title>Admin Panel - Google OAuth</title>
                  <style>
                      body {{ font-family: Arial, sans-serif; margin: 40px; }}
                      .user-info {{ background: #e8f5e8; padding: 20px; border-radius: 5px; }}
                      .protected {{ background: #fff3cd; padding: 15px; border-radius: 5px; margin: 20px 0; }}
                  </style>
              </head>
              <body>
                  <h1>🔐 Admin Panel (Google OAuth)</h1>
                  <div class="user-info">
                      <h2>Authenticated User</h2>
                      <p><strong>Email:</strong> {user_email}</p>
                      <p><strong>Name:</strong> {user_name}</p>
                      <p><strong>Provider:</strong> Google</p>
                  </div>
                  <div class="protected">
                      <h2>Protected Resources</h2>
                      <ul>
                          <li>✅ User Management</li>
                          <li>✅ System Configuration</li>
                          <li>✅ Analytics Dashboard</li>
                          <li>✅ Security Logs</li>
                      </ul>
                  </div>
                  <p>This page is protected by Google OAuth and only accessible to users from allowed domains.</p>
              </body>
              </html>
              """
              
              self.wfile.write(html.encode())

      PORT = 8080
      with socketserver.TCPServer(("", PORT), AdminHandler) as httpd:
          print(f"Admin panel running on port {PORT}")
          httpd.serve_forever()
    '';

    "dev-server/server.py".text = ''
      #!/usr/bin/env python3
      import http.server
      import socketserver
      import json

      class DevHandler(http.server.BaseHTTPRequestHandler):
          def do_GET(self):
              self.send_response(200)
              self.send_header('Content-type', 'text/html')
              self.end_headers()
              
              user_email = self.headers.get('ngrok-auth-user-email', 'Unknown')
              user_login = self.headers.get('ngrok-auth-user-login', 'Unknown')
              
              html = f"""
              <!DOCTYPE html>
              <html>
              <head>
                  <title>Development Tools - GitHub OAuth</title>
                  <style>
                      body {{ font-family: 'Courier New', monospace; margin: 40px; background: #1e1e1e; color: #fff; }}
                      .dev-info {{ background: #2d2d2d; padding: 20px; border-radius: 5px; }}
                      .tools {{ background: #0d1117; padding: 15px; border-radius: 5px; margin: 20px 0; }}
                  </style>
              </head>
              <body>
                  <h1>🔧 Development Tools (GitHub OAuth)</h1>
                  <div class="dev-info">
                      <h2>Developer Info</h2>
                      <p><strong>Email:</strong> {user_email}</p>
                      <p><strong>GitHub:</strong> {user_login}</p>
                      <p><strong>Environment:</strong> Development</p>
                  </div>
                  <div class="tools">
                      <h2>Available Tools</h2>
                      <ul>
                          <li>🔍 Code Search</li>
                          <li>📊 Performance Metrics</li>
                          <li>🐛 Debug Console</li>
                          <li>📝 API Documentation</li>
                          <li>🔄 Live Reload (WebSocket enabled)</li>
                      </ul>
                  </div>
                  <p>Access granted via GitHub OAuth to authorized developers only.</p>
              </body>
              </html>
              """
              
              self.wfile.write(html.encode())

      PORT = 3000
      with socketserver.TCPServer(("", PORT), DevHandler) as httpd:
          print(f"Dev server running on port {PORT}")
          httpd.serve_forever()
    '';

    "enterprise-server/server.py".text = ''
      #!/usr/bin/env python3
      import http.server
      import socketserver
      import json

      class EnterpriseHandler(http.server.BaseHTTPRequestHandler):
          def do_GET(self):
              self.send_response(200)
              self.send_header('Content-type', 'text/html')
              self.end_headers()
              
              user_email = self.headers.get('ngrok-auth-user-email', 'Unknown')
              user_name = self.headers.get('ngrok-auth-user-name', 'Unknown')
              
              html = f"""
              <!DOCTYPE html>
              <html>
              <head>
                  <title>Enterprise Tools - Microsoft OAuth</title>
                  <style>
                      body {{ font-family: 'Segoe UI', Arial, sans-serif; margin: 40px; }}
                      .enterprise-header {{ background: #0078d4; color: white; padding: 20px; border-radius: 5px; }}
                      .user-card {{ background: #f3f2f1; padding: 20px; border-radius: 5px; margin: 20px 0; }}
                      .tools-grid {{ display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px; }}
                      .tool-card {{ background: white; padding: 20px; border: 1px solid #ddd; border-radius: 5px; }}
                  </style>
              </head>
              <body>
                  <div class="enterprise-header">
                      <h1>🏢 Enterprise Tools (Microsoft OAuth)</h1>
                  </div>
                  <div class="user-card">
                      <h2>User Information</h2>
                      <p><strong>Email:</strong> {user_email}</p>
                      <p><strong>Name:</strong> {user_name}</p>
                      <p><strong>Domain:</strong> mycompany.com</p>
                      <p><strong>Provider:</strong> Microsoft Azure AD</p>
                  </div>
                  <div class="tools-grid">
                      <div class="tool-card">
                          <h3>📈 Analytics</h3>
                          <p>Business intelligence and reporting tools</p>
                      </div>
                      <div class="tool-card">
                          <h3>👥 Directory</h3>
                          <p>Employee directory and org chart</p>
                      </div>
                      <div class="tool-card">
                          <h3>📧 Communication</h3>
                          <p>Internal messaging and announcements</p>
                      </div>
                      <div class="tool-card">
                          <h3>🔒 Compliance</h3>
                          <p>Security and compliance monitoring</p>
                      </div>
                  </div>
                  <p><em>Enterprise-grade security with Microsoft authentication</em></p>
              </body>
              </html>
              """
              
              self.wfile.write(html.encode())

      PORT = 8090
      with socketserver.TCPServer(("", PORT), EnterpriseHandler) as httpd:
          print(f"Enterprise server running on port {PORT}")
          httpd.serve_forever()
    '';

    "marketing-server/server.py".text = ''
      #!/usr/bin/env python3
      import http.server
      import socketserver
      import json

      class MarketingHandler(http.server.BaseHTTPRequestHandler):
          def do_GET(self):
              self.send_response(200)
              self.send_header('Content-type', 'text/html')
              self.end_headers()
              
              user_email = self.headers.get('ngrok-auth-user-email', 'Unknown')
              user_name = self.headers.get('ngrok-auth-user-name', 'Unknown')
              
              html = f"""
              <!DOCTYPE html>
              <html>
              <head>
                  <title>Marketing Tools - Facebook OAuth</title>
                  <style>
                      body {{ font-family: Arial, sans-serif; margin: 40px; }}
                      .fb-header {{ background: #1877f2; color: white; padding: 20px; border-radius: 5px; }}
                      .user-info {{ background: #e3f2fd; padding: 20px; border-radius: 5px; margin: 20px 0; }}
                      .campaigns {{ background: #f5f5f5; padding: 20px; border-radius: 5px; }}
                  </style>
              </head>
              <body>
                  <div class="fb-header">
                      <h1>📱 Marketing Tools (Facebook OAuth)</h1>
                  </div>
                  <div class="user-info">
                      <h2>Marketing Team Member</h2>
                      <p><strong>Email:</strong> {user_email}</p>
                      <p><strong>Name:</strong> {user_name}</p>
                      <p><strong>Department:</strong> Marketing</p>
                      <p><strong>Provider:</strong> Facebook</p>
                  </div>
                  <div class="campaigns">
                      <h2>Available Tools</h2>
                      <ul>
                          <li>📊 Campaign Analytics</li>
                          <li>🎯 Audience Insights</li>
                          <li>📝 Content Scheduler</li>
                          <li>💰 Ad Budget Tracker</li>
                          <li>📈 Social Media Metrics</li>
                      </ul>
                  </div>
                  <p>Marketing tools accessible to authorized team members via Facebook OAuth.</p>
              </body>
              </html>
              """
              
              self.wfile.write(html.encode())

      PORT = 4000
      with socketserver.TCPServer(("", PORT), MarketingHandler) as httpd:
          print(f"Marketing server running on port {PORT}")
          httpd.serve_forever()
    '';

    "public-api/server.py".text = ''
      #!/usr/bin/env python3
      import http.server
      import socketserver
      import json

      class PublicAPIHandler(http.server.BaseHTTPRequestHandler):
          def do_GET(self):
              self.send_response(200)
              self.send_header('Content-type', 'application/json')
              self.send_header('Access-Control-Allow-Origin', '*')
              self.end_headers()
              
              if self.path == '/':
                  response = {
                      "api": "Public API",
                      "version": "1.0",
                      "description": "Open API endpoint (no OAuth required)",
                      "endpoints": [
                          "/health",
                          "/status", 
                          "/info",
                          "/metrics"
                      ],
                      "rate_limit": "1000 requests/hour",
                      "authentication": "none"
                  }
              elif self.path == '/health':
                  response = {"status": "healthy", "timestamp": "2025-06-18T12:00:00Z"}
              elif self.path == '/status':
                  response = {"service": "running", "uptime": "99.9%"}
              elif self.path == '/info':
                  response = {"hostname": "${config.networking.hostName}", "oauth_protected": False}
              elif self.path == '/metrics':
                  response = {"requests": 12345, "errors": 0, "uptime": "30d"}
              else:
                  response = {"error": "Not found"}
              
              self.wfile.write(json.dumps(response, indent=2).encode())

      PORT = 8000
      with socketserver.TCPServer(("", PORT), PublicAPIHandler) as httpd:
          print(f"Public API running on port {PORT}")
          httpd.serve_forever()
    '';
  };

  # Create symlinks for server scripts
  systemd.tmpfiles.rules = [
    "L+ /var/lib/admin-panel/server.py - - - - /etc/admin-panel/server.py"
    "L+ /var/lib/dev-server/server.py - - - - /etc/dev-server/server.py"
    "L+ /var/lib/enterprise-server/server.py - - - - /etc/enterprise-server/server.py"
    "L+ /var/lib/marketing-server/server.py - - - - /etc/marketing-server/server.py"
    "L+ /var/lib/public-api/server.py - - - - /etc/public-api/server.py"
  ];

  # Firewall configuration
  networking.firewall.allowedTCPPorts = [ 8080 3000 8090 4000 8000 ];

  # Development and monitoring packages
  environment.systemPackages = with pkgs; [
    curl
    wget
    jq
    htop
    vim
  ];

  system.stateVersion = "23.11";
  nixpkgs.config.allowUnfree = true;
}