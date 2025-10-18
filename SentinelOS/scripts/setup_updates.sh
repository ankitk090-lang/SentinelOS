#!/bin/bash

# SentinelOS Updates Layer Setup Script
# This script sets up the secure offline update mechanisms

set -e  # Exit on any error

echo "Starting SentinelOS updates layer setup..."

# Install package signing tools
echo "Installing package signing tools..."
apt-get install -y \
  gnupg \
  debootstrap \
  dpkg-dev \
  reprepro \
  apt-utils

# Create updates directory structure
mkdir -p /opt/sentinel/updates/{repository,signing,scripts,logs}

# Create GPG key for package signing (in a real scenario, this would be a secure offline process)
echo "Creating GPG key for package signing..."
cat > /opt/sentinel/updates/signing/gpg_batch << EOF
%echo Generating a basic OpenPGP key
Key-Type: RSA
Key-Length: 4096
Subkey-Type: RSA
Subkey-Length: 4096
Name-Real: SentinelOS Security Team
Name-Email: security@sentinelos.example
Expire-Date: 0
%no-protection
%commit
%echo done
EOF

# Generate the key (this is for demonstration - in production, use secure offline process)
gpg --batch --generate-key /opt/sentinel/updates/signing/gpg_batch

# Export the public key
gpg --export --armor "security@sentinelos.example" > /opt/sentinel/updates/signing/sentinelos-public.key

# Create repository structure
mkdir -p /opt/sentinel/updates/repository/{conf,incoming,logs,dists,pool}

# Create repository configuration
cat > /opt/sentinel/updates/repository/conf/distributions << EOF
Origin: SentinelOS
Label: SentinelOS Updates
Suite: stable
Codename: sentinelos
Version: 1.0
Architectures: amd64 arm64 source
Components: main security
Description: SentinelOS Secure Updates Repository
SignWith: security@sentinelos.example
EOF

cat > /opt/sentinel/updates/repository/conf/options << EOF
verbose
basedir /opt/sentinel/updates/repository
EOF

cat > /opt/sentinel/updates/repository/conf/incoming << EOF
Name: incoming
IncomingDir: incoming
TempDir: tmp
Allow: sentinelos stable>sentinelos
Cleanup: on_deny on_error
EOF

# Create update verification script
cat > /opt/sentinel/updates/scripts/verify_update.sh << EOF
#!/bin/bash
# Script to verify signed updates

UPDATE_FILE=\$1
SIGNATURE_FILE=\$2

if [ -z "\$UPDATE_FILE" ] || [ -z "\$SIGNATURE_FILE" ]; then
    echo "Usage: \$0 <update_file> <signature_file>"
    exit 1
fi

if [ ! -f "\$UPDATE_FILE" ] || [ ! -f "\$SIGNATURE_FILE" ]; then
    echo "Error: Update file or signature file not found"
    exit 1
fi

# Import the public key if not already present
gpg --list-keys "security@sentinelos.example" > /dev/null 2>&1 || gpg --import /opt/sentinel/updates/signing/sentinelos-public.key

# Verify the signature
if gpg --verify "\$SIGNATURE_FILE" "\$UPDATE_FILE" 2>/dev/null; then
    echo "Signature verified successfully"
    exit 0
else
    echo "Signature verification failed"
    exit 1
fi
EOF

chmod +x /opt/sentinel/updates/scripts/verify_update.sh

# Create update installation script
cat > /opt/sentinel/updates/scripts/install_update.sh << EOF
#!/bin/bash
# Script to install verified updates

UPDATE_FILE=\$1
SIGNATURE_FILE=\$2

if [ -z "\$UPDATE_FILE" ] || [ -z "\$SIGNATURE_FILE" ]; then
    echo "Usage: \$0 <update_file> <signature_file>"
    exit 1
fi

# Verify the update first
if ! /opt/sentinel/updates/scripts/verify_update.sh "\$UPDATE_FILE" "\$SIGNATURE_FILE"; then
    echo "Update verification failed. Aborting installation."
    exit 1
fi

# Install the update package
echo "Installing update..."
if dpkg -i "\$UPDATE_FILE"; then
    echo "Update installed successfully"
    
    # Log the update
    echo "\$(date): Update installed from \$(basename \$UPDATE_FILE)" >> /opt/sentinel/updates/logs/update.log
    
    # Restart services if needed
    systemctl daemon-reload
    
    exit 0
else
    echo "Update installation failed"
    exit 1
fi
EOF

chmod +x /opt/sentinel/updates/scripts/install_update.sh

# Create USB update script
cat > /opt/sentinel/updates/scripts/usb_update.sh << EOF
#!/bin/bash
# Script to check for and install updates from USB drive

USB_MOUNT="/mnt/usb"
UPDATE_DIR="\$USB_MOUNT/sentinelos_updates"

if [ ! -d "\$USB_MOUNT" ]; then
    mkdir -p "\$USB_MOUNT"
fi

# Find and mount USB drive
USB_DEVICE=\$(lsblk -o NAME,TYPE,MOUNTPOINT | grep disk | head -1 | awk '{print "/dev/" \$1}')

if [ -z "\$USB_DEVICE" ]; then
    echo "No USB device found"
    exit 1
fi

echo "Mounting USB device \$USB_DEVICE..."
if ! mount "\$USB_DEVICE" "\$USB_MOUNT"; then
    echo "Failed to mount USB device"
    exit 1
fi

# Check for updates
if [ ! -d "\$UPDATE_DIR" ]; then
    echo "No updates directory found on USB drive"
    umount "\$USB_MOUNT"
    exit 1
fi

echo "Checking for updates..."
UPDATE_COUNT=0

for update_pkg in "\$UPDATE_DIR"/*.deb; do
    if [ -f "\$update_pkg" ]; then
        UPDATE_COUNT=\$((UPDATE_COUNT + 1))
        PKG_NAME=\$(basename "\$update_pkg")
        SIG_FILE="\$UPDATE_DIR/\${PKG_NAME}.sig"
        
        echo "Processing update: \$PKG_NAME"
        
        if [ -f "\$SIG_FILE" ]; then
            if /opt/sentinel/updates/scripts/install_update.sh "\$update_pkg" "\$SIG_FILE"; then
                echo "Successfully installed \$PKG_NAME"
            else
                echo "Failed to install \$PKG_NAME"
            fi
        else
            echo "Signature file not found for \$PKG_NAME"
        fi
    fi
done

if [ \$UPDATE_COUNT -eq 0 ]; then
    echo "No update packages found"
fi

# Unmount USB drive
umount "\$USB_MOUNT"
echo "USB update process completed"
EOF

chmod +x /opt/sentinel/updates/scripts/usb_update.sh

# Create LAN update script
cat > /opt/sentinel/updates/scripts/lan_update.sh << EOF
#!/bin/bash
# Script to check for and install updates from LAN server

UPDATE_SERVER=\$1
UPDATE_PORT=\${2:-8080}

if [ -z "\$UPDATE_SERVER" ]; then
    echo "Usage: \$0 <update_server_ip> [port]"
    exit 1
fi

echo "Checking for updates from \$UPDATE_SERVER:\$UPDATE_PORT..."

# In a real implementation, this would download and verify updates from a LAN server
# For now, we'll simulate the process

echo "LAN update functionality would be implemented here"
echo "This would typically involve:"
echo "1. Connecting to update server"
echo "2. Checking for available updates"
echo "3. Downloading signed packages"
echo "4. Verifying signatures"
echo "5. Installing updates"

# Example of what the real implementation might do:
# wget http://\$UPDATE_SERVER:\$UPDATE_PORT/latest.update -O /tmp/latest.update
# wget http://\$UPDATE_SERVER:\$UPDATE_PORT/latest.update.sig -O /tmp/latest.update.sig
# /opt/sentinel/updates/scripts/install_update.sh /tmp/latest.update /tmp/latest.update.sig
EOF

chmod +x /opt/sentinel/updates/scripts/lan_update.sh

# Create update service file
cat > /etc/systemd/system/sentinel-updates.service << EOF
[Unit]
Description=SentinelOS Update Manager
After=network.target

[Service]
Type=simple
User=root
ExecStart=/opt/sentinel/updates/scripts/usb_update.sh
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# Create update timer for periodic checks
cat > /etc/systemd/system/sentinel-updates.timer << EOF
[Unit]
Description=Run SentinelOS Update Check Daily
Requires=sentinel-updates.service

[Timer]
Unit=sentinel-updates.service
OnCalendar=daily
Persistent=true

[Install]
WantedBy=timers.target
EOF

# Set permissions
chown -R sentinel:sentinel /opt/sentinel/updates

echo "Updates layer setup complete!"
echo "Next steps:"
echo "1. In a production environment, generate GPG keys using secure offline process"
echo "2. Distribute the public key to all SentinelOS devices"
echo "3. Set up repository management for package distribution"
echo "4. Test USB and LAN update mechanisms"
echo "5. Configure update schedules as needed"