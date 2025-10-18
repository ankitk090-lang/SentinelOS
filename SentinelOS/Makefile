# SentinelOS Makefile
# Simplified build and installation process

# Variables
INSTALL_DIR ?= /opt/sentinel
SCRIPTS_DIR = scripts
CONFIG_DIR = config

# Default target
.PHONY: all
all: help

# Help target
.PHONY: help
help:
	@echo "SentinelOS Build System"
	@echo "======================"
	@echo "Available targets:"
	@echo "  install-base     - Install base system components"
	@echo "  install-network  - Install network security components"
	@echo "  install-ai       - Install AI threat detection engine"
	@echo "  install-security - Install security monitoring"
	@echo "  install-telemetry- Install telemetry dashboard"
	@echo "  install-updates  - Install update mechanisms"
	@echo "  install-all      - Install all components"
	@echo "  clean            - Clean build artifacts"
	@echo "  help             - Show this help message"

# Install base system
.PHONY: install-base
install-base:
	@echo "Installing base system components..."
	sudo $(SCRIPTS_DIR)/setup_base.sh

# Install network layer
.PHONY: install-network
install-network:
	@echo "Installing network security components..."
	sudo $(SCRIPTS_DIR)/setup_network.sh

# Install AI layer
.PHONY: install-ai
install-ai:
	@echo "Installing AI threat detection engine..."
	sudo $(SCRIPTS_DIR)/setup_ai.sh

# Install security layer
.PHONY: install-security
install-security:
	@echo "Installing security monitoring..."
	sudo $(SCRIPTS_DIR)/setup_security.sh

# Install telemetry layer
.PHONY: install-telemetry
install-telemetry:
	@echo "Installing telemetry dashboard..."
	sudo $(SCRIPTS_DIR)/setup_telemetry.sh

# Install updates layer
.PHONY: install-updates
install-updates:
	@echo "Installing update mechanisms..."
	sudo $(SCRIPTS_DIR)/setup_updates.sh

# Install all components
.PHONY: install-all
install-all: install-base install-network install-ai install-security install-telemetry install-updates
	@echo "Installing main configuration..."
	sudo mkdir -p /etc/sentinelos
	sudo cp $(CONFIG_DIR)/sentinelos.conf /etc/sentinelos/
	@echo "All components installed successfully!"

# Clean build artifacts
.PHONY: clean
clean:
	@echo "Cleaning build artifacts..."
	@echo "Nothing to clean in this version."

# Start all services
.PHONY: start
start:
	@echo "Starting SentinelOS services..."
	sudo systemctl start sentinel-ai
	sudo systemctl start sentinel-security
	sudo systemctl start sentinel-telemetry
	@echo "Services started!"

# Stop all services
.PHONY: stop
stop:
	@echo "Stopping SentinelOS services..."
	sudo systemctl stop sentinel-telemetry
	sudo systemctl stop sentinel-security
	sudo systemctl stop sentinel-ai
	@echo "Services stopped!"

# Restart all services
.PHONY: restart
restart: stop start
	@echo "Services restarted!"

# View status of all services
.PHONY: status
status:
	@echo "SentinelOS Service Status:"
	sudo systemctl status sentinel-ai
	sudo systemctl status sentinel-security
	sudo systemctl status sentinel-telemetry