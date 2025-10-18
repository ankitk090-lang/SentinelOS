#!/bin/bash

# SentinelOS Base System Setup Script
# This script sets up the foundational components of SentinelOS

set -e  # Exit on any error

echo "Starting SentinelOS base system setup..."

# Update system packages
echo "Updating system packages..."
apt-get update && apt-get upgrade -y

# Install essential packages
echo "Installing essential packages..."
apt-get install -y \
  build-essential \
  git \
  curl \
  wget \
  vim \
  nano \
  htop \
  net-tools \
  iputils-ping \
  dnsutils \
  tcpdump \
  nmap \
  rsync \
  openssl \
  ca-certificates \
  gnupg \
  lsb-release

# Install containerization tools
echo "Installing containerization tools..."
apt-get install -y \
  docker.io \
  docker-compose

# Install security tools
echo "Installing security tools..."
apt-get install -y \
  aide \
  fail2ban \
  clamav \
  chkrootkit \
  rkhunter

# Install network monitoring tools
echo "Installing network monitoring tools..."
apt-get install -y \
  nftables \
  iptables \
  suricata \
  zeek

# Enable and start essential services
echo "Enabling essential services..."
systemctl enable docker
systemctl start docker
systemctl enable aide
systemctl start aide

# Create sentinel user
echo "Creating sentinel user..."
useradd -m -s /bin/bash sentinel
echo "sentinel:Sentinel123!" | chpasswd
usermod -aG docker,sudo sentinel

# Set up basic firewall rules
echo "Setting up basic firewall rules..."
nft add table inet filter
nft add chain inet filter input { type filter hook input priority 0 \; }
nft add chain inet filter forward { type filter hook forward priority 0 \; }
nft add chain inet filter output { type filter hook output priority 0 \; }
nft add rule inet filter input ct state established,related accept
nft add rule inet filter input iif lo accept
nft add rule inet filter input ip protocol icmp accept
nft add rule inet filter input tcp dport 22 accept
nft add rule inet filter input drop

# Initialize AIDE database
echo "Initializing AIDE database..."
aideinit -y -f

# Create basic directory structure
echo "Creating directory structure..."
mkdir -p /opt/sentinel/{ai,network,security,telemetry,updates}
chown -R sentinel:sentinel /opt/sentinel

# Set up log rotation
echo "Setting up log rotation..."
cat > /etc/logrotate.d/sentinel << EOF
/var/log/sentinel/*.log {
    daily
    missingok
    rotate 52
    compress
    delaycompress
    notifempty
    create 640 sentinel adm
}
EOF

# Set up basic system hardening
echo "Applying basic system hardening..."

# Disable unused services
systemctl disable bluetooth.service
systemctl disable cups.service
systemctl disable avahi-daemon.service

# Secure SSH configuration
cat >> /etc/ssh/sshd_config << EOF

# SentinelOS Hardening
PermitRootLogin no
PasswordAuthentication yes
PubkeyAuthentication yes
PermitEmptyPasswords no
MaxAuthTries 3
ClientAliveInterval 300
ClientAliveCountMax 2
AllowUsers sentinel
EOF

# Restart SSH service
systemctl restart ssh

echo "Base system setup complete!"
echo "Next steps:"
echo "1. Reboot the system"
echo "2. Log in as 'sentinel' user"
echo "3. Run network layer setup script"