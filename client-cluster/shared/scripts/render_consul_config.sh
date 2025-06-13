#!/bin/bash
set -e

SHARED_DIR="/ops/shared"
CONSUL_CONFIG_DIR="etc/consul.d"

HCP_CONFIG_FILE="${SHARED_DIR}/config/hcp_config"
TEMPLATE_FILE="${SHARED_DIR}/config/consul.hcl"
OUTPUT_FILE="${CONSUL_CONFIG_DIR}/consul.hcl"
CONFIG_FILE="${SHARED_DIR}/config/client_config/client_config.json"

# Read values from client config
JOIN_ADDRESS=$(jq -r '.retry_join[0]' "${CONFIG_FILE}")
DATACENTER=$(jq -r '.datacenter' "${CONFIG_FILE}")
ENCRYPTION_KEY=$(jq -r '.encrypt' "${CONFIG_FILE}")
HTTP_TOKEN=$(jq -r '.admin_token' "${HCP_CONFIG_FILE}")

# Optional override via ENV
ADVERTISE_ADDR=${ADVERTISE_ADDR:-"$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"}

# Replace placeholders in consul.hcl
sed \
  -e "s|RETRY_JOIN|${JOIN_ADDRESS}|" \
  -e "s|DATACENTER_NAME|${DATACENTER}|" \
  -e "s|ENCRYPTION_KEY|${ENCRYPTION_KEY}|" \
  -e "s|IP_ADDRESS|${ADVERTISE_ADDR}|" \
  -e "s|CONSUL_HTTP_TOKEN|${HTTP_TOKEN}|" \
  "${TEMPLATE_FILE}" > "${OUTPUT_FILE}"
