#!/bin/bash

set -e

SHARED_DIR=/ops/shared
CONFIG_DIR=${SHARED_DIR}/config
CONSUL_VERSION=1.18.7
ENVOY_VERSION=1.27.7
CONSUL_ENT_LICENSE=$1
if [ -z "$CONSUL_ENT_LICENSE" ]; then
    echo "Usage: $0 <consul_ent_license>"
    exit 1
fi
# Wait for network
sleep 15

sudo apt-get install -y software-properties-common
sudo add-apt-repository -y universe && sudo apt-get -y update
sudo apt-get install -y unzip tree redis-tools jq curl tmux
sudo apt-get clean

# Install HashiCorp Apt Repository
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

echo "Installing consul and envoy"
# Install Consul only
sudo apt-get update && sudo apt-get -y install consul-enterprise=$CONSUL_VERSION* hashicorp-envoy=$ENVOY_VERSION*

# Now render consul.hcl script
sudo bash /ops/shared/scripts/render_consul_config.sh

# Move CA to certs directory
sudo mkdir -p /ops/shared/certs
sudo cp /ops/shared/config/client_config/ca.pem /ops/shared/certs/ca.pem
sudo chmod 644 /ops/shared/certs/ca.pem

# Install license file
echo "$CONSUL_ENT_LICENSE" | sudo tee /etc/consul.d/license.hclic > /dev/null
sudo chmod a+r /etc/consul.d/license.hclic

echo "Consul config setup complete"

# Start Consul
sudo systemctl enable consul.service&& sleep 1
sudo systemctl start consul.service && sleep 10

# Wait for Consul to start
while ! sudo systemctl is-active --quiet consul.service; do
    echo "Waiting for Consul to start..."
    sleep 5
done

# Check Consul status
if consul members; then
    echo "Consul is running and members are listed."
else
    echo "Consul is not running or there are no members."
    exit 1
fi

# Export CONSUL_HTTP_TOKEN in .bashrc
CONSUL_HTTP_TOKEN=$(jq -r '.admin_token' "${CONFIG_DIR}/hcp_config")
echo "export CONSUL_HTTP_TOKEN=${CONSUL_HTTP_TOKEN}" | sudo tee -a /home/"${USER}"/.bashrc > /dev/null
