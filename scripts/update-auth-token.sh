#!/usr/bin/env bash
set -euo pipefail

# Update ngrok auth token in the VM
VM_IP="${1:-localhost}"
AUTH_TOKEN="${2:-}"
SSH_PORT="${3:-2222}"

if [ -z "$AUTH_TOKEN" ]; then
    echo "Usage: $0 <vm_ip> <auth_token> [ssh_port]"
    echo "Example: $0 localhost 2abc123def456 2222"
    exit 1
fi

echo "Updating ngrok auth token in VM at $VM_IP"
echo "Using SSH port: $SSH_PORT"
echo ""

# Function to run commands on the VM
run_vm_command() {
    ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no -p "$SSH_PORT" testuser@"$VM_IP" "$1"
}

# Test connectivity
echo "Testing VM connectivity..."
if ! run_vm_command "echo 'Connected to VM'"; then
    echo "❌ Failed to connect to VM"
    exit 1
fi
echo "✅ VM connectivity OK"

# Create a temporary configuration file
echo "Creating temporary config file..."
cat > /tmp/vm-config-update.nix << EOF
{ config, pkgs, lib, ... }:

{
  # Import the original configuration
  imports = [ /etc/nixos/configuration.nix ];

  # Override the ngrok auth token
  services.ngrok = lib.mkForce {
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
}
EOF

# Copy the config to the VM
echo "Copying updated configuration to VM..."
scp -o StrictHostKeyChecking=no -P "$SSH_PORT" /tmp/vm-config-update.nix testuser@"$VM_IP":/tmp/

# Apply the configuration
echo "Applying configuration in VM..."
run_vm_command "sudo cp /tmp/vm-config-update.nix /etc/nixos/configuration.nix"

echo "Rebuilding NixOS configuration..."
run_vm_command "sudo nixos-rebuild switch"

echo ""
echo "✅ Auth token updated successfully!"
echo "🔄 Services are restarting..."

# Wait for services to restart
sleep 10

echo ""
echo "Checking ngrok service status..."
run_vm_command "sudo systemctl status 'ngrok-*' --no-pager" || true

echo ""
echo "Testing ngrok functionality..."
run_vm_command "timeout 15 sudo journalctl -u 'ngrok-*' --no-pager -f" || true

echo ""
echo "=== Update Complete ==="
echo "Your ngrok services should now be running with the valid auth token."
echo "Check the logs above for any tunnel URLs that were created."
echo ""
echo "To test the web tunnel:"
echo "1. The tunnel URL will be shown in the logs above"
echo "2. Visit that URL in your browser"
echo "3. You should see the test web server content"

# Clean up
rm -f /tmp/vm-config-update.nix