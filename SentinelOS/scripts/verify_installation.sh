#!/bin/bash

# SentinelOS Installation Verification Script
# This script verifies that all components have been installed correctly

echo "========================================="
echo "   SentinelOS Installation Verification"
echo "========================================="
echo

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Warning: Not running as root. Some checks may fail."
    echo
fi

# Initialize counters
total_checks=0
passed_checks=0

# Function to run a check
run_check() {
    local description=$1
    local command=$2
    total_checks=$((total_checks + 1))
    
    echo -n "Checking $description... "
    
    if eval "$command" > /dev/null 2>&1; then
        echo "PASSED"
        passed_checks=$((passed_checks + 1))
        return 0
    else
        echo "FAILED"
        return 1
    fi
}

# 1. Directory Structure Verification
echo "1. Directory Structure Verification"
echo "----------------------------------"
run_check "main sentinel directory exists" "test -d /opt/sentinel"
run_check "kernel directory exists" "test -d /opt/sentinel/kernel"
run_check "network directory exists" "test -d /opt/sentinel/network"
run_check "ai directory exists" "test -d /opt/sentinel/ai"
run_check "security directory exists" "test -d /opt/sentinel/security"
run_check "telemetry directory exists" "test -d /opt/sentinel/telemetry"
run_check "updates directory exists" "test -d /opt/sentinel/updates"
run_check "scripts directory exists" "test -d /opt/sentinel/../scripts"
run_check "config directory exists" "test -d /opt/sentinel/../config"
echo

# 2. Script Verification
echo "2. Script Verification"
echo "----------------------"
run_check "base setup script exists" "test -f /opt/sentinel/../scripts/setup_base.sh"
run_check "network setup script exists" "test -f /opt/sentinel/../scripts/setup_network.sh"
run_check "ai setup script exists" "test -f /opt/sentinel/../scripts/setup_ai.sh"
run_check "security setup script exists" "test -f /opt/sentinel/../scripts/setup_security.sh"
run_check "telemetry setup script exists" "test -f /opt/sentinel/../scripts/setup_telemetry.sh"
run_check "updates setup script exists" "test -f /opt/sentinel/../scripts/setup_updates.sh"
run_check "main install script exists" "test -f /opt/sentinel/../scripts/install_sentinelos.sh"
run_check "scripts are executable" "test -x /opt/sentinel/../scripts/setup_base.sh"
echo

# 3. Service Verification
echo "3. Service Verification"
echo "-----------------------"
run_check "sentinel-ai service file exists" "test -f /etc/systemd/system/sentinel-ai.service"
run_check "sentinel-security service file exists" "test -f /etc/systemd/system/sentinel-security.service"
run_check "sentinel-telemetry service file exists" "test -f /etc/systemd/system/sentinel-telemetry.service"
run_check "sentinel-updates service file exists" "test -f /etc/systemd/system/sentinel-updates.service"
echo

# 4. Package Verification
echo "4. Package Verification"
echo "-----------------------"
run_check "nftables is installed" "which nftables"
run_check "iptables is installed" "which iptables"
run_check "suricata is installed" "which suricata"
run_check "zeek is installed" "which zeek"
run_check "aide is installed" "which aide"
run_check "fail2ban is installed" "which fail2ban-client"
run_check "clamav is installed" "which clamd"
run_check "python3 is installed" "which python3"
run_check "docker is installed" "which docker"
echo

# 5. Configuration Verification
echo "5. Configuration Verification"
echo "-----------------------------"
run_check "main config file exists" "test -f /opt/sentinel/../config/sentinelos.conf"
run_check "nftables config exists" "test -f /etc/nftables.conf"
run_check "suricata config exists" "test -f /etc/suricata/suricata.yaml"
run_check "aide config exists" "test -f /etc/aide/aide.conf"
echo

# 6. AI Component Verification
echo "6. AI Component Verification"
echo "----------------------------"
run_check "ai engine script exists" "test -f /opt/sentinel/ai/engine/threat_detector.py"
run_check "ai monitor script exists" "test -f /opt/sentinel/ai/monitor.py"
run_check "python dependencies installed" "python3 -c 'import numpy, onnxruntime'"
echo

# 7. Telemetry Component Verification
echo "7. Telemetry Component Verification"
echo "----------------------------------"
run_check "telemetry api exists" "test -f /opt/sentinel/telemetry/api/main.py"
run_check "fastapi is installed" "python3 -c 'import fastapi'"
run_check "uvicorn is installed" "python3 -c 'import uvicorn'"
echo

# Summary
echo "========================================="
echo "           Verification Summary"
echo "========================================="
echo "Total checks performed: $total_checks"
echo "Checks passed: $passed_checks"
echo "Checks failed: $((total_checks - passed_checks))"
echo

if [ $passed_checks -eq $total_checks ]; then
    echo "✅ All checks passed! Installation appears to be successful."
    echo
    echo "Next steps:"
    echo "1. Reboot the system"
    echo "2. Start the services:"
    echo "   sudo systemctl start sentinel-ai sentinel-security sentinel-telemetry"
    echo "3. Access the dashboard at http://<device-ip>:8000/api/dashboard"
elif [ $passed_checks -gt $((total_checks * 3/4)) ]; then
    echo "⚠️  Most checks passed. Installation is mostly successful."
    echo "   Some components may need attention."
else
    echo "❌ Many checks failed. Please review the installation."
fi

echo
echo "For detailed information, check the logs in /var/log/sentinel/"
echo