#!/usr/bin/env bash
set -euo pipefail

# Test ngrok service in the VM
VM_IP="${1:-localhost}"
SSH_PORT="${2:-2222}"
HTTP_PORT="${3:-8080}"

echo "Testing ngrok service on VM at $VM_IP"
echo "SSH Port: $SSH_PORT, HTTP Port: $HTTP_PORT"
echo ""

# Function to run commands on the VM
run_vm_command() {
    ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no -p "$SSH_PORT" testuser@"$VM_IP" "$1"
}

# Function to run commands as root on the VM
run_vm_root_command() {
    ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no -p "$SSH_PORT" testuser@"$VM_IP" "sudo $1"
}

echo "1. Testing VM connectivity..."
if ! run_vm_command "echo 'VM connection successful'"; then
    echo "❌ Failed to connect to VM"
    echo "Make sure VM is running and SSH is available"
    exit 1
fi
echo "✅ VM connectivity OK"

echo ""
echo "2. Checking systemd services..."
echo "Checking ngrok services status:"
run_vm_root_command "systemctl status 'ngrok-*' --no-pager" || true

echo ""
echo "3. Checking if test web server is running..."
if run_vm_command "curl -s http://localhost:8080" > /dev/null; then
    echo "✅ Test web server is running"
else
    echo "❌ Test web server is not responding"
    echo "Starting test web server..."
    run_vm_root_command "systemctl start test-webserver"
    sleep 3
fi

echo ""
echo "4. Testing ngrok configuration..."
echo "Checking ngrok config file:"
run_vm_root_command "cat /etc/ngrok/ngrok.yml" || echo "Config file not found"

echo ""
echo "5. Manual ngrok test (this will fail without valid auth token)..."
echo "Attempting to start ngrok manually:"
run_vm_command "timeout 10 ngrok --config=/etc/ngrok/ngrok.yml start --all" || echo "Expected failure - need valid auth token"

echo ""
echo "6. Checking ngrok service logs..."
echo "Recent ngrok service logs:"
run_vm_root_command "journalctl -u 'ngrok-*' --no-pager -n 20" || true

echo ""
echo "=== Test Summary ==="
echo "✅ VM is accessible via SSH"
echo "🔍 Check service logs above for ngrok status"
echo "⚠️  To fully test ngrok, provide a valid auth token"
echo ""
echo "To update auth token in VM:"
echo "1. SSH into VM: ssh -p $SSH_PORT testuser@$VM_IP"
echo "2. Edit config: sudo nano /etc/nixos/configuration.nix"
echo "3. Update services.ngrok.authToken = \"your_token_here\";"
echo "4. Rebuild: sudo nixos-rebuild switch"
echo ""
echo "Or use the update script:"
echo "./scripts/update-auth-token.sh <vm_ip> <your_token>"