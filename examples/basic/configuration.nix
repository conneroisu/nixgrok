{ config, pkgs, ... }:

{
  # Basic system configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  networking.hostName = "ngrok-basic";
  networking.networkmanager.enable = true;

  # Basic ngrok service - expose a simple web server
  services.ngrok = {
    enable = true;
    authToken = "YOUR_NGROK_AUTH_TOKEN_HERE";
    
    tunnels = {
      web = {
        protocol = "http";
        port = 8080;
      };
    };
  };

  # Simple web server for testing
  systemd.services.simple-web = {
    enable = true;
    description = "Simple web server for ngrok testing";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.python3}/bin/python3 -m http.server 8080";
      WorkingDirectory = "/var/www";
      DynamicUser = true;
      Restart = "always";
    };
  };

  # Create a simple index page
  environment.etc."www/index.html".text = ''
    <!DOCTYPE html>
    <html>
    <head>
        <title>ngrok Test Server</title>
    </head>
    <body>
        <h1>Hello from ngrok!</h1>
        <p>This is a basic web server tunneled through ngrok.</p>
        <p>Hostname: ${config.networking.hostName}</p>
    </body>
    </html>
  '';

  # Create the web directory
  systemd.tmpfiles.rules = [
    "d /var/www 0755 root root -"
    "L+ /var/www/index.html - - - - /etc/www/index.html"
  ];

  # Allow HTTP traffic
  networking.firewall.allowedTCPPorts = [ 8080 ];

  # Basic packages
  environment.systemPackages = with pkgs; [
    curl
    wget
    vim
  ];

  system.stateVersion = "23.11";
  nixpkgs.config.allowUnfree = true;
}