#!/bin/bash

# Function to print messages
print_msg() {
    echo -e "\n[INFO] $1\n"
}

# Step 1: Create docker-compose.yml file
print_msg "Creating docker-compose.yml file..."
cat <<EOL > docker-compose.yml
services:
  grafana:
    image: grafana/grafana
    container_name: grafana
    restart: unless-stopped
    ports:
    - '3000:3000'
    volumes:
    - gafana_storage:/var/lib/grafana

  prometheus:
    image: prom/prometheus
    container_imaga: prometheus
    command:
    - '--config.file=/etc/prometheus/prometheus.yml'
    ports:
    - '9090:9090'
    volumes:
    - ./prometheus:/etc/prometheus
    - prom_data:/prometehus

volumes:
  grafana_storage: {}
  prom_data:
EOL

print_msg "docker-compose.yml file created."

# Step 2: Download Node Exporter
print_msg "Downloading Node Exporter..."
NODE_EXPORTER_VERSION="1.8.2"
wget https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz

# Step 3: Extract Node Exporter
print_msg "Extracting Node Exporter..."
tar -xvzf node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz

# Step 4: Move Node Exporter binary
print_msg "Moving Node Exporter binary to /usr/local/bin..."
sudo mv node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64/node_exporter /usr/local/bin/

# Step 5: Create dedicated user for Node Exporter
print_msg "Creating dedicated user for Node Exporter..."
sudo useradd --no-create-home --shell /bin/false node_exporter
sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter

# Step 6: Create systemd service file for Node Exporter
print_msg "Creating systemd service file for Node Exporter..."
cat <<EOL | sudo tee /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter
RestartSec=3

[Install]
WantedBy=multi-user.target
EOL

# Step 7: Reload and start Node Exporter service
print_msg "Reloading systemd daemon and starting Node Exporter service..."
sudo systemctl daemon-reload
sudo systemctl start node_exporter.service
sudo systemctl enable node_exporter.service

# Step 8: Verify Node Exporter service status
print_msg "Verifying Node Exporter service status..."
sudo systemctl status node_exporter.service
curl http://localhost:9100/metrics

print_msg "Prometheus, Grafana, and Node Exporter setup completed successfully!"
