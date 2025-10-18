# SentinelOS - AI-Resistant Security Operating System

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-1.0.0-green.svg)]()

SentinelOS is a security-first, AI-hardened embedded Linux designed for offline AI-driven threat detection and network protection. It provides multi-layer firewall protection, offline AI analysis, and intrusion prevention — all without cloud dependency.

## 🛡️ Key Features

### Multi-Layer Firewall Stack
- **Level 1**: Packet-level filtering via iptables/nftables
- **Level 2**: Deep Packet Inspection (DPI) using Suricata
- **Level 3**: AI-Driven Behavior Analysis for unknown pattern detection
- **Level 4**: Application Whitelisting and Device Fingerprinting

### Offline AI Security Engine
- Lightweight 8-bit quantized model (1-3B parameters)
- Malware pattern recognition and AI traffic detection
- Data exfiltration identification
- Compression pattern analysis

### Privacy and Anonymity
- No telemetry leaves the device
- AES-256 encrypted local log storage
- Optional physical toggle for internet disconnection

### Local Admin Interface
- Web-based dashboard with real-time visualization
- Live connections and blocked threats monitoring
- CPU/network graphs and AI detection events
- Role-based access control

## 🏗️ System Architecture

```
Layer              Component              Description
────────────────────────────────────────────────────────────────
Kernel Layer       Custom Linux Kernel    Optimized for packet processing, eBPF
Network Layer      iptables/nftables      Real-time packet inspection and blocking
AI Layer           ONNX/TensorFlow Lite   Offline threat analysis engine
Security Daemons   AIDE, Fail2Ban         File integrity and intrusion prevention
Telemetry Layer    FastAPI + React        Secure local dashboard
Update Layer       Signed USB/LAN         Secure offline package updates
```

## 🖥️ Hardware Compatibility

### Minimum Requirements
- **CPU**: ARM Cortex-A76 (Raspberry Pi 5) or x86_64
- **RAM**: 8 GB LPDDR4X
- **Storage**: 256 GB SSD (NVMe preferred)
- **Network**: Gigabit Ethernet + Wi-Fi 6
- **Power**: 27W USB-C or PoE+

### Recommended Setup
- Dual LAN ports for inline network monitoring
- Hardware security module (HSM)
- Physical internet disconnect toggle
- Dedicated LED indicators

## 🚀 Quick Start

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/your-org/sentinelos.git
   cd sentinelos
   ```

2. Run the installation script:
   ```bash
   chmod +x scripts/install_sentinelos.sh
   sudo ./scripts/install_sentinelos.sh
   ```

3. Or use the Makefile:
   ```bash
   make install-all
   ```

### Testing in a Virtual Machine

You can test SentinelOS in a VM before deploying to physical hardware. See [VM Setup Guide](docs/vm_setup.md) for detailed instructions.

Supported virtualization platforms:
- UTM (recommended for Apple Silicon Macs)
- Parallels Desktop
- VMware Fusion

### Access Dashboard

After installation, access the web dashboard at:
```
http://<device-ip>:8000/api/dashboard
```

Default credentials:
- Username: `sentinel`
- Password: `Sentinel123!`

## 📁 Project Structure

```
SentinelOS/
├── config/          # Configuration files
├── docs/            # Documentation
├── kernel/          # Kernel customizations
├── network/         # Network security components
├── ai/              # AI threat detection engine
├── security/        # Security monitoring tools
├── telemetry/       # Dashboard and visualization
├── updates/         # Secure update mechanisms
└── scripts/         # Installation and setup scripts
```

## 🛠️ Core Components

### Network Security
- **Firewall**: nftables with custom rulesets
- **IDS/IPS**: Suricata for intrusion detection
- **Monitoring**: Zeek network security monitor
- **Capture**: libpcap/tcpdump for forensics

### AI Engine
- **Runtime**: ONNX Runtime or TensorFlow Lite
- **Model**: 8-bit quantized neural network
- **Detection**: Malware, AI traffic, exfiltration
- **Learning**: Adaptive local training (optional)

### Security Monitoring
- **File Integrity**: AIDE for system file monitoring
- **Intrusion Prevention**: Fail2Ban and custom daemons
- **Process Isolation**: Docker/Podman containerization
- **Root Protection**: Hardware-switch protected access

### Telemetry Dashboard
- **Backend**: FastAPI RESTful services
- **Frontend**: React dashboard (simulated with HTML/JS)
- **Metrics**: Real-time system and network monitoring
- **Visualization**: Threat detection and resource graphs

### Update System
- **Signing**: GPG-verified package distribution
- **Delivery**: USB/LAN-based offline updates
- **Verification**: Cryptographic signature validation
- **Installation**: Atomic updates with rollback

## 📖 Documentation

- [Architecture Overview](docs/architecture.md)
- [Installation Guide](docs/installation.md)
- [Quick Start Guide](docs/quickstart.md)
- [VM Setup Guide](docs/vm_setup.md)
- [Requirements Specification](docs/requirements.md)
- [Development Roadmap](docs/roadmap.md)
- [Project Summary](docs/summary.md)

## 🧪 Verification

Run the verification script to check installation:
```bash
sudo ./scripts/verify_installation.sh
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

For support, please open an issue on GitHub or contact the development team.

---

**SentinelOS - Protecting Networks with AI-Powered Security**