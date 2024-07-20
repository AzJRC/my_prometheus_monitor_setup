# Prometheus+Grafana Docker-Compose Installation

This is my personal installation for Prometheus and Grafana using Docker containers.
You can directly clone this repo and run `docker-compose up -d` in the same directory where the docker-compose.yml file is located (You may need to do some adjustments for it to work properly).

## Manual Installation

Follow this steps to set up Prometheus, Grafana and Node Exporter in your system:

1. Copy and Paste the following docker-compose.yml file. You may want to edit as your needs
```yml
#docker-compose.yml

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
```
2. Download Node Exporter. You may want to refer to [Node Exporter Releases Page](https://github.com/prometheus/node_exporter/releases/) and look for the most recent version of Node Exporter.
3. Look for the appropiate version and architecture for the Node Exporter release you are going to install.
4. Right-click on your choosen release and select `copy clean link`. It should look like this: https://github.com/prometheus/node_exporter/releases/download/v1.8.2/node_exporter-1.8.2.linux-amd64.tar.gz
5. In your server, use `wget` to install this release of Node Exporter
```bash
wget https://github.com/prometheus/node_exporter/releases/download/v1.8.2/node_exporter-1.8.2.linux-amd64.tar.gz
```
6. Your downloaded file will be comprissed. Extract the files using `tar -xvzf node_exporter-1.8.2.linux-amd64.tar.gz`
7. Once you download the files, move inside the extracted directory and move the binary file to `/usr/local/bin`. This is not mandatory, but it helps mantain organized everything in your computer.
8. Create a dedicated user for Node Exporter.
```bash
sudo useradd --no-create-home --shell /bin/false node_exporter
sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter
```
9. Create a deamon service to admnistrate Node Exporter
```bash
#node_exporter.service

[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=node_exporter
ExecStart=/usr/local/bin/node_exporter
RestartSec=3

[Install]
WantedBy=nulti-user.target
```
10. Reaload the deamon service and the newly created Node Exporter service.
```bash
sudo systemctl daemon-reload
sudo systemctl restart node_exporter.service
```
11. Finally, verify that everything is working
```bash
sudo systemctl status node_exporter.service
curl http://localhost:9100/metrics
```
