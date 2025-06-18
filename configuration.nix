{ config, pkgs, ... }:

{
  imports = [];

  # Boot loader configuration (adjust for your system)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # File systems (basic example - adjust for your actual setup)
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };

  # Network configuration
  networking.hostName = "nixgrok";
  networking.networkmanager.enable = true;

  # Enable SSH for remote management
  services.openssh.enable = true;

  # System packages
  environment.systemPackages = with pkgs; [
    curl
    wget
    git
    vim
  ];

  # Example ngrok service configuration
  services.ngrok = {
    enable = true;
    # authToken will need to be set when you provide the API key
    authToken = "YOUR_NGROK_AUTH_TOKEN_HERE";
    
    # Example tunnel configurations
    tunnels = {
      web = {
        protocol = "http";
        port = 8080;
        # subdomain = "myapp"; # Uncomment if you have a paid plan
      };
      
      ssh = {
        protocol = "tcp";
        port = 22;
      };
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  system.stateVersion = "23.11";
}