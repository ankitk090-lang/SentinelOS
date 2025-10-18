# SentinelOS Installation Guide

## Prerequisites

Before installing SentinelOS, ensure your system meets the following requirements:

- **Hardware**: 
  - Raspberry Pi 5 (8GB RAM) or x86_64 mini PC
  - 256GB SSD storage (NVMe preferred)
  - Dual Gigabit Ethernet ports (recommended)
  - 27W USB-C power or PoE

- **Software**:
  - Debian/Ubuntu Minimal or Alpine Linux
  - Root access or sudo privileges
  - Internet connectivity for initial package installation

## Installation Methods

### Method 1: Automated Installation (Recommended)

1. Clone or download the SentinelOS repository:
   ```bash
   git clone https://github.com/your-org/sentinelos.git
   cd sentinelos
   ```

2. Make the installation script executable:
   ```bash
   chmod +x scripts/install_sentinelos.sh
   ```

3. Run the installation script as root:
   ```bash
   sudo ./scripts/install_sentinelos.sh
   ```

4. Follow the prompts to complete the installation.

### Method 2: Manual Installation

For more control over the installation process, you can install each component separately:

1. **Base System**:
   ```bash
   sudo ./scripts/setup_base.sh
   ```

2. **Network Security**:
   ```bash
   sudo ./scripts/setup_network.sh
   ```

3. **AI Threat Detection**:
   ```bash
   sudo ./scripts/setup_ai.sh
   ```

4. **Security Monitoring**:
   ```bash
   sudo ./scripts/setup_security.sh
   ```

5. **Telemetry Dashboard**:
   ```bash
   sudo ./scripts/setup_telemetry.sh
   ```

6. **Update Mechanisms**:
   ```bash
   sudo ./scripts/setup_updates.sh
   ```

### Method 3: Using Makefile

You can also use the provided Makefile for installation:

1. Install all components:
   ```bash
   make install-all
   ```

2. Or install individual components:
   ```bash
   make install-base
   make install-network
   make install-ai
   make install-security
   make install-telemetry
   make install-updates
   ```

## Post-Installation Configuration

### 1. System Services

After installation, start the core services:

```bash
sudo systemctl start sentinel-ai
sudo systemctl start sentinel-security
sudo systemctl start sentinel-telemetry
```

To enable services at boot:

```bash
sudo systemctl enable sentinel-ai
sudo systemctl enable sentinel-security
sudo systemctl enable sentinel-telemetry
```

### 2. Network Configuration

Configure your network interfaces in `/etc/netplan/` or your distribution's network configuration tool.

Update firewall rules in `/etc/nftables.conf` to match your network requirements.

### 3. AI Model Deployment

Replace the placeholder AI model in `/opt/sentinel/ai/models/threat_model.onnx` with your trained quantized model.

### 4. Dashboard Access

Access the web dashboard at `http://<device-ip>:8000/api/dashboard`

Default credentials:
- Username: sentinel
- Password: Sentinel123!

### 5. Update Configuration

Configure update sources in `/etc/sentinelos/sentinelos.conf`

## Verification

After installation, verify that all components are working correctly:

1. Check service status:
   ```bash
   systemctl status sentinel-ai
   systemctl status sentinel-security
   systemctl status sentinel-telemetry
   ```

2. Verify firewall rules:
   ```bash
   nft list ruleset
   ```

3. Test AI engine:
   ```bash
   python3 /opt/sentinel/ai/engine/threat_detector.py
   ```

4. Check security monitoring:
   ```bash
   tail -f /var/log/sentinel/security.log
   ```

## Troubleshooting

### Common Issues

1. **Permission Denied Errors**:
   Ensure you're running installation scripts with sudo privileges.

2. **Package Installation Failures**:
   Update your package repository:
   ```bash
   sudo apt-get update
   ```

3. **Service Startup Failures**:
   Check service logs:
   ```bash
   journalctl -u sentinel-ai
   journalctl -u sentinel-security
   journalctl -u sentinel-telemetry
   ```

4. **Network Interface Issues**:
   Verify network configuration in `/etc/netplan/` or your distribution's network configuration.

### Getting Help

For additional support:
- Check the documentation in `/opt/sentinel/docs/`
- Review log files in `/var/log/sentinel/`
- Contact the SentinelOS community forums

## Next Steps

After successful installation:

1. Customize security policies for your environment
2. Configure network monitoring rules
3. Deploy your trained AI models
4. Set up regular security audits
5. Configure secure update mechanisms