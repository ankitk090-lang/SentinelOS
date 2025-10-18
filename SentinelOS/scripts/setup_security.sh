#!/bin/bash

# SentinelOS Security Layer Setup Script
# This script sets up the security daemons and monitoring tools

set -e  # Exit on any error

echo "Starting SentinelOS security layer setup..."

# Install security monitoring tools
echo "Installing security monitoring tools..."
apt-get install -y \
  aide \
  fail2ban \
  clamav \
  clamav-daemon \
  chkrootkit \
  rkhunter \
  lynis \
  auditd

# Configure AIDE (Advanced Intrusion Detection Environment)
echo "Configuring AIDE..."
# Backup original config
cp /etc/aide/aide.conf /etc/aide/aide.conf.bak

# Create AIDE configuration for SentinelOS
cat > /etc/aide/aide.conf << EOF
# SentinelOS AIDE Configuration

# Basic configuration
database=file:/var/lib/aide/aide.db
database_out=file:/var/lib/aide/aide.db.new
gzip_dbout=yes
verbose=5

# Select when to log
log_level=warning

# Select when to report
report_level=changed_attributes

# Group definitions
All=access+acl+selinux+ftype+link+size+uid+gid+md5+sha1+sha256+sha512+rmd160+tiger
NormalFile=access+acl+selinux+ftype+link+size+uid+gid+md5+sha1+sha256+sha512+rmd160+tiger
Directory=access+acl+selinux+ftype+link+uid+gid
FIFO=access+acl+selinux+ftype+link+uid+gid
Device=access+acl+selinux+ftype+link+uid+gid
Link=access+acl+selinux+ftype+link+uid+gid
Socket=access+acl+selinux+ftype+uid+gid

# Select directories to monitor
/etc All
/bin NormalFile
/sbin NormalFile
/lib NormalFile
/lib64 NormalFile
/usr/bin NormalFile
/usr/sbin NormalFile
/usr/lib NormalFile
/boot NormalFile
/root NormalFile

# Exclude directories that change frequently
!/etc/mtab
!/etc/.*~
!/etc/group-
!/etc/passwd-
!/etc/shadow-
!/etc/gshadow-

# Exclude log files
!/var/log/.*

# Exclude temporary files
!/tmp/.*
!/var/tmp/.*
EOF

# Initialize AIDE database
echo "Initializing AIDE database..."
aideinit -y -f

# Configure Fail2Ban
echo "Configuring Fail2Ban..."
# Create jail.local for custom configuration
cat > /etc/fail2ban/jail.local << EOF
[DEFAULT]
ignoreip = 127.0.0.1/8 ::1 192.168.0.0/16 10.0.0.0/8 172.16.0.0/12
bantime = 10m
findtime = 10m
maxretry = 5
banaction = iptables-multiport
banaction_allports = iptables-allports

[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 15m

[nginx-http-auth]
enabled = true
port = http,https
filter = nginx-http-auth
logpath = /var/log/nginx/error.log
maxretry = 3

[apache-auth]
enabled = true
port = http,https
filter = apache-auth
logpath = /var/log/apache2/error.log
maxretry = 3
EOF

# Restart Fail2Ban
systemctl restart fail2ban

# Configure ClamAV
echo "Configuring ClamAV..."
# Update virus definitions
freshclam

# Configure daemon settings
cat > /etc/clamav/clamd.conf << EOF
# SentinelOS ClamAV Configuration
LogFile /var/log/clamav/clamd.log
LogTime yes
LogVerbose no
PidFile /var/run/clamd.pid
TemporaryDirectory /tmp
DatabaseDirectory /var/lib/clamav
LocalSocket /var/run/clamav/clamd.ctl
FixStaleSocket yes
TCPAddr 127.0.0.1
TCPSocket 3310
MaxConnectionQueueLength 30
MaxThreads 5
ReadTimeout 300
CommandReadTimeout 5
SendBufTimeout 200
SelfCheck 600
Foreground false
Debug false
ExitOnOOM no
AllowAllMatchScan no
User clamav
Bytecode true
BytecodeSecurity TrustSigned
BytecodeTimeout 60000
EOF

# Configure freshclam
cat > /etc/clamav/freshclam.conf << EOF
# SentinelOS Freshclam Configuration
DatabaseDirectory /var/lib/clamav
UpdateLogFile /var/log/clamav/freshclam.log
LogTime yes
LogVerbose no
PidFile /var/run/freshclam.pid
DatabaseOwner clamav
DNSDatabaseInfo current.cvd.clamav.net
DatabaseMirror db.local.clamav.net
DatabaseMirror database.clamav.net
MaxAttempts 3
ConnectTimeout 30
ReceiveTimeout 30
TestDatabases yes
ScriptedUpdates yes
CompressLocalDatabase no
Bytecode true
NotifyClamd /etc/clamav/clamd.conf
EOF

# Restart ClamAV services
systemctl restart clamav-daemon
systemctl restart clamav-freshclam

# Create custom security monitoring daemon
mkdir -p /opt/sentinel/security/daemon
cat > /opt/sentinel/security/daemon/security_monitor.py << EOF
#!/usr/bin/env python3
"""
SentinelOS Security Monitoring Daemon
Monitors system integrity and unauthorized access attempts
"""

import os
import sys
import time
import subprocess
import hashlib
import json
import logging
from datetime import datetime

class SecurityMonitor:
    def __init__(self):
        self.logger = self._setup_logger()
        self.whitelist = self._load_whitelist()
        self.baseline = self._load_baseline()
        
    def _setup_logger(self):
        """Set up logging for the security monitor"""
        logger = logging.getLogger('SentinelSecurity')
        logger.setLevel(logging.INFO)
        
        handler = logging.FileHandler('/var/log/sentinel/security.log')
        formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
        handler.setFormatter(formatter)
        logger.addHandler(handler)
        
        return logger
    
    def _load_whitelist(self):
        """Load application whitelist"""
        whitelist_file = "/opt/sentinel/security/config/whitelist.json"
        if os.path.exists(whitelist_file):
            with open(whitelist_file, 'r') as f:
                return json.load(f)
        else:
            # Create default whitelist
            default_whitelist = {
                "processes": [
                    "systemd", "sshd", "cron", "rsyslogd", "networkd", 
                    "dockerd", "containerd", "suricata", "zeek"
                ],
                "ports": [22, 53, 80, 443],
                "users": ["root", "sentinel", "systemd-timesync", "systemd-network"]
            }
            return default_whitelist
    
    def _load_baseline(self):
        """Load system baseline for comparison"""
        baseline_file = "/opt/sentinel/security/config/baseline.json"
        if os.path.exists(baseline_file):
            with open(baseline_file, 'r') as f:
                return json.load(f)
        else:
            return {}
    
    def check_file_integrity(self):
        """Check system file integrity using AIDE"""
        try:
            result = subprocess.run(['aide', '--check'], 
                                  capture_output=True, text=True, timeout=300)
            if result.returncode == 0:
                self.logger.info("File integrity check passed")
                return True
            else:
                self.logger.warning(f"File integrity check failed: {result.stdout}")
                return False
        except subprocess.TimeoutExpired:
            self.logger.error("File integrity check timed out")
            return False
        except Exception as e:
            self.logger.error(f"Error during file integrity check: {e}")
            return False
    
    def check_unauthorized_processes(self):
        """Check for unauthorized processes"""
        try:
            # Get list of running processes
            result = subprocess.run(['ps', '-eo', 'comm'], 
                                  capture_output=True, text=True)
            
            processes = result.stdout.strip().split('\n')[1:]  # Skip header
            unauthorized = []
            
            for process in processes:
                process_name = process.strip()
                if process_name not in self.whitelist.get('processes', []):
                    unauthorized.append(process_name)
            
            if unauthorized:
                self.logger.warning(f"Unauthorized processes detected: {unauthorized}")
                return False
            else:
                self.logger.info("No unauthorized processes detected")
                return True
                
        except Exception as e:
            self.logger.error(f"Error checking processes: {e}")
            return False
    
    def check_network_connections(self):
        """Check for suspicious network connections"""
        try:
            # Get active network connections
            result = subprocess.run(['netstat', '-tn'], 
                                  capture_output=True, text=True)
            
            connections = result.stdout.strip().split('\n')[2:]  # Skip headers
            suspicious = []
            
            for conn in connections:
                parts = conn.split()
                if len(parts) >= 4:
                    # Check if connection is to unauthorized ports
                    local_addr = parts[3]
                    if ':' in local_addr:
                        port = int(local_addr.split(':')[-1])
                        if port not in self.whitelist.get('ports', []):
                            suspicious.append(local_addr)
            
            if suspicious:
                self.logger.warning(f"Suspicious connections detected: {suspicious}")
                return False
            else:
                self.logger.info("No suspicious connections detected")
                return True
                
        except Exception as e:
            self.logger.error(f"Error checking network connections: {e}")
            return False
    
    def run_security_checks(self):
        """Run all security checks"""
        self.logger.info("Starting security checks")
        
        checks = [
            ("File Integrity", self.check_file_integrity),
            ("Unauthorized Processes", self.check_unauthorized_processes),
            ("Network Connections", self.check_network_connections)
        ]
        
        results = {}
        for check_name, check_func in checks:
            try:
                results[check_name] = check_func()
            except Exception as e:
                self.logger.error(f"Error in {check_name}: {e}")
                results[check_name] = False
        
        self.logger.info(f"Security checks completed: {results}")
        return results

def main():
    """Main monitoring loop"""
    monitor = SecurityMonitor()
    
    print("SentinelOS Security Monitoring Daemon Started")
    
    while True:
        try:
            # Run security checks
            results = monitor.run_security_checks()
            
            # If any check fails, log it as an alert
            if not all(results.values()):
                print(f"SECURITY ALERT: {results}")
                # In a real implementation, this would trigger alerts, notifications, etc.
            
            # Wait before next check
            time.sleep(60)  # Check every minute
            
        except KeyboardInterrupt:
            print("Security monitoring stopped")
            break
        except Exception as e:
            print(f"Error in security monitoring: {e}")
            time.sleep(5)  # Wait before retrying

if __name__ == "__main__":
    main()
EOF

chmod +x /opt/sentinel/security/daemon/security_monitor.py

# Create whitelist configuration
mkdir -p /opt/sentinel/security/config
cat > /opt/sentinel/security/config/whitelist.json << EOF
{
  "processes": [
    "systemd", "sshd", "cron", "rsyslogd", "networkd", 
    "dockerd", "containerd", "suricata", "zeek", "aide", 
    "fail2ban-server", "clamd", "freshclam", "python3"
  ],
  "ports": [22, 53, 80, 443, 3310],
  "users": ["root", "sentinel", "systemd-timesync", "systemd-network", "clamav"]
}
EOF

# Create security service file
cat > /etc/systemd/system/sentinel-security.service << EOF
[Unit]
Description=SentinelOS Security Monitoring Daemon
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/bin/python3 /opt/sentinel/security/daemon/security_monitor.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Enable and start security services
systemctl enable aide
systemctl enable fail2ban
systemctl enable clamav-daemon
systemctl enable clamav-freshclam
systemctl enable sentinel-security

# Set permissions
chown -R sentinel:sentinel /opt/sentinel/security

echo "Security layer setup complete!"
echo "Next steps:"
echo "1. Review and customize the application whitelist"
echo "2. Configure additional security policies as needed"
echo "3. Test security monitoring daemon"
echo "4. Schedule regular AIDE integrity checks"