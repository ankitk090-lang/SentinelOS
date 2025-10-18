#!/bin/bash

# SentinelOS Telemetry Layer Setup Script
# This script sets up the dashboard and visualization components

set -e  # Exit on any error

echo "Starting SentinelOS telemetry layer setup..."

# Install web development tools
echo "Installing web development tools..."
apt-get install -y \
  nodejs \
  npm \
  python3-pip \
  python3-venv

# Install FastAPI and related packages
echo "Installing FastAPI and related packages..."
pip3 install \
  fastapi \
  uvicorn \
  pydantic \
  jinja2 \
  python-multipart \
  aiofiles

# Create telemetry directory structure
mkdir -p /opt/sentinel/telemetry/{api,frontend,logs}

# Create FastAPI backend
cat > /opt/sentinel/telemetry/api/main.py << EOF
"""
SentinelOS Telemetry API
FastAPI backend for the dashboard and metrics collection
"""

from fastapi import FastAPI, HTTPException
from fastapi.staticfiles import StaticFiles
from fastapi.responses import HTMLResponse
from pydantic import BaseModel
import json
import os
from datetime import datetime
import psutil
import asyncio

app = FastAPI(title="SentinelOS Telemetry API", version="1.0.0")

# Data models
class SystemMetrics(BaseModel):
    cpu_percent: float
    memory_percent: float
    disk_usage: float
    network_bytes_sent: int
    network_bytes_recv: int
    timestamp: str

class ThreatEvent(BaseModel):
    id: str
    timestamp: str
    threat_level: str
    source_ip: str
    destination_ip: str
    description: str

# In-memory storage for demo purposes
# In a real implementation, this would connect to a database
threat_events = []
system_metrics = []

# API endpoints
@app.get("/")
async def root():
    return {"message": "SentinelOS Telemetry API", "version": "1.0.0"}

@app.get("/api/system/metrics")
async def get_system_metrics():
    """Get current system metrics"""
    # Collect system metrics
    cpu_percent = psutil.cpu_percent(interval=1)
    memory = psutil.virtual_memory()
    disk = psutil.disk_usage('/')
    network = psutil.net_io_counters()
    
    metrics = SystemMetrics(
        cpu_percent=cpu_percent,
        memory_percent=memory.percent,
        disk_usage=(disk.used / disk.total) * 100,
        network_bytes_sent=network.bytes_sent,
        network_bytes_recv=network.bytes_recv,
        timestamp=datetime.now().isoformat()
    )
    
    # Store for history (keep last 100 entries)
    system_metrics.append(metrics)
    if len(system_metrics) > 100:
        system_metrics.pop(0)
    
    return metrics

@app.get("/api/system/metrics/history")
async def get_system_metrics_history():
    """Get historical system metrics"""
    return system_metrics

@app.get("/api/threats")
async def get_threat_events():
    """Get recent threat events"""
    return threat_events

@app.post("/api/threats")
async def add_threat_event(threat: ThreatEvent):
    """Add a new threat event"""
    threat_events.append(threat)
    # Keep only last 100 events
    if len(threat_events) > 100:
        threat_events.pop(0)
    return {"message": "Threat event added", "id": threat.id}

@app.get("/api/dashboard")
async def dashboard():
    """Serve the main dashboard page"""
    return HTMLResponse(content="""
<!DOCTYPE html>
<html>
<head>
    <title>SentinelOS Dashboard</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background-color: #f0f0f0; }
        .container { max-width: 1200px; margin: 0 auto; }
        .header { background-color: #2c3e50; color: white; padding: 20px; border-radius: 5px; }
        .metrics-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px; margin: 20px 0; }
        .metric-card { background-color: white; padding: 20px; border-radius: 5px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); }
        .metric-value { font-size: 2em; font-weight: bold; color: #3498db; }
        .metric-label { color: #7f8c8d; }
        .threats-table { width: 100%; border-collapse: collapse; background-color: white; border-radius: 5px; overflow: hidden; box-shadow: 0 2px 5px rgba(0,0,0,0.1); }
        .threats-table th, .threats-table td { padding: 12px; text-align: left; border-bottom: 1px solid #ecf0f1; }
        .threats-table th { background-color: #34495e; color: white; }
        .high-risk { background-color: #e74c3c; color: white; padding: 3px 8px; border-radius: 3px; }
        .medium-risk { background-color: #f39c12; color: white; padding: 3px 8px; border-radius: 3px; }
        .low-risk { background-color: #27ae60; color: white; padding: 3px 8px; border-radius: 3px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>SentinelOS Security Dashboard</h1>
            <p>Real-time network protection and threat monitoring</p>
        </div>
        
        <div class="metrics-grid">
            <div class="metric-card">
                <div class="metric-value" id="cpu-value">0%</div>
                <div class="metric-label">CPU Usage</div>
            </div>
            <div class="metric-card">
                <div class="metric-value" id="memory-value">0%</div>
                <div class="metric-label">Memory Usage</div>
            </div>
            <div class="metric-card">
                <div class="metric-value" id="disk-value">0%</div>
                <div class="metric-label">Disk Usage</div>
            </div>
            <div class="metric-card">
                <div class="metric-value" id="threats-value">0</div>
                <div class="metric-label">Active Threats</div>
            </div>
        </div>
        
        <h2>Recent Threat Events</h2>
        <table class="threats-table">
            <thead>
                <tr>
                    <th>Time</th>
                    <th>Threat Level</th>
                    <th>Source</th>
                    <th>Destination</th>
                    <th>Description</th>
                </tr>
            </thead>
            <tbody id="threats-table-body">
                <tr>
                    <td colspan="5" style="text-align: center;">No threat events</td>
                </tr>
            </tbody>
        </table>
    </div>
    
    <script>
        // Update metrics periodically
        function updateMetrics() {
            fetch('/api/system/metrics')
                .then(response => response.json())
                .then(data => {
                    document.getElementById('cpu-value').textContent = data.cpu_percent.toFixed(1) + '%';
                    document.getElementById('memory-value').textContent = data.memory_percent.toFixed(1) + '%';
                    document.getElementById('disk-value').textContent = data.disk_usage.toFixed(1) + '%';
                })
                .catch(error => console.error('Error fetching metrics:', error));
                
            fetch('/api/threats')
                .then(response => response.json())
                .then(data => {
                    document.getElementById('threats-value').textContent = data.length;
                    const tbody = document.getElementById('threats-table-body');
                    tbody.innerHTML = '';
                    
                    if (data.length === 0) {
                        tbody.innerHTML = '<tr><td colspan="5" style="text-align: center;">No threat events</td></tr>';
                    } else {
                        data.forEach(threat => {
                            const row = tbody.insertRow();
                            row.innerHTML = \`
                                <td>\${new Date(threat.timestamp).toLocaleTimeString()}</td>
                                <td><span class="\${threat.threat_level.toLowerCase()}-risk">\${threat.threat_level}</span></td>
                                <td>\${threat.source_ip}</td>
                                <td>\${threat.destination_ip}</td>
                                <td>\${threat.description}</td>
                            \`;
                        });
                    }
                })
                .catch(error => console.error('Error fetching threats:', error));
        }
        
        // Initial update
        updateMetrics();
        
        // Update every 5 seconds
        setInterval(updateMetrics, 5000);
    </script>
</body>
</html>
""", status_code=200)

# Background task to simulate threat events
async def simulate_threats():
    """Simulate threat events for demo purposes"""
    threat_descriptions = [
        "Suspicious outbound connection detected",
        "Malware signature matched in network traffic",
        "Unusual data compression pattern identified",
        "Possible data exfiltration attempt",
        "AI-generated traffic pattern detected"
    ]
    
    threat_levels = ["HIGH", "MEDIUM", "LOW"]
    
    while True:
        # Every 30 seconds, add a random threat event
        await asyncio.sleep(30)
        
        if len(threat_events) < 50:  # Limit for demo
            threat = ThreatEvent(
                id=f"THREAT-{len(threat_events)+1}",
                timestamp=datetime.now().isoformat(),
                threat_level=threat_levels[len(threat_events) % 3],
                source_ip=f"192.168.1.{(len(threat_events) % 250) + 1}",
                destination_ip="8.8.8.8",
                description=threat_descriptions[len(threat_events) % len(threat_descriptions)]
            )
            threat_events.append(threat)

# Start background task
@app.on_event("startup")
async def startup_event():
    asyncio.create_task(simulate_threats())

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
EOF

# Install psutil for system metrics
pip3 install psutil

# Create telemetry service file
cat > /etc/systemd/system/sentinel-telemetry.service << EOF
[Unit]
Description=SentinelOS Telemetry Dashboard
After=network.target

[Service]
Type=simple
User=sentinel
WorkingDirectory=/opt/sentinel/telemetry/api
ExecStart=/usr/bin/uvicorn main:app --host 0.0.0.0 --port 8000
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Set permissions
chown -R sentinel:sentinel /opt/sentinel/telemetry

echo "Telemetry layer setup complete!"
echo "Next steps:"
echo "1. Start the telemetry service: sudo systemctl start sentinel-telemetry"
echo "2. Enable the service on boot: sudo systemctl enable sentinel-telemetry"
echo "3. Access the dashboard at http://localhost:8000/api/dashboard"
echo "4. Customize the dashboard UI and metrics as needed"