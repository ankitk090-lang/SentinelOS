#!/bin/bash

# SentinelOS AI Layer Setup Script
# This script sets up the AI security components of SentinelOS

set -e  # Exit on any error

echo "Starting SentinelOS AI layer setup..."

# Install Python and AI dependencies
echo "Installing Python and AI dependencies..."
apt-get update
apt-get install -y \
  python3 \
  python3-pip \
  python3-venv \
  python3-dev \
  build-essential

# Install AI frameworks
echo "Installing AI frameworks..."
pip3 install \
  numpy \
  scipy \
  scikit-learn \
  pandas \
  onnxruntime \
  tensorflow-lite

# Create AI directory structure
mkdir -p /opt/sentinel/ai/{models,engine,datasets,logs}

# Create AI engine script
cat > /opt/sentinel/ai/engine/threat_detector.py << EOF
#!/usr/bin/env python3
"""
SentinelOS AI Threat Detector
Lightweight AI engine for malware pattern recognition and threat detection
"""

import numpy as np
import onnxruntime as ort
import json
import logging
import os
from datetime import datetime

class ThreatDetector:
    def __init__(self, model_path="/opt/sentinel/ai/models/threat_model.onnx"):
        """
        Initialize the threat detector with a quantized model
        """
        self.model_path = model_path
        self.session = None
        self.logger = self._setup_logger()
        
        # Load model if it exists
        if os.path.exists(model_path):
            self.session = ort.InferenceSession(model_path)
            self.logger.info("Threat detection model loaded successfully")
        else:
            self.logger.warning("Threat detection model not found, using simulation mode")
    
    def _setup_logger(self):
        """Set up logging for the threat detector"""
        logger = logging.getLogger('SentinelAI')
        logger.setLevel(logging.INFO)
        
        handler = logging.FileHandler('/opt/sentinel/ai/logs/threat_detector.log')
        formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
        handler.setFormatter(formatter)
        logger.addHandler(handler)
        
        return logger
    
    def preprocess_data(self, network_data):
        """
        Preprocess network data for AI analysis
        In a real implementation, this would extract features from network packets
        """
        # Simulate feature extraction
        features = {
            'packet_size': np.random.randint(64, 1500),
            'protocol': np.random.choice([6, 17, 1]),  # TCP, UDP, ICMP
            'entropy': np.random.uniform(0, 8),
            'connections_per_minute': np.random.randint(0, 1000),
            'data_compression_ratio': np.random.uniform(0, 1)
        }
        
        # Convert to numpy array for model input
        input_array = np.array([
            features['packet_size'],
            features['protocol'],
            features['entropy'],
            features['connections_per_minute'],
            features['data_compression_ratio']
        ], dtype=np.float32)
        
        return input_array.reshape(1, -1)
    
    def detect_threat(self, network_data):
        """
        Analyze network data for potential threats
        Returns threat score and classification
        """
        # Preprocess the data
        input_data = self.preprocess_data(network_data)
        
        # If we have a model, use it for inference
        if self.session:
            # Run inference
            input_name = self.session.get_inputs()[0].name
            result = self.session.run(None, {input_name: input_data})
            threat_score = result[0][0]
        else:
            # Simulation mode - random threat detection
            threat_score = np.random.uniform(0, 1)
        
        # Classify based on threat score
        if threat_score > 0.8:
            classification = "HIGH_RISK"
        elif threat_score > 0.5:
            classification = "MEDIUM_RISK"
        else:
            classification = "LOW_RISK"
        
        # Log the detection
        detection_result = {
            'timestamp': datetime.now().isoformat(),
            'threat_score': float(threat_score),
            'classification': classification,
            'details': network_data
        }
        
        self.logger.info(f"Threat detection: {classification} (Score: {threat_score:.3f})")
        
        return detection_result
    
    def adaptive_learning(self, feedback_data):
        """
        Update model based on feedback (in a real implementation)
        This would implement online learning capabilities
        """
        self.logger.info("Adaptive learning triggered with feedback data")
        # In a real implementation, this would update the model
        # For now, we just log the feedback
        pass

# Example usage
if __name__ == "__main__":
    # Initialize the threat detector
    detector = ThreatDetector()
    
    # Simulate network data analysis
    sample_data = {
        'source_ip': '192.168.1.100',
        'destination_ip': '8.8.8.8',
        'port': 443,
        'bytes_transferred': 1024
    }
    
    # Detect threats
    result = detector.detect_threat(sample_data)
    
    # Print result
    print(json.dumps(result, indent=2))
EOF

# Make the AI engine script executable
chmod +x /opt/sentinel/ai/engine/threat_detector.py

# Create AI service file
cat > /etc/systemd/system/sentinel-ai.service << EOF
[Unit]
Description=SentinelOS AI Threat Detector
After=network.target

[Service]
Type=simple
User=sentinel
ExecStart=/usr/bin/python3 /opt/sentinel/ai/engine/threat_detector.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Create AI monitoring script
cat > /opt/sentinel/ai/monitor.py << EOF
#!/usr/bin/env python3
"""
SentinelOS AI Monitoring Service
Monitors network traffic and feeds data to the AI engine
"""

import time
import subprocess
import json
from threat_detector import ThreatDetector

def collect_network_data():
    """Collect network statistics for analysis"""
    # In a real implementation, this would collect actual network data
    # For now, we'll simulate it
    return {
        'timestamp': time.time(),
        'active_connections': len(subprocess.check_output(['netstat', '-an']).decode().split('\n')),
        'cpu_usage': subprocess.check_output(['vmstat', '1', '2']).decode().split('\n')[-2].split()[12],
        'memory_usage': subprocess.check_output(['free']).decode().split('\n')[1].split()[2]
    }

def main():
    """Main monitoring loop"""
    detector = ThreatDetector()
    
    print("SentinelOS AI Monitoring Service Started")
    
    while True:
        try:
            # Collect network data
            network_data = collect_network_data()
            
            # Analyze for threats
            result = detector.detect_threat(network_data)
            
            # In a real implementation, this would trigger firewall actions
            if result['classification'] == 'HIGH_RISK':
                print(f"HIGH THREAT DETECTED: {result}")
                # Here we would trigger firewall blocks, alerts, etc.
            
            # Wait before next analysis
            time.sleep(30)  # Analyze every 30 seconds
            
        except KeyboardInterrupt:
            print("Monitoring service stopped")
            break
        except Exception as e:
            print(f"Error in monitoring loop: {e}")
            time.sleep(5)  # Wait before retrying

if __name__ == "__main__":
    main()
EOF

chmod +x /opt/sentinel/ai/monitor.py

# Create requirements file for AI components
cat > /opt/sentinel/ai/requirements.txt << EOF
numpy>=1.21.0
onnxruntime>=1.8.0
scikit-learn>=1.0.0
pandas>=1.3.0
EOF

# Set up Python virtual environment for AI components
python3 -m venv /opt/sentinel/ai/venv
source /opt/sentinel/ai/venv/bin/activate
pip install -r /opt/sentinel/ai/requirements.txt
deactivate

# Create placeholder for quantized AI model
echo "Placeholder for 8-bit quantized threat detection model" > /opt/sentinel/ai/models/threat_model.onnx

# Set permissions
chown -R sentinel:sentinel /opt/sentinel/ai

# Enable the AI service
systemctl enable sentinel-ai

echo "AI layer setup complete!"
echo "Next steps:"
echo "1. Replace placeholder model with actual quantized threat detection model"
echo "2. Customize feature extraction in threat_detector.py"
echo "3. Configure AI monitoring intervals"
echo "4. Test threat detection with sample network data"