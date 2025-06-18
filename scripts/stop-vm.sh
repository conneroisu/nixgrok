#!/usr/bin/env bash
set -euo pipefail

# Stop the running VM
PID_FILE="vm.pid"

if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    echo "Stopping VM (PID: $PID)..."
    
    if kill "$PID" 2>/dev/null; then
        echo "VM stopped successfully"
        rm -f "$PID_FILE"
    else
        echo "Failed to stop VM or VM already stopped"
        rm -f "$PID_FILE"
    fi
else
    echo "No PID file found. VM may not be running."
    
    # Try to find and kill any running QEMU processes
    if pgrep -f "qemu-system-aarch64.*nixos.qcow2" > /dev/null; then
        echo "Found running QEMU process, stopping..."
        pkill -f "qemu-system-aarch64.*nixos.qcow2"
        echo "VM stopped"
    else
        echo "No running VM found"
    fi
fi