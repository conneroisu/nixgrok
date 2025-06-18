#!/usr/bin/env bash
set -euo pipefail

# Test ngrok service using Docker (works on macOS ARM)
AUTH_TOKEN="${1:-}"

if [ -z "$AUTH_TOKEN" ]; then
    echo "Usage: $0 <ngrok_auth_token>"
    echo "Example: $0 2sDgZSTHV8qF9IIjb4LhrEWCeNj_4Sr1ek3BxpwA4qW6YrKGp"
    exit 1
fi

echo "Testing ngrok service with Docker..."
echo "Auth token: ${AUTH_TOKEN:0:10}..."
echo ""

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo "❌ Docker not found. Please install Docker Desktop for macOS"
    exit 1
fi

# Create a temporary directory for testing
TEST_DIR=$(mktemp -d)
echo "Test directory: $TEST_DIR"

# Create a simple Dockerfile that installs Nix and tests our service
cat > "$TEST_DIR/Dockerfile" << 'EOF'
FROM nixos/nix:2.20.6

# Install necessary tools
RUN nix-env -iA nixpkgs.git nixpkgs.curl nixpkgs.systemd

# Set up the environment
WORKDIR /test
COPY . .

# Make scripts executable
RUN chmod +x scripts/*.sh

# Install the ngrok package
RUN nix-env -iA nixpkgs.ngrok

# Expose ports for testing
EXPOSE 4040 8080

# Default command
CMD ["/bin/bash"]
EOF

# Create a test script for inside the container
cat > "$TEST_DIR/test-inside-container.sh" << EOF
#!/bin/bash
set -euo pipefail

echo "=== Testing ngrok service inside container ==="
echo ""

# Test ngrok installation
echo "1. Testing ngrok installation..."
if command -v ngrok &> /dev/null; then
    echo "✅ ngrok is installed"
    ngrok version
else
    echo "❌ ngrok not found"
    exit 1
fi

echo ""
echo "2. Testing ngrok authentication..."

# Create ngrok config
mkdir -p ~/.config/ngrok
cat > ~/.config/ngrok/ngrok.yml << EOL
version: "2"
authtoken: $AUTH_TOKEN
EOL

# Test auth
if ngrok config check; then
    echo "✅ ngrok configuration is valid"
else
    echo "❌ ngrok configuration is invalid"
    exit 1
fi

echo ""
echo "3. Starting a test web server..."
# Start a simple HTTP server in background
python3 -m http.server 8080 &
SERVER_PID=\$!
sleep 2

echo ""
echo "4. Testing ngrok tunnel..."
# Start ngrok tunnel in background
ngrok http 8080 --log stdout > ngrok.log &
NGROK_PID=\$!

# Wait for ngrok to start
sleep 5

# Check if ngrok is running and get tunnel URL
if curl -s http://localhost:4040/api/tunnels > tunnels.json; then
    echo "✅ ngrok is running"
    cat tunnels.json | python3 -c "
import json, sys
data = json.load(sys.stdin)
if data['tunnels']:
    print('🌐 Tunnel URL:', data['tunnels'][0]['public_url'])
    print('📝 Local URL: http://localhost:8080')
else:
    print('❌ No tunnels found')
    "
else
    echo "❌ ngrok API not responding"
    cat ngrok.log
fi

# Cleanup
kill \$NGROK_PID \$SERVER_PID 2>/dev/null || true

echo ""
echo "=== Test completed ==="
EOF

chmod +x "$TEST_DIR/test-inside-container.sh"

# Copy our files to the test directory
cp -r . "$TEST_DIR/"

echo "Building Docker image..."
docker build -t nixgrok-test "$TEST_DIR"

echo ""
echo "Running tests in Docker container..."
docker run --rm -it \
    -p 4040:4040 \
    -p 8080:8080 \
    -v "$TEST_DIR/test-inside-container.sh:/test-inside-container.sh:ro" \
    nixgrok-test \
    /test-inside-container.sh

echo ""
echo "Docker test completed!"

# Cleanup
rm -rf "$TEST_DIR"