#!/bin/bash
set -e

sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get install -y jq

echo "Waiting for /ops/shared/scripts/render_consul_config.sh to be available..."

for i in {1..60}; do
  if [ -f /ops/shared/scripts/render_consul_config.sh ]; then
    echo "Shared files present. Proceeding..."
    break
  fi
  echo "Waiting... ($i/60)"
  sleep 5
done

sudo mkdir -p /etc/consul.d
sudo mkdir -p /ops/consul/data

# If not found after 5 mins, exit
if [ ! -f /ops/shared/scripts/setup-consul-client.sh ]; then
  echo "ERROR: Shared config not found. Exiting."
  exit 1
fi

sudo bash /ops/shared/scripts/render_hcp_config.sh \
  -p "${hcp_project_id}" \
  -h "${hcp_hvn_id}" \
  -c "${cloud_provider}" \
  -r "${region}" \
  -b "${hcp_cidr_block}" \
  -t "${admin_token}"

sudo bash /ops/shared/scripts/setup-consul-client.sh "${license}"