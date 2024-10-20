#!/bin/bash

# Update system packages
sudo apt-get update -y

# Install dependencies
sudo apt-get install -y apt-transport-https software-properties-common wget curl

# Install Prometheus
echo "Installing Prometheus..."
wget https://github.com/prometheus/prometheus/releases/download/v2.30.3/prometheus-2.30.3.linux-amd64.tar.gz
tar -xvf prometheus-2.30.3.linux-amd64.tar.gz
sudo mv prometheus-2.30.3.linux-amd64 /etc/prometheus
sudo ln -s /etc/prometheus/prometheus /usr/local/bin/prometheus

# Set up Prometheus service
echo "Setting up Prometheus as a service..."
sudo tee /etc/systemd/system/prometheus.service > /dev/null <<EOF
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=root
ExecStart=/usr/local/bin/prometheus --config.file=/etc/prometheus/prometheus.yml

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl enable prometheus

# Install Node Exporter
echo "Installing Node Exporter..."
wget https://github.com/prometheus/node_exporter/releases/download/v1.5.0/node_exporter-1.5.0.linux-amd64.tar.gz
tar -xvf node_exporter-1.5.0.linux-amd64.tar.gz
sudo mv node_exporter-1.5.0.linux-amd64 /etc/node_exporter
sudo ln -s /etc/node_exporter/node_exporter /usr/local/bin/node_exporter

# Set up Node Exporter service
echo "Setting up Node Exporter as a service..."
sudo tee /etc/systemd/system/node_exporter.service > /dev/null <<EOF
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=root
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter

# Configure Prometheus to scrape Node Exporter metrics
echo "Configuring Prometheus to scrape Node Exporter metrics..."
sudo tee -a /etc/prometheus/prometheus.yml > /dev/null <<EOF
  - job_name: 'node_exporter'
    static_configs:
      - targets: ['localhost:9100']
EOF

# Reload Prometheus
sudo systemctl restart prometheus

# Install Grafana
echo "Installing Grafana..."
sudo add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
sudo apt-get update
sudo apt-get install grafana -y

# Start and enable Grafana service
sudo systemctl start grafana-server
sudo systemctl enable grafana-server

echo "Installation completed. You can access Grafana at http://<your_server_ip>:3000"
echo "Login with default credentials: Username: admin, Password: admin (you will be prompted to change it)"
