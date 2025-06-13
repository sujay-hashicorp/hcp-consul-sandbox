#!/bin/bash
set -e

SHARED_DIR="/ops/shared"
CONFIG_FILE="${SHARED_DIR}/config/client_config/client_config.json"
HCP_CONFIG_FILE="${SHARED_DIR}/config/hcp_config"

while getopts ":p:h:c:r:b:t:" opt; do
  case ${opt} in
    p ) PROJECT_ID=$OPTARG ;;
    h ) HCP_HVN_ID=$OPTARG ;;
    c ) CLOUD_PROVIDER=$OPTARG ;;
    r ) REGION=$OPTARG ;;
    b ) CIDR_BLOCK=$OPTARG ;;
    t ) ADMIN_TOKEN=$OPTARG ;;
    \? )
      echo "Invalid option: -$OPTARG" 1>&2
      exit 1
      ;;
    : )
      echo "Option -$OPTARG requires an argument." 1>&2
      exit 1
      ;;
  esac
done

if [ -z "$PROJECT_ID" ] || [ -z "$HCP_HVN_ID" ] || [ -z "$CLOUD_PROVIDER" ] || [ -z "$REGION" ] || [ -z "$CIDR_BLOCK" ] || [ -z "$ADMIN_TOKEN" ]; then
  echo "Usage: $0 -d <datacenter> -p <project_id> -h <hcp_hvn_id> -c <cloud_provider> -r <region> -b <cidr_block> -t <admin_token>"
  exit 1
fi

cp "${SHARED_DIR}/config/hcp_config" "${HCP_CONFIG_FILE}.tmpl"

DATACENTER=$(jq -r '.datacenter' "${CONFIG_FILE}")

sed -e "s|DATACENTER_NAME|${DATACENTER}|" \
    -e "s|PROJECT_ID|${PROJECT_ID}|" \
    -e "s|HVN_ID|${HCP_HVN_ID}|" \
    -e "s|CLOUD_PROVIDER|${CLOUD_PROVIDER}|" \
    -e "s|REGION|${REGION}|" \
    -e "s|HCP_CIDR_BLOCK|${CIDR_BLOCK}|" \
    -e "s|ADMIN_TOKEN|${ADMIN_TOKEN}|" \
    "${HCP_CONFIG_FILE}.tmpl" > "${HCP_CONFIG_FILE}"
