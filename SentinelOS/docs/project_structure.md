# SentinelOS Project Structure

## Directory Layout

```
SentinelOS/
├── README.md
├── kernel/          # Kernel configuration and patches
├── network/         # Network stack components (iptables/nftables, Suricata)
├── ai/              # AI engine and models
├── security/        # Security daemons and monitoring tools
├── telemetry/       # Dashboard and visualization components
├── updates/         # Secure update mechanisms
├── docs/            # Documentation
├── scripts/         # Installation and setup scripts
└── config/          # Configuration files
```

## Component Descriptions

### Kernel Layer
- Custom Linux kernel optimizations
- eBPF configurations
- Low-latency I/O enhancements

### Network Layer
- iptables/nftables rules
- Suricata IDS/IPS configuration
- Zeek network analysis tools
- Packet capture utilities

### AI Layer
- Quantized AI models (1-3B parameters)
- ONNX/TensorFlow Lite runtime
- Threat detection algorithms
- Local inference engine

### Security Daemons
- File integrity monitoring (aide)
- Network anomaly detection services
- Unauthorized access prevention
- Process isolation mechanisms

### Telemetry Layer
- FastAPI backend services
- React frontend dashboard
- Real-time metrics collection
- Secure local-only access

### Update Layer
- Signed package verification
- USB/LAN-based update mechanisms
- Offline patching system
- Secure boot configurations

## Hardware Targets
- Raspberry Pi 5 (8GB RAM, 256GB SSD)
- x86_64 mini PCs (8GB RAM, dual LAN)