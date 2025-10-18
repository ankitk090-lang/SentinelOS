#!/bin/bash

# SentinelOS Main Installation Script
# This script orchestrates the complete installation of SentinelOS

set -e  # Exit on any error

echo "========================================="
echo "   SentinelOS Installation Script"
echo "========================================="
echo

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root (sudo)"
    exit 1
fi

# Save the original directory
ORIGINAL_DIR="$(pwd)"

# Change to the script directory
cd "$(dirname "$0")"

# Display system information
echo "System Information:"
echo "  Hostname: $(hostname)"
echo "  OS: $(lsb_release -d | cut -f2)"
echo "  Kernel: $(uname -r)"
echo "  Architecture: $(uname -m)"
echo

# Check if running in a VM
echo "Checking environment..."
if systemd-detect-virt --quiet; then
    echo "  Environment: Virtual Machine"
    echo
    echo "💡 Note: You are installing SentinelOS in a VM."
    echo "  This is great for testing! For production deployment,"
    echo "  use the recommended hardware (Raspberry Pi 5 or x86 mini PC)."
    echo
else
    echo "  Environment: Physical Machine"
    echo
fi

# Confirm installation
echo "This script will install SentinelOS on this system."
echo "The following components will be installed:"
echo "  1. Base system and security hardening"
echo "  2. Network security layer (firewall, IDS/IPS)"
echo "  3. AI threat detection engine"
echo "  4. Security monitoring daemons"
echo "  5. Telemetry dashboard"
echo "  6. Secure update mechanisms"
echo
read -p "Do you want to proceed? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Installation cancelled."
    exit 1
fi

echo
echo "Starting SentinelOS installation..."
echo

# 1. Base System Setup
echo "Step 1: Setting up base system..."
./setup_base.sh
echo "Base system setup complete."
echo

# 2. Network Layer Setup
echo "Step 2: Setting up network security layer..."
./setup_network.sh
echo "Network security layer setup complete."
echo

# 3. AI Layer Setup
echo "Step 3: Setting up AI threat detection engine..."
./setup_ai.sh
echo "AI threat detection engine setup complete."
echo

# 4. Security Layer Setup
echo "Step 4: Setting up security monitoring..."
./setup_security.sh
echo "Security monitoring setup complete."
echo

# 5. Telemetry Layer Setup
echo "Step 5: Setting up telemetry dashboard..."
./setup_telemetry.sh
echo "Telemetry dashboard setup complete."
echo

# 6. Updates Layer Setup
echo "Step 6: Setting up secure update mechanisms..."
./setup_updates.sh
echo "Secure update mechanisms setup complete."
echo

# Return to original directory
cd "$ORIGINAL_DIR"

# Enable all services
echo "Enabling system services..."
systemctl enable sentinel-ai
systemctl enable sentinel-security
systemctl enable sentinel-telemetry
systemctl enable sentinel-updates.timer

echo
echo "========================================="
echo "   SentinelOS Installation Complete!"
echo "========================================="
echo
echo "Next steps:"
echo "1. Reboot the system: sudo reboot"
echo "2. After reboot, start the telemetry dashboard:"
echo "   sudo systemctl start sentinel-telemetry"
echo "3. Access the dashboard at http://<device-ip>:8000/api/dashboard"
echo "4. Configure network interfaces for your environment"
echo "5. Customize security policies and AI models"
echo
echo "Important files and directories:"
echo "  /opt/sentinel/     - Main SentinelOS directory"
echo "  /etc/nftables.conf - Firewall configuration"
echo "  /etc/suricata/     - IDS/IPS configuration"
echo "  /opt/sentinel/ai/  - AI threat detection engine"
echo "  /var/log/sentinel/ - SentinelOS log files"
echo
echo "For more information, see the documentation in /opt/sentinel/docs/"
echo