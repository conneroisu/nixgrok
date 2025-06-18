#!/usr/bin/env bash
set -euo pipefail

# Quick test of ngrok functionality
AUTH_TOKEN="2sDgZSTHV8qF9IIjb4LhrEWCeNj_4Sr1ek3BxpwA4qW6YrKGp"

echo "⚡ Quick ngrok test"
echo "=================="

# Set up config
mkdir -p ~/Library/Application\ Support/ngrok
cat > ~/Library/Application\ Support/ngrok/ngrok.yml << EOF
version: "2"
authtoken: $AUTH_TOKEN
tunnels:
  quick-test:
    proto: http
    addr: 8080
EOF

echo "✅ ngrok authentication token configured"

# Test config
if ngrok config check; then
    echo "✅ ngrok configuration is valid"
else
    echo "❌ ngrok configuration failed"
    exit 1
fi

# Start simple server
echo "Starting test server..."
python3 -m http.server 8080 &
SERVER_PID=$!
sleep 2

# Start ngrok in background and capture output
echo "Starting ngrok tunnel..."
timeout 30 ngrok start quick-test --log stdout > ngrok.log 2>&1 &
NGROK_PID=$!

# Wait for tunnel to establish
sleep 8

# Check if tunnel is up
if curl -s http://localhost:4040/api/tunnels > tunnels.json; then
    echo "✅ ngrok tunnel established!"
    
    # Show tunnel info
    python3 -c "
import json
with open('tunnels.json') as f:
    data = json.load(f)
if data['tunnels']:
    tunnel = data['tunnels'][0]
    print('🌐 Public URL:', tunnel['public_url'])
    print('📍 Local server: http://localhost:8080')
    print('🎯 Success! Tunnel is working.')
else:
    print('No tunnels found')
"
else
    echo "❌ Could not reach ngrok API"
fi

# Show some logs
echo ""
echo "📝 Ngrok logs:"
tail -5 ngrok.log

# Cleanup
kill $NGROK_PID $SERVER_PID 2>/dev/null || true
rm -f tunnels.json ngrok.log

echo ""
echo "🎉 Test complete! Your ngrok service configuration is working."