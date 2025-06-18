# Basic ngrok Example

This example shows the simplest possible ngrok setup: exposing a web server to the internet.

## Features

- Simple HTTP tunnel on port 8080
- Basic Python web server
- Minimal configuration

## Setup

1. **Update auth token**:
   Edit `configuration.nix` and replace `YOUR_NGROK_AUTH_TOKEN_HERE` with your actual token.

2. **Build and deploy**:
   ```bash
   sudo nixos-rebuild switch --flake .#web-server
   ```

3. **Check status**:
   ```bash
   systemctl status ngrok-web
   systemctl status simple-web
   ```

4. **View tunnel URL**:
   ```bash
   journalctl -u ngrok-web -f
   ```

## What it does

- Starts a Python HTTP server on port 8080
- Serves a simple HTML page from `/var/www/`
- Creates an ngrok tunnel exposing the server to the internet
- You'll get a public URL like `https://abc123.ngrok-free.app`

## Testing

Visit the tunnel URL in your browser to see the test page, or use curl:

```bash
curl https://your-tunnel-url.ngrok-free.app
```

## Next Steps

See the `advanced` example for more features like authentication, custom domains, and security options.