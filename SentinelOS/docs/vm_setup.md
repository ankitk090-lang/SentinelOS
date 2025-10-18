# Running SentinelOS in a Virtual Machine on macOS

This guide will help you test SentinelOS in a virtual machine on your MacBook before deploying to physical hardware.

## Prerequisites

1. **macOS 10.13 or later**
2. **Virtualization software** (choose one):
   - UTM (recommended for Apple Silicon Macs)
   - Parallels Desktop
   - VMware Fusion
3. **At least 8GB RAM** (16GB recommended)
4. **50GB+ free disk space**

## Option 1: Using UTM (Recommended for Apple Silicon Macs)

### Step 1: Install UTM

1. Download UTM from the official website or Mac App Store
2. Install UTM on your MacBook

### Step 2: Create a Debian VM

1. Open UTM
2. Click "Create a New Virtual Machine"
3. Select "Virtualize"
4. Choose "Linux"
5. Select "Debian" or "Ubuntu" as the system
6. Allocate resources:
   - CPU: 4 cores
   - RAM: 8GB
   - Storage: 50GB
7. Download Debian ISO (if needed) or use an existing one

### Step 3: Install Base OS

1. Start the VM
2. Follow Debian installation prompts
3. Set up user account:
   - Username: `sentinel`
   - Password: `Sentinel123!`
4. Install SSH server when prompted
5. Complete installation and reboot

### Step 4: Install SentinelOS

1. After Debian is installed, log in as the `sentinel` user
2. Install git:
   ```bash
   sudo apt update
   sudo apt install git -y
   ```

3. Clone the SentinelOS repository:
   ```bash
   git clone https://github.com/your-org/sentinelos.git
   cd sentinelos
   ```

4. Make scripts executable:
   ```bash
   chmod +x scripts/*.sh
   ```

5. Run the installation:
   ```bash
   sudo ./scripts/install_sentinelos.sh
   ```

6. Follow the prompts to complete installation

## Option 2: Using Parallels Desktop

### Step 1: Install Parallels Desktop

1. Download and install Parallels Desktop from the official website
2. Activate with your license

### Step 2: Create Debian VM

1. Open Parallels Desktop
2. Click "Install Windows or another OS from a DVD or image file"
3. Choose "Install an operating system manually"
4. Select Debian ISO
5. Follow installation wizard with recommended settings

### Step 3: Install SentinelOS

Follow the same steps as in Option 1, Step 4.

## Option 3: Using VMware Fusion

### Step 1: Install VMware Fusion

1. Download and install VMware Fusion
2. Activate with your license

### Step 2: Create Debian VM

1. Open VMware Fusion
2. Select "New" to create a virtual machine
3. Choose Debian ISO
4. Follow installation wizard

### Step 3: Install SentinelOS

Follow the same steps as in Option 1, Step 4.

## Post-Installation Configuration

### 1. Network Configuration

Configure network interfaces for testing:

```bash
# Edit netplan configuration
sudo nano /etc/netplan/01-netcfg.yaml
```

Example configuration for VM:
```yaml
network:
  version: 2
  ethernets:
    ens33:
      dhcp4: true
```

Apply configuration:
```bash
sudo netplan apply
```

### 2. Start Services

```bash
# Start all SentinelOS services
sudo systemctl start sentinel-ai
sudo systemctl start sentinel-security
sudo systemctl start sentinel-telemetry
```

### 3. Access Dashboard

1. Find your VM's IP address:
   ```bash
   ip addr show
   ```

2. Open a browser on your MacBook and navigate to:
   ```
   http://<VM-IP>:8000/api/dashboard
   ```

3. Log in with:
   - Username: `sentinel`
   - Password: `Sentinel123!`

## Testing Components

### 1. Firewall Testing

Check firewall rules:
```bash
sudo nft list ruleset
```

### 2. AI Engine Testing

Test the AI threat detector:
```bash
python3 /opt/sentinel/ai/engine/threat_detector.py
```

Check AI logs:
```bash
tail -f /var/log/sentinel/ai/threat_detector.log
```

### 3. Security Monitoring

Check security logs:
```bash
tail -f /var/log/sentinel/security.log
```

### 4. Network Monitoring

View network statistics:
```bash
sudo netstat -tuln
```

## Troubleshooting

### Common Issues

1. **Insufficient Resources**
   - Allocate more RAM/CPU to VM
   - Minimum: 4 cores, 8GB RAM

2. **Network Connectivity**
   - Check VM network settings
   - Ensure bridged or NAT mode is enabled

3. **Installation Errors**
   - Check logs in `/var/log/sentinel/`
   - Run verification script:
     ```bash
     sudo ./scripts/verify_installation.sh
     ```

4. **Dashboard Not Accessible**
   - Check if service is running:
     ```bash
     sudo systemctl status sentinel-telemetry
     ```
   - Check firewall rules

### Performance Optimization

For better VM performance:
1. Enable hardware acceleration in VM settings
2. Allocate at least 2 CPU cores
3. Assign 8GB+ RAM
4. Use SSD storage for VM files

## Next Steps

After successful testing in VM:

1. Document any issues or improvements needed
2. Test all security features
3. Validate AI detection capabilities
4. Prepare for deployment on physical hardware
5. Create optimized installation packages

## Cleaning Up

To remove the VM:

1. Stop the VM
2. Delete VM files from virtualization software
3. Remove any downloaded ISO files

---

**Note**: This VM setup is for testing purposes only. For production deployment, use the recommended hardware (Raspberry Pi 5 or x86 mini PC).