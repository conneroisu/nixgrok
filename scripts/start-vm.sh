#!/usr/bin/env bash
set -euo pipefail

# Start the VM using the built NixOS VM
VM_SCRIPT="./nixos-vm/bin/run-nixos-vm"

if [ ! -f "$VM_SCRIPT" ]; then
    echo "VM not built. Please run ./scripts/build-vm.sh first"
    exit 1
fi

echo "Starting NixOS VM..."
echo "VM will start in background with port forwarding:"
echo "  SSH: localhost:2222 -> VM:22"  
echo "  HTTP: localhost:8080 -> VM:8080"
echo ""

# Set VM memory and enable SSH forwarding
export NIX_DISK_IMAGE_MEMORY="2048"
export QEMU_NET_OPTS="hostfwd=tcp::2222-:22,hostfwd=tcp::8080-:8080"

# Start the VM in background
$VM_SCRIPT &
VM_PID=$!
echo $VM_PID > vm.pid

echo "VM started with PID: $VM_PID"
echo "Console log will be in the terminal"
echo ""
echo "Waiting for VM to boot..."
sleep 15

# Wait for SSH to be available
echo "Waiting for SSH service..."
for i in {1..30}; do
    if ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no -p 2222 testuser@localhost true 2>/dev/null; then
        echo "VM is ready!"
        echo "SSH: ssh -p 2222 testuser@localhost (password: testpass)"
        echo "Test web server: curl http://localhost:8080"
        break
    else
        echo "Attempt $i/30: Waiting for SSH..."
        sleep 5
    fi
done

echo ""
echo "To stop the VM: ./scripts/stop-vm.sh"