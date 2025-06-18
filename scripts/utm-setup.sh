#!/usr/bin/env bash
set -euo pipefail

# UTM Configuration Helper for macOS
echo "UTM Setup Helper for ngrok Testing"
echo "=================================="
echo ""

# Check if UTM is installed
if ! command -v utm &> /dev/null && [ ! -d "/Applications/UTM.app" ]; then
    echo "UTM is not installed. Please install it first:"
    echo "1. Download from: https://mac.getutm.app/"
    echo "2. Or install via Homebrew: brew install --cask utm"
    echo ""
    exit 1
fi

# Check if VM image exists
if [ ! -f "./vm-utm/nixos.raw" ]; then
    echo "UTM VM image not found. Building it now..."
    ./scripts/build-vm.sh
    echo ""
fi

echo "UTM VM Configuration:"
echo "1. Open UTM application"
echo "2. Click '+' to create a new VM"
echo "3. Select 'Virtualize' (not Emulate)"
echo "4. Choose 'Linux'"
echo "5. Configure as follows:"
echo ""
echo "   Boot Image: (Skip - we'll use existing disk)"
echo "   Hardware:"
echo "     - Architecture: ARM64"
echo "     - Memory: 2048 MB (or more)"
echo "     - CPU Cores: 2 (or more)"
echo "   Storage:"
echo "     - Import existing disk"
echo "     - Select: $(pwd)/vm-utm/nixos.raw"
echo "   Network:"
echo "     - Enable network"
echo "     - Mode: Shared Network"
echo "   Display:"
echo "     - Console Only (or VGA for GUI)"
echo ""
echo "6. Save the VM as 'nixgrok-test'"
echo "7. Start the VM"
echo ""
echo "Login credentials:"
echo "  - Username: testuser"
echo "  - Password: testpass"
echo "  - Root password: nixos"
echo ""

# Create a UTM configuration file template
cat > utm-config.json << 'EOF'
{
  "name": "nixgrok-test",
  "description": "NixOS VM for testing ngrok service",
  "architecture": "aarch64",
  "memory": 2048,
  "cpus": 2,
  "boot": {
    "type": "disk"
  },
  "drives": [
    {
      "type": "disk",
      "path": "./vm-utm/nixos.raw",
      "interface": "virtio"
    }
  ],
  "network": {
    "enabled": true,
    "mode": "shared"
  },
  "display": {
    "type": "console"
  }
}
EOF

echo "UTM configuration template created: utm-config.json"
echo ""
echo "After setting up the VM in UTM:"
echo "1. Start the VM"
echo "2. Note the VM's IP address (run 'ip addr' in the VM)"
echo "3. Test ngrok: ./scripts/test-ngrok.sh <vm-ip> 22 8080"
echo "4. Update auth token: ./scripts/update-auth-token.sh <vm-ip> <your-token>"
echo ""
echo "For advanced users: You can also use QEMU directly:"
echo "./scripts/start-vm.sh"