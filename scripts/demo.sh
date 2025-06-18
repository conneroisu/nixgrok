#!/usr/bin/env bash
set -euo pipefail

# Demo script showing the complete VM testing workflow
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║             NixOS ngrok Service - VM Testing Demo             ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_step() {
    echo -e "${BLUE}▶ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if we're in the right directory
if [ ! -f "flake.nix" ]; then
    print_error "Please run this script from the nixgrok repository root"
    exit 1
fi

echo "This demo will:"
echo "1. Verify the flake configuration"
echo "2. Build an aarch64 Linux VM image"
echo "3. Start the VM with QEMU"
echo "4. Test the ngrok service configuration"
echo "5. Show how to update the auth token"
echo ""
read -p "Continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Demo cancelled."
    exit 0
fi

# Step 1: Verify flake
print_step "Step 1: Verifying flake configuration..."
if NIXPKGS_ALLOW_UNFREE=1 nix flake check --impure &>/dev/null; then
    print_success "Flake configuration is valid"
else
    print_error "Flake check failed"
    echo "Run: NIXPKGS_ALLOW_UNFREE=1 nix flake check --impure"
    exit 1
fi

# Step 2: Enter development environment
print_step "Step 2: Entering development environment..."
if nix develop --command echo "Development shell ready" &>/dev/null; then
    print_success "Development environment available"
else
    print_error "Failed to enter development environment"
    exit 1
fi

# Step 3: Build VM image
print_step "Step 3: Building aarch64 Linux VM image..."
print_warning "This may take several minutes on first build..."
if ./scripts/build-vm.sh; then
    print_success "VM image built successfully"
else
    print_error "VM build failed"
    exit 1
fi

# Step 4: Start VM
print_step "Step 4: Starting VM (this will run in background)..."
if ./scripts/start-vm.sh; then
    print_success "VM started successfully"
    sleep 5
else
    print_error "Failed to start VM"
    exit 1
fi

# Step 5: Test ngrok service
print_step "Step 5: Testing ngrok service in VM..."
if ./scripts/test-ngrok.sh localhost 2222 8080; then
    print_success "Basic VM tests completed"
else
    print_warning "Some tests may have failed (expected without valid auth token)"
fi

# Step 6: Show auth token update process
print_step "Step 6: Auth token update demonstration..."
echo ""
echo "To update the ngrok auth token with a real token:"
echo "  ./scripts/update-auth-token.sh localhost YOUR_NGROK_TOKEN 2222"
echo ""
echo "To get your auth token:"
echo "1. Visit: https://ngrok.com/"
echo "2. Sign up/login"
echo "3. Go to dashboard and copy your auth token"
echo ""

# Step 7: Alternative UTM setup
print_step "Step 7: UTM setup alternative..."
echo "For GUI-based VM management on macOS:"
echo "  ./scripts/utm-setup.sh"
echo ""

# Cleanup option
echo ""
print_step "Demo completed!"
echo ""
echo "VM is still running in the background."
echo "Useful commands:"
echo "  - SSH to VM: ssh -p 2222 testuser@localhost (password: testpass)"
echo "  - Test web server: curl http://localhost:8080"
echo "  - View VM logs: tail -f vm.log"
echo "  - Stop VM: ./scripts/stop-vm.sh"
echo ""

read -p "Stop the VM now? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_step "Stopping VM..."
    ./scripts/stop-vm.sh
    print_success "VM stopped"
else
    print_warning "VM is still running. Use './scripts/stop-vm.sh' to stop it."
fi

echo ""
print_success "Demo completed successfully!"
echo ""
echo "Next steps:"
echo "1. Get your ngrok auth token from https://ngrok.com"
echo "2. Update the token: ./scripts/update-auth-token.sh localhost YOUR_TOKEN 2222"
echo "3. Test real tunneling functionality"
echo ""
echo "For production deployment:"
echo "1. Copy modules/ngrok.nix to your NixOS configuration"
echo "2. Add the service configuration to your configuration.nix"
echo "3. Set your real auth token in the configuration"
echo "4. Run: sudo nixos-rebuild switch"