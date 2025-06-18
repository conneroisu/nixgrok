{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.ngrok;
in
{
  options.services.ngrok = {
    enable = mkEnableOption "ngrok tunnel service";

    package = mkOption {
      type = types.package;
      default = pkgs.ngrok;
      description = "The ngrok package to use.";
    };

    authToken = mkOption {
      type = types.str;
      description = "ngrok authentication token";
    };

    region = mkOption {
      type = types.enum [ "us" "eu" "au" "ap" "sa" "jp" "in" ];
      default = "us";
      description = "ngrok region (us, eu, au, ap, sa, jp, in)";
    };

    metadata = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Opaque user-defined metadata for the tunnel session";
    };

    tunnels = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          protocol = mkOption {
            type = types.enum [ "http" "https" "tcp" "tls" ];
            default = "http";
            description = "Protocol to tunnel";
          };

          port = mkOption {
            type = types.port;
            description = "Local port to tunnel";
          };

          hostname = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Custom hostname for the tunnel (overrides subdomain)";
          };

          subdomain = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Custom subdomain (requires paid plan)";
          };

          auth = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "HTTP basic authentication (user:password)";
          };

          oauth = mkOption {
            type = types.nullOr (types.submodule {
              options = {
                provider = mkOption {
                  type = types.enum [ "google" "github" "microsoft" "facebook" ];
                  description = "OAuth provider";
                };
                allow_emails = mkOption {
                  type = types.nullOr (types.listOf types.str);
                  default = null;
                  description = "List of allowed email addresses";
                };
                allow_domains = mkOption {
                  type = types.nullOr (types.listOf types.str);
                  default = null;
                  description = "List of allowed email domains";
                };
                scopes = mkOption {
                  type = types.nullOr (types.listOf types.str);
                  default = null;
                  description = "OAuth scopes to request";
                };
              };
            });
            default = null;
            description = "OAuth configuration for the tunnel";
          };

          oidc = mkOption {
            type = types.nullOr (types.submodule {
              options = {
                issuer_url = mkOption {
                  type = types.str;
                  description = "OIDC issuer URL";
                };
                client_id = mkOption {
                  type = types.str;
                  description = "OIDC client ID";
                };
                client_secret = mkOption {
                  type = types.str;
                  description = "OIDC client secret";
                };
                allow_emails = mkOption {
                  type = types.nullOr (types.listOf types.str);
                  default = null;
                  description = "List of allowed email addresses";
                };
                allow_domains = mkOption {
                  type = types.nullOr (types.listOf types.str);
                  default = null;
                  description = "List of allowed email domains";
                };
                scopes = mkOption {
                  type = types.nullOr (types.listOf types.str);
                  default = null;
                  description = "OIDC scopes to request";
                };
              };
            });
            default = null;
            description = "OIDC configuration for the tunnel";
          };

          webhook_verification = mkOption {
            type = types.nullOr (types.submodule {
              options = {
                provider = mkOption {
                  type = types.enum [ "slack" "sns" "stripe" "github" "twilio" "shopify" "zoom" "svix" ];
                  description = "Webhook verification provider";
                };
                secret = mkOption {
                  type = types.str;
                  description = "Webhook verification secret";
                };
              };
            });
            default = null;
            description = "Webhook verification configuration";
          };

          mutual_tls_cas = mkOption {
            type = types.nullOr (types.listOf types.path);
            default = null;
            description = "PEM TLS certificate authority to verify client certificates";
          };

          compression = mkOption {
            type = types.bool;
            default = false;
            description = "Enable gzip compression for HTTP responses";
          };

          websocket_tcp_converter = mkOption {
            type = types.bool;
            default = false;
            description = "Enable websocket TCP converter";
          };

          circuit_breaker = mkOption {
            type = types.nullOr types.float;
            default = null;
            description = "Reject requests when 5XX responses exceed this ratio";
          };

          request_header_add = mkOption {
            type = types.attrsOf types.str;
            default = {};
            description = "Headers to add to requests";
          };

          request_header_remove = mkOption {
            type = types.listOf types.str;
            default = [];
            description = "Headers to remove from requests";
          };

          response_header_add = mkOption {
            type = types.attrsOf types.str;
            default = {};
            description = "Headers to add to responses";
          };

          response_header_remove = mkOption {
            type = types.listOf types.str;
            default = [];
            description = "Headers to remove from responses";
          };

          ip_restriction_allow_cidrs = mkOption {
            type = types.nullOr (types.listOf types.str);
            default = null;
            description = "List of allowed CIDR blocks";
          };

          ip_restriction_deny_cidrs = mkOption {
            type = types.nullOr (types.listOf types.str);
            default = null;
            description = "List of denied CIDR blocks";
          };

          inspect = mkOption {
            type = types.bool;
            default = true;
            description = "Enable/disable request inspection";
          };

          bind_tls = mkOption {
            type = types.enum [ "true" "false" "both" ];
            default = "true";
            description = "Bind an HTTPS or HTTP endpoint or both";
          };

          crt = mkOption {
            type = types.nullOr types.path;
            default = null;
            description = "PEM TLS certificate for TLS tunnels";
          };

          key = mkOption {
            type = types.nullOr types.path;
            default = null;
            description = "PEM TLS private key for TLS tunnels";
          };

          remote_addr = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Bind the remote TCP port on the given address";
          };

          extraArgs = mkOption {
            type = types.listOf types.str;
            default = [];
            description = "Extra arguments to pass to ngrok";
          };
        };
      });
      default = {};
      description = "Named tunnels to create";
    };

    configFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Path to ngrok configuration file";
    };

    user = mkOption {
      type = types.str;
      default = "ngrok";
      description = "User to run ngrok as";
    };

    group = mkOption {
      type = types.str;
      default = "ngrok";
      description = "Group to run ngrok as";
    };
  };

  config = mkIf cfg.enable {
    users.users.${cfg.user} = {
      isSystemUser = true;
      group = cfg.group;
      home = "/var/lib/ngrok";
      createHome = true;
    };

    users.groups.${cfg.group} = {};

    environment.etc."ngrok/ngrok.yml" = mkIf (cfg.configFile == null) {
      text = let
        tunnelConfig = name: tunnel: ''
          ${name}:
            proto: ${tunnel.protocol}
            addr: ${toString tunnel.port}
            ${optionalString (tunnel.hostname != null) "hostname: ${tunnel.hostname}"}
            ${optionalString (tunnel.subdomain != null) "subdomain: ${tunnel.subdomain}"}
            ${optionalString (tunnel.auth != null) "auth: ${tunnel.auth}"}
            ${optionalString (tunnel.oauth != null) ''
            oauth:
              provider: ${tunnel.oauth.provider}
              ${optionalString (tunnel.oauth.allow_emails != null) "allow_emails: [${concatStringsSep ", " tunnel.oauth.allow_emails}]"}
              ${optionalString (tunnel.oauth.allow_domains != null) "allow_domains: [${concatStringsSep ", " tunnel.oauth.allow_domains}]"}
              ${optionalString (tunnel.oauth.scopes != null) "scopes: [${concatStringsSep ", " tunnel.oauth.scopes}]"}
            ''}
            ${optionalString (tunnel.oidc != null) ''
            oidc:
              issuer_url: ${tunnel.oidc.issuer_url}
              client_id: ${tunnel.oidc.client_id}
              client_secret: ${tunnel.oidc.client_secret}
              ${optionalString (tunnel.oidc.allow_emails != null) "allow_emails: [${concatStringsSep ", " tunnel.oidc.allow_emails}]"}
              ${optionalString (tunnel.oidc.allow_domains != null) "allow_domains: [${concatStringsSep ", " tunnel.oidc.allow_domains}]"}
              ${optionalString (tunnel.oidc.scopes != null) "scopes: [${concatStringsSep ", " tunnel.oidc.scopes}]"}
            ''}
            ${optionalString (tunnel.webhook_verification != null) ''
            webhook_verification:
              provider: ${tunnel.webhook_verification.provider}
              secret: ${tunnel.webhook_verification.secret}
            ''}
            ${optionalString (tunnel.mutual_tls_cas != null) "mutual_tls_cas: [${concatStringsSep ", " (map toString tunnel.mutual_tls_cas)}]"}
            ${optionalString tunnel.compression "compression: true"}
            ${optionalString tunnel.websocket_tcp_converter "websocket_tcp_converter: true"}
            ${optionalString (tunnel.circuit_breaker != null) "circuit_breaker: ${toString tunnel.circuit_breaker}"}
            ${optionalString (tunnel.request_header_add != {}) ''
            request_header:
              add:
                ${concatStringsSep "\n    " (mapAttrsToList (k: v: "${k}: ${v}") tunnel.request_header_add)}
            ''}
            ${optionalString (tunnel.request_header_remove != []) ''
            request_header:
              remove: [${concatStringsSep ", " tunnel.request_header_remove}]
            ''}
            ${optionalString (tunnel.response_header_add != {}) ''
            response_header:
              add:
                ${concatStringsSep "\n    " (mapAttrsToList (k: v: "${k}: ${v}") tunnel.response_header_add)}
            ''}
            ${optionalString (tunnel.response_header_remove != []) ''
            response_header:
              remove: [${concatStringsSep ", " tunnel.response_header_remove}]
            ''}
            ${optionalString (tunnel.ip_restriction_allow_cidrs != null) "ip_restriction:\n  allow_cidrs: [${concatStringsSep ", " tunnel.ip_restriction_allow_cidrs}]"}
            ${optionalString (tunnel.ip_restriction_deny_cidrs != null) "ip_restriction:\n  deny_cidrs: [${concatStringsSep ", " tunnel.ip_restriction_deny_cidrs}]"}
            ${optionalString (!tunnel.inspect) "inspect: false"}
            ${optionalString (tunnel.bind_tls != "true") "bind_tls: ${tunnel.bind_tls}"}
            ${optionalString (tunnel.crt != null) "crt: ${toString tunnel.crt}"}
            ${optionalString (tunnel.key != null) "key: ${toString tunnel.key}"}
            ${optionalString (tunnel.remote_addr != null) "remote_addr: ${tunnel.remote_addr}"}
        '';
      in ''
        version: "2"
        authtoken: ${cfg.authToken}
        region: ${cfg.region}
        ${optionalString (cfg.metadata != null) "metadata: ${cfg.metadata}"}
        ${optionalString (cfg.tunnels != {}) ''
        tunnels:
        ${concatStringsSep "\n" (mapAttrsToList tunnelConfig cfg.tunnels)}
        ''}
      '';
      mode = "0600";
      user = cfg.user;
      group = cfg.group;
    };

    systemd.services = mkMerge [
      # Service for each named tunnel
      (mapAttrs' (name: tunnel:
        nameValuePair "ngrok-${name}" {
          description = "ngrok tunnel: ${name}";
          after = [ "network.target" ];
          wantedBy = [ "multi-user.target" ];
          
          serviceConfig = {
            Type = "simple";
            User = cfg.user;
            Group = cfg.group;
            Restart = "on-failure";
            RestartSec = "5s";
            WorkingDirectory = "/var/lib/ngrok";
            
            ExecStart = let
              configArg = if cfg.configFile != null 
                         then "--config=${cfg.configFile}"
                         else "--config=/etc/ngrok/ngrok.yml";
              extraArgs = concatStringsSep " " tunnel.extraArgs;
            in "${cfg.package}/bin/ngrok start ${configArg} ${name} ${extraArgs}";
          };
        }
      ) cfg.tunnels)
      
      # Default service when no named tunnels are configured
      (mkIf (cfg.tunnels == {}) {
        ngrok = {
          description = "ngrok tunnel service";
          after = [ "network.target" ];
          wantedBy = [ "multi-user.target" ];
          
          serviceConfig = {
            Type = "simple";
            User = cfg.user;
            Group = cfg.group;
            Restart = "on-failure";
            RestartSec = "5s";
            WorkingDirectory = "/var/lib/ngrok";
            
            ExecStart = let
              configArg = if cfg.configFile != null 
                         then "--config=${cfg.configFile}"
                         else "--config=/etc/ngrok/ngrok.yml";
            in "${cfg.package}/bin/ngrok start --all ${configArg}";
          };
        };
      })
    ];

    # Install ngrok package system-wide
    environment.systemPackages = [ cfg.package ];
  };
}