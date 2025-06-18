#!/usr/bin/env bash
set -euo pipefail

# Build VM for testing ngrok service
echo "Building NixOS VM for testing..."

# Since we can't cross-compile easily, let's just verify the configuration builds
echo "Verifying NixOS configuration builds..."
NIXPKGS_ALLOW_UNFREE=1 nix build --impure .#nixosConfigurations.nixgrok-aarch64.config.system.build.toplevel -o nixos-system

echo "NixOS configuration built successfully!"
echo "System derivation: ./nixos-system"

# For actual VM testing, we'll use Docker or alternative approach
echo ""
echo "Note: Cross-compilation VM not available on macOS ARM."
echo "Alternative testing approaches:"
echo "1. Use nixos-rebuild --target-host for real aarch64 Linux machine"
echo "2. Use Docker with NixOS image"
echo "3. Deploy to cloud VM for testing"

# Provide usage instructions
cat << 'EOF'

VM Usage Instructions:

1. Start VM:
   ./scripts/start-vm.sh

2. Login credentials:
   - Username: testuser
   - Password: testpass
   - Root password: nixos

3. Test ngrok service:
   ./scripts/test-ngrok.sh localhost 2222

EOF