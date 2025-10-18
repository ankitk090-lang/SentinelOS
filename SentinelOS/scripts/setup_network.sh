#!/bin/bash

# SentinelOS Network Layer Setup Script
# This script sets up the network security components of SentinelOS

set -e  # Exit on any error

echo "Starting SentinelOS network layer setup..."

# Install additional network security tools
echo "Installing network security tools..."
apt-get update

# Add security repository for Zeek if needed
if ! apt-cache show zeek >/dev/null 2>&1; then
    echo "Adding security repository for Zeek..."
    # Check if we're on Ubuntu or Debian
    if grep -q "Ubuntu" /etc/os-release 2>/dev/null; then
        # For Ubuntu, add the security repository
        apt-get install -y software-properties-common
        add-apt-repository -y ppa:security-frameworks/zeek
        apt-get update
    else
        # For Debian, we might need to install from a different source
        echo "Attempting to install Zeek from binary package..."
    fi
fi

# Try to install packages, but handle missing packages gracefully
echo "Installing network security tools..."
apt-get install -y \
  nftables \
  iptables \
  suricata \
  libpcap-dev \
  tcpdump \
  wireshark \
  ettercap-graphical \
  sslstrip \
  dsniff

# Try to install Zeek, but don't fail if it's not available
ZEK_INSTALLED=false
if apt-cache show zeek >/dev/null 2>&1; then
    echo "Installing Zeek..."
    apt-get install -y zeek
    ZEK_INSTALLED=true
else
    echo "Warning: Zeek package not available in repositories"
    echo "Attempting to install Bro (predecessor to Zeek)..."
    if apt-get install -y bro-network-monitoring; then
        ZEK_INSTALLED=true
        echo "Bro installed successfully"
    else
        echo "Bro installation also failed"
    fi
fi

# Configure nftables
echo "Configuring nftables..."
cat > /etc/nftables.conf << EOF
#!/usr/sbin/nft -f

flush ruleset

table inet filter {
    chain input {
        type filter hook input priority 0; policy drop;
        ct state established,related accept
        iif "lo" accept
        ip protocol icmp accept
        ip6 nexthdr ipv6-icmp accept
        tcp dport { 22, 80, 443 } accept
        udp dport { 53 } accept
    }

    chain forward {
        type filter hook forward priority 0; policy drop;
    }

    chain output {
        type filter hook output priority 0; policy accept;
    }
}

table ip nat {
    chain prerouting {
        type nat hook prerouting priority -100; policy accept;
    }

    chain postrouting {
        type nat hook postrouting priority 100; policy accept;
        oifname "eth0" masquerade
    }
}
EOF

# Enable and start nftables
systemctl enable nftables
systemctl start nftables

# Configure Suricata
echo "Configuring Suricata..."
# Backup original config
cp /etc/suricata/suricata.yaml /etc/suricata/suricata.yaml.bak

# Create basic Suricata configuration
cat > /etc/suricata/suricata.yaml << EOF
%YAML 1.1
---

# Suricata configuration file for SentinelOS

vars:
  address-groups:
    HOME_NET: "[192.168.0.0/16,10.0.0.0/8,172.16.0.0/12]"
    EXTERNAL_NET: "!$HOME_NET"
    HTTP_SERVERS: "$HOME_NET"
    SMTP_SERVERS: "$HOME_NET"
    SQL_SERVERS: "$HOME_NET"
    DNS_SERVERS: "$HOME_NET"
    TELNET_SERVERS: "$HOME_NET"
    AIM_SERVERS: "$EXTERNAL_NET"
    DC_SERVERS: "$HOME_NET"
    DNP3_SERVER: "$HOME_NET"
    DNP3_CLIENT: "$HOME_NET"
    MODBUS_CLIENT: "$HOME_NET"
    MODBUS_SERVER: "$HOME_NET"
    ENIP_CLIENT: "$HOME_NET"
    ENIP_SERVER: "$HOME_NET"

  port-groups:
    HTTP_PORTS: "80"
    SHELLCODE_PORTS: "!80"
    ORACLE_PORTS: 1521
    SSH_PORTS: 22
    DNP3_PORTS: 20000
    MODBUS_PORTS: 502
    FILE_DATA_PORTS: "\$(HTTP_PORTS),110,143"
    FTP_PORTS: 21

default-rule-path: /etc/suricata/rules
rule-files:
 - sentinel.rules

classification-file: /etc/suricata/classification.config
reference-config-file: /etc/suricata/reference.config
threshold-file: /etc/suricata/threshold.config

af-packet:
  - interface: eth0
    threads: auto
    defrag: yes
    cluster-type: cluster_flow
    cluster-id: 99

outputs:
  - fast:
      enabled: yes
      filename: /var/log/suricata/fast.log

  - eve-log:
      enabled: yes
      filetype: regular
      filename: /var/log/suricata/eve.json

logging:
  default-log-level: info
  default-output-filter:

detect-engine:
  - rule-reload: true

runmode: workers
EOF

# Create basic rule file
mkdir -p /etc/suricata/rules
cat > /etc/suricata/rules/sentinel.rules << EOF
# SentinelOS Basic Rules

alert tcp \$HOME_NET any -> \$EXTERNAL_NET \$HTTP_PORTS (msg:"HTTP GET Request"; flow:to_server,established; content:"GET"; http_method; sid:1000001; rev:1;)
alert tcp \$EXTERNAL_NET \$HTTP_PORTS -> \$HOME_NET any (msg:"HTTP Response"; flow:from_server,established; content:"200 OK"; http_stat_msg; sid:1000002; rev:1;)
alert icmp any any -> any any (msg:"ICMP Packet Detected"; itype:8; sid:1000003; rev:1;)
EOF

# Enable and start Suricata
systemctl enable suricata
systemctl start suricata

# Set up Zeek service (only if Zeek/Bro was installed)
if [ "$ZEK_INSTALLED" = true ]; then
    # Configure Zeek (Bro)
    echo "Configuring Zeek..."
    
    # Create basic Zeek configuration
    mkdir -p /opt/sentinel/network/zeek
    cat > /opt/sentinel/network/zeek/local.zeek << EOF
# SentinelOS Zeek Configuration

@load base/frameworks/notice
@load base/frameworks/sumstats

# Load policy scripts
@load policy/protocols/conn/contents
@load policy/protocols/http/header-names
@load policy/protocols/ssl/expiring-certs

# Site configuration
redef Site::local_nets = { 192.168.0.0/16, 10.0.0.0/8, 172.16.0.0/12 };

# Logging configuration
redef LogAscii::use_json = T;
redef LogAscii::json_timestamps = T;

# Notice configuration
redef Notice::emergencies_to_syslog = true;

# Sumstat configuration
redef SumStats::default_interval = 1min;
EOF

    # Set up Zeek service
    cat > /etc/systemd/system/zeek.service << EOF
[Unit]
Description=Zeek Network Security Monitor
After=network.target

[Service]
Type=forking
User=root
ExecStart=/usr/bin/zeekctl deploy
ExecReload=/usr/bin/zeekctl deploy
KillMode=process
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

    # Enable and start Zeek
    systemctl enable zeek
    systemctl start zeek
else
    echo "Skipping Zeek configuration as it was not installed"
fi

# Create network monitoring script
cat > /opt/sentinel/network/monitor.sh << EOF
#!/bin/bash
# Network monitoring script for SentinelOS

LOG_DIR="/var/log/sentinel/network"
mkdir -p \$LOG_DIR

# Log network connections
netstat -an > \$LOG_DIR/connections_\$(date +%Y%m%d_%H%M%S).log

# Log active processes
ps aux > \$LOG_DIR/processes_\$(date +%Y%m%d_%H%M%S).log

# Log network statistics
cat /proc/net/dev > \$LOG_DIR/netstat_\$(date +%Y%m%d_%H%M%S).log

# Run tcpdump for 1 minute
timeout 60 tcpdump -i any -w \$LOG_DIR/packets_\$(date +%Y%m%d_%H%M%S).pcap &
EOF

chmod +x /opt/sentinel/network/monitor.sh

# Set up cron job for periodic monitoring
(crontab -l 2>/dev/null; echo "*/5 * * * * /opt/sentinel/network/monitor.sh") | crontab -

echo "Network layer setup complete!"
echo "Next steps:"
echo "1. Configure specific network interfaces in nftables"
echo "2. Customize Suricata rules for your environment"
echo "3. Review Zeek policies and site configuration"
echo "4. Test network monitoring scripts"