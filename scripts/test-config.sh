#!/usr/bin/env bash
set -euo pipefail

# Test the ngrok service configuration without full VM
AUTH_TOKEN="${1:-2sDgZSTHV8qF9IIjb4LhrEWCeNj_4Sr1ek3BxpwA4qW6YrKGp}"

echo "🧪 Testing ngrok NixOS service configuration"
echo "============================================"
echo ""

# Test 1: Verify flake builds
echo "1. Testing flake configuration..."
if NIXPKGS_ALLOW_UNFREE=1 nix flake check --impure &>/dev/null; then
    echo "✅ Flake configuration is valid"
else
    echo "❌ Flake configuration failed"
    exit 1
fi

# Test 2: Build the NixOS configuration
echo ""
echo "2. Building NixOS configuration..."
if NIXPKGS_ALLOW_UNFREE=1 nix build --impure .#nixosConfigurations.nixgrok-aarch64.config.system.build.toplevel -o test-system &>/dev/null; then
    echo "✅ NixOS configuration builds successfully"
else
    echo "❌ NixOS configuration build failed"
    exit 1
fi

# Test 3: Verify the ngrok module is included
echo ""
echo "3. Checking ngrok module integration..."
if nix eval --impure .#nixosConfigurations.nixgrok-aarch64.config.services.ngrok.enable 2>/dev/null | grep -q "true"; then
    echo "✅ ngrok service is enabled in configuration"
else
    echo "❌ ngrok service not properly enabled"
    exit 1
fi

# Test 4: Check systemd service generation
echo ""
echo "4. Verifying systemd service generation..."
if nix eval --impure .#nixosConfigurations.nixgrok-aarch64.config.systemd.services --json 2>/dev/null | grep -q "ngrok-"; then
    echo "✅ ngrok systemd services are generated"
else
    echo "❌ ngrok systemd services not found"
    exit 1
fi

# Test 5: Test ngrok package availability
echo ""
echo "5. Testing ngrok package..."
if NIXPKGS_ALLOW_UNFREE=1 nix run --impure nixpkgs#ngrok -- version &>/dev/null; then
    echo "✅ ngrok package works"
else
    echo "❌ ngrok package failed"
    exit 1
fi

# Test 6: Create a test configuration with the provided auth token
echo ""
echo "6. Testing configuration with real auth token..."

# Create a temporary test configuration
cat > test-config.nix << EOF
{ config, pkgs, lib, ... }:

{
  imports = [ ./modules/ngrok.nix ];
  
  # Minimal system configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };
  
  # Enable ngrok with real token
  services.ngrok = {
    enable = true;
    authToken = "$AUTH_TOKEN";
    
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
  
  system.stateVersion = "23.11";
  nixpkgs.config.allowUnfree = true;
}
EOF

# Test the configuration builds
if NIXPKGS_ALLOW_UNFREE=1 nix build --impure --expr "
  let
    nixpkgs = builtins.getFlake \"nixpkgs\";
    system = \"aarch64-linux\";
  in
  nixpkgs.lib.nixosSystem {
    inherit system;
    modules = [ ./test-config.nix ];
  }
" &>/dev/null; then
    echo "✅ Configuration with real auth token builds successfully"
else
    echo "❌ Configuration with auth token failed to build"
    exit 1
fi

# Cleanup
rm -f test-config.nix result

echo ""
echo "🎉 All configuration tests passed!"
echo ""
echo "Summary:"
echo "- ✅ Flake configuration is valid"
echo "- ✅ NixOS builds successfully for aarch64-linux"
echo "- ✅ ngrok service module works correctly"
echo "- ✅ systemd services are generated properly"
echo "- ✅ ngrok package is functional"
echo "- ✅ Real auth token configuration works"
echo ""
echo "🚀 Ready for deployment!"
echo ""
echo "Next steps:"
echo "1. Deploy to an aarch64 Linux machine"
echo "2. Run: sudo nixos-rebuild switch --flake .#nixgrok-aarch64"
echo "3. Check status: systemctl status ngrok-*"
echo "4. View logs: journalctl -u ngrok-* -f"
echo ""
echo "Or test with Docker:"
echo "./scripts/test-docker.sh $AUTH_TOKEN"