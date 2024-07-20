#!/bin/bash

# Function to print messages
print_msg() {
    echo -e "\n[INFO] $1\n"
}

# Step 1: Stop and remove Docker containers
print_msg "Stopping and removing Docker containers..."
docker-compose down

# Step 2: Remove Docker volumes
print_msg "Removing Docker volumes..."
docker volume rm $(docker volume ls -q)

# Step 3: Remove docker-compose.yml file
print_msg "Removing docker-compose.yml file..."
rm -f docker-compose.yml

# Step 4: Stop and disable Node Exporter service
print_msg "Stopping and disabling Node Exporter service..."
sudo systemctl stop node_exporter.service
sudo systemctl disable node_exporter.service

# Step 5: Remove Node Exporter binary
print_msg "Removing Node Exporter binary..."
sudo rm -f /usr/local/bin/node_exporter

# Step 6: Remove Node Exporter user
print_msg "Removing Node Exporter user..."
sudo userdel node_exporter

# Step 7: Remove Node Exporter service file
print_msg "Removing Node Exporter service file..."
sudo rm -f /etc/systemd/system/node_exporter.service

# Step 8: Reload systemd daemon
print_msg "Reloading systemd daemon..."
sudo systemctl daemon-reload

# Step 9: Verify cleanup
print_msg "Verifying cleanup..."
if [ ! -f /usr/local/bin/node_exporter ] && [ ! -f /etc/systemd/system/node_exporter.service ]; then
    print_msg "Cleanup successful. All components have been removed."
else
    print_msg "Cleanup failed. Some components may still be present."
fi
