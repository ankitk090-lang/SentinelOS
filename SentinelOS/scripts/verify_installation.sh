#!/bin/bash

# SentinelOS Installation Verification Script
# This script verifies that all components were installed correctly

echo "========================================="
echo "   SentinelOS Installation Verification"
echo "========================================="
echo

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root (sudo) for complete verification"
    echo
fi

echo "System Information:"
echo "  Hostname: $(hostname)"
echo "  OS: $(lsb_release -d 2>/dev/null || echo "Unknown")"
echo "  Kernel: $(uname -r)"
echo "  Architecture: $(uname -m)"
echo

# Check directory structure
echo "Checking directory structure..."
if [ -d "/opt/sentinel" ]; then
    echo "✅ /opt/sentinel directory exists"
    ls -la /opt/sentinel/
else
    echo "❌ /opt/sentinel directory missing"
fi
echo

# Check service files
echo "Checking service files..."
SERVICES=("sentinel-ai.service" "sentinel-security.service" "sentinel-telemetry.service" "sentinel-updates.timer" "zeek.service" "suricata.service")

for service in "${SERVICES[@]}"; do
    if [ -f "/etc/systemd/system/$service" ]; then
        echo "✅ $service exists"
    elif systemctl list-unit-files | grep -q "$service"; then
        echo "✅ $service available (system installed)"
    else
        echo "⚠️  $service not found"
    fi
done
echo

# Check if services are enabled
echo "Checking if services are enabled..."
for service in "${SERVICES[@]}"; do
    # Remove .service extension for checking status
    service_name=${service%.service}
    service_name=${service_name%.timer}
    
    if systemctl is-enabled "$service" >/dev/null 2>&1; then
        echo "✅ $service is enabled"
    elif systemctl list-unit-files | grep -q "$service"; then
        echo "ℹ️  $service is installed but not enabled"
    else
        echo "⚠️  $service is not installed"
    fi
done
echo

# Check Python environment
echo "Checking Python environment..."
if command -v python3 >/dev/null 2>&1; then
    echo "✅ Python3 is installed: $(python3 --version)"
else
    echo "❌ Python3 is not installed"
fi

if [ -d "/opt/sentinel/ai/venv" ]; then
    echo "✅ AI virtual environment exists"
else
    echo "⚠️  AI virtual environment missing"
fi
echo

# Check required packages
echo "Checking required packages..."
PACKAGES=("nftables" "suricata" "docker" "aide" "fail2ban" "clamav")

for package in "${PACKAGES[@]}"; do
    if command -v "$package" >/dev/null 2>&1; then
        echo "✅ $package is installed"
    else
        echo "⚠️  $package is not installed"
    fi
done

# Special check for Zeek/Bro
if command -v zeek >/dev/null 2>&1; then
    echo "✅ Zeek is installed"
elif command -v bro >/dev/null 2>&1; then
    echo "✅ Bro (Zeek predecessor) is installed"
else
    echo "⚠️  Zeek/Bro is not installed"
fi
echo

# Check network configuration
echo "Checking network configuration..."
if [ -f "/etc/nftables.conf" ]; then
    echo "✅ nftables configuration exists"
else
    echo "⚠️  nftables configuration missing"
fi

if [ -f "/etc/suricata/suricata.yaml" ]; then
    echo "✅ Suricata configuration exists"
else
    echo "⚠️  Suricata configuration missing"
fi
echo

# Summary
echo "========================================="
echo "   Verification Complete"
echo "========================================="
echo
echo "If you're missing services like sentinel-ai, try:"
echo "1. Check if the service files were created in /etc/systemd/system/"
echo "2. Run: sudo systemctl daemon-reload"
echo "3. Run: sudo systemctl enable sentinel-ai"
echo "4. Run: sudo systemctl start sentinel-ai"
echo
echo "To check service status:"
echo "  systemctl status sentinel-ai"
echo "  systemctl status sentinel-security"
echo "  systemctl status sentinel-telemetry"
echo