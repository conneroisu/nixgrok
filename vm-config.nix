{ config, pkgs, lib, ... }:

{
  # VM-specific configuration for testing
  
  # Enable QEMU guest agent
  services.qemuGuest.enable = true;
  
  # Faster boot for testing
  boot.initrd.availableKernelModules = [ "virtio_pci" "virtio_scsi" "ahci" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  # Simplified filesystem for VM
  fileSystems."/" = lib.mkForce {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = lib.mkForce {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };

  # VM-friendly networking
  networking.useDHCP = lib.mkForce true;
  networking.networkmanager.enable = lib.mkForce false;
  networking.firewall.enable = false; # Disable for testing
  
  # Enable SSH for remote testing
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = true;
    };
  };

  # Set root password for testing (INSECURE - only for testing!)
  users.users.root.password = "nixos";
  
  # Create a test user
  users.users.testuser = {
    isNormalUser = true;
    password = "testpass";
    extraGroups = [ "wheel" "networkmanager" ];
  };

  # Enable wheel group for sudo
  security.sudo.wheelNeedsPassword = false;

  # Install testing tools
  environment.systemPackages = with pkgs; [
    curl
    wget
    netcat
    htop
    jq
    systemd
    # Simple web server for testing ngrok
    python3
  ];

  # Override ngrok service for testing with a dummy token initially
  services.ngrok = lib.mkForce {
    enable = true;
    authToken = "test_token_replace_me";
    
    tunnels = {
      test-web = {
        protocol = "http";
        port = 8080;
      };
      
      test-ssh = {
        protocol = "tcp";
        port = 22;
      };
    };
  };

  # Create a simple test web server service
  systemd.services.test-webserver = {
    enable = true;
    description = "Simple test web server";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    
    serviceConfig = {
      Type = "simple";
      User = "testuser";
      ExecStart = "${pkgs.python3}/bin/python3 -m http.server 8080";
      WorkingDirectory = "/tmp";
      Restart = "always";
    };
  };

  # Disable unnecessary services for faster boot
  systemd.services.systemd-udev-settle.enable = false;
  systemd.services.NetworkManager-wait-online.enable = false;

  # VM-specific kernel parameters
  boot.kernelParams = [
    "console=ttyS0,115200"
    "console=tty1"
    "boot.shell_on_fail"
  ];

  # Enable serial console
  systemd.services."serial-getty@ttyS0".enable = true;
}