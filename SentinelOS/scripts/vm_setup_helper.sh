#!/bin/bash

# SentinelOS VM Setup Helper Script
# This script helps set up SentinelOS in a VM environment

echo "========================================="
echo "   SentinelOS VM Setup Helper"
echo "========================================="
echo

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "Warning: This helper script is designed for macOS."
    echo "You may be running it on a different operating system."
    echo
fi

# Check for virtualization software
echo "Checking for virtualization software..."
echo

utm_installed=false
parallels_installed=false
vmware_installed=false

# Check for UTM
if command -v utm &> /dev/null; then
    echo "✅ UTM is installed"
    utm_installed=true
else
    if [ -d "/Applications/UTM.app" ]; then
        echo "✅ UTM is installed"
        utm_installed=true
    else
        echo "❌ UTM is not installed"
    fi
fi

# Check for Parallels
if command -v prlctl &> /dev/null; then
    echo "✅ Parallels Desktop is installed"
    parallels_installed=true
else
    if [ -d "/Applications/Parallels Desktop.app" ]; then
        echo "✅ Parallels Desktop is installed"
        parallels_installed=true
    else
        echo "❌ Parallels Desktop is not installed"
    fi
fi

# Check for VMware Fusion
if [ -d "/Applications/VMware Fusion.app" ]; then
    echo "✅ VMware Fusion is installed"
    vmware_installed=true
else
    echo "❌ VMware Fusion is not installed"
fi

echo

# Recommend virtualization software based on Mac type
if [[ $(uname -m) == "arm64" ]]; then
    echo "💡 Recommendation for Apple Silicon Mac:"
    if $utm_installed; then
        echo "   Continue with UTM (already installed) - it's optimized for Apple Silicon"
    else
        echo "   Install UTM - it's free and optimized for Apple Silicon"
        echo "   Download from: https://mac.getutm.app/"
    fi
else
    echo "💡 Recommendation for Intel Mac:"
    if $parallels_installed; then
        echo "   Continue with Parallels Desktop (already installed)"
    elif $vmware_installed; then
        echo "   Continue with VMware Fusion (already installed)"
    else
        echo "   Install either Parallels Desktop or VMware Fusion"
    fi
fi

echo

# Check system resources
echo "Checking system resources..."
echo

# Get total RAM in GB
total_ram=$(system_profiler SPHardwareDataType | grep "Memory:" | awk '{print $2}')
echo "Total RAM: ${total_ram}GB"

# Check available disk space
available_space=$(df -g / | tail -1 | awk '{print $4}')
echo "Available disk space: ${available_space}GB"

echo

# Resource recommendations
if [ "$total_ram" -lt 16 ]; then
    echo "⚠️  Warning: Recommended RAM for VM is 16GB, you have ${total_ram}GB"
    echo "   Consider closing other applications when running the VM"
fi

if [ "$available_space" -lt 50 ]; then
    echo "⚠️  Warning: Recommended disk space for VM is 50GB, you have ${available_space}GB"
fi

echo

# Provide setup instructions
echo "Next steps:"
echo "1. Install your preferred virtualization software (if not already installed)"
echo "2. Create a new Debian VM with these specifications:"
echo "   - CPU: 4 cores"
echo "   - RAM: 8GB (minimum), 16GB (recommended)"
echo "   - Storage: 50GB"
echo "3. Install Debian in the VM"
echo "4. After Debian installation, run these commands in the VM:"
echo
echo "   # Update system"
echo "   sudo apt update && sudo apt upgrade -y"
echo
echo "   # Install git"
echo "   sudo apt install git -y"
echo
echo "   # Clone SentinelOS repository"
echo "   git clone https://github.com/your-org/sentinelos.git"
echo "   cd sentinelos"
echo
echo "   # Make scripts executable"
echo "   chmod +x scripts/*.sh"
echo
echo "   # Run installation"
echo "   sudo ./scripts/install_sentinelos.sh"
echo
echo "5. Follow the installation prompts"
echo "6. After installation, start services:"
echo "   sudo systemctl start sentinel-ai sentinel-security sentinel-telemetry"
echo
echo "7. Access the dashboard at http://<VM-IP>:8000/api/dashboard"
echo

echo "For detailed instructions, see: docs/vm_setup.md"
echo