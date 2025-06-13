# HCP Sandbox: Connect AWS EC2 Client to HCP Consul Cluster

This repository demonstrates how to bootstrap a basic HashiCorp Consul environment by connecting an EC2 instance running a Consul client agent to a managed HCP Consul cluster. The setup includes:

- Provisioning AWS resources using Terraform:
  - VPC, subnet, internet gateway, route tables
  - EC2 instance for running the Consul client
  - Security group allowing required traffic
- Peering the VPC with the HCP HVN
- Bootstrapping the Consul client with HCP configuration
- Managing secrets and credentials via `.env`
- Automating setup with a Makefile

---

## Architecture

```
        +------------------+       Peering        +--------------------+
        |   AWS VPC        +--------------------->|    HCP HVN         |
        |  - EC2 instance  |                      |  - Consul cluster  |
        +------------------+                      +--------------------+
```

---

## Prerequisites

- Terraform ≥ 1.3
- AWS CLI (configured)
- HCP Account with a Consul cluster and HVN already created
- jq
- make

---

## Step-by-Step Guide

### 1. Create HCP Consul Cluster and HVN

- Log in to [HCP Portal](https://portal.cloud.hashicorp.com/)
- Create a **Consul cluster** in your project (e.g. `sk-debug-0`)
- Ensure that an **HVN** is associated with your Consul cluster (e.g. `hvn`)
- Enable **Admin Partition Support** if needed

---

### 2. Download Required HCP Config Files

- Download the **Client configuration** (`client_config.json`) from the HCP UI.
- Copy it to:

  ```
  shared/config/client_config/client_config.json
  ```

- Populate required variables in `.env`:
  ```dotenv
  TF_VAR_cloud_provider=aws
  TF_VAR_region=us-east-1
  TF_VAR_datacenter=consul-cluster
  TF_VAR_hcp_client_id=<HCP_CLIENT_ID>
  TF_VAR_hcp_client_secret=<HCP_CLIENT_SECRET>
  TF_VAR_hcp_project_id=<HCP_PROJECT_ID>
  TF_VAR_hcp_hvn_id=hvn
  TF_VAR_hcp_cidr_block=172.25.16.0/20
  TF_VAR_consul_ent_license=<CONSUL_LICENSE>
  TF_VAR_consul_admin_token=<CONSUL_ADMIN_TOKEN>
  ```

- These values will be used to:
  - Configure HCP peering
  - Inject config into templates
  - Automate `user-data` rendering

- The `render_hcp_config.sh` script now supports flag-based arguments:
  ```bash
  bash /ops/shared/scripts/render_hcp_config.sh \
    -p <project_id> \
    -h <hvn_id> \
    -c <cloud_provider> \
    -r <region> \
    -b <hvn_cidr_block> \
    -t <admin_token>
  ```

---

### 3. Create HCP Service Principal & Get Credentials

- From the **Access Control** section in the HCP UI:
  - Create a **Service Principal**
  - Assign `Network Admin` + `Consul Admin` roles
  - Generate and download **Client ID** and **Client Secret**

- Create a file named `.env` in the root of this repo:

  ```dotenv
  TF_VAR_hcp_client_id=<your-client-id>
  TF_VAR_hcp_client_secret=<your-client-secret>
  ```

---

### 4. Initialize and Apply Terraform

Run the following:

```bash
make init     # Initialize terraform modules
make plan     # Review changes
make apply    # Provision infrastructure
```

This will:

- Create the VPC, subnet, gateway, etc.
- Create peering between AWS VPC and HCP HVN
- Provision an EC2 instance with bootstrap script
- Automatically render and place `consul.hcl` file on the instance

---

### 5. Connect to EC2 Instance

Once applied, retrieve the SSH command from Terraform output:

```bash
terraform -chdir=client-cluster output ssh_command
```

Then connect:

```bash
ssh -i client-cluster/hcp-key.pem ubuntu@<instance-public-ip>
```

Consul agent should be running and joined to HCP cluster.

---

## Cleanup

To destroy the entire infrastructure:

```bash
make destroy
```

---

## Notes

- The rendered `consul.hcl` is generated on the instance using a custom `render_consul_config.sh` script.
- TLS is configured for outbound connections to HCP, using certificates placed in `/ops/shared/certs/`.
- You can inspect logs using:

  ```bash
  journalctl -u consul
  ```

---

## Next Steps

- Register example services with the Consul client
- Enable mesh gateway and connect more clients
- Use intentions and access control for testing

---

## License

MIT