{ config, pkgs, ... }:

{
  # System configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  networking.hostName = "ngrok-enterprise";
  networking.networkmanager.enable = true;

  # Enterprise-grade ngrok configuration
  services.ngrok = {
    enable = true;
    authToken = "YOUR_NGROK_AUTH_TOKEN_HERE";
    region = "us";
    metadata = "enterprise-production-v1.0";

    tunnels = {
      # Executive dashboard with OIDC
      executive-dashboard = {
        protocol = "https";
        port = 8443;
        hostname = "exec.mycompany.com"; # Custom domain
        
        oidc = {
          issuer_url = "https://auth.mycompany.com";
          client_id = "executive-dashboard";
          client_secret = "exec-oidc-secret-key";
          allow_emails = [
            "ceo@mycompany.com"
            "cfo@mycompany.com"
            "cto@mycompany.com"
          ];
          scopes = [ "openid" "email" "profile" "groups" ];
        };
        
        # Maximum security headers
        response_header_add = {
          "Strict-Transport-Security" = "max-age=31536000; includeSubDomains; preload";
          "X-Frame-Options" = "DENY";
          "X-Content-Type-Options" = "nosniff";
          "X-XSS-Protection" = "1; mode=block";
          "Referrer-Policy" = "strict-origin-when-cross-origin";
          "Content-Security-Policy" = "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'";
        };
        
        # VIP IP restrictions
        ip_restriction_allow_cidrs = [
          "203.0.113.0/24"  # Executive office
          "198.51.100.0/24" # Board room
        ];
        
        # Zero tolerance for errors
        circuit_breaker = 0.05;
      };

      # HR system with mutual TLS
      hr-system = {
        protocol = "https";
        port = 8080;
        hostname = "hr-internal.mycompany.com";
        
        oidc = {
          issuer_url = "https://auth.mycompany.com";
          client_id = "hr-system";
          client_secret = "hr-oidc-secret-key";
          allow_domains = [ "mycompany.com" ];
          scopes = [ "openid" "email" "profile" "hr:read" "hr:write" ];
        };
        
        # Mutual TLS for extra security
        mutual_tls_cas = [ "/etc/ssl/certs/company-ca.crt" ];
        
        # HR-specific headers
        request_header_add = {
          "X-Department" = "HR";
          "X-Compliance-Required" = "true";
        };
        
        response_header_add = {
          "X-Data-Classification" = "Confidential";
          "X-Retention-Policy" = "7-years";
        };
        
        # Strong circuit breaker for sensitive data
        circuit_breaker = 0.1;
      };

      # Finance API with webhook verification
      finance-api = {
        protocol = "https";
        port = 9000;
        hostname = "finance-api.mycompany.com";
        
        oidc = {
          issuer_url = "https://auth.mycompany.com";
          client_id = "finance-api";
          client_secret = "finance-oidc-secret-key";
          allow_emails = [
            "finance@mycompany.com"
            "accounting@mycompany.com"
            "auditor@mycompany.com"
          ];
          scopes = [ "openid" "email" "profile" "finance:read" "finance:write" ];
        };
        
        webhook_verification = {
          provider = "stripe";
          secret = "whsec_finance_webhook_secret";
        };
        
        # Financial compliance headers
        response_header_add = {
          "X-SOX-Compliant" = "true";
          "X-PCI-DSS" = "Level-1";
          "X-Data-Classification" = "Restricted";
        };
        
        # Strict IP restrictions for finance
        ip_restriction_allow_cidrs = [
          "10.10.0.0/16"    # Finance subnet
          "203.0.113.0/24"  # Auditor access
        ];
        
        compression = false; # Disabled for compliance
        inspect = false;     # No logging of financial data
        circuit_breaker = 0.02; # Extremely low tolerance
      };

      # Customer portal with rate limiting
      customer-portal = {
        protocol = "https";
        port = 3000;
        hostname = "portal.mycompany.com";
        
        # Public-facing but protected
        compression = true;
        
        # Customer-focused headers
        response_header_add = {
          "X-Service-Level" = "Premium";
          "Cache-Control" = "public, max-age=300";
          "X-Rate-Limit" = "1000/hour";
        };
        
        # Remove internal headers
        response_header_remove = [
          "X-Powered-By"
          "Server"
          "X-AspNet-Version"
        ];
        
        # Moderate circuit breaker for customer experience
        circuit_breaker = 0.3;
      };

      # Internal tools with basic auth fallback
      internal-tools = {
        protocol = "https";
        port = 8090;
        subdomain = "internal-tools";
        
        # Dual authentication: OIDC primary, basic auth fallback
        oidc = {
          issuer_url = "https://auth.mycompany.com";
          client_id = "internal-tools";
          client_secret = "tools-oidc-secret-key";
          allow_domains = [ "mycompany.com" ];
          scopes = [ "openid" "email" "profile" ];
        };
        
        # Backup authentication
        auth = "admin:emergency-access-password";
        
        # Internal network only
        ip_restriction_allow_cidrs = [
          "10.0.0.0/8"
          "192.168.0.0/16"
        ];
        
        # Development tools headers
        request_header_add = {
          "X-Environment" = "internal";
          "X-Tool-Access" = "true";
        };
      };

      # Monitoring and alerting
      monitoring = {
        protocol = "https";
        port = 9090;
        subdomain = "monitoring";
        
        # DevOps team access
        oidc = {
          issuer_url = "https://auth.mycompany.com";
          client_id = "monitoring";
          client_secret = "monitoring-oidc-secret-key";
          allow_emails = [
            "devops@mycompany.com"
            "sre@mycompany.com"
            "oncall@mycompany.com"
          ];
          scopes = [ "openid" "email" "profile" "monitoring:read" ];
        };
        
        # Monitoring-specific configuration
        compression = true;
        websocket_tcp_converter = true; # For real-time updates
        
        # Ops headers
        response_header_add = {
          "X-Monitoring-System" = "Prometheus";
          "X-Alert-Manager" = "enabled";
        };
        
        circuit_breaker = 0.2;
      };
    };
  };

  # Executive dashboard service
  systemd.services.executive-dashboard = {
    enable = true;
    description = "Executive dashboard";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.python3}/bin/python3 /var/lib/executive/dashboard.py";
      DynamicUser = true;
      StateDirectory = "executive";
      Restart = "always";
      # High security settings
      NoNewPrivileges = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
    };
  };

  # HR system service
  systemd.services.hr-system = {
    enable = true;
    description = "HR management system";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" "postgresql.service" ];
    
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.python3}/bin/python3 /var/lib/hr/system.py";
      DynamicUser = true;
      StateDirectory = "hr";
      Restart = "always";
      # Security hardening
      NoNewPrivileges = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
    };
  };

  # Finance API service
  systemd.services.finance-api = {
    enable = true;
    description = "Finance API server";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" "postgresql.service" ];
    
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.python3}/bin/python3 /var/lib/finance/api.py";
      DynamicUser = true;
      StateDirectory = "finance";
      Restart = "always";
      # Maximum security for financial data
      NoNewPrivileges = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      ProtectKernelTunables = true;
      ProtectControlGroups = true;
      RestrictRealtime = true;
    };
  };

  # PostgreSQL for enterprise data
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_15;
    settings = {
      ssl = "on";
      log_connections = "on";
      log_disconnections = "on";
      log_statement = "all";
    };
    authentication = ''
      hostssl all all 0.0.0.0/0 cert clientcert=verify-full
    '';
  };

  # Enterprise certificates
  security.pki.certificates = [
    # Company CA certificate
    ''
      -----BEGIN CERTIFICATE-----
      # Your company CA certificate here
      -----END CERTIFICATE-----
    ''
  ];

  # Comprehensive monitoring
  services.prometheus = {
    enable = true;
    port = 9090;
    exporters.node.enable = true;
    scrapeConfigs = [
      {
        job_name = "ngrok-services";
        static_configs = [
          { targets = [ "localhost:8443" "localhost:8080" "localhost:9000" ]; }
        ];
      }
    ];
  };

  # Log aggregation
  services.journald.extraConfig = ''
    SystemMaxUse=1G
    ForwardToSyslog=yes
  '';

  # Enterprise security packages
  environment.systemPackages = with pkgs; [
    # Security tools
    nmap
    wireshark-cli
    openssl
    
    # Monitoring
    htop
    iotop
    tcpdump
    
    # Enterprise tools
    postgresql
    curl
    jq
    
    # Compliance
    aide        # File integrity monitoring
    lynis       # Security auditing
  ];

  # Hardened SSH
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      PubkeyAuthentication = true;
      X11Forwarding = false;
      AllowTcpForwarding = "no";
      ClientAliveInterval = 300;
      ClientAliveCountMax = 2;
    };
  };

  # Firewall with strict rules
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 80 443 8080 8443 8090 9000 9090 3000 ];
    extraCommands = ''
      # Rate limiting for SSH
      iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW -m recent --set
      iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW -m recent --update --seconds 60 --hitcount 4 -j DROP
    '';
  };

  # Automated security updates
  system.autoUpgrade = {
    enable = true;
    allowReboot = false;
    channel = "https://nixos.org/channels/nixos-23.11";
  };

  # File integrity monitoring
  services.aide = {
    enable = true;
    config = ''
      database_in = file:/var/lib/aide/aide.db
      database_out = file:/var/lib/aide/aide.db.new
      database_new = file:/var/lib/aide/aide.db.new
      gzip_dbout = yes
      
      # Monitor important directories
      /etc = p+i+n+u+g+s+m+c+md5+sha1
      /bin = p+i+n+u+g+s+m+c+md5+sha1
      /sbin = p+i+n+u+g+s+m+c+md5+sha1
      /usr = p+i+n+u+g+s+m+c+md5+sha1
      /var/lib = p+i+n+u+g+s+m+c+md5+sha1
    '';
  };

  system.stateVersion = "23.11";
  nixpkgs.config.allowUnfree = true;
}