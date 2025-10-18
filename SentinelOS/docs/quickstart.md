# SentinelOS Quick Start Guide

## Welcome to SentinelOS

SentinelOS is a security-first, AI-hardened embedded Linux designed for offline AI-driven threat detection and network protection. This guide will help you get started quickly with your new security appliance.

## Testing in a Virtual Machine (Recommended First Step)

Before deploying to physical hardware, you can test SentinelOS in a virtual machine on your MacBook:

1. Follow the [VM Setup Guide](vm_setup.md) to create a Debian VM
2. Install SentinelOS in the VM using the installation instructions below
3. Test all functionality in the safe VM environment
4. Deploy to physical hardware after successful testing

## Initial Setup

### 1. Hardware Connection

1. Connect your SentinelOS device to your network:
   - Use the primary Ethernet port for WAN connection
   - Use the secondary port for LAN connection (if available)
   - Connect power (27W USB-C or PoE)

2. Connect a monitor and keyboard for initial setup (if needed)

### 2. First Boot

1. Power on the device
2. Wait for the system to boot (approximately 60-90 seconds)
3. Log in with the default credentials:
   - Username: `sentinel`
   - Password: `Sentinel123!`

### 3. Network Configuration

Configure your network interfaces:

```bash
# Edit netplan configuration
sudo nano /etc/netplan/01-netcfg.yaml

# Apply configuration
sudo netplan apply
```

Example configuration:
```yaml
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: true
      # Or static IP:
      # addresses: [192.168.1.100/24]
      # gateway4: 192.168.1.1
      # nameservers:
      #   addresses: [8.8.8.8, 1.1.1.1]
    eth1:
      addresses: [10.0.0.1/24]
```

## Accessing the Dashboard

1. Find your device's IP address:
   ```bash
   ip addr show
   ```

2. Open a web browser and navigate to:
   ```
   http://<device-ip>:8000/api/dashboard
   ```

3. Log in with the default credentials:
   - Username: `sentinel`
   - Password: `Sentinel123!`

## Core Features Overview

### Multi-Layer Firewall

SentinelOS provides four layers of firewall protection:

1. **Packet-level filtering** via nftables
2. **Deep Packet Inspection** using Suricata
3. **AI-Driven Behavior Analysis** for unknown patterns
4. **Application Whitelisting** and Device Fingerprinting

Check current firewall rules:
```bash
sudo nft list ruleset
```

### AI Threat Detection

The AI engine monitors network traffic for:
- Malware patterns
- AI-generated traffic
- Data exfiltration attempts
- Suspicious compression patterns

View AI detection logs:
```bash
tail -f /var/log/sentinel/ai/threat_detector.log
```

### Security Monitoring

Continuous monitoring of:
- File integrity (AIDE)
- Network anomalies
- Unauthorized processes
- System changes

Check security logs:
```bash
tail -f /var/log/sentinel/security.log
```

## Basic Operations

### Starting/Stopping Services

```bash
# Start all services
sudo systemctl start sentinel-ai sentinel-security sentinel-telemetry

# Stop all services
sudo systemctl stop sentinel-telemetry sentinel-security sentinel-ai

# Restart services
sudo systemctl restart sentinel-ai
```

### Checking System Status

```bash
# Check service status
sudo systemctl status sentinel-ai
sudo systemctl status sentinel-security
sudo systemctl status sentinel-telemetry

# View system resources
htop

# Check network connections
netstat -tuln
```

### Updating SentinelOS

SentinelOS supports secure offline updates:

1. **USB Update**:
   - Place signed update packages on a USB drive
   - Insert USB drive into the device
   - Run the update script:
     ```bash
     sudo /opt/sentinel/updates/scripts/usb_update.sh
     ```

2. **LAN Update**:
   - Configure update server IP in `/etc/sentinelos/sentinelos.conf`
   - Run the LAN update script:
     ```bash
     sudo /opt/sentinel/updates/scripts/lan_update.sh <server-ip>
     ```

## Customization

### Firewall Rules

Edit firewall rules in `/etc/nftables.conf`:

```bash
sudo nano /etc/nftables.conf
sudo systemctl restart nftables
```

### Suricata Rules

Customize IDS/IPS rules in `/etc/suricata/rules/sentinel.rules`:

```bash
sudo nano /etc/suricata/rules/sentinel.rules
sudo systemctl restart suricata
```

### AI Model

Replace the AI model with your own quantized model:
```bash
sudo cp your_model.onnx /opt/sentinel/ai/models/threat_model.onnx
sudo systemctl restart sentinel-ai
```

## Security Best Practices

1. **Change Default Passwords**:
   ```bash
   passwd sentinel
   sudo passwd root
   ```

2. **Enable SSH Key Authentication**:
   ```bash
   ssh-keygen -t rsa -b 4096
   ssh-copy-id sentinel@<device-ip>
   ```

3. **Regular Security Audits**:
   ```bash
   sudo aide --check
   sudo lynis audit system
   ```

4. **Monitor Logs**:
   Regularly check logs in `/var/log/sentinel/`

## Troubleshooting

### Common Issues

1. **Dashboard Not Accessible**:
   - Check if the service is running: `sudo systemctl status sentinel-telemetry`
   - Verify the port is open: `sudo nft list ruleset`
   - Check for errors: `journalctl -u sentinel-telemetry`

2. **AI Engine Not Detecting Threats**:
   - Check AI logs: `tail -f /var/log/sentinel/ai/threat_detector.log`
   - Verify the model exists: `ls /opt/sentinel/ai/models/`
   - Restart the service: `sudo systemctl restart sentinel-ai`

3. **Firewall Blocking Legitimate Traffic**:
   - Review rules: `sudo nft list ruleset`
   - Temporarily disable: `sudo systemctl stop nftables`
   - Modify rules in `/etc/nftables.conf`

### Getting Support

For additional help:
- Check documentation in `/opt/sentinel/docs/`
- Visit the community forums
- Contact enterprise support (if applicable)

## Next Steps

1. Review and customize all security policies
2. Configure network monitoring for your environment
3. Deploy your trained AI models
4. Set up regular security audits
5. Establish secure update procedures
6. Train your team on SentinelOS operations

Congratulations! You now have a fully functional SentinelOS security appliance protecting your network.